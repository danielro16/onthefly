#!/usr/bin/env python3
"""Corre las 60 intenciones contra el ruteador REAL.

Saca las instrucciones de Router.swift tal como estan —si alguien las cambia
alla, esto lo refleja— y le pide a cada frase una decision, con el estado que
corresponde al momento en que fue dicha.

    ./Scripts/probar-ruteo.py            # las 60
    ./Scripts/probar-ruteo.py --breve    # solo el conteo
    ./Scripts/probar-ruteo.py --modelo google/gemini-3.1-flash-lite --json /tmp/x.json   # otro modelo
"""
import json, re, os, sys, pathlib, urllib.request
from concurrent.futures import ThreadPoolExecutor

RAIZ = pathlib.Path(__file__).resolve().parent.parent
KEY = next(l.split("=",1)[1].strip() for l in (RAIZ/".env").read_text().split("\n")
           if l.startswith("AI_GATEWAY_API_KEY="))
SRC = (RAIZ/"Sources/Intelligence/Router.swift").read_text()
INSTR = re.search(r'private static let instructions = """\n(.*?)\n        """', SRC, re.S).group(1)
INSTR = "\n".join(l[8:] if l.startswith(" "*8) else l for l in INSTR.split("\n"))
MODELO = re.search(r'model: String = "([^"]+)"', SRC).group(1)
if "--modelo" in sys.argv: MODELO = sys.argv[sys.argv.index("--modelo") + 1]

ESTADOS = {
 "sin-pagina":   "No hay ninguna página abierta todavía.",
 "en-portada":   "Está en «Portada», en lanacion.com.ar. La página lista 42 titulares que se pueden abrir.",
 "en-nota":      "Está en «El dólar blue cerró a $1.550», en lanacion.com.ar. Es un texto largo: 14 párrafos. Le están leyendo este texto: va por el bloque 3 de 14.",
 "en-resultados":"Está en «turnos pasaporte», en lite.duckduckgo.com. Hay 8 elementos en listas.",
 "en-formulario":"Está en «Ingresar», en argentina.gob.ar. Hay un formulario con estos campos: usuario, clave, dni.",
}

def decidir(caso):
    cuerpo = json.dumps({
        "model": MODELO, "reasoning": {"enabled": False}, "max_tokens": 200,
        "response_format": {"type": "json_object"},
        "messages": [{"role":"system","content":INSTR},
                     {"role":"user","content":f"PIDIÓ: {caso['frase']}\n\nDÓNDE ESTÁ: {ESTADOS[caso['momento']]}"}],
    }).encode()
    req = urllib.request.Request("https://ai-gateway.vercel.sh/v1/chat/completions", data=cuerpo,
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
with ThreadPoolExecutor(max_workers=2) as pool:
    salidas = list(pool.map(decidir, casos))

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
tiempos = sorted(s[1]["_s"] for s in ok if "_s" in s[1])
if tiempos:
    print(f"tiempo por decisión: mediana {tiempos[len(tiempos)//2]} s · peor {tiempos[-1]} s")
costo = tin*0.10e-6 + tout*0.40e-6
print(f"\n{len(ok)} de {len(casos)} ruteados · {tin} tokens entrada / {tout} salida · US$ {costo:.5f}")
if ok:
    # Por turno REAL: sobre los que contestaron, no sobre los 60. Dividir por
    # 60 cuando 21 fallaron hace parecer el ruteo mas barato de lo que es.
    porturno = costo/len(ok)
    print(f"por turno: US$ {porturno:.7f}  →  120M turnos/mes = US$ {porturno*120_000_000:,.0f}")
