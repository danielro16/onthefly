# JEF

Un asistente para usar la web sin verla.

La página se carga **tal como es**, sin reconstruir ni reordenar nada. Lo único
que se le agrega es una conversación: la persona dice a dónde quiere ir o qué
quiere saber, y JEF la lleva, le lee, le contesta y le completa lo que se puede
completar. Recorrer una página con VoiceOver cuesta decenas de gestos aunque
esté bien hecha; decir "llevame a deportes" cuesta una frase.

La versión anterior —la que reconstruía cada web como app nativa accesible—
quedó en la rama `ui-cromo-y-tramos` y en el historial.

## Arquitectura

```
┌─────────────────────────────────────────────┐
│  WebView — la página real, a la vista       │
│  · una sola sesión: cookies y login quedan  │
│  · Readability + extract.js: los OJOS del   │
│    asistente, no lo que se dibuja           │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  Router   ¿qué pide? verbo + casilleros     │  Gemini Flash-Lite, tipado
│  Jev      ¿a cuál de estas opciones voy?    │  ~500 ms, elige, no redacta
│  Answerer orienta, contesta, resume         │  Gemini Flash, sólo la página
│  Swift    verifica cifras, decide qué es    │  instantáneo
│           seguro, navega                    │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  La conversación — SwiftUI                  │
│  al abrir ocupa la pantalla; con página,    │
│  queda abajo de ella                        │
└─────────────────────────────────────────────┘
```

## Las reglas

- **El modelo habla como una persona, pero sólo con el texto de la página.**
  Nada que sepa por fuera. Al llegar dice dónde se está, los titulares y qué
  se puede hacer, con las opciones como botones.
- **Toda cifra que dice tiene que estar en la página** —monto, precio,
  porcentaje, fecha— o no se dice nada (`Answerer.appears`). Es el invento que
  lastima y el único que no se detecta de oído.
- **El modelo nombra los botones, no sus destinos.** Una sugerencia apunta por
  número a una lista que arma el código con lo que la página ofrece.
- **Lo que se escribe en un campo sale sólo de la frase de la persona.** La
  página no participa ni como contexto.
- **Se envía sólo lo que se puede probar que es una búsqueda.** Todo lo demás
  se llena y el botón queda para la persona. La lista blanca es la defensa, no
  la negra: un botón que dice "Continuar" y cobra pasa cualquier lista negra.
- **Preguntar no mueve.** Enterarse de que se cambió de página sin pedirlo es
  lo más desorientador para alguien que no ve.
- **Nunca se confirma por voz.** La voz pide; la mano confirma tocando.
- **Los resultados de una búsqueda se presentan, no se eligen.** Tres, como
  botones, y "Ver más opciones".
- **Un límite es un traspaso.** "No compro, pero te llevo, te busco el
  producto y te leo los precios."
- **Terminología neutra de asistente:** gerundio e infinitivo, nunca
  imperativo conjugado.
- **Habla el idioma del teléfono.** El de `Locale.preferredLanguages`, no el
  de la app: la app no tiene traducciones y iOS le asigna inglés.

## Correr

```bash
./Scripts/make-secrets.sh     # genera Secrets.xcconfig desde .env
xcodegen generate && open JEFBrowser.xcodeproj
```

Requiere Xcode 26+, iOS 26+. El proyecto se genera desde `project.yml` — no
commitear `JEFBrowser.xcodeproj`. **Archivo nuevo → `xcodegen generate` antes
de compilar**: si no, queda afuera del target y el build dice SUCCEEDED igual.

## Estructura

```
Sources/
├── Extraction/     ← compartido con Android, sin APIs de plataforma
│   ├── Readability.js     (Mozilla, Apache 2.0)
│   └── extract.js         DOM → página tipada, y los controles que se aprietan
├── Engine/
│   ├── HeadlessWebView.swift   el WebView y su sesión
│   ├── PageModel.swift         contrato JSON
│   └── PageStream.swift        el recorrido de la página, en su orden
├── Intelligence/
│   ├── Assistant.swift         el lazo: rutear, llegar, leer, contestar, escribir
│   ├── Router.swift            qué pide la persona
│   ├── PageAnalyzer.swift      a dónde ir dentro de la página (Jev)
│   ├── Answerer.swift          orientar, contestar y resumir
│   └── JevClient.swift
└── UI/
    ├── ReaderView.swift        la sesión y la pantalla
    ├── AssistantPanel.swift    la conversación
    └── WebPageView.swift       la página, tal cual
```

## Probar

- `./Scripts/probar-ruteo.py` — las 60 intenciones de `Tests/intenciones.json`
  contra el ruteador real.
- `./Scripts/read-page.js <url>` / `--all` — qué ve el extractor, sin
  simulador. Red de regresión sobre `Tests/sites.txt`.
- `./Scripts/voiceover-walk.py` y `./Scripts/voiceover-tap.py` — leer y tocar
  la app en el simulador por el árbol de accesibilidad.

Ver [PROBAR.md](PROBAR.md) para el teléfono y VoiceOver, y [JEV.md](JEV.md)
para Jev y AI Gateway.

## Deuda conocida

**La API key viaja en el binario.** `Secrets.xcconfig` la inyecta en el
Info.plist: bien para desarrollar, mal para publicar. Antes de publicar, las
llamadas tienen que pasar por un backend propio.

**La frase cruda viaja al ruteador en la nube**, y una clave dictada va con
ella. Hay que enmascarar el valor en el teléfono antes de mandarla.

**Las frases fijas están sólo en castellano.** Lo que redacta el modelo sale en
el idioma del teléfono, pero "Abriendo…", "Buscando…" y el resto están en el
código: en un teléfono en inglés la conversación mezcla los dos. Tienen que
pasar a un String Catalog.

**El buscador es DuckDuckGo lite** porque Google bloquea esta máquina. Google
es el objetivo; `results(of:)` nunca se probó sobre sus resultados.

**`extract.js` sigue reparando la página en el lugar** (nombres faltantes,
`alt`, adornos): sólo agrega atributos, y medido arregló un nombre en doce
sitios. Tampoco se sacaron de ahí los ganchos que sólo usaba la vista
reconstruida (`__jefOpen`, `__jefSuggestions`, `__jefChoose`).
