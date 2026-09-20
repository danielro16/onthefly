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
        // What a screen reader says for this element, if the page said so:
        // <abbr aria-label="10 de octubre de 2026">10</abbr> reads as the
        // date, not as "10". Same rule as the accessible name computation.
        const aria = child.getAttribute("aria-label");
        if (aria && aria.trim()) {
          raw += " " + aria.trim() + " ";
          continue;
        }
        const isBlock = BLOCK_TAGS.has(child.tagName);
        // Siblings laid out apart by CSS have no space between them in the
        // text: a product card's "$749.999" and its "6" badge read as
        // "$749.9996". A space between elements costs nothing to the ear.
        if (isBlock) raw += "\n";
        else if (raw && !/\s$/.test(raw)) raw += " ";
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

  /// Tag plus leading classes: what makes two siblings "the same kind of
  /// thing" to the eye, without reading their content.
  function shapeOf(el) {
    const cls = String(el.className || "").split(/\s+/).slice(0, 2).join(".");
    return el.tagName + "|" + cls;
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

        // Two elements side by side were laid out apart — on their own
        // lines, or spaced by CSS the text no longer has. Without a break,
        // "<label>Total por pasajero/a</label><label>ARS 81.987</label>"
        // reads as one word. An extra space costs nothing to the ear.
        if (text && !/\s$/.test(text)) text += " ";
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
          // A video that did not load says so in a paragraph, four times a
          // page. Nothing a reader can do with it.
          if (/video player failed|error code:?\s*\d/i.test(content.text)) continue;
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
    const stamped = [];
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
      /^(página|page)\s*\d+$/i,                    // carousel pagination
    ];

    function isNoise(label) {
      if (label.length < 3) return true;
      // "search-icon" is the name of a glyph, not of an action.
      if (looksLikeCode(label)) return true;
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
      stamped.push({ action: action, element: element });
    }

    /*
     * The submit a form is actually built around.
     *
     * querySelector returns whichever one the markup happens to put first, and
     * on google.com that is "Buscar con IA" — so the rebuilt search box was
     * titled and submitted as the AI button while "Buscar con Google", the
     * point of the page, sat fourth in the action list.
     *
     * Same principle the intent model already uses: presence is not
     * prominence. Among the visible submits, the prominent one is the one the
     * page gives the most room to.
     */
    function primarySubmit(form) {
      const all = Array.prototype.slice.call(
        form.querySelectorAll("[type=submit], button:not([type=button]):not([type=reset])")
      );

      // The button that names what the field names is the one: google.com's
      // box is labelled "Buscar con Google", and so is one of its two
      // submits. On a phone that one is not even visible — the page submits
      // on Enter — while "Buscar con IA" is, and a search typed into the box
      // went to the AI button. Hidden is fine here: the form is submitted
      // with requestSubmit(button), which needs a submit control, not a
      // visible one.
      const fieldNames = Array.prototype.slice.call(form.querySelectorAll("input, textarea"))
        .filter(function (c) { return !isHidden(c) && !/^(submit|button|image|reset|hidden)$/i.test(c.getAttribute("type") || ""); })
        .map(function (c) { return controlLabel(c).toLowerCase(); });
      // Any button, whatever its type: on a phone Google's "Buscar con
      // Google" is a type=button wired in JavaScript, and the only real
      // submit in the form is "Buscar con IA".
      const anyButton = Array.prototype.slice.call(
        form.querySelectorAll("button, [type=submit], [role=button]")
      );
      const named = anyButton.find(function (candidate) {
        const label = labelFor(candidate).toLowerCase();
        return label && fieldNames.indexOf(label) !== -1;
      });
      if (named) return named;

      const candidates = all.filter(function (candidate) { return !isHidden(candidate); });
      if (!candidates.length) return null;

      let best = candidates[0];
      let bestArea = -1;
      for (const candidate of candidates) {
        const rect = candidate.getBoundingClientRect();
        const area = rect.width * rect.height;
        if (area > bestArea) { bestArea = area; best = candidate; }
      }
      return best;
    }

    /// Drops a segment that only repeats what an earlier one already said:
    /// a calendar cell reads "10 de octubre de 2026, 10, 112935, ARS" —
    /// the second "10" is the visible digit under the accessible date.
    function dedupeSegments(label) {
      const kept = [];
      for (const part of label.split(", ")) {
        const dup = kept.some(function (k) { return k === part || k.indexOf(part + " ") === 0; });
        if (!dup) kept.push(part);
      }
      return kept.join(", ");
    }

    function labelFor(el) {
      const aria = el.getAttribute("aria-label");
      if (aria && aria.trim()) return aria.trim();
      const labelledBy = el.getAttribute("aria-labelledby");
      if (labelledBy) {
        const target = document.getElementById(labelledBy.split(/\s+/)[0]);
        if (target) return textOf(target);
      }
      const text = dedupeSegments(textOf(el));
      if (text) return text;
      // <input type=submit value="Buscar con Google"> has no text nodes;
      // its value is its label.
      if (el.tagName === "INPUT") {
        const value = (el.getAttribute("value") || "").trim();
        if (value) return value;
      }
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
    /*
     * A label's own words, without the control it wraps.
     *
     * <label>Enter a user-agent string: <textarea>Mozilla/5.0 …</textarea></label>
     * is one label, but textOf() reads the textarea's content as part of it,
     * so the field was named after its own current value — a sixty-word
     * label that changed every time the user typed.
     */
    function labelText(label) {
      const clone = label.cloneNode(true);
      for (const control of clone.querySelectorAll("input, select, textarea, button")) {
        control.remove();
      }
      return textOf(clone);
    }

    /*
     * The closest label to a control, by position rather than by markup.
     *
     * After it first: a radio or a checkbox puts its text on the right. Then
     * before it, walking outwards one ancestor at a time and reading that
     * scope backwards from the control: the first label met is the one, and
     * the first other control met means this scope has nothing for us — a
     * label further back belongs to that other control. A bigger scope would
     * see the same order, so the search stops there.
     */
    function nearbyLabel(control) {
      const next = control.nextElementSibling;
      if (next && next.tagName === "LABEL" && !next.contains(control)) {
        const t = labelText(next);
        if (t && t.length <= 60) return t;
      }

      let scope = control.parentElement;
      for (let depth = 0; scope && depth < 4; depth++, scope = scope.parentElement) {
        const ordered = Array.prototype.slice.call(
          scope.querySelectorAll("label, input:not([type=hidden]), select, textarea")
        );
        const at = ordered.indexOf(control);
        if (at < 0) continue;
        for (let i = at - 1; i >= 0; i--) {
          const el = ordered[i];
          if (el.tagName === "LABEL") {
            if (el.contains(control)) continue;
            const t = labelText(el);
            return t && t.length <= 60 ? t : "";
          }
          return "";
        }
      }
      return "";
    }

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
            const t = labelText(label);
            if (t) return t;
          }
        } catch (_) { /* malformed id */ }
      }

      // <label>text <input></label>
      const wrapper = control.closest("label");
      if (wrapper) {
        const t = labelText(wrapper);
        if (t) return t;
      }

      // A label beside the control with nothing tying them together — the
      // commonest layout there is: <label>Partida</label><div><input
      // placeholder="dd/mm/aaaa"></div>. Taken before the placeholder,
      // because "Partida" is the name and "dd/mm/aaaa" is the format.
      const near = nearbyLabel(control);
      if (near) return near;

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
    function formLabel(form, submit, fields) {
      const aria = form.getAttribute("aria-label");
      if (aria && aria.trim()) return aria.trim();

      // A legend names its own field group, and only describes the whole form
      // when there is just one. httpbin's pizza order has two — "Pizza Size"
      // and "Pizza Toppings" — and taking the first titled the entire order
      // form after its size selector.
      const legends = form.querySelectorAll("legend");
      if (legends.length === 1) {
        const t = textOf(legends[0]);
        if (t) return t;
      }

      const heading = form.querySelector("h1, h2, h3, h4, [role=heading]");
      if (heading) {
        const t = textOf(heading);
        if (t) return t;
      }

      // A form with a single field IS that field, and the field says what it
      // is for. Naming it after a submit button misreports the task: the only
      // submit inside google.com's search form is "Buscar con IA", so the box
      // came out titled as the AI button while its own field read "Buscar con
      // Google" right underneath.
      if (fields && fields.length === 1 && fields[0].name) return fields[0].name;

      if (submit) {
        const t = labelFor(submit);
        if (t) return t;
      }
      return "Formulario";
    }

    /// The fields inside a container. The container is usually a <form>,
    /// but nothing here needs it to be.
    function fieldsOf(container) {
      const fields = [];
      // Radios sharing a name are ONE choice, not N controls. Rendering them
      // separately turns "Pizza size: small / medium / large" into three
      // unrelated text boxes.
      const radioGroups = new Map();

      for (const control of container.querySelectorAll("input, select, textarea")) {
        const type = (control.getAttribute("type") || "text").toLowerCase();
        if (type === "hidden" || isHidden(control)) continue;
        // A submit is a button, not something to fill in: Google's form came
        // out with "Buscar con Google" and "Voy a tener suerte" as fields.
        if (type === "submit" || type === "button" || type === "image" || type === "reset") continue;
        // A real form nested in an inferred one reports its own fields.
        if (container.tagName !== "FORM" && control.closest("form")) continue;
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
                if (legend) return textOf(legend);
                const group = control.closest("[role=radiogroup]");
                const aria = group ? group.getAttribute("aria-label") : "";
                return aria && aria.trim() ? aria.trim() : groupName;
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

      return fields;
    }

    // Forms first: they are the highest-value action on a task page, and a
    // form's fields tell you what the task needs.
    for (const form of document.querySelectorAll("form")) {
      if (isHidden(form)) continue;

      const fields = fieldsOf(form);
      const submit = primarySubmit(form);
      // A form with nothing to fill in is a button at best; its button is
      // collected below on its own.
      if (!fields.length) continue;

      push({
        kind: "form",
        label: formLabel(form, submit, fields),
        fields: fields,
        submit: submit ? labelFor(submit) : "",
        region: regionOf(form),
      }, submit || form);
    }

    /*
     * Forms without a <form>.
     *
     * Every SPA framework builds its search boxes out of divs. On
     * aerolineas.com.ar the flight search is origin, destination, two dates,
     * a trip-type radio, two switches and a "Buscar vuelos" button, and the
     * page has zero <form> elements — 16 real controls with nothing grouping
     * them, so the reader offered the button and none of the fields. The
     * grouping is inferred from the button instead: the closest ancestor of
     * a submit-looking button that holds a control, bounded so it never
     * swallows the page. Biggest buttons first, so a box's prominent button
     * is the one that claims it.
     */
    const SUBMIT_WORDS = /\b(buscar|search|enviar|send|submit|ingresar|entrar|login|iniciar|acceder|continuar|siguiente|next|comprar|pagar|reservar|suscrib\w*|registr\w*|sign|aplicar|apply|confirmar|calcular|cotizar|consultar|ir|go|ok)\b/i;

    function area(el) {
      const rect = el.getBoundingClientRect();
      return rect.width * rect.height;
    }

    function looseControls(box) {
      return Array.prototype.slice
        .call(box.querySelectorAll("input:not([type=hidden]), select, textarea"))
        .filter(function (c) { return !isHidden(c) && !c.closest("form"); });
    }

    function isSubmitLike(button) {
      const label = labelFor(button) || button.getAttribute("value") || "";
      return button.matches("[type=submit]") || SUBMIT_WORDS.test(label);
    }

    function defactoForms() {
      const found = [];
      const buttons = Array.prototype.slice
        .call(document.querySelectorAll("button, [role=button], input[type=submit], input[type=button]"))
        .filter(function (b) { return !isHidden(b) && !b.closest("form"); })
        // "Buscar vuelos" before "1 Pasajero/a, Economy", whatever their
        // size: the one that says what the form does is the one that owns
        // it. Size only breaks ties.
        .sort(function (a, b) {
          const sa = isSubmitLike(a) ? 1 : 0, sb = isSubmitLike(b) ? 1 : 0;
          return sb - sa || area(b) - area(a);
        });

      for (const button of buttons) {
        const looksLikeSubmit = isSubmitLike(button);
        // One field is enough behind a "Buscar". A button that says nothing
        // of the sort needs company, or a header's menu button would claim
        // the search box beside it.
        const needed = looksLikeSubmit ? 1 : 2;

        let box = button.parentElement;
        let claimed = null;
        for (let depth = 0; box && depth < 8; depth++, box = box.parentElement) {
          if (box === document.body || box === document.documentElement) break;
          const controls = looseControls(box);
          if (controls.length > 30) break;
          if (controls.length >= needed) { claimed = box; break; }
        }
        if (!claimed) continue;

        // Grow while the parent still looks like the same form: it adds
        // fields, it stays small, and it brings no second submit with it.
        // The airline's box was found one level too low — the trip-type
        // radios and the two switches sat in sibling containers.
        let parent = claimed.parentElement;
        while (parent && parent !== document.body) {
          const more = looseControls(parent).length;
          if (more <= looseControls(claimed).length || more > 30) break;
          if (textOf(parent).length > 2000) break;
          const rivals = Array.prototype.slice
            .call(parent.querySelectorAll("button, [role=button], input[type=submit]"))
            .filter(function (b) { return b !== button && !isHidden(b) && !claimed.contains(b) && isSubmitLike(b); });
          if (rivals.length) break;
          claimed = parent;
          parent = parent.parentElement;
        }

        if (found.some(function (f) { return f.box === claimed || f.box.contains(claimed) || claimed.contains(f.box); })) continue;
        found.push({ box: claimed, submit: button });
      }
      return found;
    }

    for (const entry of defactoForms()) {
      const fields = fieldsOf(entry.box);
      // Something to type into, or it is not a form: a lone checkbox next
      // to a button is a CSS menu toggle ("Side Menu", "Boton Ingresar").
      if (!fields.some(function (f) { return f.type !== "checkbox" && f.type !== "radiogroup"; })) continue;
      push({
        kind: "form",
        label: formLabel(entry.box, entry.submit, fields),
        fields: fields,
        submit: labelFor(entry.submit),
        region: regionOf(entry.box),
      }, entry.submit);
    }

    for (const button of document.querySelectorAll(
      "button, [role=button], input[type=submit], input[type=button]"
    )) {
      if (isHidden(button)) continue;
      // A disabled button is not an action; offering it reads as a control
      // that does nothing. When the page enables it, the next extraction
      // picks it up.
      if (button.disabled || button.getAttribute("aria-disabled") === "true") continue;
      // Already reported as part of a form's submit.
      if (button.closest("form") && button.matches("[type=submit]")) continue;
      if (button.hasAttribute("data-jef-id")) continue;
      const label = labelFor(button) || button.getAttribute("value") || "";
      push({ kind: "button", label: label, region: regionOf(button) }, button);
    }

    // Navigation links only. Every <a> on the page would be hundreds of
    // entries, most of them body citations that the block list already carries.
    // A footer is navigation too — "Trámites: Turnos, Trámites a distancia"
    // on argentina.gob.ar lived only there — and a link dressed as a button
    // ("Volver a la página de búsqueda", class btn) is an action wherever it
    // sits.
    for (const link of document.querySelectorAll(
      "nav a[href], header a[href], footer a[href], [role=navigation] a[href], [role=menuitem], a[href][class*=btn], a[href][class*=button]"
    )) {
      if (isHidden(link)) continue;
      const href = absolute(link.getAttribute("href") || "");
      if (!href) continue;
      push({ kind: "link", label: labelFor(link), href: href, region: regionOf(link) }, link);
    }

    /*
     * Sibling buttons of the same shape are ONE control set.
     *
     * The flight calendar is 34 day buttons under one parent. Judged one by
     * one, Jev filed them under three different goals — compare, buy, look
     * up — by whatever the label happened to say, and the grid came out
     * split across three collapsed groups. A person sees one calendar. The
     * cluster travels with each action so the classifier can judge the set
     * once and keep it together.
     */
    const siblings = new Map();
    for (const entry of stamped) {
      if (!entry.element || entry.action.kind !== "button" || !entry.element.parentElement) continue;
      const parent = entry.element.parentElement;
      if (!siblings.has(parent)) siblings.set(parent, new Map());
      const shapes = siblings.get(parent);
      const shape = shapeOf(entry.element);
      if (!shapes.has(shape)) shapes.set(shape, []);
      shapes.get(shape).push(entry.action);
    }
    let clusterCount = 0;
    for (const shapes of siblings.values()) {
      for (const members of shapes.values()) {
        if (members.length < 3) continue;
        const id = "c" + clusterCount++;
        for (const action of members) action.cluster = id;
      }
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

    const signature = shapeOf;

    for (const container of document.querySelectorAll("ul, ol, div, section, tbody")) {
      const kids = Array.prototype.filter.call(container.children, function (k) {
        return !isHidden(k);
      });
      if (kids.length < MIN_ITEMS) continue;

      const first = signature(kids[0]);
      const matching = kids.filter(function (k) { return signature(k) === first; });
      if (matching.length < MIN_ITEMS) continue;
      if (matching.length < kids.length * SIMILARITY) continue;

      // A row of buttons is already in the action list, stamped and
      // pressable. Reporting it again as a listing read the flight
      // calendar twice: 34 day buttons, then the same 34 days as items
      // nobody could activate.
      const pressable = matching.filter(function (k) {
        return k.hasAttribute("data-jef-id") || k.querySelector("[data-jef-id]");
      });
      if (pressable.length >= matching.length * 0.5) continue;

      // A row of short, unlinked tokens is a header or a legend — the
      // weekday initials over a calendar — not a list of things.
      const linked = matching.some(function (k) { return k.tagName === "A" || k.querySelector("a[href]"); });
      if (!linked && matching.every(function (k) { return textOf(k).length <= 12; })) continue;

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

    const listings = kept.slice(0, 4).map(function (candidate, index) {
      return {
        id: "L" + index,
        title: listingTitle(candidate.container),
        count: candidate.items.length,
        items: candidate.items.slice(0, 30).map(itemOf),
      };
    });

    // Cards the shape detector missed, minus anything already listed.
    const taken = new Set();
    for (const listing of listings) for (const item of listing.items) if (item.href) taken.add(item.href);
    for (const group of collectCards(taken).slice(0, 2)) {
      listings.push({
        id: "L" + listings.length,
        title: listingTitle(group.container),
        count: group.items.length,
        items: group.items.slice(0, 30),
      });
    }
    return listings;
  }

  /*
   * Cards: a link that carries a heading, with some text beside it.
   *
   * Google's results are exactly that — a <div role=heading> inside an <a>,
   * a snippet next to it — and they share no class from one result to the
   * next, so the repeated-shape detector above never sees them. Read as
   * prose, a results page was six snippets with no title and nothing to
   * open. A card is found by its heading link and grown outwards until it
   * holds some text of its own and no second heading link; cards under the
   * same parent are one listing.
   */
  function collectCards(taken) {
    const HEADING = "h1, h2, h3, h4, h5, h6, [role=heading]";
    const byParent = new Map();
    const seen = new Set();

    for (const heading of document.querySelectorAll(HEADING)) {
      if (isHidden(heading)) continue;
      // The link may wrap the heading, sit inside it, or — clarin.com —
      // be an empty overlay at the end of the <article>, a sibling of
      // everything it opens.
      let anchor = heading.closest("a[href]") || heading.querySelector("a[href]");
      if (!anchor) {
        const card = heading.closest("article, li, [class*=card], [class*=item], [class*=story]");
        if (card && card.querySelectorAll(HEADING).length === 1) anchor = card.querySelector("a[href]");
      }
      if (!anchor) continue;
      const href = absolute(anchor.getAttribute("href") || "");
      if (!href || seen.has(href) || taken.has(href)) continue;
      const title = textOf(heading);
      if (title.length < 8) continue;

      let card = anchor;
      for (let hops = 0; hops < 5 && card.parentElement && card.parentElement !== document.body; hops++) {
        const up = card.parentElement;
        const rivals = Array.prototype.filter.call(up.querySelectorAll("a[href]"), function (a) {
          return a !== anchor && a.querySelector(HEADING) && !anchor.contains(a);
        });
        if (rivals.length) break;
        card = up;
        if (textOf(card).length >= title.length + 30) break;
      }
      const parent = card.parentElement;
      if (!parent) continue;

      seen.add(href);
      const meta = tidy(textOf(card).replace(title, "")).slice(0, 200);
      if (!byParent.has(parent)) byParent.set(parent, []);
      byParent.get(parent).push({ title: title.slice(0, 120), href: href, meta: meta });
    }

    const found = [];
    const loose = [];
    for (const [parent, items] of byParent) {
      if (items.length >= 3) found.push({ container: parent, items: items });
      else loose.push.apply(loose, items);
    }
    // Cards that share no parent — Google nests each result at its own
    // depth — are still the page's results, in page order.
    if (!found.length && loose.length >= 3) {
      found.push({ container: document.body, items: loose });
    }
    found.sort(function (a, b) { return b.items.length - a.items.length; });
    return found;
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
  /// "button-row-carousel" is a class name someone put in an aria-label.
  /// A name with no spaces and a dash or underscore in it is code, not a
  /// title, and a title that is code is worse than none.
  function looksLikeCode(text) {
    return /^[\w-]+$/.test(text) && /[-_]/.test(text);
  }

  function listingTitle(container) {
    const aria = container.getAttribute("aria-label");
    if (aria && aria.trim() && !looksLikeCode(aria.trim())) return aria.trim();

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

  // Handles "$ 1.299.999", "US$ 45,50", "€1,299.00" and "$1535,00" — the
  // last one used to come out as "$153", because the pattern only knew
  // digits in groups of three. It must end at a word boundary: a price cut
  // short is a wrong price, spoken with full confidence.
  const PRICE = /(?:US\s*\$|AR\s*\$|\$|€|£|R\$)\s?(?:\d{1,3}(?:[.,]\d{3})+|\d+)(?:[.,]\d{1,2})?(?![\d.,]\d)/;

  /// Card text minus what was already said, without the pauses that
  /// removal leaves behind: ", , $749.999 6, , Precio" is three pauses for
  /// nothing.
  function tidy(text) {
    return text.replace(/\s+/g, " ").replace(/(\s*,\s*)+/g, ", ").replace(/^,\s*|,\s*$/g, "").trim();
  }

  /// Text leaves of a card, in reading order.
  function leavesOf(el) {
    const out = [];
    for (const node of el.querySelectorAll("*")) {
      if (node.children.length || SKIP_TAGS.has(node.tagName)) continue;
      const text = (node.textContent || "").replace(/\s+/g, " ").trim();
      if (text) out.push({ node: node, text: text });
    }
    return out;
  }

  /// Struck through, by tag or by style: the price it used to be.
  function isStruck(node) {
    for (let n = node; n && n !== document.body; n = n.parentElement) {
      if (/^(S|DEL|STRIKE)$/.test(n.tagName)) return true;
      const deco = window.getComputedStyle(n).textDecorationLine || "";
      if (deco.indexOf("line-through") !== -1) return true;
    }
    return false;
  }

  /// Pulls the fields a list item actually carries. Everything is optional:
  /// a news card has no price, a product card has no date.
  function itemOf(el) {
    const heading = el.querySelector("h1,h2,h3,h4,h5,h6,[role=heading]");
    const link = el.querySelector("a[href]");
    const image = el.querySelector("img");
    const text = textOf(el);
    const leaves = leavesOf(el);

    // A product card has no heading, and its link wraps the whole card, so
    // the link's text is everything at once. The name is the first line of
    // text that is not a price.
    let title = heading ? textOf(heading) : "";
    if (!title && link) {
      const linkText = textOf(link);
      if (linkText.length < text.length - 20 || linkText.length <= 80) title = linkText;
    }
    if (!title) {
      // The longest of the first few lines: a news card opens with a
      // two-word kicker ("Farmear aura") above the headline, a product card
      // with its name above the prices.
      const lines = leaves
        .filter(function (leaf) { return leaf.text.length >= 8 && !PRICE.test(leaf.text); })
        .slice(0, 3)
        .map(function (leaf) { return leaf.text; });
      title = lines.length
        ? lines.reduce(function (best, line) { return line.length > best.length ? line : best; }, "")
        : text.slice(0, 80);
    }

    const item = { title: title.slice(0, 120) };
    if (link) {
      const href = absolute(link.getAttribute("href") || "");
      if (href) item.href = href;
    }

    // Currency, because on a product card the price is the point — the
    // price it is now, not the one struck through above it.
    let priceMatch = null;
    for (const leaf of leaves) {
      const m = leaf.text.match(PRICE);
      if (m && !isStruck(leaf.node)) { priceMatch = m; break; }
    }
    if (!priceMatch) priceMatch = text.match(PRICE);

    // "Dólar oficial $1535,00" already says its price; repeating it as a
    // separate field made the stop read "Dólar oficial $1535,00, $1535,00".
    if (priceMatch && !title.includes(priceMatch[0])) {
      item.price = priceMatch[0].replace(/\s+/g, " ").trim();
    }
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
    // Taking the title and the price out leaves their commas behind:
    // ", , $749.999 6, , Precio s/imp." — each empty segment is a pause
    // VoiceOver makes for nothing.
    rest = tidy(rest);
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

    // Declared overlays. An autocomplete's popup is not one: Google's
    // suggestions box is a dialog full of "Insert …" buttons, and read as
    // an overlay it came out as an age gate with eight answers.
    function isPopupList(el) {
      if (el.matches("[role=listbox]") || el.querySelector("[role=listbox], [role=option]")) return true;
      // Whatever holds the field being typed in is the field's own popup,
      // not something in the way of the page.
      const active = document.activeElement;
      return !!(active && active !== document.body && active.matches("input, textarea, [role=combobox]") && el.contains(active));
    }
    for (const el of document.querySelectorAll("[role=dialog], [role=alertdialog], [aria-modal=true], dialog[open]")) {
      if (!isHidden(el) && !isPopupList(el)) candidates.push(el);
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
      if (isPopupList(el)) continue;
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

  /*
   * A human check the reader cannot pass for anyone.
   *
   * MercadoLibre answers a search with "Por seguridad, completá este paso" and
   * a reCAPTCHA in an iframe — off limits by design — under a disabled
   * "Continuar". Rebuilt, that page was a heading, a cookie notice and a
   * button that did nothing. What the user needs to hear is what it is and
   * where the way through is: the original page, where the check can be
   * solved with VoiceOver's own web navigation, in the same session.
   */
  function detectChallenge() {
    const frames = Array.prototype.slice.call(document.querySelectorAll("iframe"));
    const frame = frames.find(function (f) {
      const src = (f.getAttribute("src") || "") + " " + (f.getAttribute("title") || "");
      return /recaptcha|hcaptcha|turnstile|challenges\.cloudflare|arkoselabs|funcaptcha/i.test(src) && !isHidden(f);
    });
    const words = /no soy un robot|i'm not a robot|verific[aá] que (sos|eres)|verify you are human|completá este paso/i;
    if (!frame && !words.test(textOf(document.body).slice(0, 3000))) return null;

    const heading = document.querySelector("h1, h2, [role=heading]");
    const said = heading ? textOf(heading) : "";
    return {
      kind: "captcha",
      text: said || "La página pide comprobar que sos una persona.",
      choices: [],
      links: [],
    };
  }

  function extract() {
    // Collected before Readability runs, and from the live document: the parse
    // below throws all of this away.
    // Overlay first: it stamps its own controls, and the action inventory has
    // to know which elements are already spoken for.
    const found = detectOverlay();
    // A human check outranks a cookie notice: nothing else on the page works
    // until it is passed.
    const overlay = detectChallenge() || (found ? found.overlay : null);
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
      // Readability found no article, but the page still says things: "No
      // se encontraron resultados" is a heading on a page with no prose,
      // and dropping it left the user with the site's name and a footer.
      // The main landmark, read as it is, capped.
      const main = document.querySelector("main, [role=main], article") || document.body;
      const said = toBlocks(main).slice(0, 60);

      if (actions.length || listings.length || said.length) {
        return {
          ok: true,
          url: location.href,
          title: document.title || "",
          byline: "",
          siteName: location.hostname,
          excerpt: "",
          lang: document.documentElement.lang || "",
          blocks: said,
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
  /*
   * Wakes up what only loads on scroll.
   *
   * clarin.com's mobile home renders the first screen and fetches the rest
   * as the reader scrolls; the hidden WebView never scrolls, so the page
   * extracted as one headline over a footer — 12 elements where the site
   * has hundreds. A few trips to the bottom, spaced out, fire the same
   * observers a thumb would; then back to the top, so positions mean what
   * they meant. Bounded, because an infinite feed is infinite.
   */
  function wakeLazyContent(done) {
    let trips = 0;
    let lastHeight = 0;
    function trip() {
      const height = document.documentElement.scrollHeight;
      if (trips >= 4 || (trips > 0 && height === lastHeight)) {
        window.scrollTo(0, 0);
        setTimeout(done, 200);
        return;
      }
      lastHeight = height;
      trips++;
      window.scrollTo(0, height);
      setTimeout(trip, 500);
    }
    trip();
  }

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
      // Focus first. An autocomplete only offers suggestions to a focused
      // field — aerolineas.com.ar's origin box took the value and showed
      // nothing until it had focus and a key event, both of which a person
      // typing produces without thinking.
      el.focus();
      setter.call(el, String(value));

      el.dispatchEvent(new InputEvent("input", { bubbles: true, inputType: "insertText", data: String(value) }));
      el.dispatchEvent(new Event("change", { bubbles: true }));
      el.dispatchEvent(new KeyboardEvent("keyup", { bubbles: true }));
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, value: el.value };
  };

  /*
   * What an autocomplete is offering right now.
   *
   * On aerolineas.com.ar typing "Buenos" into the origin field brings up
   * "Buenos Aires (BUE)", "Aeroparque (AEP)", "Ezeiza (EZE)", and the field
   * only counts as filled once one of them is picked. That list did not
   * exist in the native view, so the form could be typed into and never
   * completed. This reads the options the page is showing and stamps them,
   * so a pick can click the real one.
   */
  window.__jefSuggestions = function (fieldId) {
    const key = String(fieldId).replace(/"/g, "");
    const control = document.querySelector('[data-jef-field="' + key + '"]');
    if (!control) return { ok: false, reason: "gone" };

    // Only this field's list. The whole document would also return the
    // options another field left open: after picking a destination, the
    // departure date came back with the three airports.
    let scope = null;
    const controls = control.getAttribute("aria-controls") || control.getAttribute("aria-owns");
    if (controls) scope = document.getElementById(controls.split(/\s+/)[0]);
    if (!scope) scope = control.closest("[role=combobox]");
    for (let up = control.parentElement, depth = 0; !scope && up && depth < 4; up = up.parentElement, depth++) {
      if (up.querySelector("[role=listbox], [role=option]")) scope = up;
    }
    if (!scope) return { ok: true, suggestions: [] };

    const shown = Array.prototype.slice.call(
      scope.querySelectorAll("[role=option], [role=listbox] li, [role=listbox] > *")
    ).filter(function (o) {
      // Leaves only. A listbox nested in a listbox — react-autosuggest
      // wraps its <ul role=listbox> in a <div role=listbox> — read as one
      // option holding all three airports.
      return !isHidden(o) && textOf(o) && !o.querySelector("[role=option], li");
    });

    const suggestions = [];
    for (const option of shown) {
      if (suggestions.length >= 8) break;
      const label = textOf(option).slice(0, 120);
      if (suggestions.some(function (s) { return s.label === label; })) continue;
      option.setAttribute("data-jef-option", key + ":" + suggestions.length);
      suggestions.push({ index: suggestions.length, label: label });
    }
    return { ok: true, suggestions: suggestions };
  };

  /// Picks a suggestion the way a tap on it would.
  window.__jefChoose = function (fieldId, index) {
    const key = String(fieldId).replace(/"/g, "");
    const option = document.querySelector('[data-jef-option="' + key + ":" + parseInt(index, 10) + '"]');
    if (!option) return { ok: false, reason: "gone" };
    try {
      // react-autosuggest commits on mousedown; plain lists on click.
      for (const type of ["mousedown", "mouseup", "click"]) {
        option.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true }));
      }
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    const control = document.querySelector('[data-jef-field="' + key + '"]');
    // Done with this field: closing it is what stops the list from coming
    // back on the next re-extraction.
    if (control) control.blur();
    return { ok: true, value: control ? control.value : "" };
  };

  /// Submits the form that owns a control, preferring a real submit button
  /// over form.submit() — frameworks hang their handlers on the click, and
  /// form.submit() skips validation and those handlers entirely.
  /*
   * What identifies the document, as opposed to the state inside it.
   *
   * aerolineas.com.ar's "VUELOS" tab moves the URL from "/" to
   * "/?activeTab=searchBox" without leaving the page: same document, one node
   * different. Reported as a navigation, the native side threw away the live
   * WebView and reloaded from scratch, so the user watched a spinner and
   * landed back on the screen they were already on — and the tab state the
   * click had just produced was lost along with the WebView.
   *
   * A query string or a fragment is state inside a page. A different path or
   * origin is a different page.
   */
  function documentKey() {
    return location.origin + location.pathname;
  }

  /*
   * Leave the field before pressing anything.
   *
   * A person taps a button and, in doing so, leaves the field they were
   * typing in; the field commits on that blur. From the native view the tap
   * lands on a SwiftUI button and the DOM input keeps its focus, so a date
   * picker that commits on blur never saw the date — "Buscar vuelos" ran
   * with an empty return date and quietly did nothing.
   */
  function leaveField() {
    const active = document.activeElement;
    if (!active || active === document.body || typeof active.blur !== "function") return false;
    active.blur();
    return true;
  }

  /*
   * Presses a control the way a finger does: after leaving the field, and
   * not in the same instant. A date picker commits its value on blur inside
   * a setTimeout — so a click that lands in the same tick still sees the
   * form without the date. With a field to leave, the press waits 300 ms;
   * the re-extraction that follows waits for the DOM to settle anyway.
   */
  function press(el, left) {
    if (!left) { el.click(); return; }
    setTimeout(function () { try { el.click(); } catch (_) { /* gone */ } }, 300);
  }

  window.__jefSubmitForm = function (actionId) {
    const anchor = document.querySelector(
      '[data-jef-id="' + String(actionId).replace(/"/g, "") + '"]'
    );
    if (!anchor) return { ok: false, reason: "gone" };

    const left = leaveField();
    const form = anchor.tagName === "FORM" ? anchor : anchor.closest("form");
    const before = documentKey();

    try {
      // A real form submits as a form: requestSubmit(button) runs the
      // page's validation and submit handlers with that button as the
      // submitter, and does not care whether the button is on screen —
      // Google's "Buscar con Google" is not, on a phone.
      const isSubmitter = anchor.tagName !== "FORM"
        && anchor.matches("input[type=submit], button[type=submit], button:not([type])");
      // A type=button named after the field, in a form that has somewhere
      // to go, is the page's own Enter key: Google's "Buscar con Google"
      // is wired in JavaScript and only exists while the box is open, so
      // clicking it after leaving the field clicks nothing. Submitting the
      // form itself is what Enter does, and it does not need the button.
      const entersForm = anchor.tagName !== "FORM"
        && anchor.matches("button[type=button], [role=button]")
        && form && form.getAttribute("action");
      if (form && (isSubmitter || entersForm) && typeof form.requestSubmit === "function") {
        const fire = function () {
          try { isSubmitter ? form.requestSubmit(anchor) : form.requestSubmit(); }
          catch (_) { anchor.click(); }
        };
        if (left) setTimeout(fire, 300); else fire();
      } else if (anchor.tagName !== "FORM" && typeof anchor.click === "function") {
        press(anchor, left);
      } else if (form) {
        const submit = form.querySelector("[type=submit], button:not([type=button])");
        if (submit) press(submit, left);
        else form.requestSubmit ? form.requestSubmit() : form.submit();
      } else {
        return { ok: false, reason: "no-form" };
      }
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, navigated: documentKey() !== before, href: location.href };
  };

  window.__jefActivate = function (id) {
    const el = document.querySelector('[data-jef-id="' + String(id).replace(/"/g, '') + '"]');
    if (!el) return { ok: false, reason: "gone" };

    const left = leaveField();
    const before = documentKey();
    try {
      // scrollIntoView first: some frameworks only wire handlers to elements
      // once they enter the viewport.
      el.scrollIntoView({ block: "center" });
      press(el, left);
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, navigated: documentKey() !== before, href: location.href };
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

  function extractAndSend() {
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
    watchLateChanges();
  }

  /*
   * The page keeps changing after it was read.
   *
   * "Buscar vuelos" pushes its route, renders "Estamos buscando resultados
   * para vos…", and goes quiet while the API answers — long enough for the
   * extraction to fire and hand the reader a spinner as the page. The
   * prices arrive two seconds later, and nothing looks again.
   *
   * So every extraction leaves an observer behind for a while. A real
   * change — twenty nodes or more, not a ticker or an ad slot — followed by
   * the usual quiet is read again and delivered as a page that changed on
   * its own. Bounded: a few rounds per route, inside a short window, so a
   * page that never stops moving cannot keep the reader re-rendering.
   */
  const LATE_WINDOW_MS = 20000;
  const LATE_THRESHOLD = 20;
  const LATE_MAX_ROUNDS = 4;
  let lateObserver = null;
  let lateRounds = 0;
  let lateRoute = null;

  function watchLateChanges() {
    if (lateObserver) lateObserver.disconnect();
    if (lateRoute !== documentKey()) { lateRoute = documentKey(); lateRounds = 0; }
    if (lateRounds >= LATE_MAX_ROUNDS) return;

    // Weigh subtrees, not nodes. A framework builds the whole calendar
    // detached and appends its root: one added node carrying forty cells.
    function weight(nodes) {
      let total = 0;
      for (const node of nodes) {
        total += 1;
        if (node.nodeType === Node.ELEMENT_NODE) total += node.querySelectorAll("*").length;
      }
      return total;
    }

    let pending = 0;
    let quiet = null;
    const observer = new MutationObserver(function (records) {
      for (const record of records) pending += weight(record.addedNodes) + weight(record.removedNodes);
      if (pending < LATE_THRESHOLD) return;
      clearTimeout(quiet);
      quiet = setTimeout(function () {
        observer.disconnect();
        if (lateObserver === observer) lateObserver = null;
        lateRounds++;
        extractAndSend();
      }, 600);
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });
    lateObserver = observer;
    setTimeout(function () {
      if (lateObserver === observer) { observer.disconnect(); lateObserver = null; }
    }, LATE_WINDOW_MS);
  }

  /*
   * A single-page app navigates without loading a document.
   *
   * "Buscar vuelos" on aerolineas.com.ar answers a second or two after the
   * click by pushing "/flex-dates-calendar" onto the history and rendering
   * the results in place. By then the re-extraction that followed the click
   * had already run — the DOM had been quiet for 600 ms — and captured the
   * home page; with no document load, nothing ever looked again, and the
   * reader stayed on a search form while the page showed prices. So the
   * history is watched: a new path is a new page, extracted once it settles
   * and delivered like any other page that changed on its own.
   */
  (function watchRoutes() {
    let last = documentKey();
    function routeChanged() {
      if (documentKey() === last) return;
      last = documentKey();
      whenSettled(extractAndSend);
    }
    for (const method of ["pushState", "replaceState"]) {
      const original = history[method];
      if (typeof original !== "function") continue;
      history[method] = function () {
        const result = original.apply(this, arguments);
        setTimeout(routeChanged, 0);
        return result;
      };
    }
    window.addEventListener("popstate", function () { setTimeout(routeChanged, 0); });
  })();

  whenSettled(function () { wakeLazyContent(function () { whenSettled(extractAndSend); }); });
})();
