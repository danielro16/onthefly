const { chromium } = require(process.env.PW);
const IPHONE = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1";
(async () => {
  const [url, locale, abrir] = [process.argv[2], process.argv[3] || "es-AR", process.argv[4]];
  const browser = await chromium.launch({ channel: "chrome", headless: true });
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true, locale, userAgent: IPHONE });
  const page = await ctx.newPage();
  try { await page.goto(url, { waitUntil: "load", timeout: 45000 }); } catch (e) {}
  await page.waitForTimeout(4000);
  if (abrir) { try { await page.click(abrir, { timeout: 3000 }); await page.waitForTimeout(1500); } catch (e) { console.log(url, "no se pudo abrir", abrir); } }
  const out = await page.evaluate(() => {
    const vis = el => { const r = el.getBoundingClientRect(); const s = getComputedStyle(el); return r.width > 0 && r.height > 0 && s.visibility !== "hidden" && s.display !== "none"; };
    const info = (el, how) => {
      const links = el.querySelectorAll("a[href]").length;
      const nav = !!(el.matches("nav, [role=navigation]") || el.querySelector("nav, [role=navigation]"));
      const buttons = Array.from(el.querySelectorAll("button, [role=button], input[type=submit], input[type=button]")).filter(vis);
      const named = buttons.filter(b => (b.innerText || b.getAttribute("aria-label") || b.value || "").trim());
      const words = /cookie|consentimiento|consent|gdpr|rgpd/i.test((el.innerText || "").slice(0, 600));
      const many = links >= 12 || (links >= 5 && nav);
      let linkText = 0;
      for (const c of el.querySelectorAll("a[href], button, [role=button], select, option, input")) {
        if (c.parentElement && c.parentElement.closest("a[href], button, [role=button], select")) continue;
        linkText += (c.innerText || c.value || "").replace(/\s+/g, " ").trim().length;
      }
      const all = (el.innerText || "").replace(/\s+/g, " ").trim().length;
      return { how, links, nav, prose: Math.max(0, all - linkText), all, named: named.length, names: named.slice(0, 6).map(b => (b.innerText || b.getAttribute("aria-label") || b.value || "").trim().slice(0, 22)), words, many, text: (el.innerText || "").replace(/\s+/g, " ").slice(0, 60) };
    };
    const res = [];
    for (const el of document.querySelectorAll("[role=dialog], [role=alertdialog], [aria-modal=true], dialog[open]")) if (vis(el)) res.push(info(el, "declarado"));
    const area = innerWidth * innerHeight;
    for (const el of document.body.querySelectorAll("div, section, aside")) {
      const s = getComputedStyle(el);
      if (s.position !== "fixed" && s.position !== "sticky") continue;
      if (!vis(el)) continue;
      if ((parseInt(s.zIndex, 10) || 0) < 10) continue;
      const r = el.getBoundingClientRect();
      if (r.width * r.height < area * 0.2) continue;
      res.push(info(el, "fijo"));
    }
    return res;
  });
  for (const d of out) if (d.many) console.log(url, JSON.stringify(d));
  if (!out.some(d => d.many)) console.log(url, "ninguno con muchos links", out.length);
  await browser.close();
})();
