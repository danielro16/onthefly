#!/usr/bin/env python3
"""Prueba las opciones que ofrece el asistente contra búsquedas reales guardadas.

Compila la función de Assistant.swift que saca los resultados de la página del
buscador —la misma, copiada del archivo, no una reimplementación— y la corre
sobre cada pedido de Tests/buscador/pedidos.json con los resultados que guardó
Scripts/traer-resultados.py.

    ./Scripts/probar-sitios.py
    ./Scripts/probar-sitios.py --lote Tests/buscador/otro   # otro lote (ver traer-resultados.py)

JEF ofrece los tres primeros en el orden del buscador. Por cada pedido dice si
el sitio esperado es el primero y si está entre los tres.
"""
import json
import pathlib
import re
import subprocess
import sys
import tempfile
import urllib.parse

RAIZ = pathlib.Path(__file__).resolve().parent.parent
FUENTE = RAIZ / "Sources" / "Intelligence" / "Assistant.swift"
LOTE = pathlib.Path(sys.argv[sys.argv.index("--lote") + 1]) if "--lote" in sys.argv else RAIZ / "Tests" / "buscador"
PEDIDOS = LOTE / "pedidos.json"
RESULTADOS = LOTE / "resultados"

FUNCIONES = ["unicode", "punycode", "results(from", "flatten"]
CONSTANTES: list[str] = []


def extraer(fuente: str) -> str:
    """Las declaraciones pedidas, tal cual están en el archivo."""
    lineas = fuente.split("\n")
    partes = []

    def desde(indice: int, cierre: str) -> str:
        fin = indice
        while lineas[fin] != cierre:
            fin += 1
        return "\n".join(lineas[indice:fin + 1])

    for nombre in FUNCIONES:
        patron = re.compile(r"^    (nonisolated )?(private )?static func " + re.escape(nombre) + (r"" if "(" in nombre else r"\("))
        indice = next(i for i, l in enumerate(lineas) if patron.match(l))
        partes.append(desde(indice, "    }"))
    for nombre in CONSTANTES:
        indice = next(i for i, l in enumerate(lineas) if l.startswith(f"    static let {nombre}"))
        texto = lineas[indice]
        partes.append(texto if texto.rstrip().endswith("]") else desde(indice, "    ]"))
    estructura = re.search(r"    struct Result: Sendable \{.*?\n    \}\n", fuente, re.S).group(0)
    return estructura + "\n" + "\n\n".join(partes)


PRINCIPAL = r"""
import Foundation

let pedidos = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String: Any]]
let carpeta = CommandLine.arguments[2]
var salida: [[String: Any]] = []
for pedido in pedidos {
    let texto = pedido["pedido"] as! String
    let archivo = carpeta + "/" + (pedido["archivo"] as! String)
    guard let datos = try? Data(contentsOf: URL(fileURLWithPath: archivo)),
          let crudos = try? JSONSerialization.jsonObject(with: datos) as? [[String: String]] else { continue }
    let links = crudos.map { (title: $0["titulo"] ?? "", href: $0["href"] ?? "") }
    let lista = Assistant.results(from: links)
    salida.append(["pedido": texto, "lista": lista.prefix(3).map { $0.href }])
}
print(String(data: try! JSONSerialization.data(withJSONObject: salida), encoding: .utf8)!)
"""


def dominio_ok(url: str, esperados: list[str]) -> bool:
    """Si la dirección cae en uno de los sitios esperados (dominio y, si se pide, ruta)."""
    partes = urllib.parse.urlparse(url)
    host = (partes.hostname or "").lower()
    for esperado in esperados:
        dominio, _, ruta = esperado.partition("/")
        if host == dominio or host.endswith("." + dominio):
            if not ruta or partes.path.lower().lstrip("/").startswith(ruta):
                return True
    return False


def nombre(pedido: str) -> str:
    plano = pedido.lower().encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", plano).strip("-") or "pedido"


def main() -> None:
    codigo = "enum Assistant {\n" + extraer(FUENTE.read_text()) + "\n}\n" + PRINCIPAL
    pedidos = json.loads(PEDIDOS.read_text())
    for entrada in pedidos:
        entrada["archivo"] = nombre(entrada["pedido"]) + ".json"
    with tempfile.TemporaryDirectory() as tmp:
        (pathlib.Path(tmp) / "main.swift").write_text(codigo)
        (pathlib.Path(tmp) / "pedidos.json").write_text(json.dumps(pedidos))
        compilado = subprocess.run(["swiftc", "-O", "-o", f"{tmp}/probar", f"{tmp}/main.swift"],
                                   capture_output=True, text=True)
        if compilado.returncode:
            print(compilado.stderr[:4000])
            sys.exit(1)
        corrida = subprocess.run([f"{tmp}/probar", f"{tmp}/pedidos.json", str(RESULTADOS)],
                                 capture_output=True, text=True, check=True)
    filas = {f["pedido"]: f for f in json.loads(corrida.stdout)}

    total = primero = entre_tres = 0
    for entrada in pedidos:
        fila = filas.get(entrada["pedido"])
        if not fila or not entrada["sitio"]:
            continue
        total += 1
        lista = fila["lista"]
        uno = bool(lista) and dominio_ok(lista[0], entrada["sitio"])
        tres = any(dominio_ok(h, entrada["sitio"]) for h in lista)
        primero += uno
        entre_tres += tres
        if not uno:
            marca = "· 2.º o 3.º" if tres else "✘ NO ESTÁ"
            print(f"{marca:12} {entrada['pedido']:32} → 1.º {lista[0] if lista else '-'}")
    print(f"\n{total} pedidos con sitio conocido · el correcto es el 1.º en {primero} · "
          f"está entre los 3 ofrecidos en {entre_tres}")
    sys.exit(0 if entre_tres == total else 1)


if __name__ == "__main__":
    main()
