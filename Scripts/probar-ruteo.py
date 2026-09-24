#!/usr/bin/env python3
"""Corre las 60 intenciones contra el ruteador REAL.

Arma el prompt desde Sources/Intelligence/prompts.json con el mismo
constructor que la app —si alguien lo cambia, esto lo refleja— y le pide a
cada frase una decision, con el estado que corresponde al momento en que fue
dicha.

    ./Scripts/probar-ruteo.py            # las 60
    ./Scripts/probar-ruteo.py --google --corridas 3   # tres veces cada una, con puntaje
    ./Scripts/probar-ruteo.py --breve    # solo el conteo
    ./Scripts/probar-ruteo.py --modelo google/gemini-3.1-flash-lite --json /tmp/x.json   # otro modelo
    ./Scripts/probar-ruteo.py --google --modelo gemini-3.1-flash-lite   # directo a Google (GEMINI_API_KEY)
"""
import json, re, os, sys, pathlib, urllib.request
from concurrent.futures import ThreadPoolExecutor

RAIZ = pathlib.Path(__file__).resolve().parent.parent
GOOGLE = "--google" in sys.argv
KEY = next(l.split("=",1)[1].strip() for l in (RAIZ/".env").read_text().split("\n")
           if l.startswith("GEMINI_API_KEY=" if GOOGLE else "AI_GATEWAY_API_KEY="))
URL = ("https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" if GOOGLE
       else "https://ai-gateway.vercel.sh/v1/chat/completions")
# Por millón de tokens, entrada y salida.
PRECIOS = {"gemini-2.5-flash-lite": (0.10, 0.40), "gemini-3.1-flash-lite": (0.25, 1.50),
           "gemini-2.5-flash": (0.30, 2.50), "gemini-3-flash-preview": (0.50, 3.00),
           "glm-5.3-flash": (0.15, 0.50)}
# El prompt, armado desde prompts.json con el mismo constructor que la app
# (Prompts.swift ↔ Scripts/prompts_gemini.py): lo que se prueba es lo que corre.
sys.path.insert(0, str(RAIZ / "Scripts"))
import prompts_gemini as P
INSTR = P.sistema("ruteador", idioma="español")
FORMATO = P.formato("ruteador")
MODELO = (re.search(r'model: "(gemini-[^"]+)"', (RAIZ/"Sources/Intelligence/Gemini.swift").read_text()).group(1) if GOOGLE
          else re.search(r'gateway: "([^"]+)"', (RAIZ/"Sources/Intelligence/Router.swift").read_text()).group(1))
if "--modelo" in sys.argv: MODELO = sys.argv[sys.argv.index("--modelo") + 1]

ESTADOS = {
 "sin-pagina":   "No page is open yet.",
 "en-portada":   "On «Portada», at lanacion.com.ar. The page lists 42 headlines that can be opened.",
 "en-nota":      "On «El dólar blue cerró a $1.550», at lanacion.com.ar. It is a long text: 14 paragraphs. It is being read to them: at block 3 of 14.",
 "en-resultados":"On «turnos pasaporte», at lite.duckduckgo.com. There are 8 items in lists.",
 "en-formulario":"On «Ingresar», at argentina.gob.ar. There is a form with these fields: usuario, clave, dni.",
}

def decidir(caso):
    # Como en la app: el ruteador razona poco ("dejale al modelo que razone
    # las intenciones", Daniel), con las decisiones de decisiones.json.
    razonar = {"reasoning_effort": "low"} if GOOGLE else {"reasoning": {"enabled": True}}
    cuerpo = json.dumps({
        "model": MODELO, **razonar, "max_tokens": 1000,
        "response_format": FORMATO,
        "messages": [{"role":"system","content":INSTR},
                     {"role":"user","content":P.mensaje("ruteador", {"pedido": caso["frase"], "pagina": ESTADOS[caso["momento"]]})}],
    }).encode()
    req = urllib.request.Request(URL, data=cuerpo,
          headers={"Authorization":f"Bearer {KEY}","Content-Type":"application/json"})
    import time
    for intento in range(5):
        try:
            inicio = time.time()
            with urllib.request.urlopen(req, timeout=60) as r:
                out = json.loads(r.read())
            d = json.loads(out["choices"][0]["message"]["content"])
            d["_s"] = round(time.time() - inicio, 2)
            u = out.get("usage", {})
            return caso, d, u.get("prompt_tokens",0), u.get("completion_tokens",0)
        except Exception as e:
            ultimo = f"{type(e).__name__}: {str(e)[:70]}"
            if intento == 4: return caso, {"action":"ERROR","_e":ultimo}, 0, 0
            time.sleep(3.0 * (intento + 1))

casos = json.loads((RAIZ/"Tests/intenciones.json").read_text())["intenciones"]
CORRIDAS = int(sys.argv[sys.argv.index("--corridas") + 1]) if "--corridas" in sys.argv else 1
with ThreadPoolExecutor(max_workers=6) as pool:
    todas = list(pool.map(decidir, [c for c in casos for _ in range(CORRIDAS)]))
salidas = todas[::CORRIDAS]

def acierta(caso, d):
    """Contra «espera»: la acción está entre las aceptables, y el segundo paso también, donde importa."""
    espera = caso.get("espera")
    if not espera or d.get("action") not in espera["accion"]:
        return False
    return d.get("then") in espera["then"] if "then" in espera else True

tin = sum(s[2] for s in salidas); tout = sum(s[3] for s in salidas)
por_momento = {}
for caso, d, _, _ in salidas: por_momento.setdefault(caso["momento"], []).append((caso, d))

if "--breve" not in sys.argv:
    for momento in ["sin-pagina","en-portada","en-nota","en-resultados","en-formulario"]:
        print(f"\n=== {momento} ===")
        for caso, d in por_momento.get(momento, []):
            if d.get("_e"): print(f"  ERROR      {caso['frase'][:52]:54} {d['_e']}"); continue
            extra = " ".join(f"{k}={json.dumps(v,ensure_ascii=False)}" for k,v in d.items()
                             if k not in ("action","_e","_s") and v not in (None,"","null"))
            print(f"  {d.get('action','?'):10} {caso['frase'][:52]:54} {extra[:70]}")

ok = [s for s in salidas if s[1].get("action") not in ("ERROR", None)]
if "--json" in sys.argv:
    destino = pathlib.Path(sys.argv[sys.argv.index("--json") + 1])
    destino.write_text(json.dumps([{"frase": c["frase"], "quiere": c["quiere"], "momento": c["momento"], "decision": d}
                                    for c, d, _, _ in salidas], ensure_ascii=False, indent=1))
aciertos = sum(acierta(c, d) for c, d, _, _ in todas)
estables = sum(len({(d.get("action"), d.get("then")) for c2, d, _, _ in todas if c2 is c}) == 1 for c in casos)
print(f"\naciertos contra «espera»: {aciertos} de {len(todas)} ({aciertos/len(todas):.0%})"
      + (f" · estables en las {CORRIDAS} corridas: {estables} de {len(casos)}" if CORRIDAS > 1 else ""))
if "--breve" not in sys.argv:
    for c in casos:
        rs = [d for c2, d, _, _ in todas if c2 is c]
        if not all(acierta(c, d) for d in rs):
            print(f"  ✗ [{c['momento']}] «{c['frase'][:55]}» espera {c['espera']['accion']}: "
                  + ", ".join(f"{d.get('action')}{'→'+str(d['then']) if d.get('then') else ''}" for d in rs))
tiempos = sorted(s[1]["_s"] for s in ok if "_s" in s[1])
if tiempos:
    print(f"tiempo por decisión: mediana {tiempos[len(tiempos)//2]} s · peor {tiempos[-1]} s")
entrada, salida = PRECIOS.get(MODELO.split("/")[-1], (0.10, 0.40))
costo = tin*entrada*1e-6 + tout*salida*1e-6
print(f"\n{len(ok)} de {len(casos)} ruteados · {tin} tokens entrada / {tout} salida · US$ {costo:.5f}")
if ok:
    # Por turno REAL: sobre los que contestaron, no sobre los 60. Dividir por
    # 60 cuando 21 fallaron hace parecer el ruteo mas barato de lo que es.
    porturno = costo/len(ok)
    print(f"por turno: US$ {porturno:.7f}  →  120M turnos/mes = US$ {porturno*120_000_000:,.0f}")
