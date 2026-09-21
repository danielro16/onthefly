#!/usr/bin/env python3
"""Arma veredicto.md de una ronda a partir de jueces.json.

    ./Scripts/veredicto.py Tests/corridas/ronda-1
"""
import json
import pathlib
import sys

ronda = pathlib.Path(sys.argv[1])
datos = json.loads((ronda / "jueces.json").read_text())
sintesis = datos["sintesis"]
veredictos = {v["id"]: v for v in datos["veredictos"]}

lineas = [f"# Veredicto — {ronda.name}", "", sintesis["resumen"], "",
          "## Tablero", "", "| Escenario | Logros | Promedio (1-5) |", "|---|---|---|"]
for t in sintesis["tablero"]:
    lineas.append(f"| {t['escenario']} | {t['logros']} | {t['promedio']:.1f} |")
promedios = [t["promedio"] for t in sintesis["tablero"]]
lineas += ["", f"**Promedio general: {sum(promedios) / len(promedios):.2f}**", "", "## Problemas", ""]
for p in sintesis["problemas"]:
    v = veredictos.get(p["id"], {})
    estado = "confirmado" if v.get("real") and not v.get("delArnes") else \
        ("del script de prueba" if v.get("delArnes") else "no confirmado")
    lineas += [f"### {p['id']} · {p['titulo']}", "",
               f"*{p['gravedad']}* · {estado} · jueces: {', '.join(p['jueces'])} · escenarios: {', '.join(p['escenarios'])}", "",
               "Evidencia:"] + [f"- {e}" for e in p["evidencia"]] + [
               "", f"Causa probable: {p['causaProbable']}", "", f"Propuesta: {p['propuesta']}", ""]
    if v.get("motivo"):
        lineas += [f"Escéptico: {v['motivo']}", ""]
lineas += ["## Lo que funciona", ""] + [f"- {x}" for x in sintesis["loQueFunciona"]]
(ronda / "veredicto.md").write_text("\n".join(lineas) + "\n")
print(f"{ronda / 'veredicto.md'}: {len(sintesis['problemas'])} problemas, promedio {sum(promedios) / len(promedios):.2f}")
