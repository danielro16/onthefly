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

  /*
   * Frames keep coming while unseen.
   *
   * WebKit stops requestAnimationFrame in a WebView that is not on screen,
   * and this one never is. React Helmet renames the document inside a
   * frame, so the title stayed "Calendario de vuelos" through a whole
   * purchase; anything else a site defers to the next frame stalls the
   * same way. While the document is hidden a frame is a 16 ms timeout,
   * which is what a frame is to code that only wants "soon".
   */
  (function keepFramesComing() {
    const nativeRequest = window.requestAnimationFrame;
    const nativeCancel = window.cancelAnimationFrame;
    if (typeof nativeRequest !== "function") return;
    window.requestAnimationFrame = function (callback) {
      if (document.visibilityState === "visible") return nativeRequest.call(window, callback);
      return window.setTimeout(function () { callback(window.performance.now()); }, 16);
    };
    window.cancelAnimationFrame = function (id) {
      window.clearTimeout(id);
      if (typeof nativeCancel === "function") nativeCancel.call(window, id);
    };
  })();

  /*
   * Transitions end at once while unseen.
   *
   * Same cause as the frames above: a WebView that is not on screen does
   * not advance a CSS transition either. lanacion.com.ar slides its
   * sections menu in; unseen, the slide never moved, so the panel was
   * there and its seventy links kept measuring nothing — the reader was
   * offered the panel as one giant button and none of the sections. With
   * no duration a transition is already over, which is where a person
   * finds it by the time they look.
   *
   * A constructed sheet, because a page's content policy can refuse a
   * <style> element; and only while hidden, so the original page still
   * moves the way its authors meant when the user asks to see it.
   */
  (function endTransitionsWhileUnseen() {
    if (typeof CSSStyleSheet !== "function" || !("adoptedStyleSheets" in document)) return;
    let sheet;
    try {
      sheet = new CSSStyleSheet();
      sheet.replaceSync(
        "*, *::before, *::after { transition-duration: 0s !important; transition-delay: 0s !important; " +
        "animation-duration: 0s !important; animation-delay: 0s !important; }"
      );
    } catch (_) {
      return;
    }
    function apply() {
      const others = Array.prototype.filter.call(document.adoptedStyleSheets, function (s) { return s !== sheet; });
      document.adoptedStyleSheets = document.visibilityState === "visible" ? others : others.concat([sheet]);
    }
    apply();
    document.addEventListener("visibilitychange", apply);
  })();

  const MAX_BLOCKS = 2000;
  // A calendar alone is 68 day buttons; with the cap at 40 the bar at the
  // bottom of the page — "Ver vuelos" — never made it in. Clusters mean Jev
  // judges a grid once, so the cap costs nothing to raise.
  const MAX_ACTIONS = 80;

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
  /// Text that fits, cut between words and marked as cut. A slice in the
  /// middle of a word read "Los dinosaurios que se comi" as the end of a
  /// headline.
  function clip(text, max) {
    if (text.length <= max) return text;
    const cut = text.slice(0, max);
    const space = cut.lastIndexOf(" ");
    return (space > max / 2 ? cut.slice(0, space) : cut).replace(/[\s,;:.\-–—]+$/, "") + "…";
  }

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
        // Code is not text. A Mercado Libre offer link carried its own
        // tracking script inside, and the name came out as "GLAM DAYS
        // PANTALONES ¡HASTA 40% OFF! Ver ofertas, var trackMclicks =…".
        // A screen reader never reads these.
        if (child.tagName === "SCRIPT" || child.tagName === "STYLE" ||
            child.tagName === "NOSCRIPT" || child.tagName === "TEMPLATE") continue;
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
    // The first class only. Styled-components put the component's name
    // first and a hash of its props second, so the highlighted card in a
    // row ("¡La mejor tarifa!") differed from its six siblings and the row
    // fell under the similarity bar.
    const cls = String(el.className || "").split(/\s+/).slice(0, 1).join(".");
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
          let chunk = (child.textContent || "").replace(/\s+/g, " ");
          // A space already there is enough. Wikipedia writes "301&nbsp;%"
          // with the nbsp in its own span, and the break added for the span
          // plus the nbsp read "301  %" — two spaces the ear hears as a pause.
          if (/\s$/.test(text) && chunk.startsWith(" ")) chunk = chunk.slice(1);
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

    // The offsets were measured before trimming. A paragraph that opens with
    // a line break had every link shifted by it: "Buscar con DNI" came out
    // linked from its second letter to three past its end.
    const lead = text.length - text.replace(/^\s+/, "").length;
    const trimmed = text.trim();
    const kept = [];
    for (const link of merged) {
      const start = Math.max(0, link.start - lead);
      const end = Math.min(trimmed.length, link.end - lead);
      if (end > start) kept.push({ start: start, end: end, href: link.href });
    }

    return { text: trimmed, links: kept };
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

    // A list of links laid out with a table — a search engine's results, an
    // old site's menu — is not data either. Kept as a table, its links were
    // lost inside the cells: DuckDuckGo's results reached the assistant as
    // "Tabla de 33 filas", and it said there were no results. With no
    // headers, no caption, and a link in at least one row out of four, the
    // walk goes inside instead and the links come out as links.
    if (headerIndex < 0 && !caption && !keyValue) {
      let linkRows = 0;
      for (const row of rows) {
        if (row.querySelector("a[href]:not([href^='#']):not([href^='javascript'])")) linkRows++;
      }
      if (linkRows >= 3 && linkRows * 4 >= body.length) return null;
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
  /// Ids are handles the native side holds on to, so a node keeps the id
  /// it was given for as long as it lives. Numbering restarts per run used
  /// to shift every id whenever a re-extraction saw one control more or
  /// less — and a re-extraction that reads as the same page is not shown,
  /// so the reader kept the old ids: "Opciones de Nacionalidad" opened the
  /// list of days. Nothing is cleared here: option stamps used to be, and
  /// a list of thirty-one days opening was itself enough change for the
  /// observer to re-extract and unstamp the options before the pick.
  // Counting on from any stamps already in the document: a second copy of
  // this script in the same document (the test harness, a restored page)
  // must not hand out ids the first one gave to other nodes.
  function highestStamp(attr, prefix) {
    let highest = -1;
    for (const el of document.querySelectorAll("[" + attr + "]")) {
      const m = new RegExp("^" + prefix + "(\\d+)").exec(el.getAttribute(attr) || "");
      if (m) highest = Math.max(highest, parseInt(m[1], 10));
    }
    return highest + 1;
  }
  let nextActionId = highestStamp("data-jef-id", "a");
  let nextFieldId = highestStamp("data-jef-field", "f");
  let nextChoiceId = highestStamp("data-jef-id", "o");

  function priorId(element, attr, prefix) {
    const prior = element ? element.getAttribute(attr) || "" : "";
    return new RegExp("^" + prefix + "\\d+$").test(prior) ? prior : null;
  }

  function collectActions(excluded) {
    const actions = [];
    const seen = new Set();
    const stamped = [];
    // "Botón sin nombre" is a last resort, and a page full of them is
    // worse than a page without them.
    let unnamed = 0;
    // Controls the cap left out. Reported, never silent.
    let dropped = 0;
    // Elements this run has reported. Not the stamp: a stamp now outlives
    // the run that set it.
    const reported = new Set();

    /*
     * Chrome that is never a user task. Measured against a real airline home
     * page, where a consent banner and a carousel ate 7 of the 40 slots and
     * pushed real tasks past the cap.
     */
    const NOISE = [
      /^\d+$/,                                        // carousel dots
      // Cookie consent only — the overlay reports those as its choices. A
      // bare "Aceptar" is a confirm button, and the fare warning's one was
      // being thrown away with the banners'.
      /^(aceptar|accept|rechazar|reject|permitir|allow)\b.*(cookie|esencial|essential|todas|all)/i,
      // "Cerrar" is NOT here on purpose. An overlay's own controls are
      // already excluded, so the only close buttons that reach this list
      // belong to modals we failed to detect — and there, closing is the
      // one way out. Discarding it turned the modal into a trap.
      /^(ok|got it|entendido)\b/i,
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
      // A control with no accessible name is the site's bug, and the "×"
      // that closes a modal is usually one of them. Discarding it made the
      // modal a trap. Ambiguous is bad; missing is worse.
      //
      // A lone glyph counts as no name: "×" is a drawing of a cross, and a
      // screen reader says "multiplicación" or nothing at all.
      const nameless = !action.label || LONE_GLYPH.test(action.label);
      if (nameless && action.kind === "button" && element) {
        // No guessing here with the words of one language ("account" →
        // "Mi cuenta", always in Spanish). The assistant names it: Jev picks
        // its kind from these hints, the name comes in the person's
        // language, and window.__jefName writes it back into the page.
        const hints = controlHints(element);
        if (!hints || unnamed >= 8) return;
        unnamed++;
        action.label = "";
        action.unnamed = true;
        action.hints = hints;
      }
      if (!action.unnamed && (!action.label || isNoise(action.label))) return;
      // Controls the overlay owns are reported as its choices, not as page
      // actions. Listing them twice would also mean stamping one element with
      // two ids, and the second stamp wins: the action becomes unpressable.
      if (excluded && element && excluded.contains(element)) return;
      if (element && reported.has(element)) return;
      // Same label twice is the same link to a user, however the markup
      // differs (mobile nav duplicating desktop nav is the usual culprit).
      // Not so for buttons: "Desde 81.987 ARS" sits on three different
      // flights, and deduplicating it left two of them with nothing to
      // press.
      const key = action.kind === "button" ? null : action.kind + "|" + action.label.toLowerCase();
      if (key && seen.has(key)) return;
      // Past the cap, a control is not reported and nobody could tell. Counted
      // so the reader can say it out loud: a number the person can act on
      // beats a silence they cannot.
      if (actions.length >= MAX_ACTIONS) { dropped++; return; }
      if (key) seen.add(key);
      action.id = priorId(element, "data-jef-id", "a") || "a" + nextActionId++;
      // Stamp the live element so it can be found again later.
      //
      // A button's behaviour lives in the page's own JavaScript, so the native
      // UI cannot press it — it has to ask this element to click itself. A CSS
      // selector would break on any re-render; an attribute survives until the
      // node is replaced, and a node keeps the id it was first given.
      if (element) {
        reported.add(element);
        element.setAttribute("data-jef-id", action.id);
        // Never seen by any extraction of this document: what the last tap
        // made appear. Unlike the id, this mark is not cleared, so a second
        // "Comprar" — the one inside the modal that "Comprar" opened — is
        // new even though its label is not.
        action.fresh = !element.hasAttribute("data-jef-seen");
        element.setAttribute("data-jef-seen", "1");
      }
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
      // Every id it points at, joined, which is what a screen reader says.
      // Taking only the first dropped half the name of the commonest pattern
      // there is: a label and its unit, or a title and its price, written as
      // two elements and tied together with one attribute.
      const named = namedBy(el);
      if (named) return named;
      const text = dedupeSegments(textOf(el));
      if (text) return text;
      const pictured = imageName(el);
      if (pictured) return pictured;
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

      // A heading names the form only from before its first field: the
      // checkout's only heading was an upsell ("¡Mejorá la experiencia de
      // tu vuelo!") sitting after the passenger's fields. With no heading
      // there, the first short line before the first field is the name —
      // "Datos de pasajero/ra", the accordion the form lives in.
      const firstControl = form.querySelector("input:not([type=hidden]), select, textarea");
      const precedes = function (el) {
        return !firstControl || !!(el.compareDocumentPosition(firstControl) & Node.DOCUMENT_POSITION_FOLLOWING);
      };
      const heading = Array.prototype.find.call(
        form.querySelectorAll("h1, h2, h3, h4, [role=heading]"), function (h) { return precedes(h) && textOf(h); }
      );
      if (heading) return textOf(heading);
      if (firstControl) {
        const walker = document.createTreeWalker(form, NodeFilter.SHOW_TEXT);
        for (let node = walker.nextNode(); node && precedes(node); node = walker.nextNode()) {
          const t = (node.textContent || "").replace(/\s+/g, " ").trim();
          if (t && t.length <= 60 && node.parentElement && !isHidden(node.parentElement)) return t;
        }
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
    /// The validation message a control carries, if any: what
    /// aria-describedby / aria-errormessage point at when the control says
    /// aria-invalid, or an alert beside it.
    function fieldError(control) {
      if (control.getAttribute("aria-invalid") !== "true") return "";
      const ids = ((control.getAttribute("aria-errormessage") || "") + " " + (control.getAttribute("aria-describedby") || "")).split(/\s+/).filter(Boolean);
      for (const id of ids) {
        const el = document.getElementById(id);
        const text = el && !isHidden(el) ? textOf(el) : "";
        if (text) return text.slice(0, 200);
      }
      for (let up = control.parentElement, depth = 0; up && depth < 3; up = up.parentElement, depth++) {
        const alert = up.querySelector("[role=alert], [class*=error], [class*=invalid]");
        const text = alert && !isHidden(alert) ? textOf(alert) : "";
        if (text) return text.slice(0, 200);
      }
      return "";
    }

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
        // A checkout is long: the passenger form has 25 controls, and the
        // email — the one it will not go on without — came after the cap.
        if (fields.length >= 40) break;

        const groupName = control.getAttribute("name") || "";

        if (type === "radio" && groupName) {
          if (!radioGroups.has(groupName)) {
            const priorGroup = (control.getAttribute("data-jef-field") || "").split(":")[0];
            const fieldId = /^f\d+$/.test(priorGroup) ? priorGroup : "f" + nextFieldId++;
            const field = {
              id: fieldId,
              // The group's name comes from its fieldset, not from any one
              // option — "Pizza Size", not "Small".
              name: (function () {
                const fs = control.closest("fieldset");
                const legend = fs ? fs.querySelector("legend") : null;
                if (legend) return textOf(legend);
                const group = control.closest("[role=radiogroup]");
                const aria = (group ? group.getAttribute("aria-label") || "" : "").trim();
                // Not an aria-label that is the field's internal name —
                // aria-label="phone_type" sat right after a label saying
                // "Teléfono".
                if (aria && !looksLikeCode(aria)) return aria;
                // The label a sighted person reads sits just before the
                // group: "Género", "Teléfono" — not "phone_type".
                for (let up = group || control.parentElement, depth = 0; up && depth < 4; up = up.parentElement, depth++) {
                  const prev = up.previousElementSibling;
                  if (!prev || !/^(LABEL|H[1-6]|LEGEND)$/.test(prev.tagName)) continue;
                  const t = labelText(prev);
                  if (t && t.length <= 40) return t;
                }
                return groupName;
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

        const fieldId = priorId(control, "data-jef-field", "f") || "f" + nextFieldId++;
        control.setAttribute("data-jef-field", fieldId);

        // What the page declares the field holds, by the HTML standard
        // (WHATWG autofill tokens): the same in every language.
        const autocomplete = (control.getAttribute("autocomplete") || "").trim().toLowerCase();
        const field = {
          id: fieldId,
          name: name.trim(),
          type: control.tagName === "SELECT" ? "select"
              : control.tagName === "TEXTAREA" ? "textarea"
              : type,
          required: control.hasAttribute("required"),
          // A password or a card number never leaves the page, not even
          // into our own model of it.
          value: type === "checkbox" ? (control.checked ? "on" : "")
              : isSecret(type, autocomplete) ? ""
              : (control.value || ""),
        };
        if (autocomplete) field.autocomplete = autocomplete;
        if (isSecret(type, autocomplete)) field.secret = true;
        // A search box, by the standard: its type, the key its keyboard
        // shows, or the search landmark it sits in.
        if (type === "search" || /^search$/i.test(control.getAttribute("enterkeyhint") || "")
            || /^search$/i.test(control.getAttribute("inputmode") || "")
            || control.closest("[role=search], search")) field.search = true;

        // What the page holds against the field. The checkout's "Siguiente"
        // did nothing audible: the email was missing, the message sat
        // beside the box, and the reader heard the same page again.
        const complaint = fieldError(control);
        if (complaint) field.error = complaint;

        // A combobox — react-select's "Día", "Mes", "Año" on the checkout —
        // keeps what was chosen beside the input, not in it, and shows its
        // whole list on ArrowDown. A read-only input that opens a picker
        // when pressed is the same thing to the person: open it, pick one.
        if (control.tagName === "INPUT" && type === "text" && (
          control.getAttribute("aria-autocomplete") === "list" ||
          control.getAttribute("role") === "combobox" ||
          control.hasAttribute("readonly")
        )) {
          field.type = "combobox";
          field.value = displayedValue(control);
        }

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
        notices: noticesOf(form, submit || form),
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
        notices: noticesOf(entry.box, entry.submit),
        region: regionOf(entry.box),
      }, entry.submit);
    }

    /*
     * The button in the bar pinned to the bottom of the screen is the
     * page's own answer to "and now what?": "Ver vuelos" under the total,
     * "Agregar al carrito", "Pagar". Its words vary; its place does not. A
     * sighted person's thumb finds it without reading; a screen reader
     * finds it forty stops later, in whatever group the words fell into.
     */
    function inBottomBar(el) {
      for (let n = el.parentElement; n && n !== document.body; n = n.parentElement) {
        const style = window.getComputedStyle(n);
        if (style.position !== "fixed" && style.position !== "sticky") continue;
        const rect = n.getBoundingClientRect();
        return rect.bottom >= window.innerHeight - 8 && rect.height < window.innerHeight * 0.35;
      }
      return false;
    }

    const buttons = Array.prototype.slice.call(document.querySelectorAll(
      "button, [role=button], input[type=submit], input[type=button]"
    )).filter(function (button) {
      if (isHidden(button) || isUntouchable(button)) return false;
      // A disabled button is not an action; offering it reads as a control
      // that does nothing. When the page enables it, the next extraction
      // picks it up.
      if (button.disabled || button.getAttribute("aria-disabled") === "true") return false;
      // A "button" that holds other controls is a container with the wrong
      // role. lanacion.com.ar wraps its whole sections menu — seventy links
      // and a search box — in <div role="button">: reported, it was one
      // control named after every word inside it ("overlay, Buscar en LA
      // NACION, Buscar por voz, Últimas noticias, Política…"), and pressing
      // it closed the menu. What it holds is reported on its own.
      if (button.querySelectorAll("a[href], button, [role=button], input:not([type=hidden]), select, textarea").length >= 2) return false;
      // Ya reportado como el botón de envío de su formulario.
      //
      // Sólo ése. Un formulario puede tener varios submit y el login de un
      // diario los usa para lo que más se usa: "Iniciar sesión con Google",
      // "con Facebook", "con Apple" son los tres type=submit del mismo form
      // que el de "INICIAR SESIÓN". Descartarlos a todos dejaba una página de
      // ingreso con una sola forma de ingresar — menos de lo que la página
      // original ofrece, que es lo único que esta app no puede hacer.
      if (button.closest("form") && button.matches("[type=submit]")) {
        const form = button.closest("form");
        const label = (labelFor(button) || "").trim().toLowerCase();
        const twin = Array.prototype.slice
          .call(form.querySelectorAll("[data-jef-id]"))
          .some(function (el) {
            return (labelFor(el) || "").trim().toLowerCase() === label;
          });
        if (twin) return false;
      }
      return !reported.has(button);
    });
    // The bottom bar first: it is last in the DOM, and a page of sixty day
    // buttons hit the cap before it.
    buttons.sort(function (a, b) { return (inBottomBar(b) ? 1 : 0) - (inBottomBar(a) ? 1 : 0); });
    for (const button of buttons) {
      const label = labelFor(button) || button.getAttribute("value") || "";
      const action = { kind: "button", label: label, region: regionOf(button) };
      if (inBottomBar(button)) action.primary = true;
      push(action, button);
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
      // A link with no destination of its own is a button in a link's
      // clothes: "Secciones" on lanacion.com.ar is <a href="#"> and opens
      // the site's menu from JavaScript; "SUSCRIBITE" is <a href="#promo">
      // and opens a panel. Sent as an address, the first reloaded the front
      // page and the second did too — and the click handler that does the
      // real work never ran. Without an href the native side presses it
      // inside the page, like any other control.
      const raw = (link.getAttribute("href") || "").trim();
      if (!opensAnotherPage(raw)) {
        push({ kind: "link", label: labelFor(link), region: regionOf(link) }, link);
        continue;
      }
      const href = absolute(raw);
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

    actions.droppedCount = dropped;
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
    if (el.closest("[inert]")) return true;
    // The browser's own answer, which knows about content-visibility, an
    // ancestor at opacity 0, and every other way a page can make something
    // invisible while leaving its box in place. Our hand-rolled version read
    // only the element's own display and size, so a control faded out to
    // nothing was still offered as an action.
    if (typeof el.checkVisibility === "function") {
      if (!el.checkVisibility({ checkOpacity: true, checkVisibilityCSS: true })) return true;
    } else {
      const style = window.getComputedStyle(el);
      if (style.display === "none" || style.visibility === "hidden") return true;
    }
    const rect = el.getBoundingClientRect();
    if (rect.width < 2 || rect.height < 2) return true;
    return false;
  }

  /*
   * A control nobody can touch, however visible it looks.
   *
   * Measured on fravega.com: 137 of its 141 visible buttons carry
   * `pointer-events: none`. A finger cannot reach them and neither can a
   * click — offering them means a person hears an option, activates it, and
   * nothing happens. Asked of the element and its ancestors, because the
   * property inherits and a page usually sets it on the wrapper.
   */
  function isUntouchable(el) {
    for (let node = el; node && node !== document.documentElement; node = node.parentElement) {
      const events = window.getComputedStyle(node).pointerEvents;
      if (events === "none") return true;
      // An explicit value on a child overrides the parent's none.
      if (events && events !== "none") return false;
    }
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
      // When the items ARE the buttons — a calendar's days, greyed out or
      // not — the row is an action set, already reported, not a list of
      // things. A card that merely holds a button (a flight with its price,
      // a product with "Agregar") is still a card: its text says far more
      // than its button.
      // Rows of a form — "Nombre, Apellido", "Fecha de Nacimiento" — are
      // the form, already offered as its fields, not a list of things.
      const formish = matching.filter(function (k) {
        return k.querySelector("input:not([type=hidden]), select, textarea");
      });
      if (formish.length >= matching.length * 0.5) continue;

      const pressable = matching.filter(function (k) {
        if (k.matches("button, [role=button], a[href]")) return true;
        const button = k.querySelector("[data-jef-id], button[disabled], [aria-disabled=true]");
        if (!button) return false;
        return textOf(k).length <= textOf(button).length + 12;
      });
      if (pressable.length >= matching.length * 0.5) continue;

      // A row of short, unlinked tokens is a header or a legend — the
      // weekday initials over a calendar — not a list of things.
      const linked = matching.some(function (k) { return k.tagName === "A" || k.querySelector("a[href]"); });
      if (!linked && matching.every(function (k) { return textOf(k).length <= 12; })) continue;

      // A card made of nothing but links, and carrying several, is not one
      // thing: it is a column of a menu. The BCRA's read as five items
      // called "Tasas de interés, Datos monetarios diarios, Metodologías
      // de las estadísticas monetarias y financieras" — three destinations
      // in one unreachable stop. Each link is its own item.
      const columns = matching.filter(function (k) {
        if (k.querySelectorAll("a[href]").length < 2) return false;
        const clone = k.cloneNode(true);
        for (const link of clone.querySelectorAll("a[href]")) link.remove();
        return !textOf(clone);
      });
      if (columns.length >= matching.length * 0.5) {
        const links = [];
        for (const column of matching) {
          for (const link of column.querySelectorAll("a[href]")) {
            if (!isHidden(link) && textOf(link)) links.push(link);
          }
        }
        if (links.length >= MIN_ITEMS) {
          candidates.push({ container: container, items: links });
          continue;
        }
      }

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

    // Where each listing sits, so the ordered stream can put it in its place.
    const containers = new Map();

    const listings = kept.slice(0, 4).map(function (candidate, index) {
      containers.set("L" + index, candidate.container);
      return {
        id: "L" + index,
        title: listingTitle(candidate.container),
        count: candidate.items.length,
        items: candidate.items.slice(0, 30).map(itemOf),
      };
    });

    // The same list twice — a mobile page carries its nav for two layouts —
    // is one list. Same first three titles, same list.
    const signatures = new Set();
    for (let i = listings.length - 1; i >= 0; i--) {
      const key = listings[i].items.slice(0, 3).map(function (it) { return it.title; }).join("|");
      if (signatures.has(key)) listings.splice(i, 1);
      else signatures.add(key);
    }

    // Cards the shape detector missed, minus anything already listed.
    const taken = new Set();
    for (const listing of listings) for (const item of listing.items) if (item.href) taken.add(item.href);
    // Numbered past the four the shape detector can hand out: counting from
    // `listings.length` gave a card group the id of a listing that survived
    // the de-duplication above.
    collectCards(taken).slice(0, 2).forEach(function (group, index) {
      const id = "L" + (4 + index);
      containers.set(id, group.container);
      listings.push({
        id: id,
        title: listingTitle(group.container),
        count: group.items.length,
        items: group.items.slice(0, 30),
      });
    });

    // A stamp per run: a listing dropped since the last reading must not
    // keep its place. Loose cards gathered under <body> have no place.
    for (const el of document.querySelectorAll("[data-jef-listing]")) el.removeAttribute("data-jef-listing");
    for (const listing of listings) {
      const container = containers.get(listing.id);
      if (container && container !== document.body) container.setAttribute("data-jef-listing", listing.id);
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
      byParent.get(parent).push({ title: clip(title, 200), href: href, meta: meta });
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
  const PRICE = /(?:US\s*\$|AR\s*\$|\$|€|£|R\$)\s?(?:\d{1,3}(?:[.,]\d{3})+|\d+)(?:[.,]\d{1,2})?(?![\d.,]\d)|(?:\d{1,3}(?:[.,]\d{3})+|\d+)(?:[.,]\d{1,2})?\s?(?:ARS|USD|EUR|BRL|CLP|MXN|COP|PEN|UYU)\b|\b(?:ARS|USD|EUR|BRL|CLP|MXN|COP|PEN|UYU)\s?(?:\d{1,3}(?:[.,]\d{3})+|\d+)(?:[.,]\d{1,2})?(?![\d.,]\d)/;

  /// Card text minus what was already said, without the pauses that
  /// removal leaves behind: ", , $749.999 6, , Precio" is three pauses for
  /// nothing.
  function tidy(text) {
    return text.replace(/\s+/g, " ").replace(/(\s*,\s*)+/g, ", ").replace(/^,\s*|,\s*$/g, "").trim();
  }

  /// Text leaves of a card, in reading order. A button or a link inside
  /// the card is one leaf, whatever it is made of: "Desde 81.987 ARS", not
  /// "Desde", "81.987", "ARS".
  /// The name an image gives the element it sits in: a button that is
  /// only a Visa logo is called "Visa" by its alt, and by nothing else.
  function imageName(el) {
    const img = el.querySelector("img[alt], [role=img][aria-label]");
    if (img) {
      const alt = (img.getAttribute("alt") || img.getAttribute("aria-label") || "").trim();
      if (alt) return alt;
    }
    const title = el.querySelector("svg > title");
    return title ? (title.textContent || "").trim() : "";
  }

  /// The card's lines, in order: each control as one, and each element
  /// that has text of its own as one. "1 <span>Cuota</span> sin interés"
  /// is one line, not the lone word "Cuota" — the outer span's own text
  /// used to be dropped because the span had a child.
  function leavesOf(el) {
    const out = [];
    (function walk(parent) {
      for (const node of parent.children) {
        // Controls first: BUTTON is a skipped tag for prose, and a card's
        // fare buttons are lines of the card.
        if (node.matches("button, a[href], [role=button]")) {
          const text = textOf(node) || imageName(node);
          if (text) out.push({ node: node, text: text });
          continue;
        }
        if (SKIP_TAGS.has(node.tagName)) continue;
        const ownText = Array.prototype.some.call(node.childNodes, function (n) {
          return n.nodeType === Node.TEXT_NODE && (n.textContent || "").trim();
        });
        if (!node.children.length || ownText) {
          const text = textOf(node);
          if (text) out.push({ node: node, text: text });
          continue;
        }
        walk(node);
      }
    })(el);
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
    // The first heading a person can see. Google opens a result that has
    // links to its site's sections with a heading only screen readers get
    // — "Resultado web con vínculos a sitio", clipped to one pixel — and it
    // became the result's title, with the site nowhere.
    const heading = Array.prototype.find.call(
      el.querySelectorAll("h1,h2,h3,h4,h5,h6,[role=heading]"),
      function (h) { return !isHidden(h); }
    );
    const link = el.querySelector("a[href]");
    const image = el.querySelector("img");
    const text = textOf(el);
    const leaves = leavesOf(el);

    // A product card has no heading, and its link wraps the whole card, so
    // the link's text is everything at once. The name is the first line of
    // text that is not a price.
    // Leaves spoken for by the title (and, below, the price) stay out of
    // the rest: replacing the title's string in the card's text missed
    // whenever the two were joined differently, and the rest repeated it.
    const used = new Set();
    let title = "";
    if (heading) {
      title = textOf(heading);
      for (const leaf of leaves) if (heading.contains(leaf.node)) used.add(leaf.node);
    }
    if (!title && link) {
      const linkText = textOf(link);
      if (linkText.length < text.length - 20 || linkText.length <= 80) {
        // A link that wraps headline, summary and section together: the
        // headline is its first real line. Taken whole, a Clarín card read
        // "…dos millones de personas, La Secretaría de Energía informó…".
        const first = linkText.length > 100
          ? leaves.find(function (leaf) { return link.contains(leaf.node) && leaf.text.length >= 25; })
          : null;
        if (first) {
          title = first.text;
          used.add(first.node);
        } else {
          title = linkText;
          for (const leaf of leaves) if (link.contains(leaf.node)) used.add(leaf.node);
        }
      }
    }
    if (!title) {
      // What the card says, minus what its buttons say: "Ver itinerario"
      // names an action, not a flight.
      const said = leaves.filter(function (leaf) {
        return !leaf.node.closest("button, a[href], [role=button]") && !PRICE.test(leaf.text);
      });
      // The longest of the first few lines: a news card opens with a
      // two-word kicker ("Farmear aura") above the headline, a product card
      // with its name above the prices. When no line says much on its own
      // — a flight is "Domingo", "07:00", "AEP", "1h 30m" — the lines
      // together are the name.
      const first = said.slice(0, 4);
      const longest = first.reduce(function (best, leaf) { return leaf.text.length > best.text.length ? leaf : best; }, { text: "" });
      if (longest.text.length >= 20) {
        title = longest.text;
        used.add(longest.node);
      } else {
        let joined = "";
        for (const leaf of said) {
          if (joined.length + leaf.text.length > 80) break;
          joined += (joined ? " " : "") + leaf.text;
          used.add(leaf.node);
        }
        title = joined || clip(text, 80);
      }
    }

    const item = { title: clip(title, 200) };
    if (link) {
      const href = absolute(link.getAttribute("href") || "");
      if (href) item.href = href;
      // The web address the link shows, when it shows one. A search
      // engine's result goes through the engine's own redirect, and the
      // site is only in what the link says: "ANSES https://www.anses.gob.ar".
      const address = textOf(link).match(/https?:\/\/[^\s,›]+/);
      if (address && title.indexOf(address[0]) === -1) item.shown = address[0];
    }
    // A card with no link but a button — "Desde 81.987 ARS" on a flight —
    // opens by pressing that button: the one that names the price, or the
    // last one, which is where a card keeps its choice. The first was "Ver
    // itinerario", and picking a flight opened its map instead.
    if (!item.href) {
      const buttons = Array.prototype.slice.call(el.querySelectorAll("[data-jef-id]"));
      const priced = buttons.find(function (b) { return PRICE.test(textOf(b)); });
      // Several buttons and no price: the card is a choice among them —
      // "1 Cuota sin interés" with Visa, American Express and Mastercard
      // to pick from. Each is offered on the card, none is the card.
      if (!priced && buttons.length > 1) {
        item.choices = buttons.slice(0, 8).map(function (b) {
          used.add(b);
          return { id: b.getAttribute("data-jef-id"), label: (textOf(b) || imageName(b)).slice(0, 60) };
        }).filter(function (c) { return c.label; });
      } else {
        const chosen = priced || buttons[buttons.length - 1];
        if (chosen) item.actionId = chosen.getAttribute("data-jef-id");
      }
    }

    // A card that opens by its link can still hold buttons of its own —
    // "Guardar" on every recipe of foodit.lanacion.com.ar. They belong to
    // the card: listed apart, fifteen rows reading "Guardar" say nothing
    // about what each one saves.
    if (item.href) {
      const extras = Array.prototype.slice.call(el.querySelectorAll("[data-jef-id]"), 0, 4).map(function (b) {
        return { id: b.getAttribute("data-jef-id"), label: (labelOf(b) || imageName(b)).slice(0, 60) };
      }).filter(function (extra) { return extra.label; });
      if (extras.length) item.extras = extras;
    }

    // Currency, because on a product card the price is the point — the
    // price it is now, not the one struck through above it.
    let priceMatch = null;
    for (const leaf of leaves) {
      const m = leaf.text.match(PRICE);
      if (m && !isStruck(leaf.node)) { priceMatch = m; used.add(leaf.node); break; }
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

    // Whatever else the card says, minus the title and price we already
    // have. A button's words describe the card only when they carry a
    // number: "Plus 232.244 ARS" says something about the flight, "Ver
    // itinerario" and "Comparar condiciones" only name what pressing does.
    let rest = leaves.length
      ? leaves.filter(function (leaf) {
          if (used.has(leaf.node)) return false;
          return !leaf.node.matches("button, a[href], [role=button]") || PRICE.test(leaf.text);
        }).map(function (leaf) { return leaf.text; }).join(", ")
      : text.replace(title, "");
    if (item.price) rest = rest.replace(item.price, "");
    rest = tidy(rest);
    if (rest) item.meta = rest.slice(0, 200);

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
    // Nor is a menu. The sections panel of lanacion.com.ar is pinned, on
    // top and as tall as the screen — and it is seventy links, which no
    // notice is. Read as an overlay it came out as "Contenido para
    // suscriptores" (one of its links says so) with eight answers, and the
    // other sixty sections were thrown away with it.
    //
    // Told apart by shape, not by words. Measured on 56 sites in 14
    // languages: the menus had 27 to 243 links, the notices 15 at most —
    // Le Monde's consent with its partners, Jack Daniel's age gate with its
    // countries. Fewer links make a menu only in a navigation landmark with
    // nothing to answer: Jägermeister's age gate carries a nav of five links
    // and a form, and it was being skipped as a menu.
    function isMenu(el) {
      const links = el.querySelectorAll("a[href]").length;
      if (links >= 20) return true;
      if (links < 5) return false;
      const nav = !!(el.matches("nav, [role=navigation]") || el.querySelector("nav, [role=navigation]"));
      const answers = Array.prototype.some.call(
        el.querySelectorAll("button, [role=button], input:not([type=hidden]), select, textarea"),
        function (c) { return !isHidden(c); });
      return nav && !answers;
    }
    for (const el of document.querySelectorAll("[role=dialog], [role=alertdialog], [aria-modal=true], dialog[open]")) {
      if (!isHidden(el) && !isPopupList(el) && !isMenu(el)) candidates.push(el);
    }

    // Undeclared ones: fixed or sticky boxes large enough to block, which is
    // how most cookie banners and paywalls are actually built.
    const viewportArea = window.innerWidth * window.innerHeight;
    for (const el of document.body.querySelectorAll("div, section, aside")) {
      if (candidates.indexOf(el) !== -1) continue;
      const style = window.getComputedStyle(el);
      if (style.position !== "fixed" && style.position !== "sticky") continue;
      if (isHidden(el)) continue;
      // Modals do not all climb to z-index 100: the fare warning sat lower
      // and read as prose with its buttons scattered. Anything pinned, on
      // top, and a fifth of the screen is in the way.
      const zIndex = parseInt(style.zIndex, 10) || 0;
      if (zIndex < 10) continue;
      const rect = el.getBoundingClientRect();
      if (rect.width * rect.height < viewportArea * 0.2) continue;
      if (isPopupList(el) || isMenu(el)) continue;
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
      const id = priorId(control, "data-jef-id", "o") || "o" + nextChoiceId++;
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
        // That something covers the page, by its shape. What it asks —
        // cookies, a subscription, an age — Jev says from its text and its
        // buttons, in any language (`aviso` in criterios.json). A list of
        // words did it here: 17 of 22 real notices, none in Polish, Dutch or
        // Arabic, and LinkedIn's sign-in wall read as cookies. Jev: 22.
        kind: "other",
        text: text.slice(0, 400),
        choices: choices,
        links: links,
      },
    };
  }

  /// What `aria-labelledby` names, in order, with every id it points at.
  /// Guards against a cycle: a label that points back at its own control.
  function namedBy(el, seen) {
    const ids = (el.getAttribute("aria-labelledby") || "").trim();
    if (!ids) return "";
    seen = seen || new Set();
    if (seen.has(el)) return "";
    seen.add(el);
    const parts = [];
    for (const id of ids.split(/\s+/)) {
      const target = document.getElementById(id);
      if (!target || seen.has(target)) continue;
      const text = namedBy(target, seen) || (target.getAttribute("aria-label") || "").trim() || textOf(target);
      if (text) parts.push(text);
    }
    return parts.join(" ");
  }

  /// Label resolution that works outside collectActions' closure.
  function labelOf(el) {
    const aria = el.getAttribute("aria-label");
    if (aria && aria.trim()) return aria.trim();
    const named = namedBy(el);
    if (named) return named.slice(0, 60);
    const text = textOf(el);
    if (text) return text.slice(0, 60);
    const title = el.getAttribute("title");
    return title ? title.trim() : "";
  }

  /// A drawing, not a word. "×" is a picture of a cross, and a screen reader
  /// says "multiplicación" or nothing at all — so it counts as no name.
  ///
  /// Letters are in here on purpose: on a BUTTON, a lone "x" is a close
  /// cross. That is a fact about control labels and about nothing else —
  /// see DECORATION for why it must not be used on running text.
  const LONE_GLYPH = /^[\s×✕✖✗xX+−·•–—<>‹›«»←-⇿✀-➿]{1,2}$/;

  /// Punctuation standing alone in the middle of prose: a bullet between two
  /// dates, a carousel's dots, a pipe between links.
  ///
  /// No letters. Reusing LONE_GLYPH here silenced eleven spans reading "XX"
  /// in the Spanish Wikipedia — the century, not a pair of crosses. A rule
  /// about buttons applied to prose deletes the prose.
  const DECORATION = /^[\s·•‣▪▫◦※|¦+−–—‒―×✕✖✗<>‹›«»↑↓←→⇑⇓⇐⇒★☆♦◆▲▼✦✧]{1,2}$/;

  /*
   * The words a page hides around its own icons.
   *
   * Measured on fravega.com: 126 of its controls have no accessible name,
   * and every one of them is an inline <svg> inside a button whose classes
   * are generated — `sc-gJCZQp bsaTbk` says nothing about anything. But the
   * naming is usually there, one attribute away from where a screen reader
   * looks: a `data-testid`, a sprite reference like `<use href="#icon-cart">`,
   * or an `alt` sitting on the <svg> itself, which is not a real attribute
   * and so is read by nobody.
   *
   * None of this is authoritative. It feeds the guess, which is still only
   * used when the page left no name at all.
   */
  function iconHint(element) {
    const parts = [];
    for (const attr of ["data-testid", "data-test", "data-qa", "data-icon", "name"]) {
      const value = element.getAttribute(attr);
      if (value) parts.push(value);
    }
    const svg = element.querySelector("svg");
    if (svg) {
      for (const attr of ["alt", "aria-label", "data-icon", "id"]) {
        const value = svg.getAttribute(attr);
        if (value) parts.push(value);
      }
      const title = svg.querySelector("title");
      if (title) parts.push(title.textContent || "");
      const use = svg.querySelector("use");
      if (use) parts.push(use.getAttribute("href") || use.getAttribute("xlink:href") || "");
      // Sprite ids live on the <g>/<symbol> the icon was copied from.
      const group = svg.querySelector("[id]");
      if (group) parts.push(group.getAttribute("id") || "");
    }
    // Separated, so "icon-cart" and "search" never run into one word.
    return parts.join(" ");
  }

  /// A field whose value must never be copied out of the page: a password,
  /// a one-time code, a card. Decided by the HTML standard — the input type
  /// and the WHATWG autofill tokens — never by what the field is called.
  const SECRET_TOKENS = ["current-password", "new-password", "one-time-code",
    "cc-number", "cc-csc", "cc-exp", "cc-exp-month", "cc-exp-year"];
  function isSecret(type, autocomplete) {
    if (type === "password") return true;
    return (autocomplete || "").split(/\s+/).some(function (token) { return SECRET_TOKENS.indexOf(token) !== -1; });
  }

  /// What the markup says about a control that has no name: the glyph it
  /// draws, its class and id, its title, and its icon's names (see
  /// iconHint). Evidence for the model that names it, in whatever language
  /// the site wrote its code. Not a name.
  function controlHints(element) {
    if (!element) return "";
    const parts = [textOf(element), String(element.className || ""), element.id || "",
      element.getAttribute("title") || "", iconHint(element)];
    return parts.map(function (p) { return String(p).trim(); }).filter(Boolean).join(" ").replace(/\s+/g, " ").slice(0, 200);
  }

  /* ---------------------------------------------------------------------
   * The page, repaired where it stands.
   *
   * Nothing here moves, groups, or redraws anything. The page keeps the
   * shape its author gave it and the layout everybody else sees; what this
   * fixes are the three gaps that make VoiceOver useless on a page that
   * otherwise works — a control with no name, an image with no alt, and a
   * decorative glyph read out loud as if it meant something.
   *
   * Two rules keep a repair from being worse than the damage:
   *
   *   1. It only ADDS attributes. No node is moved or removed, no handler
   *      replaced, no style touched. The worst case of a wrong guess is a
   *      badly named button — never a broken one.
   *   2. It never hides anything that can take focus. Hiding a focusable
   *      element from the accessibility tree is the one "fix" that makes a
   *      page unusable: the cursor lands on something VoiceOver has been
   *      told is not there, and the person is stuck on a control that does
   *      not exist.
   *
   * What it deliberately does NOT do: `inert` on what looks unreachable.
   * A mobile nav panel usually sits at opacity 0 waiting to fade in, and
   * `pointer-events: none` covers 137 of Frávega's 141 buttons because the
   * handler lives on a wrapper. Marking either one unreachable would gut a
   * page that works. Unreachable stays a reading problem, not a repair.
   * ------------------------------------------------------------------- */

  /// Anything the focus can land on. `tabindex="-1"` counts: it is out of
  /// the tab order but a screen reader still reaches it.
  const FOCUSABLE = "a[href],button,input,select,textarea,summary,[tabindex],[contenteditable],[role=button],[role=link],[role=tab],[role=menuitem],[role=checkbox],[role=radio]";

  /// The controls worth naming. Same list the inventory walks, minus the
  /// cap: the inventory stops at MAX_ACTIONS because each one costs money
  /// to reason about, but a name costs nothing and the fortieth button is
  /// as unusable as the first.
  const REPAIRABLE = "a[href],button,summary,input[type=button],input[type=submit],input[type=image],input[type=checkbox],input[type=radio],[role=button],[role=link],[role=tab],[role=menuitem],[role=checkbox],[role=radio]";

  /// What a screen reader would say for this element today, as close as we
  /// can compute it without asking the platform.
  function spokenName(el) {
    const own = labelOf(el);
    if (own && !LONE_GLYPH.test(own)) return own;
    // A picture with an alt IS the name, natively — the inventory was the
    // only thing missing it.
    const pic = imageName(el);
    if (pic && !LONE_GLYPH.test(pic)) return pic;
    if (el.tagName === "INPUT") {
      const value = (el.getAttribute("value") || "").trim();
      if (value && /^(submit|button|image)$/i.test(el.getAttribute("type") || "")) return value;
      const alt = (el.getAttribute("alt") || "").trim();
      if (alt) return alt;
      const placeholder = (el.getAttribute("placeholder") || "").trim();
      if (placeholder) return placeholder;
    }
    // <label for> and a wrapping <label> are both real names to VoiceOver.
    const wrapping = el.closest("label");
    if (wrapping) {
      const text = textOf(wrapping);
      if (text && !LONE_GLYPH.test(text)) return text.slice(0, 60);
    }
    if (el.id && typeof CSS !== "undefined" && CSS.escape) {
      const tag = document.querySelector('label[for="' + CSS.escape(el.id) + '"]');
      if (tag) {
        const text = textOf(tag);
        if (text && !LONE_GLYPH.test(text)) return text.slice(0, 60);
      }
    }
    return "";
  }

  /// Whether this element, or anything inside it, can take focus.
  function holdsFocus(el) {
    try {
      if (el.matches(FOCUSABLE)) return true;
      return !!el.querySelector(FOCUSABLE);
    } catch (_) {
      return true; // Unsure means leave it alone.
    }
  }

  /// A picture that carries no meaning: it sits inside a control that
  /// already has a name, or it is too small to be anything but a rule, a
  /// spacer or a tracking pixel.
  function isDecorativeImage(img) {
    const control = img.closest(REPAIRABLE);
    if (control && spokenName(control)) return true;
    const rect = img.getBoundingClientRect();
    if (rect.width && rect.height && rect.width <= 40 && rect.height <= 40) return true;
    const src = (img.getAttribute("src") || "") + " " + (String(img.className || ""));
    return /sprite|icon|spacer|pixel|separator|divider|bullet|\/1x1\.|blank\.gif/i.test(src);
  }

  function repairInPlace() {
    // A page can turn this off for a run; the native side owns the switch.
    if (window.__jefRepair === false) return { named: 0, quieted: 0, silenced: 0 };
    let named = 0, quieted = 0, silenced = 0;

    // 1. Controls the page left without a name: named by the assistant,
    //    in the person's language, through window.__jefName. What stays
    //    here is stepping back when the page names one itself.
    for (const el of document.querySelectorAll("[data-jef-name]")) {
      if (el.getAttribute("aria-label") !== el.getAttribute("data-jef-name")) el.removeAttribute("data-jef-name");
    }

    // 2. Pictures with no alt at all. VoiceOver reads the file name, which
    //    is how a person hears "guion bajo hero guion bajo dos mil
    //    veinticuatro punto jpg" in the middle of a front page. An empty
    //    alt is silence, and silence is only right when the picture means
    //    nothing — so a photo we cannot name is left alone rather than
    //    silenced. That gap is where a caption model would go.
    for (const img of document.querySelectorAll("img:not([alt])")) {
      if (img.getAttribute("role") === "presentation") continue;
      if (!isDecorativeImage(img)) continue;
      img.setAttribute("alt", "");
      img.setAttribute("data-jef-alt", "");
      quieted++;
    }

    // 3. Decoration read out loud. A carousel's dots, a bullet between two
    //    dates, an emoji used as a divider: each is its own stop, and a
    //    front page can hold dozens.
    for (const el of document.querySelectorAll("span,i,em,b,strong,div,li,p")) {
      if (el.hasAttribute("aria-hidden")) continue;
      if (el.children.length) continue;
      const text = (el.textContent || "").trim();
      if (!text || !DECORATION.test(text)) continue;
      // Rule 2, the one that must never be broken.
      if (holdsFocus(el)) continue;
      // And its other half, which cost me 268 links on Wikipedia: the
      // reference backlinks are <a href="#cite"><span>↑</span></a>, and
      // silencing the span left the link with no name at all. The person
      // still lands on it and now hears nothing. So: decoration inside
      // something focusable is left alone, unless that something already
      // carries its own name and does not depend on this text.
      const owner = el.closest(FOCUSABLE);
      if (owner && !(owner.getAttribute("aria-label") || owner.getAttribute("aria-labelledby"))) continue;
      if (el.closest("[role=img],figure")) continue;
      el.setAttribute("aria-hidden", "true");
      el.setAttribute("data-jef-quiet", "1");
      silenced++;
    }

    return { named: named, quieted: quieted, silenced: silenced };
  }

  /*
   * Whether a destination is another document, or a place inside this one.
   *
   * The difference decides how a link is offered. A link to another document
   * is an address the reader can load. A link to this same document — an
   * empty href, a bare "#", a fragment like "#newsletter", the page's own
   * path — goes nowhere on its own: whatever it does, the page's JavaScript
   * does on click. Handed to the reader as an address, it reloaded the page
   * and the click handler never ran, so the modal it was meant to open never
   * opened and the person heard the same page again.
   */
  function opensAnotherPage(href) {
    const raw = (href || "").trim();
    if (!raw || /^#/.test(raw) || /^javascript:/i.test(raw)) return false;
    let target;
    try {
      target = new URL(raw, document.baseURI);
    } catch (_) {
      return false;
    }
    if (target.protocol !== "http:" && target.protocol !== "https:") return false;
    return target.origin !== location.origin
      || target.pathname !== location.pathname
      || target.search !== location.search;
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
      // The invisible reCAPTCHA's badge is not a test: it asks nothing of
      // anyone. ANSES's appointment lookup carries one next to a two-field
      // form, and the assistant asked a blind person to solve a test that
      // did not exist.
      if (/size=invisible/i.test(src) || f.closest(".grecaptcha-badge")) return false;
      return /recaptcha|hcaptcha|turnstile|challenges\.cloudflare|arkoselabs|funcaptcha/i.test(src) && !isHidden(f);
    });
    // Cloudflare's own check page hides its widget in a closed shadow root,
    // so no iframe is found; the page declares itself with its challenge
    // objects instead, which ordinary pages behind Cloudflare do not carry.
    // It used to be caught by its words — "verify you are human", "no soy un
    // robot" —, which only worked in Spanish and English.
    const cloudflare = typeof window._cf_chl_opt !== "undefined"
      || !!document.querySelector("#challenge-stage, #challenge-form, #cf-challenge-running");
    if (!frame && !cloudflare) return null;
    // A form with a check is a form, not a wall. The passenger-data page
    // carried one and read as "Verificación de seguridad" over forty fields.
    // A wall has little else: Mercado Libre's is a heading, «Ir al login»
    // and a cookie notice.
    if (!cloudflare) {
      const controls = Array.prototype.filter.call(
        document.querySelectorAll("input:not([type=hidden]), select, textarea, button, a[href]"),
        function (c) { return !isHidden(c); }
      );
      if (controls.length > 12) return null;
    }

    const heading = document.querySelector("h1, h2, [role=heading]");
    const said = heading ? textOf(heading) : "";
    // reCAPTCHA and hCaptcha both offer an audio challenge, and it lives
    // inside their iframe — another origin, so we cannot press it from
    // here. What we can do is say it exists, which is more than handing
    // over a page whose whole point is that it cannot be seen.
    const src = frame ? (frame.getAttribute("src") || "") : "";
    const audio = /recaptcha|hcaptcha/i.test(src);
    return {
      kind: "captcha",
      text: said || "La página pide comprobar que sos una persona.",
      audioChallenge: audio,
      choices: [],
      links: [],
    };
  }

  /*
   * The page, in its own order.
   *
   * The passes above build inventories — what the page says, what it lets
   * you do, what it lists — and each keeps its own order. None knows what
   * came before what. On a login page the reader could only stack all the
   * text, then all the buttons, then the form, and "ó ingresá con tu email"
   * was read before the three buttons it is the alternative to. The order
   * was the one thing the page had already solved, and it was thrown away.
   *
   * One walk of the live document, top to bottom. Text becomes a block
   * where it stands; a control the action pass reported is a reference to
   * it, at its place; a form sits where its first field is; a listing where
   * its container is. Nothing is reordered and nothing is judged here.
   *
   * `noise` marks a stop that says nothing: a lone emoji or bullet, an image
   * named after its file, a button the site never named. It is not dropped —
   * the native side keeps those out of the way, together, in one place.
   */
  const MAX_STREAM = 800;
  const STREAM_SKIP = new Set([
    "SCRIPT", "STYLE", "NOSCRIPT", "TEMPLATE", "IFRAME", "SVG", "CANVAS", "VIDEO",
    "AUDIO", "OBJECT", "EMBED", "MAP", "HEAD", "LINK", "META", "OPTION", "DATALIST",
  ]);
  const BLOCKISH = Array.from(BLOCK_TAGS)
    .filter(function (tag) { return tag !== "BR"; })
    .join(",").toLowerCase();

  /// Whether a text says anything: a letter or a digit, in any script.
  function says(text) {
    return /[\p{L}\p{N}]/u.test(text || "");
  }

  function collectStream(actions, listings, overlayElement) {
    const entries = [];
    const byId = new Map();
    const formOfField = new Map();
    const fieldNames = new Set();
    for (const action of actions) {
      byId.set(action.id, action);
      for (const field of action.fields || []) {
        formOfField.set(field.id, action.id);
        fieldNames.add(plain(field.name));
        // What the page holds against a field, and what it wrote back after
        // a submit, the rebuilt form says where they belong.
        if (field.error) fieldNames.add(plain(field.error));
      }
      for (const notice of action.notices || []) fieldNames.add(plain(notice));
    }
    const listed = new Set(listings.map(function (l) { return l.id; }));
    // Buttons a listing row already presses: the row is their place.
    const inListings = new Set();
    for (const listing of listings) {
      for (const item of listing.items) {
        if (item.actionId) inListings.add(item.actionId);
        for (const choice of item.choices || []) inListings.add(choice.id);
        for (const extra of item.extras || []) inListings.add(extra.id);
      }
    }
    const placed = new Set();
    const saidLinks = new Set();
    let counter = 0;
    function nextId() { return "s" + counter++; }

    /// For telling two labels apart: case, the required mark and the colon
    /// are typography.
    function plain(text) {
      return (text || "").toLowerCase().replace(/[\s*:]+$/g, "").replace(/\s+/g, " ").trim();
    }

    // What holds something with a place of its own, and what holds a block:
    // marked once, bottom-up, instead of asked again at every level.
    const holdsStamp = new WeakSet();
    for (const el of document.body.querySelectorAll("[data-jef-id], [data-jef-field], [data-jef-listing]")) {
      for (let up = el.parentElement; up && !holdsStamp.has(up); up = up.parentElement) holdsStamp.add(up);
    }
    const holdsBlock = new WeakSet();
    for (const el of document.body.querySelectorAll(BLOCKISH + ", img, picture, input, select, textarea, button")) {
      for (let up = el.parentElement; up && !holdsBlock.has(up); up = up.parentElement) holdsBlock.add(up);
    }

    /// Out of the page for everyone, not just collapsed to nothing: a
    /// wrapper with `display: contents` or no height of its own still has
    /// children to read, so size is asked of leaves only.
    function isPruned(el) {
      if (el.hasAttribute("hidden") || el.getAttribute("aria-hidden") === "true") return true;
      const style = window.getComputedStyle(el);
      return style.display === "none" || style.visibility === "hidden";
    }

    /// What an option is listed with: the nearest container that repeats
    /// its shape — the <ul> of a link in an <li>, the row of three sign-in
    /// buttons. Options that touch but do not share one are neighbours,
    /// not a list: a news card right under eight department links is not
    /// the ninth department.
    const groupIds = new Map();
    function groupKey(container) {
      if (!groupIds.has(container)) groupIds.set(container, "g" + groupIds.size);
      return groupIds.get(container);
    }
    function groupOf(el) {
      let child = el;
      for (let hops = 0; hops < 6 && child.parentElement; hops++) {
        const parent = child.parentElement;
        const shape = shapeOf(child);
        let alike = 0;
        for (const sibling of parent.children) if (shapeOf(sibling) === shape) alike++;
        if (alike >= 2) return groupKey(parent);
        if (parent === document.body) break;
        child = parent;
      }
      return null;
    }

    function put(entry, el) {
      if (entries.length >= MAX_STREAM) return;
      entry.id = entry.id || nextId();
      entry.zone = el ? regionOf(el) : "body";
      entries.push(entry);
    }

    function isNoiseBlock(block) {
      switch (block.type) {
        case "heading": case "paragraph": case "quote":
          return !says(block.text);
        case "list":
          return !block.items.some(function (item) { return says(item.text); });
        case "image":
          // "prod-lanacion" is the name of a file, not of a picture.
          return !says(block.caption) && (!says(block.alt) || looksLikeCode(block.alt));
        default:
          return false;
      }
    }

    function putBlock(block, el) {
      const entry = { id: block.id, kind: "block", block: block };
      if (isNoiseBlock(block)) entry.noise = true;
      put(entry, el);
    }

    /// A form and a listing name themselves, and the name was taken from
    /// the line just above them. Left there, it is one stop said twice.
    function dropEcho(name) {
      const last = entries[entries.length - 1];
      if (!name || !last || last.kind !== "block" || !last.block.text) return;
      // Listing titles are cut at sixty characters.
      if (plain(last.block.text).slice(0, 60) === plain(name).slice(0, 60)) entries.pop();
    }

    function putAction(id, el) {
      if (placed.has(id)) return;
      placed.add(id);
      const action = byId.get(id);
      if (action.kind === "form") dropEcho(action.label);
      if (action.kind === "link" && action.href) saidLinks.add(plain(action.label) + "|" + action.href);
      const entry = { kind: "action", ref: id };
      if (action.unnamed) entry.noise = true;
      if (action.kind !== "form") {
        const group = groupOf(el);
        if (group) entry.group = group;
      }
      put(entry, el);
    }

    /// A destination the reader can load. Ver `opensAnotherPage`.
    const opens = opensAnotherPage;

    /// A headline under an empty link that `cardLink` misses. Clarín's lead
    /// story is a heading that is no link, an <a> with nothing in it
    /// stretched over the card, and a related story's own link in the same
    /// card: two destinations, so not "one card, one link", and the lead
    /// read as loose text nobody could open (Daniel, on his iPhone). A link
    /// with no text of its own (an aria-label is not shown) belongs to the
    /// one heading around it that no link holds, when it lies over that
    /// heading and no other nameless link there leads elsewhere; that
    /// heading becomes the link, and everything else in the card is read as
    /// before. Structure and geometry only: no class names, no words.
    const headlineLinks = new WeakMap();
    const linkEntries = new Map();
    /// Whether the link lies over the heading, as a stretched card link
    /// does — the one a finger on the headline would press. Wikipedia's
    /// edit pencil sits beside its section heading and is no headline's.
    function covers(link, heading) {
      const l = link.getBoundingClientRect(), h = heading.getBoundingClientRect();
      if (l.width < 2 || l.height < 2 || h.width < 2 || h.height < 2) return false;
      const x = h.left + h.width / 2, y = h.top + h.height / 2;
      return x >= l.left && x <= l.right && y >= l.top && y <= l.bottom;
    }
    (function pairEmptyLinks() {
      const free = function (h) { return !h.closest("a[href]") && !h.querySelector("a[href]"); };
      for (const a of document.querySelectorAll("a[href]")) {
        if (isPruned(a)) continue;
        const to = absolute(a.getAttribute("href") || "");
        if (!to || !opens(to)) continue;
        // A link that says exactly what the unlinked heading of its card
        // says is that headline's link: El Universo's lead is an <h2> that
        // is no link and, apart, a link with the same words.
        const said = plain(textOf(a));
        if (said) {
          for (let up = a.parentElement; up && up.nodeType === Node.ELEMENT_NODE && !up.matches("body, main, nav, header, footer, aside, [role=main], [role=navigation], [role=banner], [role=contentinfo]"); up = up.parentElement) {
            const headings = Array.prototype.filter.call(up.querySelectorAll("h1, h2, h3, h4, h5, h6, [role=heading]"), free);
            if (!headings.length) continue;
            if (headings.length === 1 && plain(textOf(headings[0])) === said && !headlineLinks.has(headings[0])) {
              headlineLinks.set(headings[0], to);
            }
            break;
          }
          continue;
        }
        // No visible text: an aria-label names it for a screen reader —
        // Clarín's says the whole headline — but the walk reads what is shown.
        if (a.querySelector("img[alt]:not([alt=''])")) continue;
        for (let up = a.parentElement; up && up.nodeType === Node.ELEMENT_NODE && !up.matches("body, main, nav, header, footer, aside, [role=main], [role=navigation], [role=banner], [role=contentinfo]"); up = up.parentElement) {
          const headings = Array.prototype.filter.call(up.querySelectorAll("h1, h2, h3, h4, h5, h6, [role=heading]"), free);
          if (!headings.length) continue;
          const rival = Array.prototype.some.call(up.querySelectorAll("a[href]"), function (o) {
            return o !== a && !textOf(o) && absolute(o.getAttribute("href") || "") !== to;
          });
          if (headings.length === 1 && !rival && covers(a, headings[0]) && !headlineLinks.has(headings[0])) {
            headlineLinks.set(headings[0], to);
          }
          break;
        }
      }
    })();

    /// What names a link that does not name itself. «Leer» under «Agenda tu
    /// Cita Médica Digital» (imss.gob.mx) reached every model as "Leer",
    /// and Jev chose the feed «Suscribirse a cita médica» instead. The
    /// link's card is the nearest element around it that says something
    /// besides the link and leads nowhere else. A link that fills a list
    /// item or an article, or opens its card («Migración» on gub.uy, with
    /// its description below), names itself; otherwise the card's heading
    /// names the link, or its first line —that IMSS title is a plain
    /// <div>—, when it says more than the link. Kept apart from the label:
    /// «Buscar con DNI» is what the button does, «¿Sos suscriptor y
    /// olvidaste tu email?» is where. Structure, not words.
    const LANDMARKS = "body, main, nav, header, footer, aside, [role=main], [role=navigation], [role=banner], [role=contentinfo]";
    function namedByCard(el, href, label) {
      for (let node = el; node && node.nodeType === Node.ELEMENT_NODE && !node.matches(LANDMARKS); node = node.parentElement) {
        for (const other of node.querySelectorAll("a[href]")) {
          const to = absolute(other.getAttribute("href") || "");
          if (to && to !== href && !isPruned(other)) return null;
        }
        const first = firstLine(node, href);
        if (first === null) {
          if (node.matches("li, [role=listitem], article")) return null;
          continue;
        }
        if (first.own) return null;
        const heading = Array.prototype.find.call(node.querySelectorAll("h1, h2, h3, h4, h5, h6, [role=heading]"), function (h) {
          return !isPruned(h) && !h.closest("a[href]") && textOf(h);
        });
        const name = heading ? textOf(heading).replace(/\s+/g, " ").trim() : first.text;
        return name.length > label.length ? name : null;
      }
      return null;
    }

    /// The first thing an element says, and whether it is the link to
    /// `href` itself. Null when the element says nothing else.
    function firstLine(node, href) {
      const walker = document.createTreeWalker(node, NodeFilter.SHOW_TEXT);
      let own = false;
      for (let text = walker.nextNode(); text; text = walker.nextNode()) {
        const said = text.textContent.replace(/\s+/g, " ").trim();
        const parent = text.parentElement;
        if (!said || !parent || parent.closest("script, style, noscript, template") || isPruned(parent)) continue;
        const link = parent.closest("a[href]");
        if (link && absolute(link.getAttribute("href") || "") === href) { own = true; continue; }
        return { text: said, own: own };
      }
      return null;
    }

    function putLink(label, href, el, level, group) {
      label = (label || "").replace(/\s+/g, " ").trim();
      if (!label) return;
      // The same link twice is the same link to a person — the rule the
      // action pass already applies to a mobile nav repeating the desktop's.
      const key = plain(label) + "|" + href;
      if (saidLinks.has(key)) {
        // Met again as a headline —its card's heading after its own link—:
        // the link already read becomes the headline, once.
        const earlier = linkEntries.get(key);
        if (level && earlier && !earlier.level) earlier.level = level;
        return;
      }
      saidLinks.add(key);
      const entry = { kind: "link", label: clip(label, 200), href: href };
      linkEntries.set(key, entry);
      // Naming a link never costs the page: a card inside a shadow root or
      // a node that is not an element just goes without a name.
      if (!level && el && el.nodeType === Node.ELEMENT_NODE) {
        try {
          const card = namedByCard(el, href, label);
          if (card) entry.context = clip(card, 80);
        } catch (_) {}
      }
      if (level) entry.level = level;
      if (group) entry.group = group;
      if (!says(label)) entry.noise = true;
      put(entry, el);
    }

    /// The links of a text that is nothing but links — what sits between
    /// them is typography: "Términos | Privacidad · Ayuda". Null when the
    /// text says anything of its own.
    function linksOnly(content) {
      if (!content.links.length) return null;
      let outside = "";
      let at = 0;
      const found = [];
      for (const link of content.links) {
        outside += content.text.slice(at, link.start);
        at = link.end;
        found.push({ label: content.text.slice(link.start, link.end), href: link.href });
      }
      outside += content.text.slice(at);
      if (says(outside)) return null;
      return found.every(function (link) { return opens(link.href); }) ? found : null;
    }

    /// Text that stands together is one stop: a run of text nodes and
    /// inline elements, read as one line with its links inside.
    function flush(run, anchor, type, level) {
      if (!run.length) return;
      const holder = document.createElement("span");
      for (const node of run) holder.appendChild(node.cloneNode(true));
      run.length = 0;
      // An icon's <title> is not part of the sentence, and neither is what
      // the page hides from a screen reader.
      for (const unread of holder.querySelectorAll("svg, script, style, noscript, template, [hidden], [aria-hidden=true]")) {
        unread.remove();
      }
      const content = inlineContent(holder);
      if (!content.text) return;
      // A bar or a bullet between two links is typography, the same thing
      // an <hr> is: it goes nowhere, not even to the noise. An emoji said
      // something to someone, so it is kept — apart.
      if (!says(content.text) && !/\p{Extended_Pictographic}/u.test(content.text)) return;

      const links = linksOnly(content);
      if (links && type !== "quote") {
        // Several links in one line are that line's list; a line that is
        // one link — a headline — is listed with the lines shaped like it.
        const group = links.length > 1 ? groupKey(anchor) : groupOf(anchor);
        for (const link of links) putLink(link.label, link.href, anchor, level, group);
        return;
      }
      if (level) {
        putBlock({ id: nextId(), type: "heading", level: level, text: content.text }, anchor);
        return;
      }
      // A line that only repeats what the rebuilt form already says — a
      // field's name, its complaint, the form's notice — is that, said twice.
      if (!content.links.length && content.text.length <= 200 && fieldNames.has(plain(content.text))) return;
      putBlock({ id: nextId(), type: type || "paragraph", text: content.text, links: content.links }, anchor);
    }

    /// Whether an element reads as part of the line it sits in.
    function isFlow(el) {
      // Upper-cased: an inline <svg> reports its tag in lower case, and its
      // <title> was being read into the sentence around it.
      const tag = el.tagName.toUpperCase();
      if (tag === "BR") return true;
      if (BLOCK_TAGS.has(tag) || STREAM_SKIP.has(tag)) return false;
      if (/^(IMG|PICTURE|INPUT|SELECT|TEXTAREA|BUTTON|LABEL|LEGEND)$/.test(tag)) return false;
      if (el.hasAttribute("data-jef-id") || el.hasAttribute("data-jef-field") || el.hasAttribute("data-jef-listing")) return false;
      const role = el.getAttribute("role");
      if (role === "heading" || role === "button") return false;
      return !holdsStamp.has(el) && !holdsBlock.has(el);
    }

    /// Children in the order the page SHOWS them. A flex or grid container
    /// can place its children anywhere with `order`, or run backwards, and
    /// a sighted reader never knows: La Nación's login is written form
    /// first and buttons last, and shown the other way round — so "ó
    /// ingresá con tu email" reads, in the markup's order, after the email
    /// it is the alternative to. The order on screen is the one that means
    /// something, and it is geometry the page already had.
    function shownOrder(parent) {
      const nodes = Array.prototype.slice.call(parent.childNodes);
      if (parent.nodeType !== Node.ELEMENT_NODE) return nodes;
      const style = window.getComputedStyle(parent);
      if (!/flex|grid/.test(style.display)) return nodes;
      const keyed = nodes.map(function (node, index) {
        const order = node.nodeType === Node.ELEMENT_NODE
          ? parseInt(window.getComputedStyle(node).order, 10) || 0
          : 0;
        return { node: node, index: index, order: order };
      });
      if (keyed.some(function (k) { return k.order !== 0; })) {
        keyed.sort(function (a, b) { return a.order - b.order || a.index - b.index; });
      }
      const ordered = keyed.map(function (k) { return k.node; });
      if (/flex/.test(style.display) && /reverse/.test(style.flexDirection)) ordered.reverse();
      return ordered;
    }

    /// The buttons a card holds, when buttons are all it holds: they are
    /// the card's own actions and travel with it. Null when it holds any
    /// other reported control — a form's field, a navigation link — because
    /// then it is not one thing.
    function cardButtons(el) {
      const found = [];
      for (const inner of el.querySelectorAll("[data-jef-id], [data-jef-field], [data-jef-listing]")) {
        const action = byId.get(inner.getAttribute("data-jef-id") || "");
        if (!action || action.kind !== "button") return null;
        if (!placed.has(action.id)) found.push(action);
      }
      return found;
    }

    /// A card's name: its headline first, then the rest of what it says,
    /// minus what its buttons say.
    function cardLabel(el, heading, buttons) {
      const title = heading ? textOf(heading) : "";
      let rest = textOf(el);
      if (title) rest = rest.replace(title, "");
      for (const button of buttons) rest = rest.replace(button.label, "");
      rest = tidy(rest);
      return title ? (rest ? title + ", " + rest : title) : (rest || imageName(el));
    }

    function putCard(label, href, el, level, buttons, title) {
      const before = entries.length;
      putLink(label, href, el, level, groupOf(el));
      // The same card twice is dropped whole, buttons included.
      const entry = entries.length > before ? entries[entries.length - 1] : null;
      // The headline alone, apart from the card's whole text: read as a
      // front page's headlines, Clarín's cards came with their kicker,
      // section and byline — "…Presupuesto 2027, Otra salida del Gobierno,
      // Política, Renunció el secretario…".
      if (entry && title && title !== label) entry.title = clip(title.replace(/\s+/g, " ").trim(), 200);
      for (const button of buttons) {
        placed.add(button.id);
        if (entry && !button.unnamed) (entry.extras = entry.extras || []).push(button.id);
      }
    }

    /// A card under an empty link. clarin.com closes every <article> with
    /// an <a> that holds nothing and is stretched over the whole card: read
    /// in order, that is a headline nobody can open and a link with no
    /// name. They are one thing — one heading, one destination — and the
    /// headline is what the link is called.
    function cardLink(el) {
      if (!el.matches("article, li, [class*=card], [class*=story], [class*=item]")) return null;
      const buttons = holdsStamp.has(el) ? cardButtons(el) : [];
      if (!buttons) return null;
      const headings = el.querySelectorAll("h1, h2, h3, h4, h5, h6, [role=heading]");
      if (headings.length !== 1) return null;
      const heading = headings[0];
      // The usual shape — the link wraps the headline, or sits in it — is
      // already read as a link.
      if (heading.closest("a[href]") || heading.querySelector("a[href]")) return null;
      const hrefs = new Set();
      for (const anchor of el.querySelectorAll("a[href]")) {
        if (!isPruned(anchor)) hrefs.add(absolute(anchor.getAttribute("href") || ""));
      }
      if (hrefs.size !== 1) return null;
      const href = hrefs.values().next().value;
      if (!textOf(heading) || !opens(href) || isHidden(el)) return null;
      return {
        label: cardLabel(el, heading, buttons),
        title: textOf(heading),
        href: href,
        level: HEADING_LEVEL[heading.tagName] || 2,
        buttons: buttons,
      };
    }

    function walk(parent) {
      const run = [];
      for (const node of shownOrder(parent)) {
        if (entries.length >= MAX_STREAM) break;
        if (node.nodeType === Node.TEXT_NODE) {
          run.push(node);
          continue;
        }
        if (node.nodeType !== Node.ELEMENT_NODE) continue;
        if (node === overlayElement || isPruned(node)) continue;
        if (isFlow(node)) {
          run.push(node);
          continue;
        }
        flush(run, parent);
        visit(node);
      }
      flush(run, parent);
    }

    function visit(el) {
      const tag = el.tagName.toUpperCase();
      if (STREAM_SKIP.has(tag)) return;

      const listing = el.getAttribute("data-jef-listing");
      if (listing && listed.has(listing)) {
        if (!placed.has(listing)) {
          placed.add(listing);
          const found = listings.find(function (l) { return l.id === listing; });
          dropEcho(found && found.title);
          put({ kind: "listing", ref: listing }, el);
        }
        return;
      }

      const stamp = el.getAttribute("data-jef-id");
      if (stamp && byId.has(stamp)) {
        // A form with no submit is stamped on itself. Its first field
        // places it; what else it holds is still read, in order.
        if (byId.get(stamp).kind === "form" && el.querySelector("[data-jef-field]")) walk(el);
        else putAction(stamp, el);
        return;
      }

      const fieldStamp = el.getAttribute("data-jef-field");
      if (fieldStamp) {
        const owner = formOfField.get(fieldStamp.split(":")[0]);
        if (owner) putAction(owner, el);
        return;
      }

      // A control nobody reported — disabled, past the cap, chrome. Its
      // words are not prose. Unless it is a container dressed as a button,
      // which is read like any other container.
      if (/^(INPUT|SELECT|TEXTAREA|BUTTON)$/.test(tag)) return;
      if (el.getAttribute("role") === "button" && !holdsStamp.has(el)) return;

      // A legend names a group of controls, and the rebuilt form owns its
      // groups: "Pizza Size" is already the radio group's name, and "Pizza
      // Toppings" read on its own after the submit button names nothing.
      if (tag === "LEGEND") return;

      if (tag === "LABEL" && el.control && el.control.hasAttribute("data-jef-field")) {
        // The field says its own name. A label wrapped around its control
        // still marks where the form starts.
        if (el.contains(el.control)) visit(el.control);
        return;
      }

      const card = cardLink(el);
      if (card) {
        putCard(card.label, card.href, el, card.level, card.buttons, card.title);
        return;
      }

      const level = HEADING_LEVEL[tag]
        || (el.getAttribute("role") === "heading" ? parseInt(el.getAttribute("aria-level") || "2", 10) || 2 : 0);
      if (level) {
        // A heading that is a reported control: the control is the stop.
        if (holdsStamp.has(el)) { walk(el); return; }
        if (isHidden(el)) return;
        // The headline of an empty link stretched over its card.
        if (headlineLinks.has(el) && textOf(el)) {
          putLink(textOf(el), headlineLinks.get(el), el, level, groupOf(el));
          return;
        }
        // A headline is a heading AND a link. As a block it could be jumped
        // to and never opened; as a link with a level it is both.
        flush(Array.prototype.slice.call(el.childNodes), el, "paragraph", level);
        return;
      }

      if (tag === "P" || tag === "BLOCKQUOTE") {
        if (holdsStamp.has(el) || holdsBlock.has(el)) { walk(el); return; }
        flush(Array.prototype.slice.call(el.childNodes), el, tag === "P" ? "paragraph" : "quote");
        return;
      }

      if (tag === "UL" || tag === "OL") {
        if (holdsStamp.has(el) || holdsBlock.has(el)) { walk(el); return; }
        // A list of links is a list of places to go, each its own stop.
        const items = Array.prototype.filter.call(el.children, function (li) { return li.tagName === "LI" && !isPruned(li); });
        const asLinks = items.map(function (li) { return linksOnly(inlineContent(li)); });
        if (items.length && asLinks.every(Boolean)) {
          asLinks.forEach(function (links, index) {
            for (const link of links) putLink(link.label, link.href, items[index], 0, groupKey(el));
          });
          return;
        }
        const block = listBlock(el, nextId());
        if (block) putBlock(block, el);
        return;
      }

      if (tag === "IMG") {
        if (isHidden(el)) return;
        // Drawn small is an icon, whatever size its file is.
        const drawn = el.getBoundingClientRect();
        if (drawn.width < 48 && drawn.height < 48) return;
        const block = imageBlock(el, nextId());
        if (block) putBlock(block, el);
        return;
      }

      if (tag === "FIGURE" && !holdsStamp.has(el)) {
        const img = el.querySelector("img");
        const block = img && !isHidden(img) ? imageBlock(img, nextId()) : null;
        if (block) {
          const caption = el.querySelector("figcaption");
          if (caption) block.caption = textOf(caption);
          putBlock(block, el);
          return;
        }
      }

      if (tag === "PRE") {
        const text = el.textContent || "";
        if (text.trim()) putBlock({ id: nextId(), type: "code", text: text }, el);
        return;
      }

      if (tag === "HR") {
        putBlock({ id: nextId(), type: "separator" }, el);
        return;
      }

      if (tag === "TABLE") {
        const block = tableBlock(el, nextId());
        if (block) {
          putBlock(block, el);
          // The table keeps its shape; the buttons in its cells follow it.
          for (const inner of el.querySelectorAll("[data-jef-id]")) {
            const id = inner.getAttribute("data-jef-id");
            if (byId.has(id) && !isPruned(inner)) putAction(id, inner);
          }
          return;
        }
      }

      // A link that reaches here is not a word in a line: it wraps a card —
      // a title, a picture, a blurb — or a picture alone. One stop that
      // says the card and opens it; split into its parts, the parts were
      // text nobody could open.
      // foodit.lanacion.com.ar puts "Guardar" inside the link itself: read
      // piece by piece, the recipe was a headline nobody could open and a
      // button that said nothing about what it saved.
      const held = tag === "A" && el.hasAttribute("href") ? (holdsStamp.has(el) ? cardButtons(el) : []) : null;
      if (held) {
        const href = absolute(el.getAttribute("href") || "");
        if (opens(href)) {
          if (isHidden(el)) return;
          const heading = el.querySelector("h1, h2, h3, h4, h5, h6, [role=heading]");
          const name = cardLabel(el, heading, held);
          if (name && !looksLikeCode(name)) {
            putCard(name, href, el, heading ? (HEADING_LEVEL[heading.tagName] || 2) : 0, held, heading ? textOf(heading) : "");
          } else if (!saidLinks.has("|" + href)) {
            // No words and no named picture: the site's unnamed control.
            saidLinks.add("|" + href);
            put({ kind: "link", label: "Enlace sin nombre", href: href, noise: true }, el);
          }
          return;
        }
      }

      walk(el);
    }

    walk(document.body);

    // Reported but never met on the way: inside a listing's card, under a
    // wrapper hidden from assistive technology. Last, so nothing is lost.
    for (const listing of listings) {
      if (!placed.has(listing.id)) put({ kind: "listing", ref: listing.id }, null);
    }
    for (const action of actions) {
      if (placed.has(action.id) || inListings.has(action.id)) continue;
      const entry = { kind: "action", ref: action.id, id: nextId(), zone: action.region };
      if (action.unnamed) entry.noise = true;
      if (entries.length < MAX_STREAM) entries.push(entry);
    }

    return entries;
  }

  function extract() {
    // First, and on the live document: the page is repaired before anything
    // reads it, so the inventory below sees the names we just wrote instead
    // of computing them twice. Everything after this point is reading.
    const repaired = repairInPlace();
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
    // After the inventories: it places what they reported.
    const stream = collectStream(actions, listings, found ? found.element : null);

    // Readability mutates the document it parses, so hand it a clone.
    const clone = document.cloneNode(true);
    // What a wiki puts around an article is not the article. Read as its
    // first paragraphs, Mar del Plata opened with "ciudad de la provincia de
    // Buenos Aires, Argentina" (the short description) and "«Marplatense»
    // redirige aquí" (a hatnote), and every citation mark read as "[2 ]".
    if (clone.querySelector(".mw-parser-output")) {
      // The mobile skin puts the short description under the title, as a
      // tagline, outside the article body.
      clone.querySelectorAll(
        ".tagline, .shortdescription, .hatnote, .dablink, .rellink, sup.reference, .mw-editsection, " +
        ".mw-empty-elt, .navbox, .ambox, .noprint, #toc, .toc, .mw-cite-backlink"
      ).forEach(function (el) { el.remove(); });
      // The mobile skin folds every section after the introduction —
      // hidden="until-found" — and Readability drops what is hidden: Mar del
      // Plata ended "Fin de la nota" after four paragraphs, with Historia,
      // Geografía and the rest never read. Unfolded and unwrapped, the
      // article is one.
      clone.querySelectorAll(".mw-parser-output [hidden]").forEach(function (el) { el.removeAttribute("hidden"); });
      clone.querySelectorAll(".mw-parser-output section").forEach(function (section) {
        while (section.firstChild) section.parentNode.insertBefore(section.firstChild, section);
        section.remove();
      });
    }
    const article = new Readability(clone, {
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
          stream: stream,
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
            droppedActions: actions.droppedCount || 0,
            repaired: repaired,
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

    // A short paragraph a listing item already says — "Domingo", "05:20",
    // "AEP", the flight card read back as prose — is said once.
    const saidByItems = [];
    for (const listing of listings) for (const item of listing.items) saidByItems.push(item.title + " " + (item.meta || ""));
    const blocks = toBlocks(holder.body).filter(function (block) {
      if (block.type !== "paragraph" || block.text.length >= 60) return true;
      return !saidByItems.some(function (said) { return said.indexOf(block.text) !== -1; });
    });

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
      stream: stream,
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
        droppedActions: actions.droppedCount || 0,
        repaired: repaired,
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
  /// What a control shows as its value. For most that is `.value`; a
  /// combobox that clears its input on pick — react-select — shows the
  /// pick in a sibling instead, and its placeholder where nothing is
  /// picked yet. Walks up while the container holds this one control.
  function displayedValue(control) {
    if (control.value) return control.value;
    const own = [control.getAttribute("aria-label"), control.getAttribute("placeholder")]
      .map(function (s) { return (s || "").trim(); });
    let up = control.parentElement;
    for (let depth = 0; up && depth < 4; up = up.parentElement, depth++) {
      if (up.querySelectorAll("input, select, textarea").length > 1) break;
      const clone = up.cloneNode(true);
      for (const gone of clone.querySelectorAll("[class*=placeholder], input, select, textarea, [aria-live]")) gone.remove();
      const text = (clone.textContent || "").replace(/\s+/g, " ").trim();
      if (text) return own.indexOf(text) === -1 ? text : "";
    }
    return "";
  }

  /// Opens a combobox's list without typing: what pressing it and
  /// ArrowDown do for a person, so `__jefSuggestions` can read all of it.
  window.__jefOpen = function (fieldId) {
    const key = String(fieldId).replace(/"/g, "");
    const el = document.querySelector('[data-jef-field="' + key + '"]');
    if (!el) return { ok: false, reason: "gone" };
    try {
      el.focus();
      for (const type of ["mousedown", "mouseup", "click"]) {
        el.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true }));
      }
      el.dispatchEvent(new KeyboardEvent("keydown", { bubbles: true, key: "ArrowDown", code: "ArrowDown", keyCode: 40 }));
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true };
  };

  /// The assistant's name for a control the page left unnamed, written
  /// where VoiceOver reads it. Only while the page says nothing itself.
  window.__jefName = function (id, label) {
    const el = document.querySelector('[data-jef-id="' + String(id).replace(/[^A-Za-z0-9_-]/g, "") + '"]');
    if (!el || !label) return false;
    if (el.getAttribute("data-jef-name") === null && spokenName(el)) return false;
    el.setAttribute("aria-label", label);
    el.setAttribute("data-jef-name", label);
    return true;
  };

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
      // And let go, unless the field offers suggestions: a field left
      // focused keeps the keyboard's form bar on screen — "˄ ˅ ✓", an
      // unnamed "Barra de herramientas" next to the conversation.
      const suggests = el.getAttribute("role") === "combobox" || el.hasAttribute("aria-autocomplete") ||
        el.hasAttribute("list") || el.getAttribute("aria-haspopup") === "listbox";
      if (!suggests) el.blur();
    } catch (e) {
      return { ok: false, reason: "error", message: String((e && e.message) || e) };
    }
    return { ok: true, value: el.value };
  };

  /// What the page says on its own when something happens: its live
  /// regions, the ones a screen reader announces by standard (aria-live,
  /// role=status, role=alert, role=log, <output>) — "Agregado al carrito",
  /// "Datos guardados". Kept until the app takes them with
  /// `__jefTakeSaid`, which it does before and after pressing something:
  /// what came in between is the page's answer.
  const saidByPage = [];
  const LIVE = '[aria-live]:not([aria-live="off"]), [role="status"], [role="alert"], [role="log"], output';
  function liveRegionOf(node) {
    const el = node && (node.nodeType === Node.ELEMENT_NODE ? node : node.parentElement);
    const region = el && el.closest ? el.closest(LIVE) : null;
    return region && !region.closest('[aria-hidden="true"]') ? region : null;
  }
  try {
    new MutationObserver(function (records) {
      const touched = new Set();
      for (const record of records) {
        const region = liveRegionOf(record.target);
        if (region) touched.add(region);
        for (const node of record.addedNodes) {
          if (node.nodeType === Node.ELEMENT_NODE && node.matches(LIVE)) touched.add(node);
        }
      }
      touched.forEach(function (region) {
        const text = (region.textContent || "").replace(/\s+/g, " ").trim().slice(0, 300);
        if (text && saidByPage[saidByPage.length - 1] !== text) saidByPage.push(text);
        if (saidByPage.length > 10) saidByPage.shift();
      });
    }).observe(document.documentElement, { childList: true, subtree: true, characterData: true });
  } catch (e) { /* a page without a document element says nothing */ }
  window.__jefTakeSaid = function () {
    const out = saidByPage.slice();
    saidByPage.length = 0;
    return out;
  };

  /// Closes what covers the page the standard way, as a keyboard does:
  /// Escape, which the WAI-ARIA dialog pattern asks every modal to honor.
  /// Nothing on the page is pressed. For notices whose close button has no
  /// name, a drawn "×" the reader cannot offer.
  window.__jefDismiss = function () {
    const target = document.activeElement || document.body || document.documentElement;
    for (const type of ["keydown", "keyup"]) {
      target.dispatchEvent(new KeyboardEvent(type, {
        key: "Escape", code: "Escape", keyCode: 27, which: 27, bubbles: true, cancelable: true,
      }));
    }
    return true;
  };

  /// What a field holds now, as `__jefFill` left it or as the page changed
  /// it after reacting. A radio group answers with its checked option.
  window.__jefValue = function (fieldId) {
    const key = String(fieldId).replace(/"/g, "");
    const el = document.querySelector('[data-jef-field="' + key + '"]');
    if (el) return { ok: true, value: el.type === "checkbox" ? (el.checked ? "on" : "") : String(el.value || "") };
    const radios = document.querySelectorAll('[data-jef-field^="' + key + ':"]');
    if (!radios.length) return { ok: false, reason: "gone" };
    const checked = Array.prototype.find.call(radios, function (r) { return r.checked; });
    return { ok: true, value: checked ? String(checked.value) : "" };
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
    // A dropdown rendered at the end of <body> — most date pickers — has
    // no scope near its field. The person just opened it: what is visible
    // is what it offers.
    if (!scope) scope = document;

    const shown = Array.prototype.slice.call(
      scope.querySelectorAll("[role=option], [role=listbox] li, [role=listbox] > *")
    ).filter(function (o) {
      // Leaves only. A listbox nested in a listbox — react-autosuggest
      // wraps its <ul role=listbox> in a <div role=listbox> — read as one
      // option holding all three airports.
      return !isHidden(o) && textOf(o) && !o.querySelector("[role=option], li");
    });

    // This field's previous list, wherever its nodes ended up, must not
    // answer for the new one.
    for (const old of document.querySelectorAll('[data-jef-option^="' + key + ':"]')) old.removeAttribute("data-jef-option");

    const suggestions = [];
    for (const option of shown) {
      if (suggestions.length >= 40) break;
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
    return { ok: true, value: control ? displayedValue(control) : "" };
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

  /// Every visible run of text under `root`, normalised, as a set.
  function leafTexts(root) {
    const texts = new Set();
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      const text = (node.textContent || "").replace(/\s+/g, " ").trim();
      if (!text || !node.parentElement || isHidden(node.parentElement)) continue;
      texts.add(text);
    }
    return texts;
  }

  // What the page said in reply to the last submit. A form that stays put
  // after "Siguiente" has usually written why beside a field — and not
  // always on the field itself: "Debes indicar la fecha de caducidad"
  // hung under three date boxes with nothing on any of them. Texts that
  // were not there when the button was pressed are the reply.
  let submittedTexts = null;
  let submittedAnchor = null;

  function noticesOf(container, submitEl) {
    if (!submittedTexts || submitEl !== submittedAnchor) return undefined;
    const notices = [];
    for (const text of leafTexts(container)) {
      if (notices.length >= 6) break;
      if (text.length <= 200 && !submittedTexts.has(text)) notices.push(text);
    }
    return notices.length ? notices : undefined;
  }

  window.__jefSubmitForm = function (actionId) {
    const anchor = document.querySelector(
      '[data-jef-id="' + String(actionId).replace(/"/g, "") + '"]'
    );
    if (!anchor) return { ok: false, reason: "gone" };
    lateRounds = 0;
    submittedTexts = leafTexts(document.body);
    submittedAnchor = anchor;

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

  /*
   * Whether this is still the control the reader was told about.
   *
   * An id survives a re-render — that is the point of stamping the node — but
   * what the node SAYS can change underneath it. A calendar that rolls to the
   * next month keeps its cells and swaps their dates; a tab strip reuses its
   * buttons. Pressing by id alone means pressing whatever took the place of
   * what the person heard, which is the one mistake a reader must never make:
   * they cannot see that it changed.
   *
   * Compared by name, because the name is what was said out loud.
   */
  function stillTheSame(el, expected) {
    if (!expected) return true;
    const now = (labelOf(el) || "").replace(/\s+/g, " ").trim().toLowerCase();
    const said = String(expected).replace(/\s+/g, " ").trim().toLowerCase();
    if (!now || !said) return true;
    return now === said || now.indexOf(said) === 0 || said.indexOf(now) === 0;
  }

  window.__jefActivate = function (id, expected) {
    const el = document.querySelector('[data-jef-id="' + String(id).replace(/"/g, '') + '"]');
    if (!el) return { ok: false, reason: "gone" };
    if (!stillTheSame(el, expected)) return { ok: false, reason: "changed", label: labelOf(el) };
    // A tap is a new trigger; the late-change budget is per trigger, not
    // per URL, or the fourth tap on a page stopped being watched.
    lateRounds = 0;

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
  /// Through extractAndSend, so what the page does NEXT is watched too: the
  /// "Comprar" bar slid in a second after the fare was picked, and the
  /// re-extraction that followed the tap had already come and gone.
  window.__jefReextract = function () {
    whenSettled(extractAndSend);
  };

  /// Reads the page now, without waiting for it to settle. The app's safety
  /// net calls it when the page finished loading and nothing has arrived:
  /// the waits above run on the page's own clock, and in an off-screen
  /// WebView that clock sometimes stretches a 6 s wait to 20.
  window.__jefExtractNow = function () {
    extractAndSend(false);
  };

  /// What a reading of the page amounts to, for telling two apart. Not
  /// field values: typing must not read as the page changing.
  function signatureOf(page) {
    return [
      page.title, page.blocks.length, page.listings.length,
      page.actions.map(function (a) {
        return a.label + (a.fields ? "/" + a.fields.map(function (f) { return f.name + ":" + f.type; }).join(",") : "");
      }).join("|"),
      // The walk is what the reader draws on a page read in its own order.
      // Left out, a tap that changed only the walk — a panel that opened
      // with no new controls, a section that expanded — read as "nothing
      // happened" and was never sent. Its shape, not its text: a ticker
      // rewrites itself on its own and must not read as a new page.
      (page.stream || []).map(function (e) {
        return e.kind + (e.ref || e.href || "");
      }).join("|"),
      page.overlay ? page.overlay.text : "",
    ].join("\n");
  }
  let lastSignature = "";

  /// `onlyIfChanged`: the late-change observer asks, and a reading that
  /// says the same as the last one is not sent and costs no round. A
  /// spinner's class flips used to burn all six rounds before the
  /// checkout's form arrived, and then nobody was watching when it did.
  function extractAndSend(onlyIfChanged) {
    try {
      const page = extract();
      // Nothing to read is said as it is: its signature threw, and the app
      // heard "page.blocks.length" instead of "no-article".
      if (!page.ok) {
        send(page);
        watchLateChanges();
        return;
      }
      const signature = signatureOf(page);
      if (onlyIfChanged && signature === lastSignature) {
        watchLateChanges();
        return;
      }
      if (onlyIfChanged) lateRounds++;
      lastSignature = signature;
      send(page);
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
   * change — twenty nodes or a paragraph of text, not a ticker or an ad
   * slot — followed by the usual quiet is read again and delivered as a
   * page that changed on its own. Bounded: a few rounds per route, inside
   * a short window, so a page that never stops moving cannot keep the
   * reader re-rendering.
   */
  // Ninety seconds, because a checkout took longer than twenty to render
  // its form and the reader kept a spinner; six rounds, so a page that
  // never stops moving still stops being re-read.
  const LATE_WINDOW_MS = 90000;
  const LATE_THRESHOLD = 20;
  // Few nodes can still be the page. Demoblaze fills its product a second
  // after loading: name, price and description, nine nodes and 175
  // characters. Read before that, the store was described as empty and
  // «¿cuánto cuesta?» went to Google. A paragraph of new text is a change;
  // a ticker brings a few characters at a time, an ad slot none.
  const LATE_TEXT_THRESHOLD = 100;
  const LATE_MAX_ROUNDS = 6;
  /// How long a change may keep churning before it is read anyway.
  const LATE_DEADLINE_MS = 2500;
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
    let pendingText = 0;
    let quiet = null;
    let deadline = null;

    function read() {
      clearTimeout(quiet);
      clearTimeout(deadline);
      observer.disconnect();
      if (lateObserver === observer) lateObserver = null;
      extractAndSend(true);
    }

    const observer = new MutationObserver(function (records) {
      for (const record of records) {
        if (record.type === "attributes") {
          // An accordion opens by a class: nothing is added, a subtree is
          // shown. The checkout's passenger form appeared that way and
          // the reader kept a spinner. Weigh what the change reveals.
          const target = record.target;
          if (target.nodeType === Node.ELEMENT_NODE) pending += 1 + target.querySelectorAll("*").length;
          continue;
        }
        pending += weight(record.addedNodes) + weight(record.removedNodes);
        for (const node of record.addedNodes) pendingText += (node.textContent || "").trim().length;
      }
      if (pending < LATE_THRESHOLD && pendingText < LATE_TEXT_THRESHOLD) return;
      // Wait for quiet, but not forever. A spinner animating by class
      // never leaves 600 ms of silence, and the checkout's passenger
      // form sat there unread until the person pressed "Leer de nuevo".
      // Reading too early costs nothing now: a reading that says the
      // same thing is not sent, and the observer arms again after.
      if (!deadline) deadline = setTimeout(read, LATE_DEADLINE_MS);
      clearTimeout(quiet);
      quiet = setTimeout(read, 600);
    });
    observer.observe(document.documentElement, {
      childList: true, subtree: true,
      attributes: true, attributeFilter: ["class", "style", "hidden", "aria-hidden", "aria-expanded", "open", "disabled"],
    });
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

    /*
     * A fragment is a move inside the same document.
     *
     * `documentKey` deliberately ignores the hash — two fragments of one page
     * are not two pages — so `routeChanged` never fires for them. But now
     * that a link into this same page is pressed instead of loaded, a tab
     * strip or an accordion built on fragments changes the page and nothing
     * was watching: the reader kept whatever it had read before the tap.
     */
    window.addEventListener("hashchange", function () {
      whenSettled(function () { extractAndSend(true); });
    });

    // The title arrives after the page: "Ofertas de vuelos" was still read
    // as "Calendario de vuelos" because the SPA renamed the document after
    // the last extraction. A new title is worth one more read.
    // Watched from <head>, not from the <title> node: React Helmet swaps
    // the node out, and an observer on the old one hears nothing.
    let lastTitle = document.title;
    let titleTimer = null;
    new MutationObserver(function () {
      if (document.title === lastTitle) return;
      lastTitle = document.title;
      clearTimeout(titleTimer);
      titleTimer = setTimeout(function () { whenSettled(extractAndSend); }, 600);
    }).observe(document.head || document.documentElement, { childList: true, characterData: true, subtree: true });
  })();

  /*
   * A page that comes back from the back/forward cache loads nothing.
   *
   * "Volver" restores the previous document as it was — no parse, no
   * document end, so this script does not run again and nobody tells the
   * reader that the page is there. It waited out its whole timeout on a
   * page that had been ready from the first instant. `persisted` is how the
   * page says it was restored rather than loaded.
   */
  window.addEventListener("pageshow", function (event) {
    if (event.persisted) whenSettled(extractAndSend);
  });

  // No scrolling to wake lazy content any more: the reader is the page the
  // person sees, and it jumped to the bottom and back on every load, and
  // Clarín's video players started as they scrolled into view (Daniel).
  // Measured without it on Clarín, La Nación, El Universo and 20minutos: the
  // same text within 1 %; Clarín, which it was written for, identical.
  whenSettled(extractAndSend);
})();
