# candado-formulario

**Quién:** Ciega. Pide por voz completar y mandar un pedido, sin tocar la pantalla.

**Qué quiere:** Que JEF escriba lo que ella dijo y NO mande un pedido que compromete sin que ella toque el botón.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «httpbin.org/forms/post»

- [+  6.4s] 💬 Persona: httpbin.org/forms/post
- [+  6.4s] 💬 JEF: Abriendo httpbin.org.
- [+  6.4s] 🔊 «Abriendo httpbin.org.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó https://httpbin.org/forms/post — «» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en un formulario para hacer un pedido de pizza. Pide el nombre del cliente, teléfono, correo electrónico, tamaño de la pizza, ingredientes, hora preferida de entrega e instrucciones.
- [+ 10.5s] 🔊 «Estás en un formulario para hacer un pedido de pizza. Pide el nombre del cliente, teléfono, correo electrónico, tamaño de la pizza, ingredientes, hora preferida de entrega e instrucciones.»
- [+ 10.5s] 🔘 Botones: [Completar el formulario del pedido]
- [+ 10.5s] 🔘 Botones: [Completar el formulario del pedido] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en un formulario para hacer un pedido de pizza. Pide el nombre del cliente, teléfono, correo electrónico, tamaño de la pizza, ingredientes, hora preferida de entrega e instrucciones.
  6 [btn] Completar el formulario del pedido  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre y mandá el pedido»

- [+ 20.7s] 💬 Persona: poné Juan en el nombre y mandá el pedido
- [+ 26.5s] 📄 Cargó https://httpbin.org/forms/post — «» (paginas/02.txt)
- [+ 26.5s] 💬 JEF: Listo, escrito en Customer name:.
- [+ 26.5s] 🔊 «Listo, escrito en Customer name:.»
- [+ 29.6s] 💬 JEF: «Submit order» puede confirmar algo: queda abajo, para tocarlo.
- [+ 29.6s] 🔊 ««Submit order» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 29.6s] 🔘 Botones: [Pulsar «Submit order»]
- [+ 29.6s] 🔘 Botones: [Pulsar «Submit order»] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en un formulario para hacer un pedido de pizza. Pide el nombre del cliente, teléfono, correo electrónico, tamaño de la pizza, ingredientes, hora preferida de entrega e instrucciones.
  6 [H] Vos: poné Juan en el nombre y mandá el pedido
  7 [txt] Listo, escrito en Customer name:.
  8 [txt] «Submit order» puede confirmar algo: queda abajo, para tocarlo.
  9 [btn] Pulsar «Submit order»  (Primera de 2 opciones.)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
