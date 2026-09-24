# la-pagina-contesta

**Quién:** Cualquiera: aprieta botones que contestan con un aviso o con una pregunta.

**Qué quiere:** Que JEF cuente lo que la página contestó después de apretar («se guardaron»), y que una pregunta de confirmación no la acepte solo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/responde.html»

- [+  6.2s] 💬 Persona: http://localhost:8765/responde.html
- [+  6.2s] 💬 JEF: Abriendo localhost.
- [+  6.2s] 🔊 «Abriendo localhost.»
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/01.txt)
- [+ 10.8s] 💬 JEF: Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
- [+ 10.8s] 🔊 «Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.»
- [+ 10.8s] 🔘 Botones: [Guardar preferencias] · [Borrar todo]
- [+ 10.8s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
  6 [btn] Guardar preferencias  (Primera de 3 opciones.)
  7 [btn] Borrar todo
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «guardá las preferencias»

- [+ 18.7s] 💬 Persona: guardá las preferencias
- [+ 21.5s] 💬 JEF: «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
- [+ 21.5s] 🔊 ««Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 21.5s] 🔘 Botones: [Pulsar «Guardar preferencias»]
- [+ 21.5s] 🔘 Botones: [Pulsar «Guardar preferencias»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Guardar preferencias»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Guardar preferencias»»

- [+ 43.0s] 💬 Persona: Pulsar «Guardar preferencias»
- [+ 43.0s] 💬 JEF: Pulsando «Guardar preferencias».
- [+ 43.0s] 🔊 «Pulsando «Guardar preferencias».»
- [+ 44.6s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/02.txt)
- [+ 46.7s] 💬 JEF: Listo: guardé tus preferencias y la página confirmó «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
- [+ 46.7s] 🔊 «Listo: guardé tus preferencias y la página confirmó «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.»
- [+ 46.7s] 🔘 Botones: [Otra cosa]

Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Listo: guardé tus preferencias y la página confirmó «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 4 — escribe «borrá todo»


Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Listo: guardé tus preferencias y la página confirmó «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Otra cosa»

- [+ 72.9s] 💬 Persona: Otra cosa
- [+ 72.9s] 💬 JEF: ¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.
- [+ 72.9s] 🔊 «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.»

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página «Mis preferencias», donde elegís cómo querés recibir las novedades del club. La página muestra ese mensaje y dos botones: «Guardar preferencias» y «Borrar todo»; no se ven más opciones para marcar. Podés guardar lo elegido o borrar todo cuando quieras.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Listo: guardé tus preferencias y la página confirmó «Tus preferencias se guardaron». Estás en la página «Mis preferencias» del club, donde se elige cómo recibir las novedades. Si querés, también podés borrar todo lo guardado.
 11 [H] Vos: Otra cosa
 12 [txt] ¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
