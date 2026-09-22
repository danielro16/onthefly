#!/usr/bin/env python3
"""¿De qué país es lo que se pide? Contra el ruteador REAL.

La búsqueda va con la región del país de lo pedido, no con la del teléfono:
"banco nación" desde un iPhone en Estados Unidos se busca en Argentina. Ese
país lo decide el ruteador —el mismo modelo que ya lee cada pedido—, sin
listas de sitios por país. Esto lo mide con pedidos de varios países y con
pedidos que no son de ninguno.

Saca las instrucciones de Router.swift tal como están.

    ./Scripts/probar-pais.py              # el teléfono en Estados Unidos
    ./Scripts/probar-pais.py --region AR  # en otra región
"""
import json
import pathlib
import re
import sys
import time
import urllib.request

RAIZ = pathlib.Path(__file__).resolve().parent.parent
KEY = next(l.split("=", 1)[1].strip() for l in (RAIZ / ".env").read_text().split("\n")
           if l.startswith("AI_GATEWAY_API_KEY="))
SRC = (RAIZ / "Sources/Intelligence/Router.swift").read_text()
INSTR = re.search(r'private static let instructions = """\n(.*?)\n        """', SRC, re.S).group(1)
INSTR = "\n".join(l[8:] if l.startswith(" " * 8) else l for l in INSTR.split("\n"))
MODELO = re.search(r'model: String = "([^"]+)"', SRC).group(1)
REGION = sys.argv[sys.argv.index("--region") + 1] if "--region" in sys.argv else "US"

# pedido → países aceptados (None = no es de ningún país en particular)
CASOS = [
    ("llevame a banco nación", {"AR"}),
    ("anses", {"AR"}),
    ("quiero sacar un turno en pami", {"AR"}),
    ("¿a cuánto está el dólar blue hoy?", {"AR"}),
    ("abrí clarín", {"AR"}),
    ("la voz del interior", {"AR"}),
    ("diario el país de españa", {"ES"}),
    ("cita previa seguridad social", {"ES"}),
    ("le monde", {"FR"}),
    ("la jornada de méxico", {"MX"}),
    ("sat factura electrónica", {"MX"}),
    ("dmv appointment", {"US"}),
    ("nhs 111", {"GB"}),
    ("receita federal cpf", {"BR"}),
    # Sin país propio: decir el del teléfono es lo mismo que no decir ninguno,
    # porque la búsqueda termina con la región del teléfono igual.
    ("wikipedia", {None, REGION}),
    ("netflix", {None, REGION}),
    ("youtube", {None, REGION}),
    ("amazon", {None, REGION}),
    ("cómo hacer pan casero", {None, REGION}),
    ("noticias de hoy", {None, REGION}),
]


def decidir(pedido: str) -> dict:
    estado = f"No hay ninguna página abierta todavía. El teléfono está en la región {REGION}."
    cuerpo = json.dumps({
        "model": MODELO, "reasoning": {"enabled": False}, "max_tokens": 200,
        "response_format": {"type": "json_object"},
        "messages": [{"role": "system", "content": INSTR},
                     {"role": "user", "content": f"PIDIÓ: {pedido}\n\nDÓNDE ESTÁ: {estado}"}],
    }).encode()
    pedido_http = urllib.request.Request("https://ai-gateway.vercel.sh/v1/chat/completions", data=cuerpo,
                                         headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"})
    for intento in range(5):
        try:
            with urllib.request.urlopen(pedido_http, timeout=30) as r:
                contenido = json.loads(r.read())["choices"][0]["message"]["content"]
            return json.loads(contenido)
        except Exception:
            time.sleep(3 * (intento + 1))
    return {}


def main() -> None:
    # De a uno: en paralelo, el gateway devuelve 429.
    decisiones = []
    for pedido, _ in CASOS:
        decisiones.append(decidir(pedido))
        time.sleep(0.5)
    bien = 0
    for (pedido, aceptados), decision in zip(CASOS, decisiones):
        pais = decision.get("country")
        pais = pais.upper() if isinstance(pais, str) and len(pais) == 2 else None
        ok = pais in aceptados
        bien += ok
        esperado = "/".join(a or "ninguno" for a in aceptados)
        print(f"{'✔' if ok else '✘'} {pedido:38} → {pais or 'ninguno':8} (esperado {esperado}) · {decision.get('action')}")
    print(f"\n{bien}/{len(CASOS)} con el país que corresponde, teléfono en {REGION}")


if __name__ == "__main__":
    main()
