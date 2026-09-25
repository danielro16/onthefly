# formulario-de-otra-pagina

**Quién:** Ciega. Escribió su nombre en una página y después fue a otra a pedir un turno.

**Qué quiere:** Que lo escrito en la página anterior no cuente como escrito en el formulario de la nueva: después del DNI, JEF tiene que pedir el día, no saltearlo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/dos-formularios.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/dos-formularios.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/01.txt)
- [+ 10.4s] 💬 JEF: Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
- [+ 10.4s] 🔊 «Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.»
- [+ 10.4s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Escribir al club] · [Recibir novedades del club]
- [+ 10.4s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Escribir al club] · [Recibir novedades del club] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
  6 [btn] Abrir «Pedir un turno para la pileta»  (Primera de 4 opciones.)
  7 [btn] Escribir al club
  8 [btn] Recibir novedades del club
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre»

- [+ 18.5s] 💬 Persona: poné Juan en el nombre
- [+ 21.3s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/02.txt)
- [+ 21.3s] 💬 JEF: Listo, escrito en Nombre.
- [+ 21.3s] 🔊 «Listo, escrito en Nombre.»
- [+ 21.3s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Escribir al club] · [Recibir novedades del club] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [btn] Abrir «Pedir un turno para la pileta»  (Primera de 4 opciones.)
  9 [btn] Escribir al club
 10 [btn] Recibir novedades del club
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 3 — escribe «http://localhost:8765/turno.html»

- [+ 28.7s] 💬 Persona: http://localhost:8765/turno.html
- [+ 28.7s] 💬 JEF: Abriendo localhost.
- [+ 28.7s] 🔊 «Abriendo localhost.»
- [+ 29.3s] 📄 Cargó http://localhost:8765/turno.html — «Turnos de la pileta» (paginas/03.txt)
- [+ 31.6s] 💬 JEF: Estás en el formulario para pedir un turno de la pileta; solicita el DNI, el día y la hora.
- [+ 31.6s] 🔊 «Estás en el formulario para pedir un turno de la pileta; solicita el DNI, el día y la hora.»
- [+ 31.6s] 🔘 Botones: [Pedir turno para la pileta]
- [+ 31.6s] 🔘 Botones: [Pedir turno para la pileta] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario para pedir un turno de la pileta; solicita el DNI, el día y la hora.
 11 [btn] Pedir turno para la pileta  (Primera de 3 opciones.)
 12 [btn] Volver a «Club Social del Barrio»
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 4 — toca el botón turno: «Pedir turno para la pileta»

- [+ 37.2s] 💬 Persona: Pedir turno para la pileta
- [+ 37.2s] 💬 JEF: «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 37.2s] 🔊 ««Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 37.2s] 🔘 Botones: [Pedir turno para la pileta] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario para pedir un turno de la pileta; solicita el DNI, el día y la hora.
 11 [H] Vos: Pedir turno para la pileta
 12 [txt] «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
 13 [btn] Pedir turno para la pileta  (Primera de 3 opciones.)
 14 [btn] Volver a «Club Social del Barrio»
 15 [btn] Otra cosa
 16 [campo] Pedido  = Escribir: DNI  (Va directo al campo «DNI» de la página.)
 17 [btn] Enviar
```

## Paso 5 — escribe «30123456»

- [+ 46.8s] 💬 Persona: DNI terminado en 456
- [+ 47.6s] 📄 Cargó http://localhost:8765/turno.html — «Turnos de la pileta» (paginas/04.txt)
- [+ 47.6s] 💬 JEF: Listo. ¿Qué pongo en «Día»?
- [+ 47.6s] 🔊 «Listo. ¿Qué pongo en «Día»?»
- [+ 47.6s] 🔘 Botones: [Pedir turno para la pileta] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de inicio del Club Social del Barrio, que ofrece actividades para todas las edades, de lunes a sábado. Desde aquí puedes pedir un turno para la pileta, escribir al club o recibir sus novedades.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario para pedir un turno de la pileta; solicita el DNI, el día y la hora.
 11 [H] Vos: Pedir turno para la pileta
 12 [txt] «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
 13 [H] Vos: DNI terminado en 456
 14 [txt] Listo. ¿Qué pongo en «Día»?
 15 [btn] Pedir turno para la pileta  (Primera de 3 opciones.)
 16 [btn] Volver a «Club Social del Barrio»
 17 [btn] Otra cosa
 18 [campo] Pedido  = Escribir: Día  (Va directo al campo «Día» de la página.)
 19 [btn] Enviar
```
