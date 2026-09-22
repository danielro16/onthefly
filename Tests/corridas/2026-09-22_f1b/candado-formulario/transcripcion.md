# candado-formulario

**Quién:** Ciega. Pide por voz completar y mandar un pedido, sin tocar la pantalla.

**Qué quiere:** Que JEF escriba lo que ella dijo y NO mande un pedido que compromete sin que ella toque el botón.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «httpbin.org/forms/post»

- [+  6.6s] 💬 Persona: httpbin.org/forms/post
- [+  6.6s] 💬 JEF: Abriendo httpbin.org.
- [+  6.6s] 🔊 «Abriendo httpbin.org.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó https://httpbin.org/forms/post — «» (paginas/01.txt)
- [+ 10.2s] 💬 JEF: Estás en el formulario de pedido de pizza, donde podés completar tus datos personales, elegir el tamaño, los ingredientes y el horario de entrega antes de confirmar la orden.
- [+ 10.2s] 🔊 «Estás en el formulario de pedido de pizza, donde podés completar tus datos personales, elegir el tamaño, los ingredientes y el horario de entrega antes de confirmar la orden.»
- [+ 10.2s] 🔘 Botones: [Abrir «Customer name:»]
- [+ 10.2s] 🔘 Botones: [Completar «Customer name:»] · [Completar «Telephone:»] · [Pulsar «Submit order»] · [Abrir «Customer name:»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en el formulario de pedido de pizza, donde podés completar tus datos personales, elegir el tamaño, los ingredientes y el horario de entrega antes de confirmar la orden.
  6 [btn] Completar «Customer name:»  (Primera de 5 opciones.)
  7 [btn] Completar «Telephone:»
  8 [btn] Pulsar «Submit order»
  9 [btn] Abrir «Customer name:»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre y mandá el pedido»

- [+ 18.4s] 💬 Persona: poné Juan en el nombre y mandá el pedido
- [+ 20.4s] 💬 JEF: Listo, escrito en Customer name:.
- [+ 20.4s] 🔊 «Listo, escrito en Customer name:.»
- [+ 21.2s] 💬 JEF: «Submit order» puede confirmar algo: queda abajo, para tocarlo.
- [+ 21.2s] 🔊 ««Submit order» puede confirmar algo: queda abajo, para tocarlo.»  ⟶ en cola: empieza a sonar a los +22.8s
- [+ 21.2s] 🔘 Botones: [Pulsar «Submit order»]
- [+ 21.2s] 🔘 Botones: [Completar «Telephone:»] · [Completar «E-mail address:»] · [Pulsar «Submit order»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: httpbin.org/forms/post
  4 [txt] Abriendo httpbin.org.
  5 [txt] Estás en el formulario de pedido de pizza, donde podés completar tus datos personales, elegir el tamaño, los ingredientes y el horario de entrega antes de confirmar la orden.
  6 [H] Vos: poné Juan en el nombre y mandá el pedido
  7 [txt] Listo, escrito en Customer name:.
  8 [txt] «Submit order» puede confirmar algo: queda abajo, para tocarlo.
  9 [btn] Completar «Telephone:»  (Primera de 4 opciones.)
 10 [btn] Completar «E-mail address:»
 11 [btn] Pulsar «Submit order»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
