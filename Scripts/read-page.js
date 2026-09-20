#!/usr/bin/env node
/*
 * Lee una página con el extractor real, sin simulador.
 *
 * Abre la URL en Chrome como un iPhone, inyecta Readability.js y extract.js
 * tal como lo hace la app, y muestra el recorrido en el orden en que
 * VoiceOver lo diría. Veinte segundos por página, contra dos minutos de
 * compilar, instalar y tocar.
 *
 *   ./Scripts/read-page.js https://www.lanacion.com.ar
 *   ./Scripts/read-page.js https://... --json /tmp/pagina.json
 *   ./Scripts/read-page.js --all          # una línea por sitio de Tests/sites.txt
 *
 * `--all` es la red de regresión: cada arreglo del extractor es una regla
 * sobre el DOM, y una regla nueva puede romper un sitio que ya andaba sin que
 * nadie se entere. Correrlo antes de cada commit que toque extract.js.
 *
 * Lo que NO ve: el WebView real. Chrome avanza transiciones y frames que un
 * WKWebView fuera de pantalla congela, así que un menú que acá abre puede no
 * abrir en la app. Para eso, el simulador.
 *
 * Necesita playwright-core (`npx -y playwright-core --version` lo deja en la
 * caché de npx) y Google Chrome instalado.
 */

const fs = require("fs");
const os = require("os");
const path = require("path");

const ROOT = path.join(__dirname, "..", "Sources", "Extraction");
const SITES = path.join(__dirname, "..", "Tests", "sites.txt");
const IPHONE =
  "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1";

function loadPlaywright() {
  try {
    return require("playwright-core");
  } catch (_) {
    const cache = path.join(os.homedir(), ".npm", "_npx");
    const dirs = fs.existsSync(cache) ? fs.readdirSync(cache) : [];
    for (const dir of dirs) {
      const candidate = path.join(cache, dir, "node_modules", "playwright-core");
      if (fs.existsSync(candidate)) return require(candidate);
    }
  }
  console.error("Falta playwright-core. Corré: npx -y playwright-core --version");
  process.exit(2);
}

async function read(browser, url, waitMs) {
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 },
    isMobile: true,
    hasTouch: true,
    locale: "es-AR",
    userAgent: IPHONE,
  });
  const page = await context.newPage();
  // El puente que en la app es un message handler de WebKit.
  await page.addInitScript(() => {
    window.__jef = [];
    window.webkit = {
      messageHandlers: new Proxy({}, {
        get: (_, name) => ({ postMessage: (m) => { if (name === "jefExtract") window.__jef.push(m); } }),
      }),
    };
  });
  try {
    await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
    // Un login redirige dos o tres veces antes de quedarse quieto.
    await page.waitForTimeout(waitMs);
    await page.waitForLoadState("domcontentloaded");
    await page.addScriptTag({ path: path.join(ROOT, "Readability.js") });
    await page.addScriptTag({ path: path.join(ROOT, "extract.js") });
    await page.waitForFunction(() => window.__jef.length > 0, null, { timeout: 60000 });
    await page.waitForTimeout(1500);
    const payload = JSON.parse(await page.evaluate(() => window.__jef[window.__jef.length - 1]));

    // Los titulares de la página original, por URL: contra qué se mide que
    // una portada llegó entera.
    const headlines = await page.evaluate(() => {
      const found = new Set();
      for (const h of document.querySelectorAll("h1, h2, h3, h4")) {
        const rect = h.getBoundingClientRect();
        const style = getComputedStyle(h);
        if (rect.width < 2 || rect.height < 2 || style.visibility === "hidden" || style.display === "none") continue;
        let a = h.closest("a[href]") || h.querySelector("a[href]");
        if (!a) {
          // El link como capa vacía sobre la tarjeta: clarin.com.
          const card = h.closest("article, li, [class*=card], [class*=story]");
          if (card && card.querySelectorAll("h1, h2, h3, h4").length === 1) a = card.querySelector("a[href]");
        }
        if (a && (h.textContent || "").trim().length >= 25) found.add(a.href);
      }
      return [...found];
    });
    return { payload, headlines };
  } finally {
    await context.close();
  }
}

function hrefsIn(payload) {
  const listings = new Map((payload.listings || []).map((l) => [l.id, l]));
  const actions = new Map((payload.actions || []).map((a) => [a.id, a]));
  const hrefs = new Set();
  for (const entry of payload.stream || []) {
    if (entry.kind === "link") hrefs.add(entry.href);
    if (entry.kind === "listing") for (const item of (listings.get(entry.ref) || { items: [] }).items) if (item.href) hrefs.add(item.href);
    if (entry.kind === "action" && (actions.get(entry.ref) || {}).href) hrefs.add(actions.get(entry.ref).href);
    if (entry.kind === "block") for (const link of entry.block.links || []) hrefs.add(link.href);
  }
  return hrefs;
}

function summary(url, payload, headlines) {
  if (!payload.ok) return `${url}\n  FALLÓ: ${payload.reason} ${payload.message || ""}`;
  const stream = payload.stream || [];
  const reached = hrefsIn(payload);
  const kept = headlines.filter((h) => reached.has(h)).length;
  const noise = stream.filter((e) => e.noise).length;
  return [
    url,
    `  paradas originales ${payload.stats.originalStops} · recorrido ${stream.length} · ruido ${noise}`,
    `  titulares ${kept}/${headlines.length} · acciones ${payload.actions.length} · listados ${payload.listings.length}` +
      (payload.overlay ? ` · aviso: ${payload.overlay.kind}` : ""),
  ].join("\n");
}

function print(payload) {
  const actions = new Map(payload.actions.map((a) => [a.id, a]));
  const listings = new Map(payload.listings.map((l) => [l.id, l]));
  for (const entry of payload.stream || []) {
    const mark = entry.noise ? "  [ruido]" : "";
    const zone = entry.zone.padEnd(8);
    if (entry.kind === "block") {
      const block = entry.block;
      const text = block.text || block.alt || block.caption || (block.items ? `${block.items.length} ítems` : "");
      console.log(`  ${zone} ${block.type.padEnd(10)} ${JSON.stringify(text.slice(0, 90))}${mark}`);
    } else if (entry.kind === "action") {
      const action = actions.get(entry.ref);
      if (action.kind === "form") {
        const fields = action.fields.map((f) => f.name).join(", ");
        console.log(`  ${zone} ${"FORMULARIO".padEnd(10)} ${JSON.stringify(action.label)} [${fields}] → ${JSON.stringify(action.submit)}${mark}`);
      } else {
        console.log(`  ${zone} ${action.kind.padEnd(10)} ${JSON.stringify(action.label.slice(0, 80))} ${entry.group || "-"}${mark}`);
      }
    } else if (entry.kind === "link") {
      const kind = entry.level ? `link h${entry.level}` : "link";
      console.log(`  ${zone} ${kind.padEnd(10)} ${JSON.stringify(entry.label.slice(0, 80))} ${entry.group || "-"}${mark}`);
    } else if (entry.kind === "listing") {
      const listing = listings.get(entry.ref);
      console.log(`  ${zone} ${"LISTADO".padEnd(10)} ${JSON.stringify(listing.title)} (${listing.count})`);
    }
  }
}

(async () => {
  const args = process.argv.slice(2);
  const flag = (name) => { const i = args.indexOf(name); return i === -1 ? null : args[i + 1]; };
  const waitMs = parseInt(flag("--wait") || "4000", 10);
  const all = args.includes("--all");
  const urls = all
    ? fs.readFileSync(SITES, "utf8").split("\n").map((l) => l.trim()).filter((l) => l && !l.startsWith("#"))
    : args.filter((a, i) => !a.startsWith("--") && !(i > 0 && ["--json", "--wait"].includes(args[i - 1])));
  if (!urls.length) {
    console.error("Uso: read-page.js <url> [--json archivo] [--wait ms]  |  read-page.js --all");
    process.exit(2);
  }

  const { chromium } = loadPlaywright();
  const browser = await chromium.launch({ channel: "chrome", headless: true });
  let failed = 0;
  try {
    for (const url of urls) {
      try {
        const { payload, headlines } = await read(browser, url, waitMs);
        console.log(summary(url, payload, headlines));
        if (!payload.ok) failed++;
        if (!all && payload.ok) print(payload);
        const out = flag("--json");
        if (out && !all) fs.writeFileSync(out, JSON.stringify(payload, null, 1));
      } catch (error) {
        failed++;
        console.log(`${url}\n  FALLÓ: ${error.message.split("\n")[0]}`);
      }
    }
  } finally {
    await browser.close();
  }
  process.exit(failed ? 1 : 0);
})();
