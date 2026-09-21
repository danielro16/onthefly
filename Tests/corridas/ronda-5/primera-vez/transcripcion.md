# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 💬 JEF: Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
- [+  7.2s] 🔊 «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~68%)
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

- [+ 14.3s] 💬 Persona: Llevame a La Nación
- [+ 14.3s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 14.3s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 19.0s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 21.0s] 💬 JEF: Estás en la portada de La Nación. Los titulares principales son: el secretario de Discapacidad renunció por la puja del rumbo del área; las cadenas de TV reaccionaron al veto de Trump; un gas contaminado causaría el apagón que dejó a oscuras a más de 2 millones de personas; y el Papa tendrá tres misas y orfebrería diplomática para evitar que su visita se politice.
- [+ 21.0s] 🔊 «Estás en la portada de La Nación. Los titulares principales son: el secretario de Discapacidad renunció por la puja del rumbo del área; las cadenas de TV reaccionaron al veto de Trump; un gas contaminado causaría el apagón que dejó a oscuras a más de 2 millones de personas; y el Papa tendrá tres misas y orfebrería diplomática para evitar que su visita se politice.»
- [+ 21.0s] 🔘 Botones: [Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»] · [Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»] · [Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»] · [Abrir «70 horas de frenesí. Tres misas y mucha orfebrería diplomática para…»]
- [+ 21.0s] 🔘 Botones: [Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»] · [Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»] · [Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»] · [Abrir «70 horas de frenesí. Tres misas y mucha orfebrería diplomática para…»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de La Nación. Los titulares principales son: el secretario de Discapacidad renunció por la puja del rumbo del área; las cadenas de TV reaccionaron al veto de Trump; un gas contaminado causaría el apagón que dejó a oscuras a más de 2 millones de personas; y el Papa tendrá tres misas y orfebrería diplomática para evitar que su visita se politice.
  7 [btn] Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»  (Primera de 5 opciones.)
  8 [btn] Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»
  9 [btn] Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»
 10 [btn] Abrir «70 horas de frenesí. Tres misas y mucha orfebrería diplomática para…»
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
  6 [txt] Estás en la portada de La Nación. Los titulares principales son: el secretario de Discapacidad renunció por la puja del rumbo del área; las cadenas de TV reaccionaron al veto de Trump; un gas contaminado causaría el apagón que dejó a oscuras a más de 2 millones de personas; y el Papa tendrá tres misas y orfebrería diplomática para evitar que su visita se politice.
  7 [H] Vos: no entiendo, ¿dónde estoy?
  8 [txt] Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.
  9 [btn] Leer los titulares  (Primera de 3 opciones.)
 10 [btn] Resumir la portada
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```
