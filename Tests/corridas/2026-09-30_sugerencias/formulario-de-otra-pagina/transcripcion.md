# formulario-de-otra-pagina

**Quién:** Ciega. Escribió su nombre en una página y después fue a otra a pedir un turno.

**Qué quiere:** Que lo escrito en la página anterior no cuente como escrito en el formulario de la nueva: después del DNI, JEF tiene que pedir el día, no saltearlo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/dos-formularios.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/dos-formularios.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
- [+ 10.5s] 🔊 «Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.»
- [+ 10.5s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Enviar un mensaje al Club Social del Barrio]
- [+ 10.5s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Enviar un mensaje al Club Social del Barrio] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
  6 [btn] Abrir «Pedir un turno para la pileta»  (Primera de 3 opciones.)
  7 [btn] Enviar un mensaje al Club Social del Barrio
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre»

- [+ 18.7s] 💬 Persona: poné Juan en el nombre
- [+ 22.6s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/02.txt)
- [+ 22.6s] 💬 JEF: Listo, escrito en Nombre.
- [+ 22.6s] 🔊 «Listo, escrito en Nombre.»
- [+ 22.6s] 🔘 Botones: [Abrir «Pedir un turno para la pileta»] · [Enviar un mensaje al Club Social del Barrio] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [btn] Abrir «Pedir un turno para la pileta»  (Primera de 3 opciones.)
  9 [btn] Enviar un mensaje al Club Social del Barrio
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — escribe «http://localhost:8765/turno.html»

- [+ 31.7s] 💬 Persona: http://localhost:8765/turno.html
- [+ 31.7s] 💬 JEF: Abriendo localhost.
- [+ 31.7s] 🔊 «Abriendo localhost.»
- [+ 32.3s] 📄 Cargó http://localhost:8765/turno.html — «Turnos de la pileta» (paginas/03.txt)
- [+ 34.5s] 💬 JEF: Estás en el formulario de turnos de la pileta; pide el DNI, el día y la hora para solicitar un turno.
- [+ 34.5s] 🔊 «Estás en el formulario de turnos de la pileta; pide el DNI, el día y la hora para solicitar un turno.»
- [+ 34.5s] 🔘 Botones: [Pedir turno para la pileta] · [Resumir la página]
- [+ 34.5s] 🔘 Botones: [Pedir turno para la pileta] · [Resumir la página] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario de turnos de la pileta; pide el DNI, el día y la hora para solicitar un turno.
 11 [btn] Pedir turno para la pileta  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a «Club Social del Barrio»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 4 — toca el botón turno: «Pedir turno para la pileta»

- [+ 40.6s] 💬 Persona: Pedir turno para la pileta
- [+ 40.6s] 💬 JEF: «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 40.6s] 🔊 ««Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 40.6s] 🔘 Botones: [Pedir turno para la pileta] · [Resumir la página] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario de turnos de la pileta; pide el DNI, el día y la hora para solicitar un turno.
 11 [H] Vos: Pedir turno para la pileta
 12 [txt] «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
 13 [btn] Pedir turno para la pileta  (Primera de 4 opciones.)
 14 [btn] Resumir la página
 15 [btn] Volver a «Club Social del Barrio»
 16 [btn] Otra cosa
 17 [campo] Pedido  = Escribir: DNI  (Va directo al campo «DNI» de la página.)
 18 [btn] Enviar
```

## Paso 5 — escribe «30123456»

- [+ 51.8s] 💬 Persona: DNI terminado en 456
- [+ 52.6s] 📄 Cargó http://localhost:8765/turno.html — «Turnos de la pileta» (paginas/04.txt)
- [+ 52.6s] 💬 JEF: Listo. ¿Qué pongo en «Día»?
- [+ 52.6s] 🔊 «Listo. ¿Qué pongo en «Día»?»
- [+ 52.6s] 🔘 Botones: [Pedir turno para la pileta] · [Resumir la página] · [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página principal del Club Social del Barrio, que ofrece actividades para todas las edades de lunes a sábado.
  6 [H] Vos: poné Juan en el nombre
  7 [txt] Listo, escrito en Nombre.
  8 [H] Vos: http://localhost:8765/turno.html
  9 [txt] Abriendo localhost.
 10 [txt] Estás en el formulario de turnos de la pileta; pide el DNI, el día y la hora para solicitar un turno.
 11 [H] Vos: Pedir turno para la pileta
 12 [txt] «Pedir turno para la pileta»: ¿qué escribo? Se puede escribir o dictar acá abajo.
 13 [H] Vos: DNI terminado en 456
 14 [txt] Listo. ¿Qué pongo en «Día»?
 15 [btn] Pedir turno para la pileta  (Primera de 4 opciones.)
 16 [btn] Resumir la página
 17 [btn] Volver a «Club Social del Barrio»
 18 [btn] Otra cosa
 19 [campo] Pedido  = Escribir: Día  (Va directo al campo «Día» de la página.)
 20 [btn] Enviar
```
