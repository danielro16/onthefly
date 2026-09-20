/*
 * Lo que un lector de pantalla diría en esta página, parada por parada.
 *
 * Se inyecta en la página viva y devuelve la lista de paradas en orden de
 * lectura: lo mismo que se escucha haciendo swipe a la derecha una y otra
 * vez en Safari. Es la columna contra la que se compara la versión
 * accesible — ver "La prueba que manda" en PROBAR.md.
 *
 * No pretende reproducir VoiceOver al detalle; reproduce su regla central,
 * que es la que importa acá: **una parada por elemento accesible**, y un
 * control con texto adentro es una sola parada, no una por palabra.
 *
 * Emite, por parada: qué diría, de qué tipo es, a dónde lleva si lleva a
 * algún lado, y si estaba visible sin desplegar nada. Nada de esto se le
 * muestra al usuario: es material de prueba.
 */

window.__jefVoiceOverStops = function () {
  "use strict";

  const INTERACTIVE =
    "a[href], button, input:not([type=hidden]), select, textarea, summary, " +
    "[role=button], [role=link], [role=menuitem], [role=tab], [role=checkbox], " +
    "[role=radio], [role=combobox], [role=switch], [tabindex]:not([tabindex='-1'])";

  const HEADING = "h1, h2, h3, h4, h5, h6, [role=heading]";

  // Lo que nunca se dice.
  const MUTE = new Set([
    "SCRIPT", "STYLE", "NOSCRIPT", "TEMPLATE", "HEAD", "LINK", "META",
    "IFRAME", "SVG", "CANVAS", "OPTION", "DATALIST", "AUDIO", "VIDEO",
  ]);

  // Lo que separa una línea de la siguiente. Un lector de pantalla no
  // junta dos bloques en una parada.
  const BLOCK = new Set([
    "ADDRESS", "ARTICLE", "ASIDE", "BLOCKQUOTE", "DD", "DIV", "DL", "DT",
    "FIELDSET", "FIGCAPTION", "FIGURE", "FOOTER", "FORM", "H1", "H2", "H3",
    "H4", "H5", "H6", "HEADER", "HR", "LI", "MAIN", "NAV", "OL", "P", "PRE",
    "SECTION", "TABLE", "TBODY", "TD", "TFOOT", "TH", "THEAD", "TR", "UL",
  ]);

  function hidden(el) {
    if (el.hasAttribute("hidden") || el.getAttribute("aria-hidden") === "true") return true;
    const style = window.getComputedStyle(el);
    return style.display === "none" || style.visibility === "hidden";
  }

  /// Dibujado en alguna parte: un menú cerrado mide cero y no se recorre
  /// hasta que se abre. Se anota, no se descarta — llegar a él es
  /// justamente lo que hay que comparar.
  function drawn(el) {
    const rect = el.getBoundingClientRect();
    return rect.width >= 2 && rect.height >= 2;
  }

  function flat(text) {
    return (text || "").replace(/\s+/g, " ").trim();
  }

  /// El nombre accesible, en el orden en que lo resuelve un lector de
  /// pantalla: aria-label, aria-labelledby, el contenido, el alt de lo que
  /// dibuja, el título.
  function name(el) {
    const aria = flat(el.getAttribute("aria-label"));
    if (aria) return aria;

    const by = el.getAttribute("aria-labelledby");
    if (by) {
      const parts = by.split(/\s+/)
        .map(function (id) { return document.getElementById(id); })
        .filter(Boolean)
        .map(function (target) { return flat(target.textContent); })
        .filter(Boolean);
      if (parts.length) return parts.join(" ");
    }

    const own = flat(el.textContent);
    if (own) return own;

    const img = el.querySelector("img[alt], [role=img][aria-label]");
    if (img) {
      const alt = flat(img.getAttribute("alt") || img.getAttribute("aria-label"));
      if (alt) return alt;
    }

    const title = el.querySelector("svg > title");
    if (title && flat(title.textContent)) return flat(title.textContent);

    if (el.tagName === "INPUT") {
      const value = flat(el.getAttribute("value"));
      if (value) return value;
      const placeholder = flat(el.getAttribute("placeholder"));
      if (placeholder) return placeholder;
    }

    return flat(el.getAttribute("title"));
  }

  /// El nombre de un campo: su label, como lo resuelve un lector.
  function fieldName(el) {
    const own = name(el);
    if (own) return own;
    const id = el.getAttribute("id");
    if (id) {
      try {
        const label = document.querySelector('label[for="' + CSS.escape(id) + '"]');
        if (label) return flat(label.textContent);
      } catch (_) { /* id malformado */ }
    }
    const wrapper = el.closest("label");
    if (wrapper) return flat(wrapper.textContent);
    return flat(el.getAttribute("name"));
  }

  function role(el) {
    const declared = el.getAttribute("role");
    if (declared) return declared;
    switch (el.tagName) {
      case "A": return el.hasAttribute("href") ? "link" : "text";
      case "BUTTON": case "SUMMARY": return "button";
      case "SELECT": case "TEXTAREA": return "field";
      case "INPUT": {
        const type = (el.getAttribute("type") || "text").toLowerCase();
        if (type === "submit" || type === "button" || type === "reset" || type === "image") return "button";
        if (type === "checkbox" || type === "radio") return type;
        return "field";
      }
      case "IMG": return "image";
      default: return "text";
    }
  }

  const stops = [];
  const claimed = new WeakSet();

  function push(el, kind, label, extra) {
    label = flat(label);
    if (!label) return;
    const entry = { kind: kind, label: label.slice(0, 200) };
    if (el) {
      const href = el.tagName === "A" ? el.getAttribute("href") : null;
      if (href) {
        try { entry.href = new URL(href, document.baseURI).href; } catch (_) { /* malformado */ }
      }
      if (!drawn(el)) entry.offscreen = true;
      const heading = el.closest(HEADING) || (el.matches && el.matches(HEADING) ? el : null);
      if (heading) entry.heading = true;
    }
    if (extra) Object.assign(entry, extra);
    stops.push(entry);
  }

  /// Un control es UNA parada, diga lo que diga adentro. Todo lo que tiene
  /// dentro deja de ser parada propia — ésa es la regla que hace que un
  /// titular envuelto en un link no se escuche dos veces.
  function claim(el) {
    claimed.add(el);
    for (const inner of el.querySelectorAll("*")) claimed.add(inner);
  }

  (function walk(node) {
    let run = "";

    function flush() {
      const text = flat(run);
      run = "";
      if (text) push(null, "text", text);
    }

    for (const child of node.childNodes) {
      if (child.nodeType === Node.TEXT_NODE) {
        if (!claimed.has(node)) run += child.textContent;
        continue;
      }
      if (child.nodeType !== Node.ELEMENT_NODE) continue;
      if (MUTE.has(child.tagName) || hidden(child)) continue;

      if (claimed.has(child)) continue;

      // Un control: una parada, y lo de adentro queda tomado.
      if (child.matches(INTERACTIVE)) {
        flush();
        claim(child);
        const kind = role(child);
        const label = kind === "field" || kind === "checkbox" || kind === "radio"
          ? fieldName(child)
          : name(child);
        push(child, kind, label || "(sin nombre)");
        continue;
      }

      if (child.tagName === "IMG") {
        flush();
        const alt = flat(child.getAttribute("alt"));
        // Una imagen sin alt es decorativa y no se dice. Con alt vacío,
        // tampoco: así se marca lo decorativo en HTML.
        if (alt) push(child, "image", alt);
        continue;
      }

      const blockish = BLOCK.has(child.tagName);
      if (blockish) flush();
      walk(child);
      if (blockish) flush();
    }

    flush();
  })(document.body);

  return stops;
};
