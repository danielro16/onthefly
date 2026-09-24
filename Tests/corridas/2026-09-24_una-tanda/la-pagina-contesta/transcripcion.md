# la-pagina-contesta

**Quién:** Cualquiera: aprieta botones que contestan con un aviso o con una pregunta.

**Qué quiere:** Que JEF cuente lo que la página contestó después de apretar («se guardaron»), y que una pregunta de confirmación no la acepte solo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/responde.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/responde.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/01.txt)
- [+  9.8s] 💬 JEF: Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
- [+  9.8s] 🔊 «Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.»
- [+  9.8s] 🔘 Botones: [Guardar preferencias] · [Borrar todo]
- [+  9.8s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
  6 [btn] Guardar preferencias  (Primera de 3 opciones.)
  7 [btn] Borrar todo
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «guardá las preferencias»

- [+ 16.8s] 💬 Persona: guardá las preferencias
- [+ 19.9s] 💬 JEF: «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
- [+ 19.9s] 🔊 ««Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 19.9s] 🔘 Botones: [Pulsar «Guardar preferencias»]
- [+ 19.9s] 🔘 Botones: [Pulsar «Guardar preferencias»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Guardar preferencias»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Guardar preferencias»»

- [+ 25.5s] 💬 Persona: Pulsar «Guardar preferencias»
- [+ 25.5s] 💬 JEF: Pulsando «Guardar preferencias».
- [+ 25.5s] 🔊 «Pulsando «Guardar preferencias».»
- [+ 26.7s] 📄 Cargó http://localhost:8765/responde.html — «Mis preferencias» (paginas/02.txt)
- [+ 28.7s] 💬 JEF: Las preferencias se guardaron correctamente. Esta página del club permite elegir cómo recibir sus novedades.
- [+ 28.7s] 🔊 «Las preferencias se guardaron correctamente. Esta página del club permite elegir cómo recibir sus novedades.»
- [+ 28.7s] 🔘 Botones: [Borrar todo] · [Resumir la página]
- [+ 28.7s] 🔘 Botones: [Borrar todo] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Las preferencias se guardaron correctamente. Esta página del club permite elegir cómo recibir sus novedades.
 11 [btn] Borrar todo  (Primera de 3 opciones.)
 12 [btn] Resumir la página
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 4 — escribe «borrá todo»

- [+ 36.9s] 💬 Persona: borrá todo
- [+ 41.8s] 💬 JEF: «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
- [+ 41.8s] 🔊 ««Borrar todo» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 41.8s] 🔘 Botones: [Pulsar «Borrar todo»]
- [+ 41.8s] 🔘 Botones: [Pulsar «Borrar todo»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Las preferencias se guardaron correctamente. Esta página del club permite elegir cómo recibir sus novedades.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [btn] Pulsar «Borrar todo»  (Primera de 2 opciones.)
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Pulsar «Borrar todo»»

- [+ 47.3s] 💬 Persona: Pulsar «Borrar todo»
- [+ 47.3s] 💬 JEF: Pulsando «Borrar todo».
- [+ 47.3s] 🔊 «Pulsando «Borrar todo».»
- [+ 50.9s] 🔊 «Borrar todo no cambió la página.»
- [+ 53.0s] 💬 JEF: La página pidió confirmar el borrado de todas tus preferencias, pero no se aceptó. Esta página sirve para guardar cómo quieres recibir las novedades del club; tus preferencias aparecen como guardadas.
- [+ 53.0s] 🔊 «La página pidió confirmar el borrado de todas tus preferencias, pero no se aceptó. Esta página sirve para guardar cómo quieres recibir las novedades del club; tus preferencias aparecen como guardadas.»
- [+ 53.0s] 🔘 Botones: [Guardar preferencias] · [Borrar todo]
- [+ 53.0s] 🔘 Botones: [Guardar preferencias] · [Borrar todo] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/responde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario «Mis preferencias» de la institución, que permite elegir cómo recibir las novedades del club.
  6 [H] Vos: guardá las preferencias
  7 [txt] «Guardar preferencias» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Guardar preferencias»
  9 [txt] Pulsando «Guardar preferencias».
 10 [txt] Las preferencias se guardaron correctamente. Esta página del club permite elegir cómo recibir sus novedades.
 11 [H] Vos: borrá todo
 12 [txt] «Borrar todo» puede confirmar algo: queda abajo, para tocarlo.
 13 [H] Vos: Pulsar «Borrar todo»
 14 [txt] Pulsando «Borrar todo».
 15 [txt] La página pidió confirmar el borrado de todas tus preferencias, pero no se aceptó. Esta página sirve para guardar cómo quieres recibir las novedades del club; tus preferencias aparecen como guardadas.
 16 [btn] Guardar preferencias  (Primera de 3 opciones.)
 17 [btn] Borrar todo
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
