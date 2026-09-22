"""Arma los prompts de Gemini desde Sources/Intelligence/prompts.json, igual que
Prompts.swift en la app: lo que se prueba es lo que corre.

    import prompts_gemini as P
    sistema = P.sistema("ruteador", idioma="es")
    usuario = P.mensaje("ruteador", {"pedido": "...", "pagina": "..."})
    formato = P.formato("ruteador")          # response_format con json_schema
"""
from __future__ import annotations

import json
import pathlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
PROMPTS = json.loads((RAIZ / "Sources/Intelligence/prompts.json").read_text())
CRITERIOS = json.loads((RAIZ / "Sources/Intelligence/criterios.json").read_text())
DECISIONES = json.loads((RAIZ / "Sources/Intelligence/decisiones.json").read_text())["decisiones"]


def _completar(texto: str, idioma: str, hoy: str) -> str:
    ruido = CRITERIOS["ruido"]
    for clave, valor in {"{idioma}": idioma, "{hoy}": hoy, "{ruido_es}": ruido["es"],
                         "{ruido_no_es}": ruido["no_es"], "{ruido_tipos}": ", ".join(ruido["tipos"])}.items():
        texto = texto.replace(clave, valor)
    return texto


def sistema(nombre: str, idioma: str, hoy: str = "") -> str:
    """Rol, qué recibe, acciones si las hay, reglas (las del prompt, las de
    hablarle a la persona si corresponde, y las comunes) y las decisiones."""
    p, h = PROMPTS["prompts"][nombre], PROMPTS["encabezados"]
    partes = [p["rol"], h["recibe"] + "\n" + "\n".join(f"- {e['etiqueta']}: {e['es']}" for e in p["recibe"])]
    if p.get("acciones"):
        partes.append(h["acciones"] + "\n" + "\n".join(f"- {a['accion']}: {a['es']}" for a in p["acciones"]))
    reglas = p["reglas"] + (PROMPTS["para_la_persona"] if p.get("para_la_persona") else []) + PROMPTS["comunes"]
    partes.append(h["reglas"] + "\n" + "\n".join(f"- {r}" for r in reglas))
    partes.append(h["decisiones"] + "\n" + "\n".join(f"- {d}" for d in DECISIONES))
    return _completar("\n\n".join(partes), idioma, hoy)


def mensaje(nombre: str, valores: dict[str, str | None]) -> str:
    """Los datos, con las etiquetas del prompt, en su orden. Lo vacío no va."""
    p = PROMPTS["prompts"][nombre]
    return "\n\n".join(f"{e['etiqueta']}:\n{valores[e['clave']]}" for e in p["recibe"]
                       if valores.get(e["clave"]))


def formato(nombre: str) -> dict:
    """El response_format: la forma de la respuesta la garantiza la API."""
    esquema = json.dumps(PROMPTS["prompts"][nombre]["devuelve"])
    esquema = esquema.replace('"{ruido_tipos}"', json.dumps(CRITERIOS["ruido"]["tipos"]))
    return {"type": "json_schema", "json_schema": {"name": nombre, "strict": True, "schema": json.loads(esquema)}}
