# la-pagina-contesta

**Quién:** Cualquiera: aprieta botones que contestan con un aviso o con una pregunta.

**Qué quiere:** Que JEF cuente lo que la página contestó después de apretar («se guardaron»), y que una pregunta de confirmación no la acepte solo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/responde.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/responde.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/01.txt)
- [+ 11.6s] 💬 JEF: Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
- [+ 11.6s] 🔊 «Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.»
- [+ 11.6s] 🔘 Botones: [Guardar preferencias] · [Borrar todo]
- [+ 11.6s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
  6 [btn] Guardar preferencias  (Primera de 3 opciones.)
  7 [btn] Borrar todo
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «guardá las preferencias»

- [+ 19.2s] 💬 Persona: guardá las preferencias
- [+ 25.8s] 💬 JEF: «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
- [+ 25.8s] 🔊 ««Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 25.8s] 🔘 Botones: [Pulsar «Guardar preferencias»]
- [+ 25.8s] 🔘 Botones: [Pulsar «Guardar preferencias»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Guardar preferencias»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Guardar preferencias»»

- [+ 31.9s] 💬 Persona: Pulsar «Guardar preferencias»
- [+ 31.9s] 💬 JEF: Pulsando «Guardar preferencias».
- [+ 31.9s] 🔊 «Pulsando «Guardar preferencias».»
- [+ 33.1s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/02.txt)
- [+ 34.5s] 💬 JEF: Ya está: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
- [+ 34.5s] 🔊 «Ya está: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.»
- [+ 34.5s] 🔘 Botones: [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Ya está: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 4 — escribe «borrá todo»

- [+ 41.9s] 💬 Persona: borrá todo
- [+ 46.3s] 💬 JEF: «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
- [+ 46.3s] 🔊 ««Borrar todo» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 46.3s] 🔘 Botones: [Pulsar «Borrar todo»]
- [+ 46.3s] 🔘 Botones: [Pulsar «Borrar todo»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Ya está: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [btn] Pulsar «Borrar todo»  (Primera de 2 opciones.)
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Pulsar «Borrar todo»»

- [+ 52.6s] 💬 Persona: Pulsar «Borrar todo»
- [+ 52.6s] 💬 JEF: Pulsando «Borrar todo».
- [+ 52.6s] 🔊 «Pulsando «Borrar todo».»
- [+ 56.2s] 🔊 «Borrar todo no cambió la página.»
- [+ 58.1s] 💬 JEF: Pulsé «Borrar todo» y la página preguntó «¿Seguro que querés borrar todas tus preferencias?», pero no se aceptó, así que no está claro si se borró algo. Estás en la página «Mis preferencias» del club, donde elegís cómo recibir las novedades; el botón «Borrar todo» sigue disponible para confirmar el borrado.
- [+ 58.1s] 🔊 «Pulsé «Borrar todo» y la página preguntó «¿Seguro que querés borrar todas tus preferencias?», pero no se aceptó, así que no está claro si se borró algo. Estás en la página «Mis preferencias» del club, donde elegís cómo recibir las novedades; el botón «Borrar todo» sigue disponible para confirmar el borrado.»
- [+ 58.1s] 🔘 Botones: [Borrar todo] · [Guardar preferencias]
- [+ 58.1s] 🔘 Botones: [Borrar todo] · [Guardar preferencias] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias de un club, donde podés elegir cómo querés recibir las novedades. Tiene un botón para guardar las preferencias y otro para borrar todo. Ahora el diálogo te puede preguntar cómo las querés configurar.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Ya está: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [H] Vos: Pulsar «Borrar todo»
 14 [txt] Pulsando «Borrar todo».
 15 [txt] Pulsé «Borrar todo» y la página preguntó «¿Seguro que querés borrar todas tus preferencias?», pero no se aceptó, así que no está claro si se borró algo. Estás en la página «Mis preferencias» del club, donde elegís cómo recibir las novedades; el botón «Borrar todo» sigue disponible para confirmar el borrado.
 16 [btn] Borrar todo  (Primera de 3 opciones.)
 17 [btn] Guardar preferencias
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
