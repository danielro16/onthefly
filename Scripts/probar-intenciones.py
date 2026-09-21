#!/usr/bin/env python3
"""Corre las 60 intenciones contra el clasificador REAL del asistente.

No reimplementa nada: saca las funciones puras de Assistant.swift tal como
estan y las compila. Si alguien cambia una expresion regular alla, esto lo
refleja aca — que es todo el punto de una red de regresion.

    ./Scripts/probar-intenciones.py
"""
import json, re, subprocess, sys, pathlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
FUENTE = RAIZ / "Sources/Intelligence/Assistant.swift"
CASOS = RAIZ / "Tests/intenciones.json"

PUROS = [r'static func intent\(of goal: String\) -> Intent\? \{.*?\n    \}']

def main():
    src = FUENTE.read_text()
    trozos = []
    for patron in PUROS:
        m = re.search(patron, src, re.S)
        if not m:
            sys.exit(f"No encontre en Assistant.swift: {patron[:40]}…")
        trozos.append(m.group(0).replace("static func", "func"))

    casos = json.loads(CASOS.read_text())["intenciones"]
    # Las frases van por archivo y no interpoladas: tienen comillas, acentos y
    # angulares, y meterlas dentro de un literal de Swift es pedir que una se
    # escape mal y el compilador culpe a otra cosa.
    frases_json = pathlib.Path("/tmp/jef-frases.json")
    frases_json.write_text(json.dumps([c["frase"] for c in casos], ensure_ascii=False))

    swift = f'''import Foundation
enum Intent {{ case orient, summarize, read, keepReading }}
{chr(10).join(trozos)}
let datos = FileManager.default.contents(atPath: "{frases_json}")!
let frases = try! JSONDecoder().decode([String].self, from: datos)
for f in frases {{
  let g: String
  switch intent(of: f) {{
  case .some(.orient): g = "orient"
  case .some(.summarize): g = "summarize"
  case .some(.read): g = "read"
  case .some(.keepReading): g = "keepReading"
  case nil: g = "-" }}
  print(g)
}}
'''
    tmp = pathlib.Path("/tmp/jef-intenciones.swift")
    tmp.write_text(swift)
    out = subprocess.run(["swift", str(tmp)], capture_output=True, text=True)
    if out.returncode:
        sys.exit(out.stderr[-2000:])
    rutas = out.stdout.strip().split("\n")

    por_momento = {}
    for caso, ruta in zip(casos, rutas):
        por_momento.setdefault(caso["momento"], []).append((caso, ruta))

    for momento in ["sin-pagina", "en-portada", "en-nota", "en-resultados", "en-formulario"]:
        if momento not in por_momento: continue
        print(f"\n=== {momento} ===")
        for caso, ruta in por_momento[momento]:
            marca = ruta if ruta != "-" else "→ Jev/LLM"
            print(f"  {marca:12} {caso['frase'][:66]}")

if __name__ == "__main__":
    main()
