#!/usr/bin/env node
/*
 * Qué leería VoiceOver antes y después de reparar la página.
 *
 * La regla de esta casa es comparar el original contra el nuestro, parada por
 * parada. Acá eso se puede medir sin tocar nada: el motor calcula el nombre
 * accesible de cada control con el mismo algoritmo que usa VoiceOver para
 * decidir qué pronunciar, así que se le pide el árbol dos veces —antes de
 * inyectar el extractor y después— y se cuentan los controles que quedaron
 * mudos.
 *
 * Esto NO es fiarse del árbol del sitio. El árbol del sitio es justamente lo
 * que está mal; lo que se mide es cuánto de ese daño queda en pie.
 *
 *   ./Scripts/voiceover-gap.js https://www.lanacion.com.ar
 *   ./Scripts/voiceover-gap.js --all
 *
 * Necesita playwright-core y Google Chrome, igual que read-page.js.
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
  process.exit(1);
}

/// Un control que VoiceOver anuncia sin poder decir qué es.
const SPEAKS = new Set([
  "button", "link", "checkbox", "radio", "tab", "menuitem", "switch",
  "combobox", "textbox", "searchbox", "slider",
]);

/// "×" no es una palabra. Misma regla que el extractor.
const LONE_GLYPH = /^[\s×✕✖✗xX+−·•–—<>‹›«»←-⇿✀-➿]{1,2}$/;

/// El nombre que delata que nadie escribió uno: el archivo de la imagen.
const FILENAME = /\.(jpe?g|png|gif|webp|svg|avif)\b/i;

/*
 * El árbol accesible entero, pedido por CDP.
 *
 * No es el árbol que el sitio declara: es el que el motor COMPUTA, con el
 * mismo algoritmo de nombre accesible que después usa VoiceOver para decidir
 * qué pronunciar. Un botón que acá sale sin nombre es un botón que la persona
 * va a oír como "botón", y nada más.
 *
 * Se piden los nodos ignorados también: un nodo sin nombre es, para Chrome,
 * poco interesante — y es exactamente el que estamos buscando.
 */
async function measure(cdp) {
  const { nodes } = await cdp.send("Accessibility.getFullAXTree");
  const mute = [];
  const glyph = [];
  const filename = [];
  let controls = 0;

  for (const node of nodes) {
    if (node.ignored) continue;
    const role = (node.role && node.role.value) || "";
    const name = ((node.name && node.name.value) || "").trim();
    if (SPEAKS.has(role)) {
      controls++;
      if (!name) mute.push(role);
      else if (LONE_GLYPH.test(name)) glyph.push(role + ": " + name);
    }
    if (role === "image" && FILENAME.test(name)) filename.push(name.slice(0, 50));
  }

  return { controls, mute: mute.length, glyph: glyph.length, filename: filename.length,
           samples: { glyph: glyph.slice(0, 3), filename: filename.slice(0, 3) } };
}

async function look(browser, url, verbose) {
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true, locale: "es-AR",
    userAgent: IPHONE,
  });
  const page = await context.newPage();
  await page.addInitScript(() => {
    window.__jef = [];
    window.webkit = { messageHandlers: new Proxy({}, { get: (_, n) => ({ postMessage: m => {
      if (n === "jefExtract") window.__jef.push(m);
    } }) }) };
  });

  const cdp = await context.newCDPSession(page);
  await cdp.send("Accessibility.enable");

  try {
    await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
    await page.waitForTimeout(4000);

    const before = await measure(cdp);

    await page.addScriptTag({ path: path.join(ROOT, "Readability.js") });
    await page.addScriptTag({ path: path.join(ROOT, "extract.js") });
    await page.waitForFunction(() => window.__jef.length > 0, null, { timeout: 60000 });
    await page.waitForTimeout(800);

    const after = await measure(cdp);
    const payload = JSON.parse(await page.evaluate(() => window.__jef[window.__jef.length - 1]));
    const fixed = (payload.stats && payload.stats.repaired) || {};

    if (verbose) {
      console.log(`\n${url}`);
      console.log(`  controles: ${before.controls}`);
      console.log(`  mudos:        ${before.mute} → ${after.mute}`);
      console.log(`  sólo un signo: ${before.glyph} → ${after.glyph}`);
      console.log(`  nombre = archivo: ${before.filename} → ${after.filename}`);
      console.log(`  reparados: ${fixed.named || 0} nombres, ${fixed.quieted || 0} imágenes, ${fixed.silenced || 0} adornos`);
      if (before.samples.glyph.length) console.log(`  ej. signo: ${before.samples.glyph.join(" | ")}`);
      if (before.samples.filename.length) console.log(`  ej. archivo: ${before.samples.filename.join(" | ")}`);
    } else {
      const gap = before.mute + before.glyph + before.filename;
      const rest = after.mute + after.glyph + after.filename;
      console.log(
        String(url).padEnd(46) +
        ` mudos ${String(before.mute).padStart(3)}→${String(after.mute).padEnd(3)}` +
        ` signo ${String(before.glyph).padStart(2)}→${String(after.glyph).padEnd(2)}` +
        ` archivo ${String(before.filename).padStart(2)}→${String(after.filename).padEnd(2)}` +
        `  total ${String(gap).padStart(3)}→${String(rest).padEnd(3)}` +
        `  (+${fixed.named || 0}n ${fixed.quieted || 0}i ${fixed.silenced || 0}a)`
      );
    }
  } catch (e) {
    console.log(String(url).padEnd(46) + "  FALLÓ: " + String(e.message).slice(0, 70));
  } finally {
    await context.close();
  }
}

(async () => {
  const { chromium } = loadPlaywright();
  const args = process.argv.slice(2);
  const all = args.includes("--all");
  const urls = all
    ? fs.readFileSync(SITES, "utf8").split("\n").map(l => l.trim()).filter(l => l && !l.startsWith("#"))
    : args.filter(a => !a.startsWith("--"));

  if (!urls.length) {
    console.error("Uso: ./Scripts/voiceover-gap.js <url> | --all");
    process.exit(1);
  }

  const browser = await chromium.launch({ channel: "chrome", headless: true });
  for (const url of urls) await look(browser, url, !all);
  await browser.close();
})().catch(e => { console.error("FAIL", e.message); process.exit(1); });
