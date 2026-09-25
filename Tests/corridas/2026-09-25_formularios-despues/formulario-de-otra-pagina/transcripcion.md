# formulario-de-otra-pagina

**Quién:** Ciega. Escribió su nombre en una página y después fue a otra a pedir un turno.

**Qué quiere:** Que lo escrito en la página anterior no cuente como escrito en el formulario de la nueva: después del DNI, JEF tiene que pedir el día, no saltearlo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/dos-formularios.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/dos-formularios.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/01.txt)
- [+  7.9s] ⚠️ La orientación del modelo se descartó (transport("La conexión a internet parece estar desactivada.")): JEF usa la descripción de plantilla
- [+  7.9s] 💬 JEF: Estás en «Club Social del Barrio», localhost.
- [+  7.9s] 🔊 «Estás en «Club Social del Barrio», localhost.»
- [+  7.9s] 💬 JEF: Hay un formulario de 1 campo: Correo electrónico.
- [+  7.9s] 🔊 «Hay un formulario de 1 campo: Correo electrónico.»  ⟶ en cola: empieza a sonar a los +11.2s
- [+  7.9s] 💬 JEF: Indicar qué poner y lo completo.
- [+  7.9s] 🔊 «Indicar qué poner y lo completo.»  ⟶ en cola: empieza a sonar a los +14.7s
- [+  7.9s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en «Club Social del Barrio», localhost.
  6 [txt] Hay un formulario de 1 campo: Correo electrónico.
  7 [txt] Indicar qué poner y lo completo.
  8 [btn] Leer la página  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — escribe «poné Juan en el nombre»

- [+ 18.4s] 💬 Persona: poné Juan en el nombre
- [+ 18.4s] 💬 JEF: Sin conexión. No puedo entender lo que pedís sin internet.
- [+ 18.4s] 🔊 «Sin conexión. No puedo entender lo que pedís sin internet.»
- [+ 18.4s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en «Club Social del Barrio», localhost.
  6 [txt] Hay un formulario de 1 campo: Correo electrónico.
  7 [txt] Indicar qué poner y lo completo.
  8 [H] Vos: poné Juan en el nombre
  9 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
 10 [btn] Leer la página  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — escribe «http://localhost:8765/turno.html»

- [+ 28.6s] 💬 Persona: http://localhost:8765/turno.html
- [+ 28.6s] 💬 JEF: Abriendo localhost.
- [+ 28.6s] 🔊 «Abriendo localhost.»
- [+ 29.3s] 📄 Cargó http://localhost:8765/turno.html — «Turnos de la pileta» (paginas/02.txt)
- [+ 29.3s] ⚠️ La orientación del modelo se descartó (transport("La conexión a internet parece estar desactivada.")): JEF usa la descripción de plantilla
- [+ 29.3s] 💬 JEF: Estás en «Turnos de la pileta», localhost.
- [+ 29.3s] 🔊 «Estás en «Turnos de la pileta», localhost.»
- [+ 29.3s] 💬 JEF: Hay un formulario de 3 campos: DNI, Día, Hora.
- [+ 29.3s] 🔊 «Hay un formulario de 3 campos: DNI, Día, Hora.»  ⟶ en cola: empieza a sonar a los +33.0s
- [+ 29.3s] 💬 JEF: Indicar qué poner y lo completo.
- [+ 29.3s] 🔊 «Indicar qué poner y lo completo.»  ⟶ en cola: empieza a sonar a los +36.3s
- [+ 29.3s] 🔘 Botones: [Volver a «Club Social del Barrio»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en «Club Social del Barrio», localhost.
  6 [txt] Hay un formulario de 1 campo: Correo electrónico.
  7 [txt] Indicar qué poner y lo completo.
  8 [H] Vos: poné Juan en el nombre
  9 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
 10 [H] Vos: http://localhost:8765/turno.html
 11 [txt] Abriendo localhost.
 12 [txt] Estás en «Turnos de la pileta», localhost.
 13 [txt] Hay un formulario de 3 campos: DNI, Día, Hora.
 14 [txt] Indicar qué poner y lo completo.
 15 [btn] Volver a «Club Social del Barrio»  (Primera de 2 opciones.)
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```

## Paso 4 — toca el botón 1: «Volver a «Club Social del Barrio»»

- [+ 38.9s] 💬 Persona: Volver a «Club Social del Barrio»
- [+ 38.9s] 💬 JEF: Volviendo.
- [+ 38.9s] 🔊 «Volviendo.»
- [+ 39.5s] 📄 Cargó http://localhost:8765/dos-formularios.html — «Club Social del Barrio» (paginas/03.txt)
- [+ 39.5s] 💬 JEF: De vuelta en «Club Social del Barrio», localhost.
- [+ 39.5s] 🔊 «De vuelta en «Club Social del Barrio», localhost.»
- [+ 39.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en «Club Social del Barrio», localhost.
  6 [txt] Hay un formulario de 1 campo: Correo electrónico.
  7 [txt] Indicar qué poner y lo completo.
  8 [H] Vos: poné Juan en el nombre
  9 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
 10 [H] Vos: http://localhost:8765/turno.html
 11 [txt] Abriendo localhost.
 12 [txt] Estás en «Turnos de la pileta», localhost.
 13 [txt] Hay un formulario de 3 campos: DNI, Día, Hora.
 14 [txt] Indicar qué poner y lo completo.
 15 [H] Vos: Volver a «Club Social del Barrio»
 16 [txt] Volviendo.
 17 [txt] De vuelta en «Club Social del Barrio», localhost.
 18 [btn] Leer la página  (Primera de 3 opciones.)
 19 [btn] Resumir la página
 20 [btn] Otra cosa
 21 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 22 [btn] Enviar
```

## Paso 5 — escribe «30123456»

- [+ 48.5s] 💬 Persona: 30123456
- [+ 48.5s] 💬 JEF: Sin conexión. No puedo entender lo que pedís sin internet.
- [+ 48.5s] 🔊 «Sin conexión. No puedo entender lo que pedís sin internet.»
- [+ 48.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/dos-formularios.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en «Club Social del Barrio», localhost.
  6 [txt] Hay un formulario de 1 campo: Correo electrónico.
  7 [txt] Indicar qué poner y lo completo.
  8 [H] Vos: poné Juan en el nombre
  9 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
 10 [H] Vos: http://localhost:8765/turno.html
 11 [txt] Abriendo localhost.
 12 [txt] Estás en «Turnos de la pileta», localhost.
 13 [txt] Hay un formulario de 3 campos: DNI, Día, Hora.
 14 [txt] Indicar qué poner y lo completo.
 15 [H] Vos: Volver a «Club Social del Barrio»
 16 [txt] Volviendo.
 17 [txt] De vuelta en «Club Social del Barrio», localhost.
 18 [H] Vos: 30123456
 19 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
 20 [btn] Leer la página  (Primera de 3 opciones.)
 21 [btn] Resumir la página
 22 [btn] Otra cosa
 23 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 24 [btn] Enviar
```
