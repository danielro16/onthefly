/*
 * extract.js — platform-agnostic page extraction.
 *
 * Runs INSIDE the hidden WebView. Takes the live DOM and emits a flat,
 * typed block list that a native UI can render directly.
 *
 * This file is the shared core: it runs unchanged on iOS (WKWebView) and
 * on Android (WebView) later. Nothing in here may touch platform APIs.
 *
 * Contract: posts one JSON message to the `jefExtract` handler.
 *
 * Link offsets are UTF-16 code-unit indices, which map 1:1 onto NSRange
 * on the Swift side. Do not switch to code points.
 */

(function () {
  "use strict";

  const MAX_BLOCKS = 2000;
  const MAX_ACTIONS = 40;

  // Nodes that never carry reader content, independent of site.
  const SKIP_TAGS = new Set([
    "SCRIPT", "STYLE", "NOSCRIPT", "IFRAME", "SVG", "CANVAS",
    "FORM", "INPUT", "BUTTON", "SELECT", "TEXTAREA", "NAV", "FOOTER",
  ]);

  const HEADING_LEVEL = { H1: 1, H2: 2, H3: 3, H4: 4, H5: 5, H6: 6 };

  /// Tags that start a new line for a sighted reader.
  const BLOCK_TAGS = new Set([
    "ADDRESS", "ARTICLE", "ASIDE", "BLOCKQUOTE", "BR", "DD", "DIV", "DL", "DT",
    "FIELDSET", "FIGCAPTION", "FIGURE", "FOOTER", "FORM", "H1", "H2", "H3",
    "H4", "H5", "H6", "HEADER", "HR", "LI", "MAIN", "NAV", "OL", "P", "PRE",
    "SECTION", "TABLE", "TBODY", "TD", "TFOOT", "TH", "THEAD", "TR", "UL",
  ]);

  /*
   * Flattens a subtree to one line, keeping block boundaries as punctuation.
   *
   * textContent concatenates siblings with nothing in between. A Wikipedia
   * infobox cell holding three nested rows came out
   * "Jefe de GobiernoVicejefa de GobiernoLegislatura", which VoiceOver reads
   * as one invented word. The boundary is in the DOM; only the flattening
   * loses it, and a sighted reader gets it for free as a line break.
   *
   * A comma and not a space, because the pieces are separate values and comma
   * is punctuation VoiceOver pauses on instead of pronouncing. Tag-based and
   * not getComputedStyle, because this runs over every cell, label and button
   * on the page.
   */
  function textOf(node) {
    if (!node) return "";
    let raw = "";

    (function walk(parent) {
      for (const child of parent.childNodes) {
        if (child.nodeType === Node.TEXT_NODE) {
          raw += child.textContent || "";
          continue;
        }
        if (child.nodeType !== Node.ELEMENT_NODE) continue;
        const isBlock = BLOCK_TAGS.has(child.tagName);
        if (isBlock) raw += "\n";
        walk(child);
        if (isBlock) raw += "\n";
      }
    })(node);

    return raw
      .replace(/[^\S\n]+/g, " ")           // collapse spaces, keep the breaks
      .replace(/ *\n[\s\n]*/g, "\n")      // a run of breaks is one boundary
      .replace(/^\n+|\n+$/g, "")
      .replace(/([,;:.!?\u2026]) *\n/g, "$1 ")  // already punctuated: just separate
      .replace(/\n/g, ", ")
      .trim();
  }

  function absolute(href) {
    try {
      return new URL(href, document.baseURI).href;
    } catch (_) {
      return null;
    }
  }

  /*
   * Walks an element and returns its text plus the UTF-16 ranges of every
   * inline link inside it.
   *
   * This is the part that makes per-link VoiceOver focus possible: the native
   * side needs to know exactly which characters of the paragraph are a link.
   * Flattening to plain text here would reproduce the React Native bug we are
   * building natively to avoid.
   */
  function inlineContent(el) {
    let text = "";
    const links = [];

    (function walk(node, hrefStack) {
      for (const child of node.childNodes) {
        if (child.nodeType === Node.TEXT_NODE) {
          const chunk = (child.textContent || "").replace(/\s+/g, " ");
          if (!chunk) continue;
          const start = text.length;
          text += chunk;
          const href = hrefStack[hrefStack.length - 1];
          if (href) {
            links.push({ start: start, end: text.length, href: href });
          }
          continue;
        }

        if (child.nodeType !== Node.ELEMENT_NODE) continue;
        if (SKIP_TAGS.has(child.tagName)) continue;

        if (child.tagName === "BR") {
          text += " ";
          continue;
        }

        if (child.tagName === "A") {
          const href = absolute(child.getAttribute("href") || "");
          hrefStack.push(href);
          walk(child, hrefStack);
          hrefStack.pop();
          continue;
        }

        walk(child, hrefStack);
      }
    })(el, []);

    // Merge links that the walker split across adjacent text nodes.
    const merged = [];
    for (const link of links) {
      const prev = merged[merged.length - 1];
      if (prev && prev.href === link.href && prev.end === link.start) {
        prev.end = link.end;
      } else {
        merged.push(link);
      }
    }

    return { text: text.trim(), links: merged };
  }

  function imageBlock(el, id) {
    const src = absolute(el.getAttribute("src") || el.getAttribute("data-src") || "");
    if (!src) return null;
    const alt = (el.getAttribute("alt") || "").trim();
    const w = parseInt(el.getAttribute("width") || "0", 10) || el.naturalWidth || 0;
    const h = parseInt(el.getAttribute("height") || "0", 10) || el.naturalHeight || 0;

    // Tracking pixels and spacers are not content.
    if (w && h && w < 48 && h < 48) return null;

    return {
      id: id,
      type: "image",
      src: src,
      alt: alt,
      // Signals the native side that this image needs a generated description.
      needsAlt: alt.length === 0,
      width: w,
      height: h,
    };
  }

  /*
   * A data table, kept as a table.
   *
   * Flattening one into prose destroys the only thing that makes it readable:
   * which column a value belongs to. A bank statement is a table, and "12/03,
   * Transferencia, -5.000" is meaningless without knowing that those are date,
   * concept and amount.
   *
   * Column headers travel with the rows so the native side can speak each cell
   * as "Concepto: Transferencia" — the pairing a sighted reader gets for free
   * from the grid.
   *
   * Returns null for layout tables: markup used for positioning, not for data.
   */
  function tableBlock(el, id) {
    const rows = Array.prototype.slice.call(el.rows);
    if (rows.length < 2) return null;

    /*
     * Finding the header row is harder than rows[0].
     *
     * Wikipedia's climate table opens with a single cell spanning the whole
     * width — a title, not headers — and the real column names sit in the
     * next row. Taking rows[0] blindly yielded one header for a fourteen
     * column table, leaving every value after the first labelled "Columna N".
     *
     * The width that most rows share is the table's real shape; any leading
     * row narrower than that is a caption in disguise.
     */
    const widths = {};
    for (const row of rows) {
      const n = row.cells.length;
      widths[n] = (widths[n] || 0) + 1;
    }
    let shape = 0, shapeCount = 0;
    for (const width in widths) {
      if (widths[width] > shapeCount) { shapeCount = widths[width]; shape = Number(width); }
    }

    let headerIndex = -1;
    let spanningTitle = "";
    for (let i = 0; i < rows.length && i < 3; i++) {
      const cells = rows[i].cells;
      if (cells.length < shape) {
        // Narrower than the table: a title band.
        if (!spanningTitle) spanningTitle = textOf(rows[i]).slice(0, 120);
        continue;
      }
      let ths = 0;
      for (const cell of cells) if (cell.tagName === "TH") ths++;
      if (ths >= Math.max(1, cells.length / 2)) { headerIndex = i; }
      break;
    }

    let headers = [];
    if (headerIndex >= 0) {
      headers = Array.prototype.map.call(rows[headerIndex].cells, function (c) {
        return textOf(c).slice(0, 40);
      });
    }

    /*
     * Key–value tables put their headers in the first COLUMN, not the first
     * row: Wikipedia infoboxes, product spec sheets, order details, account
     * summaries. Without detecting this, "Coordenadas | 34°35'59\"S" reads as
     * "Columna 1: Coordenadas, Columna 2: 34°35'59\"S" — the label announced
     * as a value, and every field named after its position.
     *
     * Reported separately so the native side can render one line per field
     * instead of a record list.
     */
    let rowHeaders = 0;
    for (const row of rows) {
      if (row.cells.length >= 2 && row.cells[0].tagName === "TH") rowHeaders++;
    }
    const keyValue = headerIndex < 0 && shape === 2 &&
      rowHeaders >= Math.max(2, rows.length * 0.6);

    const body = [];
    const start = headerIndex >= 0 ? headerIndex + 1 : 0;
    for (let i = start; i < rows.length && body.length < 200; i++) {
      // In a key-value table a row narrower than the shape is a section band
      // ("Bandera", "Escudo"), not a field. Keeping it as a record produces a
      // value with no name.
      if (keyValue && rows[i].cells.length < shape) continue;
      const cells = Array.prototype.map.call(rows[i].cells, function (c) {
        return textOf(c).slice(0, 200);
      });
      if (cells.some(function (c) { return c.length > 0; })) body.push(cells);
    }
    if (!body.length) return null;

    // Layout table: no headers, no caption, and cells long enough to be prose
    // rather than data. Treating it as a table would invent structure.
    const caption = el.caption ? textOf(el.caption) : spanningTitle;
    if (headerIndex < 0 && !caption) {
      const avgLength = body[0].join("").length / Math.max(1, body[0].length);
      if (body[0].length <= 2 && avgLength > 120) return null;
    }

    return {
      id: id,
      type: "table",
      caption: caption.slice(0, 120),
      headers: headers,
      rows: body,
      keyValue: keyValue,
      columnCount: Math.max.apply(null, body.map(function (r) { return r.length; })),
    };
  }

  function listBlock(el, id) {
    const items = [];
    for (const li of el.children) {
      if (li.tagName !== "LI") continue;
      const content = inlineContent(li);
      if (content.text) items.push(content);
    }
    if (!items.length) return null;
    return {
      id: id,
      type: "list",
      ordered: el.tagName === "OL",
      items: items,
    };
  }

  /*
   * Flattens the article subtree into ordered blocks.
   *
   * Deliberately shallow: no semantic judgment happens here. Anything that
   * requires understanding intent is left to the decision cascade on the
   * native side. This function only preserves structure that the DOM already
   * states and that plain text would destroy.
   */
  function toBlocks(root) {
    const blocks = [];
    let counter = 0;
    const nextId = () => "b" + counter++;

    (function walk(node) {
      if (blocks.length >= MAX_BLOCKS) return;

      for (const el of node.children) {
        if (SKIP_TAGS.has(el.tagName)) continue;
        if (blocks.length >= MAX_BLOCKS) return;

        const tag = el.tagName;

        if (HEADING_LEVEL[tag]) {
          const text = textOf(el);
          if (text) {
            blocks.push({
              id: nextId(),
              type: "heading",
              level: HEADING_LEVEL[tag],
              text: text,
            });
          }
          continue;
        }

        if (tag === "P") {
          const content = inlineContent(el);
          if (content.text) {
            blocks.push({
              id: nextId(),
              type: "paragraph",
              text: content.text,
              links: content.links,
            });
          }
          continue;
        }

        if (tag === "UL" || tag === "OL") {
          const block = listBlock(el, nextId());
          if (block) blocks.push(block);
          else counter--;
          continue;
        }

        if (tag === "IMG") {
          const block = imageBlock(el, nextId());
          if (block) blocks.push(block);
          else counter--;
          continue;
        }

        if (tag === "FIGURE") {
          const img = el.querySelector("img");
          if (img) {
            const block = imageBlock(img, nextId());
            if (block) {
              const caption = el.querySelector("figcaption");
              if (caption) block.caption = textOf(caption);
              blocks.push(block);
            } else counter--;
          }
          continue;
        }

        if (tag === "BLOCKQUOTE") {
          const content = inlineContent(el);
          if (content.text) {
            blocks.push({
              id: nextId(),
              type: "quote",
              text: content.text,
              links: content.links,
            });
          }
          continue;
        }

        if (tag === "PRE") {
          const text = el.textContent || "";
          if (text.trim()) {
            blocks.push({ id: nextId(), type: "code", text: text });
          }
          continue;
        }

        if (tag === "HR") {
          blocks.push({ id: nextId(), type: "separator" });
          continue;
        }

        if (tag === "TABLE") {
          const block = tableBlock(el, nextId());
          if (block) blocks.push(block);
          else counter--;
          continue;
        }

        walk(el);
      }
    })(root);

    return blocks;
  }

  /*
   * Collects what the page lets you DO, as opposed to what it says.
   *
   * Readability deletes all of this — it is built for articles, and on an
   * airline or a government site the actions ARE the page. Without this pass
   * the reader shows an empty shell on exactly the sites where a screen-reader
   * user needs the most help.
   *
   * Runs against the live document, not Readability's output.
   */
  function collectActions(excluded) {
    const actions = [];
    const seen = new Set();
    let counter = 0;
    let fieldCounter = 0;

    /*
     * Chrome that is never a user task. Measured against a real airline home
     * page, where a consent banner and a carousel ate 7 of the 40 slots and
     * pushed real tasks past the cap.
     */
    const NOISE = [
      /^\d+$/,                                        // carousel dots
      /^(aceptar|accept|rechazar|reject|permitir|allow)\b.*(cookie|esencial|essential|todas|all)?/i,
      /^(ok|got it|entendido|cerrar|close|dismiss)\b/i,
      /^(ir a|skip to|saltar a)\b/i,                  // skip links
      /^(cerrar alerta|close alert)$/i,
      /^(quitar|agregar|remove|add) (uno|one)$/i,     // stepper controls
      /^(anterior|siguiente|previous|next)$/i,
    ];

    function isNoise(label) {
      if (label.length < 3) return true;
      return NOISE.some(function (pattern) { return pattern.test(label); });
    }

    function push(action, element) {
      if (!action.label || isNoise(action.label)) return;
      // Controls the overlay owns are reported as its choices, not as page
      // actions. Listing them twice would also mean stamping one element with
      // two ids, and the second stamp wins: the action becomes unpressable.
      if (excluded && element && excluded.contains(element)) return;
      // Same label twice is the same action to a user, however the markup
      // differs (mobile nav duplicating desktop nav is the usual culprit).
      const key = action.kind + "|" + action.label.toLowerCase();
      if (seen.has(key) || actions.length >= MAX_ACTIONS) return;
      seen.add(key);
      action.id = "a" + counter++;
      // Stamp the live element so it can be found again later.
      //
      // A button's behaviour lives in the page's own JavaScript, so the native
      // UI cannot press it — it has to ask this element to click itself. A CSS
      // selector would break on any re-render; an attribute survives until the
      // node is replaced, and a re-extraction re-stamps everything anyway.
      if (element) element.setAttribute("data-jef-id", action.id);
      actions.push(action);
    }

    function labelFor(el) {
      const aria = el.getAttribute("aria-label");
      if (aria && aria.trim()) return aria.trim();
      const labelledBy = el.getAttribute("aria-labelledby");
      if (labelledBy) {
        const target = document.getElementById(labelledBy.split(/\s+/)[0]);
        if (target) return textOf(target);
      }
      const text = textOf(el);
      if (text) return text;
      const title = el.getAttribute("title");
      return title ? title.trim() : "";
    }

    /*
     * The human name of a form control.
     *
     * Resolves the <label> the way a screen reader does, because that is the
     * name the page's author actually wrote. Falling back to the `name`
     * attribute produces "custname" and "custtel" where the page says
     * "Customer name" and "Telephone" — technically a label, useless to read
     * aloud, and exactly the failure this app exists to fix.
     */
    function controlLabel(control) {
      const aria = control.getAttribute("aria-label");
      if (aria && aria.trim()) return aria.trim();

      const labelledBy = control.getAttribute("aria-labelledby");
      if (labelledBy) {
        const target = document.getElementById(labelledBy.split(/\s+/)[0]);
        if (target) {
          const t = textOf(target);
          if (t) return t;
        }
      }

      // <label for="id">
      const id = control.getAttribute("id");
      if (id) {
        try {
          const label = document.querySelector('label[for="' + CSS.escape(id) + '"]');
          if (label) {
            const t = textOf(label);
            if (t) return t;
          }
        } catch (_) { /* malformed id */ }
      }

      // <label>text <input></label>
      const wrapper = control.closest("label");
      if (wrapper) {
        const t = textOf(wrapper);
        if (t) return t;
      }

      const placeholder = control.getAttribute("placeholder");
      if (placeholder && placeholder.trim()) return placeholder.trim();

      const title = control.getAttribute("title");
      if (title && title.trim()) return title.trim();

      // Last resort. Machine-readable, not human-readable.
      return (control.getAttribute("name") || "").trim();
    }

    /*
     * A form's title, without swallowing its whole contents.
     *
     * `textOf(form)` returns every word inside it — labels, options, the
     * submit button — which reads as one long unpunctuated sentence. Only
     * these narrow sources name a form.
     */
    function formLabel(form, submit) {
      const aria = form.getAttribute("aria-label");
      if (aria && aria.trim()) return aria.trim();

      const legend = form.querySelector("legend");
      if (legend) {
        const t = textOf(legend);
        if (t) return t;
      }

      const heading = form.querySelector("h1, h2, h3, h4, [role=heading]");
      if (heading) {
        const t = textOf(heading);
        if (t) return t;
      }

      if (submit) {
        const t = labelFor(submit);
        if (t) return t;
      }
      return "Formulario";
    }

    // Forms first: they are the highest-value action on a task page, and a
    // form's fields tell you what the task needs.
    for (const form of document.querySelectorAll("form")) {
      if (isHidden(form)) continue;

      const fields = [];
      // Radios sharing a name are ONE choice, not N controls. Rendering them
      // separately turns "Pizza size: small / medium / large" into three
      // unrelated text boxes.
      const radioGroups = new Map();

      for (const control of form.querySelectorAll("input, select, textarea")) {
        const type = (control.getAttribute("type") || "text").toLowerCase();
        if (type === "hidden" || isHidden(control)) continue;
        if (fields.length >= 12) break;

        const groupName = control.getAttribute("name") || "";

        if (type === "radio" && groupName) {
          if (!radioGroups.has(groupName)) {
            const fieldId = "f" + fieldCounter++;
            const field = {
              id: fieldId,
              // The group's name comes from its fieldset, not from any one
              // option — "Pizza Size", not "Small".
              name: (function () {
                const fs = control.closest("fieldset");
                const legend = fs ? fs.querySelector("legend") : null;
                return legend ? textOf(legend) : groupName;
              })(),
              type: "radiogroup",
              required: control.hasAttribute("required"),
              value: "",
              options: [],
            };
            radioGroups.set(groupName, field);
            fields.push(field);
          }
          const group = radioGroups.get(groupName);
          const optionLabel = controlLabel(control) || control.value;
          group.options.push({ value: control.value, label: optionLabel });
          if (control.checked) group.value = control.value;
          // Every radio in the group is stampable: filling the group means
          // clicking the matching one.
          control.setAttribute("data-jef-field", group.id + ":" + control.value);
          continue;
        }

        const name = controlLabel(control);
        if (!name) continue;

        const fieldId = "f" + fieldCounter++;
        control.setAttribute("data-jef-field", fieldId);

        const field = {
          id: fieldId,
          name: name.trim(),
          type: control.tagName === "SELECT" ? "select"
              : control.tagName === "TEXTAREA" ? "textarea"
              : type,
          required: control.hasAttribute("required"),
          value: type === "checkbox" ? (control.checked ? "on" : "") : (control.value || ""),
        };

        // A <select>'s options have to travel: a native picker cannot offer
        // choices it does not know about.
        if (control.tagName === "SELECT") {
          field.options = Array.prototype.slice
            .call(control.options, 0, 60)
            .map(function (o) { return { value: o.value, label: textOf(o) }; })
            .filter(function (o) { return o.label; });
        }

        fields.push(field);
      }

      const submit = form.querySelector(
        "[type=submit], button:not([type=button]):not([type=reset])"
      );

      push({
        kind: "form",
        label: formLabel(form, submit),
        fields: fields,
        submit: submit ? labelFor(submit) : "",
        region: regionOf(form),
      }, submit || form);
    }

    for (const button of document.querySelectorAll(
      "button, [role=button], input[type=submit], input[type=button]"
    )) {
      if (isHidden(button)) continue;
      // Already reported as part of a form's submit.
      if (button.closest("form") && button.matches("[type=submit]")) continue;
      const label = labelFor(button) || button.getAttribute("value") || "";
      push({ kind: "button", label: label, region: regionOf(button) }, button);
    }

    // Navigation links only. Every <a> on the page would be hundreds of
    // entries, most of them body citations that the block list already carries.
    for (const link of document.querySelectorAll(
      "nav a[href], header a[href], [role=navigation] a[href], [role=menuitem]"
    )) {
      if (isHidden(link)) continue;
      const href = absolute(link.getAttribute("href") || "");
      if (!href) continue;
      push({ kind: "link", label: labelFor(link), href: href, region: regionOf(link) }, link);
    }

    return actions;
  }

  /*
   * Cheap visibility test. Not exhaustive — offscreen and clipped elements
   * still pass — but it removes the bulk of collapsed mobile menus.
   *
   * The size check is load-bearing, not a nicety. Wikipedia's search box is a
   * real <input> collapsed to 0×0 underneath a Vue component; without this it
   * extracted as a fillable field, and the rebuilt form wrote into a control
   * the page does not read. A field that looks filled and submits empty is
   * worse than no field at all.
   */
  function isHidden(el) {
    if (el.hasAttribute("hidden") || el.getAttribute("aria-hidden") === "true") return true;
    const style = window.getComputedStyle(el);
    if (style.display === "none" || style.visibility === "hidden") return true;
    const rect = el.getBoundingClientRect();
    if (rect.width < 2 || rect.height < 2) return true;
    return false;
  }

  /// Which landmark an element sits in. Gives Jev the structural hint that a
  /// label alone does not carry: "Search" in a header means something different
  /// from "Search" inside main content.
  function regionOf(el) {
    const landmark = el.closest("nav, header, footer, main, aside, [role=navigation], [role=banner], [role=contentinfo], [role=main], [role=search]");
    if (!landmark) return "body";
    const role = landmark.getAttribute("role");
    if (role) return role;
    return landmark.tagName.toLowerCase();
  }

  /*
   * Groups actions into navigable clusters.
   *
   * This is the core of the product, and it is pure code — no model needed.
   *
   * Measured on aerolineas.com.ar: 224 VoiceOver stops, of which 112 are
   * interactive, and ONE heading in the whole page. A screen-reader user has
   * no way to skip: the headings rotor has a single destination, so reaching
   * anything means swiping past everything before it.
   *
   * Grouping collapses each cluster into one stop that expands on demand, and
   * — because every group carries a title — gives the headings rotor the
   * destinations the page never declared. Jev's job is only to title and order
   * the groups, which is ~10 judgments instead of 224.
   */
  function groupActions(actions) {
    const groups = [];
    const byRegion = new Map();

    for (const action of actions) {
      // Region is the coarse split a page already declares. Within a region,
      // kind separates a row of buttons from a list of links — different
      // things to a user even when they sit together in the DOM.
      const key = action.region + "|" + action.kind;
      if (!byRegion.has(key)) byRegion.set(key, []);
      byRegion.get(key).push(action);
    }

    for (const [key, members] of byRegion) {
      const parts = key.split("|");
      groups.push({
        id: "g" + groups.length,
        region: parts[0],
        kind: parts[1],
        // Candidate titles for Jev to choose from. It cannot generate text, so
        // the title has to already exist somewhere in the group.
        candidates: members.slice(0, 8).map(function (m) { return m.label; }),
        actionIds: members.map(function (m) { return m.id; }),
        size: members.length,
      });
    }

    // Biggest first: a 40-link footer is the single largest win available, and
    // ordering by size makes the win visible before any model runs.
    groups.sort(function (a, b) { return b.size - a.size; });
    return groups;
  }

  /*
   * Finds repeated structures: product grids, article feeds, result lists.
   *
   * A catalogue is the same markup stamped N times, and that repetition is a
   * fact the DOM already states. Recognising it needs no model at all.
   *
   * Measured across every site sampled — ARCA (8 items), Banco Galicia (17),
   * La Nación (13) — so this is the most universal pattern found, not an
   * e-commerce special case. Without it, fifty products read as fifty
   * unrelated links and their prices are lost, which is the one number the
   * visitor came for.
   */
  function collectListings() {
    const MIN_ITEMS = 4;
    const SIMILARITY = 0.8;
    const candidates = [];

    function signature(el) {
      const cls = String(el.className || "").split(/\s+/).slice(0, 2).join(".");
      return el.tagName + "|" + cls;
    }

    for (const container of document.querySelectorAll("ul, ol, div, section, tbody")) {
      const kids = Array.prototype.filter.call(container.children, function (k) {
        return !isHidden(k);
      });
      if (kids.length < MIN_ITEMS) continue;

      const first = signature(kids[0]);
      const matching = kids.filter(function (k) { return signature(k) === first; });
      if (matching.length < MIN_ITEMS) continue;
      if (matching.length < kids.length * SIMILARITY) continue;

      candidates.push({ container: container, items: matching });
    }

    // Nested containers both match; keep the innermost, which is the one whose
    // children are actual items rather than groups of items.
    const kept = candidates.filter(function (c) {
      return !candidates.some(function (other) {
        return other !== c && c.container.contains(other.container);
      });
    });

    kept.sort(function (a, b) { return b.items.length - a.items.length; });

    return kept.slice(0, 4).map(function (candidate, index) {
      return {
        id: "L" + index,
        title: listingTitle(candidate.container),
        count: candidate.items.length,
        items: candidate.items.slice(0, 30).map(itemOf),
      };
    });
  }

  /*
   * The name of a listing, taken from what the page already says.
   *
   * Pages label their lists — "Últimas noticias", "Trámites frecuentes" —
   * usually in a heading immediately before the container. Without this every
   * listing renders as "Listado", and four boxes reading "Listado" tell a
   * screen-reader user nothing, which is the same failure as calling a group
   * "Pie de página": a fact about the markup, not about what it holds.
   */
  function listingTitle(container) {
    const aria = container.getAttribute("aria-label");
    if (aria && aria.trim()) return aria.trim();

    const labelledBy = container.getAttribute("aria-labelledby");
    if (labelledBy) {
      const target = document.getElementById(labelledBy.split(/\s+/)[0]);
      if (target) {
        const t = textOf(target);
        if (t) return t.slice(0, 60);
      }
    }

    const HEADING = "H1,H2,H3,H4,H5,H6";

    // Walk back through previous siblings, and up through ancestors, looking
    // for the nearest heading that precedes this container.
    let node = container;
    for (let hops = 0; node && hops < 4; hops++) {
      let sibling = node.previousElementSibling;
      while (sibling) {
        if (HEADING.indexOf(sibling.tagName) !== -1 || sibling.getAttribute("role") === "heading") {
          const t = textOf(sibling);
          if (t) return t.slice(0, 60);
        }
        // A wrapper whose last thing is a heading counts too.
        const inner = sibling.querySelector ? sibling.querySelector(HEADING) : null;
        if (inner && sibling.children.length <= 2) {
          const t = textOf(inner);
          if (t) return t.slice(0, 60);
        }
        sibling = sibling.previousElementSibling;
      }
      node = node.parentElement;
    }

    return "";
  }

  /// Pulls the fields a list item actually carries. Everything is optional:
  /// a news card has no price, a product card has no date.
  function itemOf(el) {
    const heading = el.querySelector("h1,h2,h3,h4,h5,h6,[role=heading]");
    const link = el.querySelector("a[href]");
    const image = el.querySelector("img");

    // Currency first, because on a product card the price is the point.
    // Handles "$ 1.299.999", "US$ 45,50", "€1,299.00".
    const text = textOf(el);
    const priceMatch = text.match(
      /(?:US\s*\$|AR\s*\$|\$|€|£|R\$)\s?\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?/
    );

    let title = heading ? textOf(heading) : "";
    if (!title && link) title = textOf(link);
    if (!title) title = text.slice(0, 80);

    const item = { title: title.slice(0, 120) };
    if (link) {
      const href = absolute(link.getAttribute("href") || "");
      if (href) item.href = href;
    }
    if (priceMatch) item.price = priceMatch[0].replace(/\s+/g, " ").trim();
    if (image) {
      const alt = (image.getAttribute("alt") || "").trim();
      if (alt) item.imageAlt = alt;
      const src = absolute(image.getAttribute("src") || image.getAttribute("data-src") || "");
      if (src) item.image = src;
    }

    // Whatever else the card says, minus the title and price we already have.
    let rest = text;
    if (title) rest = rest.replace(title, "");
    if (item.price) rest = rest.replace(item.price, "");
    rest = rest.replace(/\s+/g, " ").trim();
    if (rest && rest.length < 120) item.meta = rest;

    return item;
  }

  /*
   * Detects an overlay blocking the page: cookie banner, paywall, newsletter
   * prompt, age gate, login wall.
   *
   * This has to be surfaced FIRST and as itself. A sighted visitor sees the
   * page dimmed behind a box and knows the box comes first; a screen-reader
   * user gets the overlay's controls mixed into the page's, with no cue that
   * nothing else will work until it is dealt with.
   *
   * The app never dismisses one on the user's behalf — accepting terms or
   * choosing cookie preferences is their decision, not ours. It only makes the
   * choice reachable and says what it is.
   */
  function detectOverlay() {
    const candidates = [];

    // Declared overlays.
    for (const el of document.querySelectorAll("[role=dialog], [role=alertdialog], [aria-modal=true], dialog[open]")) {
      if (!isHidden(el)) candidates.push(el);
    }

    // Undeclared ones: fixed or sticky boxes large enough to block, which is
    // how most cookie banners and paywalls are actually built.
    const viewportArea = window.innerWidth * window.innerHeight;
    for (const el of document.body.querySelectorAll("div, section, aside")) {
      if (candidates.indexOf(el) !== -1) continue;
      const style = window.getComputedStyle(el);
      if (style.position !== "fixed" && style.position !== "sticky") continue;
      if (isHidden(el)) continue;
      const zIndex = parseInt(style.zIndex, 10) || 0;
      if (zIndex < 100) continue;
      const rect = el.getBoundingClientRect();
      if (rect.width * rect.height < viewportArea * 0.2) continue;
      candidates.push(el);
    }

    if (!candidates.length) return null;

    // The outermost one: nested panels belong to the same overlay.
    const outer = candidates.filter(function (c) {
      return !candidates.some(function (o) { return o !== c && o.contains(c); });
    });
    const el = outer[0] || candidates[0];

    const choices = [];
    const links = [];
    for (const control of el.querySelectorAll("button, [role=button], a[href], input[type=submit]")) {
      if (isHidden(control)) continue;
      const label = labelOf(control);
      if (!label) continue;

      // A link to the privacy policy is not an answer to the banner. Offered
      // beside "Aceptar" it reads as a third option, and taking it abandons
      // the page instead of resolving anything. Measured on aerolineas.com.ar,
      // where "Puedes conocer nuestras políticas de cookies y privacidad."
      // came back as the first of three choices.
      if (control.tagName === "A" && leavesPage(control)) {
        if (links.length >= 4) continue;
        if (links.some(function (l) { return l.label === label; })) continue;
        links.push({ label: label, href: control.href });
        continue;
      }

      if (choices.length >= 8) continue;
      if (choices.some(function (c) { return c.label === label; })) continue;
      const id = "o" + choices.length;
      control.setAttribute("data-jef-id", id);
      choices.push({ id: id, label: label });
    }

    const text = textOf(el);

    // A fixed box with nothing to read and nothing to press is layout, not an
    // overlay: spiegel.de has one and it rendered as an empty "Aviso de la
    // página" card at the top of the article.
    if (!choices.length && !links.length && !text) return null;

    return {
      // Kept so the action inventory can skip what belongs to the overlay.
      element: el,
      overlay: {
        // What it is, so the app can say it plainly.
        kind: classifyOverlay(text, choices),
        text: text.slice(0, 400),
        choices: choices,
        links: links,
      },
    };
  }

  /// Label resolution that works outside collectActions' closure.
  function labelOf(el) {
    const aria = el.getAttribute("aria-label");
    if (aria && aria.trim()) return aria.trim();
    const text = textOf(el);
    if (text) return text.slice(0, 60);
    const title = el.getAttribute("title");
    return title ? title.trim() : "";
  }

  /// Whether following an anchor would leave the page behind, which is what
  /// separates "read our policy" from "accept".
  function leavesPage(anchor) {
    const href = anchor.getAttribute("href") || "";
    if (!href || href.charAt(0) === "#") return false;
    if (/^javascript:/i.test(href)) return false;
    try {
      const target = new URL(href, document.baseURI);
      if (target.protocol !== "http:" && target.protocol !== "https:") return false;
      return target.origin !== location.origin || target.pathname !== location.pathname;
    } catch (_) {
      return false;
    }
  }

  /// Names the overlay from its own words. A guess, but a narrow one, and the
  /// full text travels alongside so the user can judge for themselves.
  function classifyOverlay(text, choices) {
    const all = (text + " " + choices.map(function (c) { return c.label; }).join(" ")).toLowerCase();
    if (/cookie|consentimiento|consent|privacidad|rgpd|gdpr/.test(all)) return "cookies";
    if (/suscri|subscribe|paywall|seguí leyendo|continuar leyendo|registrate para/.test(all)) return "paywall";
    if (/newsletter|bolet[ií]n|not[ií]cias por mail/.test(all)) return "newsletter";
    if (/iniciar sesi[oó]n|log ?in|sign ?in|ingres[aá]/.test(all)) return "login";
    if (/edad|age|mayor de/.test(all)) return "age";
    return "other";
  }

  /// Counts what a screen reader would stop on, before any of our work.
  /// Reported so the app can show the user what it saved them, and so the
  /// number stays honest as sites change.
  function countStops() {
    const INTERACTIVE = "a[href], button, input:not([type=hidden]), select, textarea, [role=button], [role=link], [role=menuitem], [role=tab], [tabindex]:not([tabindex='-1'])";
    let interactive = 0;
    for (const el of document.querySelectorAll(INTERACTIVE)) {
      if (!isHidden(el)) interactive++;
    }
    let images = 0;
    for (const el of document.querySelectorAll("img, [role=img]")) {
      if (!isHidden(el)) images++;
    }
    let headings = 0;
    for (const el of document.querySelectorAll("h1,h2,h3,h4,h5,h6,[role=heading]")) {
      if (!isHidden(el)) headings++;
    }
    return { interactive: interactive, images: images, headings: headings };
  }

  function extract() {
    // Collected before Readability runs, and from the live document: the parse
    // below throws all of this away.
    // Overlay first: it stamps its own controls, and the action inventory has
    // to know which elements are already spoken for.
    const found = detectOverlay();
    const overlay = found ? found.overlay : null;
    const actions = collectActions(found ? found.element : null);
    const groups = groupActions(actions);
    const listings = collectListings();
    const original = countStops();

    // Readability mutates the document it parses, so hand it a clone.
    const article = new Readability(document.cloneNode(true), {
      charThreshold: 200,
allowedVideoRegex: /^$/,
    }).parse();

    // A page with no prose but with actions is not a failure — it is a task
    // page, which is precisely the case the actions pass exists for.
    if (!article || !article.content) {
      if (actions.length || listings.length) {
        return {
          ok: true,
          url: location.href,
          title: document.title || "",
          byline: "",
          siteName: location.hostname,
          excerpt: "",
          lang: document.documentElement.lang || "",
          blocks: [],
          actions: actions,
          groups: groups,
          listings: listings,
          overlay: overlay,
          stats: {
            blockCount: 0,
            actionCount: actions.length,
            groupCount: groups.length,
            listingCount: listings.length,
            originalStops: original.interactive + original.images,
            originalHeadings: original.headings,
            charCount: 0,
            truncated: false,
            imagesWithoutAlt: 0,
            unsupported: 0,
          },
        };
      }
      return { ok: false, reason: "no-article", url: location.href };
    }

    /*
     * Readability returns an HTML string; reparse it to walk real nodes.
     *
     * DOMParser produces an INERT document: scripts in the parsed markup never
     * execute and no resources load, so hostile page content cannot run here.
     * Do not swap this for `innerHTML` on a live node — page content is
     * untrusted by definition in a browser, and Readability's own cleanup is
     * a convenience, not a security boundary.
     */
    const holder = new DOMParser().parseFromString(article.content, "text/html");

    const blocks = toBlocks(holder.body);

    return {
      ok: true,
      url: location.href,
      title: article.title || document.title || "",
      byline: article.byline || "",
      siteName: article.siteName || location.hostname,
      excerpt: article.excerpt || "",
      lang: document.documentElement.lang || "",
      blocks: blocks,
      actions: actions,
      groups: groups,
      listings: listings,
      overlay: overlay,
      stats: {
        blockCount: blocks.length,
        actionCount: actions.length,
        groupCount: groups.length,
        listingCount: listings.length,
        originalStops: original.interactive + original.images,
        originalHeadings: original.headings,
        charCount: (article.textContent || "").length,
        truncated: blocks.length >= MAX_BLOCKS,
        imagesWithoutAlt: blocks.filter(b => b.type === "image" && b.needsAlt).length,
        unsupported: blocks.filter(b => b.type === "unsupported").length,
      },
    };
  }

  function send(payload) {
    try {
      window.webkit.messageHandlers.jefExtract.postMessage(JSON.stringify(payload));
    } catch (e) {
      // Android will bind a different bridge here.
      if (window.jefExtract && window.jefExtract.postMessage) {
        window.jefExtract.postMessage(JSON.stringify(payload));
      }
    }
  }

  /*
   * Waits for the DOM to stop changing before extracting.
   *
   * `atDocumentEnd` fires when the HTML is parsed, which on a single-page app
   * is before the framework has rendered anything. Measured: extracting
   * immediately on aerolineas.com.ar yields zero actions and no article, while
   * the same code run once the page settles yields 40 actions in 6 groups.
   *
   * Resolves on QUIET_MS of no mutations, or at MAX_WAIT_MS regardless — a
   * page with a spinner or a polling widget never goes quiet, and waiting
   * forever is worse than extracting something.
   */
  function whenSettled(callback) {
    const QUIET_MS = 600;
    const MAX_WAIT_MS = 6000;

    let quietTimer = null;
    let done = false;

    function finish() {
      if (done) return;
      done = true;
      clearTimeout(quietTimer);
      observer.disconnect();
      clearTimeout(hardStop);
      callback();
    }

    const observer = new MutationObserver(function () {
      clearTimeout(quietTimer);
      quietTimer = setTimeout(finish, QUIET_MS);
    });

    const hardStop = setTimeout(finish, MAX_WAIT_MS);

    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
      characterData: true,
    });

    // A static page produces no mutations at all, so start the clock now
    // rather than waiting for a change that never comes.
    quietTimer = setTimeout(finish, QUIET_MS);
  }

  /*
   * Activates a previously extracted control.
   *
   * Called from Swift via evaluateJavaScript. The id comes from our own
   * extraction, never from the page, so a page cannot ask to have one of its
   * own controls pressed.
   *
   * Returns a status the native side can act on rather than throwing: the
   * caller needs to distinguish "clicked, re-extract" from "the node is gone,
   * re-extract and try again" from "nothing happened".
   */
  /*
   * Writes a value into a form control the user filled in natively.
   *
   * Assigning to `.value` is NOT enough. React keeps its own value tracker on
   * the node and ignores a plain assignment, so the component's state never
   * updates and the field snaps back on the next render. Calling the native
   * prototype setter bypasses the tracker, and the dispatched events are what
   * React, Angular and Vue actually listen for.
   *
   * Without this the fields would look filled and submit empty — worse than
   * not offering them.
   */
  window.__jefFill = function (fieldId, value) {
    const key = String(fieldId).replace(/"/g, "");

    // A radio group is filled by clicking the option that matches, which is
    // what a person does and what the framework listens for.
    if (key.indexOf(":") === -1) {
      const radio = document.querySelector(
        '[data-jef-field="' + key + ':' + String(value).replace(/"/g, "") + '"]'
      );
      if (radio) {
        radio.click();
        return { ok: true, value: radio.value };
      }
    }

    const el = document.querySelector('[data-jef-field="' + key + '"]');
    if (!el) return { ok: false, reason: "gone" };

    // Checkboxes toggle; they have no text value to write.
    if (el.type === "checkbox") {
      const wanted = value === "on" || value === "true" || value === true;
      if (el.checked !== wanted) el.click();
      return { ok: true, value: el.checked ? "on" : "" };
    }

    try {
      const prototype =
        el.tagName === "SELECT" ? window.HTMLSelectElement.prototype
        : el.tagName === "TEXTAREA" ? window.HTMLTextAreaElement.prototype
        : window.HTMLInputElement.prototype;

      const setter = Object.getOwnPropertyDescriptor(prototype, "value").set;
      setter.call(el, String(value));

      el.dispatchEvent(new Event("input", { bubbles: true }));
      el.dispatchEvent(new Event("change", { bubbles: true }));
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, value: el.value };
  };

  /// Submits the form that owns a control, preferring a real submit button
  /// over form.submit() — frameworks hang their handlers on the click, and
  /// form.submit() skips validation and those handlers entirely.
  window.__jefSubmitForm = function (actionId) {
    const anchor = document.querySelector(
      '[data-jef-id="' + String(actionId).replace(/"/g, "") + '"]'
    );
    if (!anchor) return { ok: false, reason: "gone" };

    const form = anchor.tagName === "FORM" ? anchor : anchor.closest("form");
    const before = location.href;

    try {
      if (anchor.tagName !== "FORM" && typeof anchor.click === "function") {
        anchor.click();
      } else if (form) {
        const submit = form.querySelector("[type=submit], button:not([type=button])");
        if (submit) submit.click();
        else form.requestSubmit ? form.requestSubmit() : form.submit();
      } else {
        return { ok: false, reason: "no-form" };
      }
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, navigated: location.href !== before, href: location.href };
  };

  window.__jefActivate = function (id) {
    const el = document.querySelector('[data-jef-id="' + String(id).replace(/"/g, '') + '"]');
    if (!el) return { ok: false, reason: "gone" };

    const before = location.href;
    try {
      // scrollIntoView first: some frameworks only wire handlers to elements
      // once they enter the viewport.
      el.scrollIntoView({ block: "center" });
      el.click();
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, navigated: location.href !== before, href: location.href };
  };

  /// Re-runs extraction on demand, after an activation changed the page.
  window.__jefReextract = function () {
    whenSettled(function () {
      try {
        send(extract());
      } catch (e) {
        send({ ok: false, reason: "error", message: String((e && e.message) || e), url: location.href });
      }
    });
  };

  whenSettled(function () {
    try {
      send(extract());
    } catch (e) {
      send({
        ok: false,
        reason: "error",
        message: String((e && e.message) || e),
        url: location.href,
      });
    }
  });
})();
