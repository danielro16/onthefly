#!/usr/bin/env python3
"""Prueba la elección de sitio del asistente contra búsquedas reales guardadas.

Compila las funciones de Assistant.swift que eligen entre resultados —las
mismas, copiadas del archivo, no una reimplementación— y las corre sobre cada
pedido de Tests/buscador/pedidos.json con los resultados que guardó
Scripts/traer-resultados.py. Con el país fijo en Argentina.

    ./Scripts/probar-sitios.py
    ./Scripts/probar-sitios.py --lote Tests/buscador/otro   # otro lote (ver traer-resultados.py)
    ./Scripts/probar-sitios.py --region US                  # con el teléfono en otra región

Por cada pedido dice qué haría JEF: ir directo (a qué dirección) o mostrar la
lista (y cuál queda primero), y si eso es el sitio esperado. Lo que no se
admite nunca es ir directo a un sitio que no era.
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

FUNCIONES = [
    "unicode", "punycode", "results(from", "isOfficial", "closer", "mentionsOtherCountry", "labels",
    "siteName", "flatten", "stems", "depth", "distance", "words", "registered", "segments", "initials",
    "isHosted", "keys", "imitates", "names", "phoneCode", "namedSite", "ranked", "named", "siteNamed", "bare",
]
CONSTANTES = ["countries", "suffixes", "fillers", "endings", "generic", "tasks", "numbers"]


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
    codigo = estructura + "\n" + "\n\n".join(partes)
    # El país de la persona, fijo: la región de esta máquina no es la del caso.
    region = sys.argv[sys.argv.index("--region") + 1] if "--region" in sys.argv else "AR"
    return codigo.replace('Locale.current.region?.identifier ?? "AR"', f'"{region}"')


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
    let resultados = Assistant.results(from: links)
    let lista = Assistant.ranked(texto, among: resultados, naming: true)
    var fila: [String: Any] = ["pedido": texto, "lista": lista.prefix(3).map { $0.href }]
    if let directo = Assistant.namedSite(texto, among: resultados) {
        fila["directo"] = directo.go
        fila["sitio"] = directo.site.title
    }
    salida.append(fila)
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

    directos = equivocados = lista_ok = 0
    for entrada in pedidos:
        fila = filas.get(entrada["pedido"])
        if not fila:
            print(f"?  {entrada['pedido']}: sin resultados guardados")
            continue
        esperados = entrada["sitio"]
        # Sin sitio esperado —Garbarino quebró—, lo correcto es la lista.
        if not esperados:
            bien = "directo" not in fila
            equivocados += not bien
            directos += not bien
            print(f"{'· lista, sin sitio' if bien else '✘ DIRECTO SIN SITIO':24} {entrada['pedido']:30} → "
                  f"{fila.get('directo') or (fila['lista'][0] if fila['lista'] else '')}")
            continue
        if "directo" in fila:
            directos += 1
            bien = dominio_ok(fila["directo"], esperados)
            equivocados += not bien
            marca = "✔ directo" if bien else "✘ DIRECTO A OTRO SITIO"
            print(f"{marca:24} {entrada['pedido']:30} → {fila['directo']}")
        else:
            primero = fila["lista"][0] if fila["lista"] else ""
            bien = dominio_ok(primero, esperados)
            lista_ok += bien
            marca = "· lista, 1.º bien" if bien else "· lista, 1.º OTRO"
            print(f"{marca:24} {entrada['pedido']:30} → {primero}")
    print(f"\n{directos} directos ({equivocados} a otro sitio) · {len(pedidos) - directos} con lista "
          f"({lista_ok} con el sitio primero)")
    sys.exit(1 if equivocados else 0)


if __name__ == "__main__":
    main()
