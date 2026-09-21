# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
- [+  7.5s] 🔊 «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~65%)
- [+  7.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [btn] Llevame a La Nación  (Primera de 4 opciones.)
  5 [btn] ¿A cuánto está el dólar hoy?
  6 [btn] ¿Cómo va a estar el tiempo mañana?
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  9 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Llevame a La Nación»

- [+ 14.4s] 💬 Persona: Llevame a La Nación
- [+ 14.4s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 14.4s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 18.5s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 20.7s] 💬 JEF: Estás en la portada de LA NACION, un portal de noticias. Los titulares principales son: Adorni explicó la situación de los Bitcoins en negro y ventas a escondidas. Hubo filtraciones y desconfianza en la Quinta de Olivos, lo que generó una denuncia judicial y la salida de una colaboradora de Karina Milei. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Grandes cadenas le cortaron el audio a Trump tras su veto a CNN, Politico y MS NOW.
- [+ 20.7s] 🔊 «Estás en la portada de LA NACION, un portal de noticias. Los titulares principales son: Adorni explicó la situación de los Bitcoins en negro y ventas a escondidas. Hubo filtraciones y desconfianza en la Quinta de Olivos, lo que generó una denuncia judicial y la salida de una colaboradora de Karina Milei. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Grandes cadenas le cortaron el audio a Trump tras su veto a CNN, Politico y MS NOW.»
- [+ 20.7s] 🔘 Botones: [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»] · [Abrir «Filtraciones, desconfianza y una denuncia judicial: la trastienda de…»] · [Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»] · [Abrir «La guerra con la prensa. Las grandes cadenas le cortaron el audio a…»]
- [+ 20.7s] 🔘 Botones: [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»] · [Abrir «Filtraciones, desconfianza y una denuncia judicial: la trastienda de…»] · [Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»] · [Abrir «La guerra con la prensa. Las grandes cadenas le cortaron el audio a…»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, un portal de noticias. Los titulares principales son: Adorni explicó la situación de los Bitcoins en negro y ventas a escondidas. Hubo filtraciones y desconfianza en la Quinta de Olivos, lo que generó una denuncia judicial y la salida de una colaboradora de Karina Milei. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Grandes cadenas le cortaron el audio a Trump tras su veto a CNN, Politico y MS NOW.
  7 [btn] Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»  (Primera de 5 opciones.)
  8 [btn] Abrir «Filtraciones, desconfianza y una denuncia judicial: la trastienda de…»
  9 [btn] Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»
 10 [btn] Abrir «La guerra con la prensa. Las grandes cadenas le cortaron el audio a…»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 29.0s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 29.6s] 💬 JEF: Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.
- [+ 29.6s] 🔊 «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- [+ 29.6s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, un portal de noticias. Los titulares principales son: Adorni explicó la situación de los Bitcoins en negro y ventas a escondidas. Hubo filtraciones y desconfianza en la Quinta de Olivos, lo que generó una denuncia judicial y la salida de una colaboradora de Karina Milei. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Grandes cadenas le cortaron el audio a Trump tras su veto a CNN, Politico y MS NOW.
  7 [H] Vos: no entiendo, ¿dónde estoy?
  8 [txt] Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.
  9 [btn] Leer los titulares  (Primera de 3 opciones.)
 10 [btn] Resumir la portada
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```
