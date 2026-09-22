#!/usr/bin/env python3
"""Trae del buscador los resultados reales de cada pedido de Tests/buscador/pedidos.json.

Es la materia prima para probar la regla de "¿cuál es el sitio que la persona
nombró?" contra búsquedas de verdad y no sólo contra los ocho sitios de las
rondas. Pide lo mismo que la app: DuckDuckGo lite, con el país y el idioma
(kl=ar-es), como un iPhone.

    ./Scripts/traer-resultados.py              # los que falten
    ./Scripts/traer-resultados.py --todos      # todos de nuevo
    ./Scripts/traer-resultados.py --lote Tests/buscador/otro   # otro lote

Un lote es una carpeta con pedidos.json; los resultados van a su
subcarpeta resultados/, una lista {titulo, href} por pedido.
"""
import html
import json
import pathlib
import re
import sys
import time
import urllib.parse
import urllib.request

RAIZ = pathlib.Path(__file__).resolve().parent.parent
LOTE = pathlib.Path(sys.argv[sys.argv.index("--lote") + 1]) if "--lote" in sys.argv else RAIZ / "Tests" / "buscador"
PEDIDOS = LOTE / "pedidos.json"
SALIDA = LOTE / "resultados"
IPHONE = ("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 "
          "(KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1")
LINK = re.compile(r"<a[^>]*href=\"([^\"]+)\"[^>]*class=.result-link.[^>]*>(.*?)</a>", re.S)


def nombre(pedido: str) -> str:
    """Un nombre de archivo para el pedido."""
    plano = pedido.lower().encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", plano).strip("-") or "pedido"


def traer(pedido: str) -> list[dict]:
    """Los resultados del buscador para un pedido, en su orden."""
    url = "https://lite.duckduckgo.com/lite/?" + urllib.parse.urlencode({"q": pedido, "kl": "ar-es"})
    pedido_http = urllib.request.Request(url, headers={"User-Agent": IPHONE, "Accept-Language": "es-AR,es;q=0.9"})
    with urllib.request.urlopen(pedido_http, timeout=20) as respuesta:
        pagina = respuesta.read().decode("utf-8", "replace")
    resultados = []
    if "result-link" not in pagina:
        # Sin resultados o con el aviso de "demasiadas búsquedas": no se guarda.
        raise RuntimeError("el buscador no devolvió resultados (¿demasiadas búsquedas?)")
    for href, titulo in LINK.findall(pagina):
        titulo = html.unescape(re.sub(r"<[^>]+>", "", titulo)).strip()
        resultados.append({"titulo": titulo, "href": html.unescape(href)})
    return resultados


def main() -> None:
    SALIDA.mkdir(parents=True, exist_ok=True)
    todos = "--todos" in sys.argv
    for entrada in json.loads(PEDIDOS.read_text()):
        destino = SALIDA / f"{nombre(entrada['pedido'])}.json"
        if destino.exists() and not todos:
            continue
        resultados = None
        for intento in range(3):
            try:
                resultados = traer(entrada["pedido"])
                break
            except Exception as error:  # la red o el límite del buscador: se espera y se reintenta
                print(f"✘ {entrada['pedido']}: {error}")
                time.sleep(15 * (intento + 1))
        if resultados is None:
            continue
        destino.write_text(json.dumps(resultados, ensure_ascii=False, indent=1))
        print(f"✔ {entrada['pedido']}: {len(resultados)} resultados")
        # Despacio: el buscador corta a quien pregunta demasiado rápido.
        time.sleep(3)


if __name__ == "__main__":
    main()
