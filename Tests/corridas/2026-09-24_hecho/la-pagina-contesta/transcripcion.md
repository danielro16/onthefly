# la-pagina-contesta

**Quién:** Cualquiera: aprieta botones que contestan con un aviso o con una pregunta.

**Qué quiere:** Que JEF cuente lo que la página contestó después de apretar («se guardaron»), y que una pregunta de confirmación no la acepte solo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/responde.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/responde.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/01.txt)
- [+ 10.4s] 💬 JEF: Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
- [+ 10.4s] 🔊 «Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.»
- [+ 10.4s] 🔘 Botones: [Guardar preferencias] · [Borrar todo]
- [+ 10.4s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
  6 [btn] Guardar preferencias  (Primera de 3 opciones.)
  7 [btn] Borrar todo
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «guardá las preferencias»

- [+ 18.2s] 💬 Persona: guardá las preferencias
- [+ 19.9s] 💬 JEF: Acá no hay un formulario para enviar.
- [+ 19.9s] 🔊 «Acá no hay un formulario para enviar.»
- [+ 19.9s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
  6 [H] Vos: guardá las preferencias
  7 [txt] Acá no hay un formulario para enviar.
  8 [btn] Guardar preferencias  (Primera de 3 opciones.)
  9 [btn] Borrar todo
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Guardar preferencias»

- [+ 27.5s] 💬 Persona: Guardar preferencias
- [+ 27.5s] 💬 JEF: Tocando «Guardar preferencias».
- [+ 27.5s] 🔊 «Tocando «Guardar preferencias».»
- [+ 28.7s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/02.txt)
- [+ 30.1s] 💬 JEF: Listo: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. No queda nada más pendiente de lo que viniste a hacer.
- [+ 30.1s] 🔊 «Listo: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. No queda nada más pendiente de lo que viniste a hacer.»
- [+ 30.1s] 🔘 Botones: [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
  6 [H] Vos: guardá las preferencias
  7 [txt] Acá no hay un formulario para enviar.
  8 [H] Vos: Guardar preferencias
  9 [txt] Tocando «Guardar preferencias».
 10 [txt] Listo: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. No queda nada más pendiente de lo que viniste a hacer.
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 4 — escribe «borrá todo»

- [+ 37.3s] 💬 Persona: borrá todo
- [+ 40.8s] 💬 JEF: «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
- [+ 40.8s] 🔊 ««Borrar todo» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 40.8s] 🔘 Botones: [Pulsar «Borrar todo»]
- [+ 40.8s] 🔘 Botones: [Pulsar «Borrar todo»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
  6 [H] Vos: guardá las preferencias
  7 [txt] Acá no hay un formulario para enviar.
  8 [H] Vos: Guardar preferencias
  9 [txt] Tocando «Guardar preferencias».
 10 [txt] Listo: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. No queda nada más pendiente de lo que viniste a hacer.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [btn] Pulsar «Borrar todo»  (Primera de 2 opciones.)
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Pulsar «Borrar todo»»

- [+ 47.7s] 💬 Persona: Pulsar «Borrar todo»
- [+ 47.7s] 💬 JEF: Pulsando «Borrar todo».
- [+ 47.7s] 🔊 «Pulsando «Borrar todo».»
- [+ 51.4s] 🔊 «Borrar todo no cambió la página.»
- [+ 53.3s] 💬 JEF: Presionaste «Borrar todo» y la página preguntó si estás seguro, pero no se aceptó, así que no se confirmó el borrado. Estás en la página «Mis preferencias» del club, un formulario para elegir cómo querés recibir las novedades. Abajo aparece el aviso «Tus preferencias se guardaron», y para cumplir lo que viniste a hacer está el botón «Guardar preferencias» al lado de «Borrar todo».
- [+ 53.3s] 🔊 «Presionaste «Borrar todo» y la página preguntó si estás seguro, pero no se aceptó, así que no se confirmó el borrado. Estás en la página «Mis preferencias» del club, un formulario para elegir cómo querés recibir las novedades. Abajo aparece el aviso «Tus preferencias se guardaron», y para cumplir lo que viniste a hacer está el botón «Guardar preferencias» al lado de «Borrar todo».»
- [+ 53.3s] 🔘 Botones: [Guardar preferencias] · [Resumir la página]
- [+ 53.3s] 🔘 Botones: [Guardar preferencias] · [Resumir la página] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de preferencias del club, donde podés elegir cómo querés recibir las novedades. Ahora mismo tiene dos opciones: guardar lo que elijas o borrar todo; no veo casillas marcadas todavía. Si querés, puedo revisar las opciones disponibles para completarlas.
  6 [H] Vos: guardá las preferencias
  7 [txt] Acá no hay un formulario para enviar.
  8 [H] Vos: Guardar preferencias
  9 [txt] Tocando «Guardar preferencias».
 10 [txt] Listo: se guardaron tus preferencias, la página lo confirma con «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. No queda nada más pendiente de lo que viniste a hacer.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [H] Vos: Pulsar «Borrar todo»
 14 [txt] Pulsando «Borrar todo».
 15 [txt] Presionaste «Borrar todo» y la página preguntó si estás seguro, pero no se aceptó, así que no se confirmó el borrado. Estás en la página «Mis preferencias» del club, un formulario para elegir cómo querés recibir las novedades. Abajo aparece el aviso «Tus preferencias se guardaron», y para cumplir lo que viniste a hacer está el botón «Guardar preferencias» al lado de «Borrar todo».
 16 [btn] Guardar preferencias  (Primera de 3 opciones.)
 17 [btn] Resumir la página
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
