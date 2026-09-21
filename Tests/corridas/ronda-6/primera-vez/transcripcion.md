# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 💬 JEF: Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
- [+  7.2s] 🔊 «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~67%)
- [+  7.2s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

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
- [+ 18.6s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 20.5s] 💬 JEF: Estás en la portada de LA NACION, un portal de noticias de Argentina y el mundo. Los titulares principales son: Un gas contaminado sería la causa del apagón que dejó a oscuras a más de 2 millones de personas. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele. Tres misas y mucha orfebrería diplomática para evitar que la visita del Papa se politice.
- [+ 20.5s] 🔊 «Estás en la portada de LA NACION, un portal de noticias de Argentina y el mundo. Los titulares principales son: Un gas contaminado sería la causa del apagón que dejó a oscuras a más de 2 millones de personas. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele. Tres misas y mucha orfebrería diplomática para evitar que la visita del Papa se politice.»
- [+ 20.5s] 🔘 Botones: [Abrir «Un gas contaminado sería la causa del apagón que dejó a oscuras a más…»] · [Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»] · [Abrir «Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde…»] · [Abrir «Tres misas y mucha orfebrería diplomática para evitar que la visita…»]
- [+ 20.5s] 🔘 Botones: [Abrir «Un gas contaminado sería la causa del apagón que dejó a oscuras a más…»] · [Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»] · [Abrir «Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde…»] · [Abrir «Tres misas y mucha orfebrería diplomática para evitar que la visita…»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, un portal de noticias de Argentina y el mundo. Los titulares principales son: Un gas contaminado sería la causa del apagón que dejó a oscuras a más de 2 millones de personas. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele. Tres misas y mucha orfebrería diplomática para evitar que la visita del Papa se politice.
  7 [btn] Abrir «Un gas contaminado sería la causa del apagón que dejó a oscuras a más…»  (Primera de 5 opciones.)
  8 [btn] Abrir «A partir de este momento". Renunció el secretario de Discapacidad en…»
  9 [btn] Abrir «Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde…»
 10 [btn] Abrir «Tres misas y mucha orfebrería diplomática para evitar que la visita…»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 27.3s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 28.0s] 💬 JEF: Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.
- [+ 28.0s] 🔊 «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- [+ 28.0s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, un portal de noticias de Argentina y el mundo. Los titulares principales son: Un gas contaminado sería la causa del apagón que dejó a oscuras a más de 2 millones de personas. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele. Tres misas y mucha orfebrería diplomática para evitar que la visita del Papa se politice.
  7 [H] Vos: no entiendo, ¿dónde estoy?
  8 [txt] Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.
  9 [btn] Leer los titulares  (Primera de 3 opciones.)
 10 [btn] Resumir la portada
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```
