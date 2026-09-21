#!/usr/bin/env python3
"""Corre tareas reales contra la app en el simulador y guarda lo que pasó.

Cada escenario de Tests/escenarios.json es una persona con un objetivo y una
lista de pasos: escribir un pedido, o tocar uno de los botones que el
asistente ofrece. Por cada paso quedan la captura, el árbol de accesibilidad
(lo que VoiceOver puede recorrer) y, del registro que la app escribe en las
compilaciones DEBUG, todo lo que se dijo en voz alta con su hora. Con eso se
arma transcripcion.md: la sesión tal como la habría escuchado alguien que no
ve, que es lo que evalúan los jueces.

    ./Scripts/probar-escenarios.py                     # todos
    ./Scripts/probar-escenarios.py --solo dolar,anses  # algunos
    ./Scripts/probar-escenarios.py --udid <udid> --salida Tests/corridas/x

Necesita la app DEBUG instalada en el simulador, `axe`, y la región del
simulador en es_AR (el buscador ordena por país).
"""

import json
import os
import pathlib
import subprocess
import sys
import time
import unicodedata

RAIZ = pathlib.Path(__file__).resolve().parent.parent
APP = "ai.jef.browser"
# VoiceOver en castellano, velocidad por defecto: unos 14 caracteres por
# segundo. Sirve para estimar si un anuncio alcanzó a decirse antes de que
# llegara el siguiente, que lo corta.
CARACTERES_POR_SEGUNDO = 14.0


def correr(args, **kw):
    return subprocess.run(args, capture_output=True, text=True, **kw)


def plano(texto):
    texto = unicodedata.normalize("NFD", texto or "")
    return "".join(c for c in texto if unicodedata.category(c) != "Mn").lower()


class Simulador:
    def __init__(self, udid):
        self.udid = udid

    def nodos(self):
        salida = correr(["axe", "describe-ui", "--udid", self.udid]).stdout
        try:
            arbol = json.loads(salida)
        except json.JSONDecodeError:
            return []
        encontrados = []

        def recorrer(nodo):
            if isinstance(nodo, list):
                for hijo in nodo:
                    recorrer(hijo)
                return
            if nodo.get("role") != "AXApplication":
                encontrados.append(nodo)
            for hijo in nodo.get("children") or []:
                recorrer(hijo)

        recorrer(arbol)
        return encontrados

    def arbol_texto(self, nodos=None):
        roles = {"AXHeading": "H", "AXButton": "btn", "AXStaticText": "txt",
                 "AXTextField": "campo", "AXLink": "link", "AXImage": "img", "AXGroup": "grp"}
        lineas = []
        for i, n in enumerate(nodos if nodos is not None else self.nodos(), 1):
            limpio = lambda v: None if v in (None, "None", "") else v
            linea = f"{i:3d} [{roles.get(n.get('role'), n.get('role'))}] {limpio(n.get('AXLabel')) or '(sin etiqueta)'}"
            if limpio(n.get("AXValue")):
                linea += f"  = {n.get('AXValue')}"
            if limpio(n.get("help")):
                linea += f"  ({n.get('help')})"
            lineas.append(linea)
        return "\n".join(lineas)

    def tocar_punto(self, x, y):
        correr(["axe", "touch", "-x", str(x), "-y", str(y), "--down", "--up",
                "--delay", "0.1", "--udid", self.udid])

    def arrastrar(self, desde_y, hasta_y):
        # Lento, no un latigazo: un latigazo deja el scroll desacelerando y el
        # toque siguiente sólo lo frena.
        correr(["axe", "swipe", "--start-x", "200", "--start-y", str(desde_y),
                "--end-x", "200", "--end-y", str(hasta_y), "--duration", "0.5",
                "--udid", self.udid])
        time.sleep(0.8)

    def tecla(self, codigo):
        correr(["axe", "key", str(codigo), "--udid", self.udid])

    def combinacion(self, codigo):
        correr(["axe", "key-combo", "--modifiers", "227", "--key", str(codigo), "--udid", self.udid])

    def captura(self, destino):
        png = destino.with_suffix(".png")
        correr(["xcrun", "simctl", "io", self.udid, "screenshot", str(png)])
        # JPEG a 1400 px: se lee igual y pesa una décima parte.
        correr(["sips", "-s", "format", "jpeg", "-s", "formatOptions", "70", "-Z", "1400",
                str(png), "--out", str(destino.with_suffix(".jpg"))])
        png.unlink(missing_ok=True)

    def contenedor(self):
        ruta = correr(["xcrun", "simctl", "get_app_container", self.udid, APP, "data"]).stdout.strip()
        return pathlib.Path(ruta) if ruta else None

    def reiniciar_app(self):
        correr(["xcrun", "simctl", "terminate", self.udid, APP])
        time.sleep(1)
        carpeta = self.contenedor()
        if carpeta:
            (carpeta / "Documents" / "registro.jsonl").unlink(missing_ok=True)
        correr(["xcrun", "simctl", "launch", self.udid, APP])
        time.sleep(4)

    def registro(self):
        carpeta = self.contenedor()
        archivo = carpeta / "Documents" / "registro.jsonl" if carpeta else None
        if not archivo or not archivo.exists():
            return []
        lineas = []
        for linea in archivo.read_text().splitlines():
            try:
                lineas.append(json.loads(linea))
            except json.JSONDecodeError:
                pass
        return lineas


class Panel:
    """Lo que hace falta del panel del asistente: el campo y los botones."""

    def __init__(self, sim):
        self.sim = sim

    def limites(self, nodos):
        arriba, abajo = 560, 780
        for n in nodos:
            marco = n.get("frame") or {}
            if n.get("AXLabel") == "Asistente" and n.get("role") == "AXHeading":
                arriba = marco["y"] + marco["height"] + 8
            if n.get("AXLabel") == "Pedido":
                abajo = marco["y"] - 8
        return arriba, abajo

    @staticmethod
    def opciones(nodos):
        # En el panel, todo botón es una opción salvo "Enviar". El contenido de
        # la página no aparece en el árbol que da axe.
        return [n for n in nodos if n.get("role") == "AXButton" and n.get("AXLabel") != "Enviar"]

    def escribir(self, texto):
        campo = next((n for n in self.sim.nodos() if n.get("AXLabel") == "Pedido"), None)
        if not campo:
            raise RuntimeError("no encuentro el campo Pedido")
        marco = campo["frame"]
        self.sim.tocar_punto(marco["x"] + marco["width"] / 2, marco["y"] + marco["height"] / 2)
        time.sleep(1.0)
        self.sim.combinacion(4)   # ⌘A
        self.sim.tecla(42)        # borrar
        # Pegado, no tipeado: `axe type` manda teclas de un teclado de EE.UU.
        # y el simulador en castellano cambia los signos.
        correr(["xcrun", "simctl", "pbcopy", self.sim.udid], input=texto)
        self.sim.combinacion(25)  # ⌘V
        time.sleep(0.8)
        self.sim.tecla(40)        # enviar

    def tocar(self, cual):
        """`cual` es un número (la enésima opción) o un pedazo de su etiqueta."""
        for _ in range(12):
            nodos = self.sim.nodos()
            opciones = self.opciones(nodos)
            if isinstance(cual, int):
                elegido = opciones[cual - 1] if 0 < cual <= len(opciones) else None
            else:
                elegido = next((n for n in opciones if plano(cual) in plano(n.get("AXLabel"))), None)
            if elegido is None:
                disponibles = [n.get("AXLabel") for n in opciones]
                raise RuntimeError(f"no hay opción {cual!r}; hay: {disponibles}")
            arriba, abajo = self.limites(nodos)
            marco = elegido["frame"]
            y = marco["y"] + marco["height"] / 2
            if arriba + 4 <= y <= abajo - 4:
                self.sim.tocar_punto(marco["x"] + marco["width"] / 2, y)
                return elegido.get("AXLabel")
            # Se scrollea el panel, no la página: arrastrando adentro de él, y
            # lejos de los bordes — a 10 puntos del campo de escribir el
            # arrastre no lo toma nadie y el panel no se mueve.
            # Y de al menos 100 puntos: uno corto y lento no pasa de un toque
            # sostenido, y el panel no se mueve.
            desde_abajo, desde_arriba = abajo - 25, arriba + 25
            recorrido = desde_abajo - desde_arriba
            if y > abajo:
                self.sim.arrastrar(desde_abajo, desde_abajo - min(max(100, y - abajo + 40), recorrido))
            else:
                self.sim.arrastrar(desde_arriba, desde_arriba + min(max(100, arriba - y + 40), recorrido))
        raise RuntimeError(f"no pude traer {cual!r} a la vista")


def esperar_calma(sim, maximo=100):
    """Hasta que el asistente terminó: sin "Buscando" y el registro quieto."""
    inicio = time.time()
    time.sleep(2.5)
    tam_anterior, quietos = -1, 0
    while time.time() - inicio < maximo:
        ocupado = any(n.get("AXLabel") == "Buscando" for n in sim.nodos())
        carpeta = sim.contenedor()
        archivo = carpeta / "Documents" / "registro.jsonl" if carpeta else None
        tam = archivo.stat().st_size if archivo and archivo.exists() else 0
        quietos = quietos + 1 if (not ocupado and tam == tam_anterior) else 0
        if quietos >= 2:
            return True
        tam_anterior = tam
        time.sleep(1.5)
    return False


def transcribir(escenario, pasos, registro, destino):
    """La sesión como se habría escuchado, paso por paso."""
    voces = [r for r in registro if r["tipo"] == "voz"]
    t0 = registro[0]["t"] if registro else time.time()
    out = [f"# {escenario['id']}", "",
           f"**Quién:** {escenario['persona']}", "",
           f"**Qué quiere:** {escenario['objetivo']}", "",
           "Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. "
           "Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno "
           "en cola espera a que termine el anterior. La duración se estima a "
           f"{CARACTERES_POR_SEGUNDO:.0f} caracteres por segundo. 💬 lo que queda escrito en la "
           "conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. "
           "📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).", ""]
    # Cuándo empieza a sonar cada anuncio: uno en cola espera al anterior.
    # Uno que interrumpe corta al que suena y descarta los que esperaban.
    suena, descartado, fin_anterior = {}, set(), 0.0
    for v in voces:
        dura = max(0.6, len(v["texto"]) / CARACTERES_POR_SEGUNDO)
        if v.get("cola"):
            inicio = max(v["t"], fin_anterior)
        else:
            inicio = v["t"]
            for otro, empieza in suena.items():
                if empieza >= v["t"]:
                    descartado.add(otro)
        suena[id(v)] = inicio
        fin_anterior = inicio + dura
    num_pagina = 0
    for i, paso in enumerate(pasos, 1):
        fin = pasos[i]["inicio"] if i < len(pasos) else float("inf")
        out.append(f"## Paso {i} — {paso['descripcion']}")
        if paso.get("error"):
            out.append(f"> ⚠️ El paso no se pudo hacer: {paso['error']}")
        if not paso.get("termino", True):
            out.append("> ⚠️ El asistente seguía trabajando al cumplirse el tiempo máximo de espera.")
        out.append("")
        for r in registro:
            if not (paso["inicio"] - 0.5 <= r["t"] < fin - 0.5):
                continue
            rel = r["t"] - t0
            if r["tipo"] == "voz":
                siguiente = next((v for v in voces if v["t"] > r["t"]), None)
                dura = max(0.6, len(r["texto"]) / CARACTERES_POR_SEGUNDO)
                nota = ""
                demora = suena[id(r)] - r["t"]
                if id(r) in descartado:
                    nota = "  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara"
                elif r.get("cola"):
                    if demora > 1.5:
                        nota = f"  ⟶ en cola: empieza a sonar a los +{suena[id(r)] - t0:.1f}s"
                elif siguiente and not siguiente.get("cola") and siguiente["t"] - r["t"] < dura:
                    oido = (siguiente["t"] - r["t"]) / dura
                    nota = f"  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~{oido:.0%})"
                out.append(f"- [+{rel:5.1f}s] 🔊 «{r['texto']}»{nota}")
            elif r["tipo"] == "turno":
                quien = "Persona" if r["quien"] == "persona" else "JEF"
                out.append(f"- [+{rel:5.1f}s] 💬 {quien}: {r['texto']}")
            elif r["tipo"] == "botones" and r.get("opciones"):
                out.append(f"- [+{rel:5.1f}s] 🔘 Botones: " + " · ".join(f"[{o}]" for o in r["opciones"]))
            elif r["tipo"] == "pagina":
                num_pagina += 1
                out.append(f"- [+{rel:5.1f}s] 📄 Cargó {r['url']} — «{r['titulo']}» (paginas/{num_pagina:02d}.txt)")
            elif r["tipo"] == "error":
                out.append(f"- [+{rel:5.1f}s] ❌ Error de carga: {r['mensaje']}")
        out.append("")
        out.append(f"Al terminar el paso ({paso['segundos']:.0f} s), lo que VoiceOver puede recorrer en la conversación "
                   f"(árbol completo en arbol-{i:02d}.txt, captura en paso-{i:02d}.jpg):")
        out.append("```")
        out.append(paso["panel"])
        out.append("```")
        out.append("")
    (destino / "transcripcion.md").write_text("\n".join(out))

    carpeta = destino / "paginas"
    carpeta.mkdir(exist_ok=True)
    n = 0
    for r in registro:
        if r["tipo"] == "pagina":
            n += 1
            (carpeta / f"{n:02d}.txt").write_text(f"{r['url']}\n{r['titulo']}\n\n{r['texto']}")


def panel_de(texto_arbol):
    """Del árbol entero, sólo lo que va de "Asistente" en adelante."""
    lineas = texto_arbol.splitlines()
    for i, linea in enumerate(lineas):
        if "[H] Asistente" in linea:
            return "\n".join(lineas[i:])
    return texto_arbol


def correr_escenario(sim, escenario, destino):
    destino.mkdir(parents=True, exist_ok=True)
    panel = Panel(sim)
    sim.reiniciar_app()
    pasos = []
    for i, paso in enumerate(escenario["pasos"], 1):
        registro_paso = {"inicio": time.time()}
        try:
            if "escribir" in paso:
                registro_paso["descripcion"] = f"escribe «{paso['escribir']}»"
                panel.escribir(paso["escribir"])
            elif "boton" in paso:
                etiqueta = panel.tocar(paso["boton"])
                registro_paso["descripcion"] = f"toca el botón {paso['boton']}: «{etiqueta}»"
            elif "tocar" in paso:
                etiqueta = panel.tocar(paso["tocar"])
                registro_paso["descripcion"] = f"toca «{etiqueta}»"
            elif "esperar" in paso:
                # La persona hace algo en la página misma —resolver una
                # prueba— mientras el asistente espera.
                registro_paso["descripcion"] = f"no toca el asistente durante {paso['esperar']} s (resuelve algo en la página)"
                time.sleep(paso["esperar"])
            registro_paso["termino"] = esperar_calma(sim)
        except RuntimeError as error:
            registro_paso.setdefault("descripcion", json.dumps(paso, ensure_ascii=False))
            registro_paso["error"] = str(error)
        registro_paso["segundos"] = time.time() - registro_paso["inicio"]
        sim.captura(destino / f"paso-{i:02d}")
        arbol = sim.arbol_texto()
        (destino / f"arbol-{i:02d}.txt").write_text(arbol)
        registro_paso["panel"] = panel_de(arbol)
        pasos.append(registro_paso)
        print(f"  {i}. {registro_paso['descripcion']} — {registro_paso['segundos']:.0f} s"
              + (f" — ERROR: {registro_paso['error']}" if registro_paso.get("error") else ""), flush=True)
        if registro_paso.get("error"):
            break
    registro = sim.registro()
    with open(destino / "registro.jsonl", "w") as f:
        for r in registro:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    transcribir(escenario, pasos, registro, destino)


def main():
    args = sys.argv[1:]
    udid = args[args.index("--udid") + 1] if "--udid" in args else os.environ.get("UDID", "8001AFAF-0DAF-421D-A0D8-DBABE38D9303")
    solo = set(args[args.index("--solo") + 1].split(",")) if "--solo" in args else None
    archivo = args[args.index("--escenarios") + 1] if "--escenarios" in args else "Tests/escenarios.json"
    salida = pathlib.Path(args[args.index("--salida") + 1]) if "--salida" in args else \
        RAIZ / "Tests" / "corridas" / time.strftime("%Y-%m-%d_%H%M")
    escenarios = json.loads((RAIZ / archivo).read_text())
    sim = Simulador(udid)
    for escenario in escenarios:
        if solo and escenario["id"] not in solo:
            continue
        print(f"▶ {escenario['id']}", flush=True)
        # Páginas propias, servidas desde la Mac: el simulador las ve en
        # localhost.
        servidor = None
        if escenario.get("servir"):
            # Un puerto libre, no uno fijo: otro programa de la Mac puede
            # estar usando el que se eligiera, y respondía él con un 404.
            import socket
            with socket.socket() as s:
                s.bind(("", 0))
                puerto = s.getsockname()[1]
            servidor = subprocess.Popen(
                [sys.executable, "-m", "http.server", str(puerto), "--directory", str(RAIZ / escenario["servir"])],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(1)
            escenario = json.loads(json.dumps(escenario).replace("{servidor}", f"http://localhost:{puerto}"))
        try:
            correr_escenario(sim, escenario, salida / escenario["id"])
        finally:
            if servidor:
                servidor.terminate()
    print(f"Listo: {salida}")


if __name__ == "__main__":
    main()
