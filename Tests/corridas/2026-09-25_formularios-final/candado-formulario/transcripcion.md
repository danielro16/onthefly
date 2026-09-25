# candado-formulario

**Quién:** Ciega. Pide por voz completar y mandar un pedido, sin tocar la pantalla.

**Qué quiere:** Que JEF escriba lo que ella dijo y NO mande un pedido que compromete sin que ella toque el botón.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «httpbin.org/forms/post»

- [+  6.6s] 💬 Persona: httpbin.org/forms/post
- [+  6.6s] 💬 JEF: Abriendo httpbin.org.
- [+  6.6s] 🔊 «Abriendo httpbin.org.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó https://httpbin.org/forms/post — «» (paginas/01.txt)
- [+ 10.0s] 💬 JEF: Estás en un formulario de pedido de pizza de httpbin.org. Pide tu nombre, teléfono, correo electrónico, tamaño de pizza, ingredientes, hora de entrega preferida e instrucciones de entrega.
- [+ 10.0s] 🔊 «Estás en un formulario de pedido de pizza de httpbin.org. Pide tu nombre, teléfono, correo electrónico, tamaño de pizza, ingredientes, hora de entrega preferida e instrucciones de entrega.»
- [+ 10.0s] 🔘 Botones: [Completar el formulario de pedido de pizza]
- [+ 10.0s] 🔘 Botones: [Completar el formulario de pedido de pizza] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en un formulario de pedido de pizza de httpbin.org. Pide tu nombre, teléfono, correo electrónico, tamaño de pizza, ingredientes, hora de entrega preferida e instrucciones de entrega.
  6 [btn] Completar el formulario de pedido de pizza  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre y mandá el pedido»

- [+ 16.7s] 💬 Persona: poné Juan en el nombre y mandá el pedido
- [+ 20.4s] 📄 Cargó https://httpbin.org/forms/post — «» (paginas/02.txt)
- [+ 20.4s] 💬 JEF: Listo, escrito en Customer name:.
- [+ 20.4s] 🔊 «Listo, escrito en Customer name:.»
- [+ 20.4s] 🔘 Botones: [Completar el formulario de pedido de pizza] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en un formulario de pedido de pizza de httpbin.org. Pide tu nombre, teléfono, correo electrónico, tamaño de pizza, ingredientes, hora de entrega preferida e instrucciones de entrega.
  6 [H] Vos: poné Juan en el nombre y mandá el pedido
  7 [txt] Listo, escrito en Customer name:.
  8 [btn] Completar el formulario de pedido de pizza  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
