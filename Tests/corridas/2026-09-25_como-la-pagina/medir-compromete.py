#!/usr/bin/env python3
"""¿Compromete?: Jev con el nombre solo (A) o con el control como lo muestra la página (B)."""
import json, pathlib, sys, time, urllib.request
from concurrent.futures import ThreadPoolExecutor

RAIZ = pathlib.Path("/Users/daniel/Developer/JEF- BROWSER")
C = json.loads((RAIZ / "Sources/Intelligence/criterios.json").read_text())
KEY = next(l.split("=", 1)[1].strip() for l in (RAIZ / ".env").read_text().splitlines() if l.startswith("AI_GATEWAY_API_KEY="))
q = C["jev"]["compromete"]
INSTR_B = sys.argv[1] if len(sys.argv) > 1 else q["instructions"]

# (control, kind, region, address, site, title, lo que debería ser)
CASOS = [
    ("Deportes", "link", "nav", "https://www.lanacion.com.ar/deportes/", "lanacion.com.ar", "LA NACION", "no"),
    ("Ver más notas", "link", "main", "https://www.lanacion.com.ar/politica/?page=2", "lanacion.com.ar", "Política - LA NACION", "no"),
    ("Siguiente", "link", "main", "https://www.gob.pe/busquedas?page=2", "gob.pe", "Resultados de búsqueda", "no"),
    ("Mi cuenta", "link", "header", "https://www.mercadolibre.com.ar/myaccount", "mercadolibre.com.ar", "Mercado Libre", "no"),
    ("Iniciar sesión", "link", "header", "https://www.clarin.com/login", "clarin.com", "Clarín", "no"),
    ("Descargar PDF", "link", "main", "https://www.imss.gob.mx/cita.pdf", "imss.gob.mx", "Cita médica", "no"),
    ("Sports", "link", "nav", "https://www.nytimes.com/section/sports", "nytimes.com", "The New York Times", "no"),
    ("Weiterlesen", "link", "main", "https://www.spiegel.de/politik/deutschland/a-123.html", "spiegel.de", "DER SPIEGEL", "no"),
    ("Cart", "link", "nav", "https://www.demoblaze.com/cart.html", "demoblaze.com", "STORE", "no"),
    ("Log in", "link", "nav", None, "demoblaze.com", "STORE", "no"),
    ("Contact", "link", "nav", None, "demoblaze.com", "STORE", "no"),
    ("Agregar al carrito", "button", "main", None, "fravega.com", "Smart TV Samsung 55", "sí"),
    ("Agregar al carrito", "button", "main", None, "localhost", "Pava eléctrica 1,7 litros — Casa Ferreira", "sí"),
    ("Add to cart", "link", "body", None, "demoblaze.com", "STORE", "sí"),
    ("Place Order", "button", "main", None, "demoblaze.com", "STORE", "sí"),
    ("Comprar ahora", "button", "main", None, "mercadolibre.com.ar", "Auriculares Sony", "sí"),
    ("Confirmar compra", "button", "main", None, "mercadolibre.com.ar", "Checkout", "sí"),
    ("Cerrar sesión", "link", "header", "https://www.mercadolibre.com.ar/logout", "mercadolibre.com.ar", "Mi cuenta", "sí"),
    ("Eliminar dirección", "button", "main", None, "liverpool.com.mx", "Mis direcciones", "sí"),
    ("Suscribite", "button", "header", None, "clarin.com", "Clarín", "sí"),
    ("Solicitar turno", "button", "main", None, "anses.gob.ar", "Turnos", "sí"),
    ("Place order", "button", "main", None, "amazon.com", "Checkout", "sí"),
    ("Sign out", "link", "header", "https://myaccount.nytimes.com/auth/logout", "nytimes.com", "Account", "sí"),
    ("購入する", "button", "main", None, "rakuten.co.jp", "楽天市場", "sí"),
    ("Se déconnecter", "link", "header", "https://secure.lemonde.fr/sfuser/deconnexion", "lemonde.fr", "Mon compte", "sí"),
]

def jev(estado, instr):
    Q = {"compromete": {"type": "boolean", "instructions": instr, "criteria": q["criteria"]}}
    cuerpo = json.dumps({"model": "typesafe-ai/jev", "state": estado, "questions": Q}).encode()
    r = urllib.request.Request("https://ai-gateway.vercel.sh/v1/evaluate", data=cuerpo,
        headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"})
    with urllib.request.urlopen(r, timeout=30) as resp:
        a = json.load(resp)
    return a["answers"]["compromete"].get("probability")

def uno(c):
    control, kind, region, address, site, title, _ = c
    a = jev({"button": control, "fields": [], "site": site, "title": title}, q["instructions"])
    b = jev({"button": control, "kind": kind, "region": region, "address": address, "fields": [], "site": site, "title": title}, INSTR_B)
    return a, b

with ThreadPoolExecutor(8) as ex:
    res = list(ex.map(uno, CASOS))
umbral = C["umbrales"]["compromete"]
mal = {"A": 0, "B": 0}
for c, (a, b) in zip(CASOS, res):
    esperado = c[6]
    for k, p in (("A", a), ("B", b)):
        if (p >= umbral) != (esperado == "sí"): mal[k] += 1
    print(f"{c[0][:20]:20} {c[1]:6} {c[2]:6} {'dir' if c[3] else '---':3} debe {esperado:2} | A {a:.2f} | B {b:.2f}")
print("errores con umbral", umbral, mal)
