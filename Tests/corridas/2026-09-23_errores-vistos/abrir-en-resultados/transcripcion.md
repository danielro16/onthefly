# abrir-en-resultados

**Quién:** Jubilado, ciego. Busca turno en ANSES y pide abrirlo con sus palabras, sin tocar los botones.

**Qué quiere:** Que en la página de Google lo que se abra sea un resultado, nunca una imagen ni una pestaña del buscador.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «anses turnos»

- [+  6.6s] 💬 Persona: anses turnos
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.0s] 💬 JEF: Buscando: anses turnos.
- [+  8.0s] 🔊 «Buscando: anses turnos.»
- [+ 12.2s] 📄 Cargó https://www.google.com/search?q=anses%20turnos&gl=us&hl=es — «anses turnos - Buscar con Google» (paginas/01.txt)
- [+ 12.5s] 💬 JEF: Estás en los resultados de «anses turnos». Los 3 más probables:
- [+ 12.5s] 🔊 «Estás en los resultados de «anses turnos». Los 3 más probables: 1. Turnos, anses.gob.ar. 2. Solicitar turnos en ANSES, argentina.gob.ar. 3. ANSES, anses.gob.ar»
- [+ 12.5s] 🔘 Botones: [Turnos — www.anses.gob.ar] · [Solicitar turnos en ANSES — www.argentina.gob.ar] · [ANSES — www.anses.gob.ar] · [Ver más opciones (3)]
- [+ 12.5s] 🔘 Botones: [Turnos — www.anses.gob.ar] · [Solicitar turnos en ANSES — www.argentina.gob.ar] · [ANSES — www.anses.gob.ar] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses turnos
  4 [txt] Buscando: anses turnos.
  5 [txt] Estás en los resultados de «anses turnos». Los 3 más probables:
  6 [btn] Turnos — www.anses.gob.ar  (Primera de 5 opciones.)
  7 [btn] Solicitar turnos en ANSES — www.argentina.gob.ar
  8 [btn] ANSES — www.anses.gob.ar
  9 [btn] Ver más opciones (3)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — escribe «Turnos Anses»

- [+ 20.1s] 💬 Persona: Turnos Anses
- [+ 23.5s] 💬 JEF: Abriendo Solicitar turnos en ANSES — www.argentina.gob.ar.
- [+ 23.5s] 🔊 «Abriendo Solicitar turnos en ANSES — www.argentina.gob.ar.»
- [+ 26.7s] 📄 Cargó https://www.argentina.gob.ar/servicio/solicitar-turnos-en-anses — «Solicitar turnos en ANSES» (paginas/02.txt)
- [+ 27.3s] 💬 JEF: Abriendo Pedir turno.
- [+ 27.3s] 🔊 «Abriendo Pedir turno.»
- [+ 30.3s] 📄 Cargó https://servicioswww.anses.gob.ar/TurnosInternet/Burbujas/Prestaciones — «ANSES | Turnos - Prestaciones» (paginas/03.txt)
- [+ 32.1s] 💬 JEF: Esta es la página de turnos de ANSES donde puedes realizar diversos trámites previsionales y de seguridad social. Si ya tienes un turno, puedes consultarlo o reprogramarlo directamente aquí. ¿Qué trámite necesitas gestionar?
- [+ 32.1s] 🔊 «Esta es la página de turnos de ANSES donde puedes realizar diversos trámites previsionales y de seguridad social. Si ya tienes un turno, puedes consultarlo o reprogramarlo directamente aquí. ¿Qué trámite necesitas gestionar?»
- [+ 32.1s] 🔘 Botones: [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Solicitud de Pensión] · [Pensión no Contributiva por Invalidez Laboral] · [Ver más opciones (14)]
- [+ 32.1s] 🔘 Botones: [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Solicitud de Pensión] · [Pensión no Contributiva por Invalidez Laboral] · [Ver más opciones (14)] · [Volver a «Solicitar turnos en ANSES»] · [Otra cosa]

Al terminar el paso (19 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses turnos
  4 [txt] Buscando: anses turnos.
  5 [txt] Estás en los resultados de «anses turnos». Los 3 más probables:
  6 [H] Vos: Turnos Anses
  7 [txt] Abriendo Solicitar turnos en ANSES — www.argentina.gob.ar.
  8 [txt] Abriendo Pedir turno.
  9 [txt] Esta es la página de turnos de ANSES donde puedes realizar diversos trámites previsionales y de seguridad social. Si ya tienes un turno, puedes consultarlo o reprogramarlo directamente aquí. ¿Qué trámite necesitas gestionar?
 10 [btn] Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…  (Primera de 7 opciones.)
 11 [btn] Solicitud de Jubilación
 12 [btn] Solicitud de Pensión
 13 [btn] Pensión no Contributiva por Invalidez Laboral
 14 [btn] Ver más opciones (14)
 15 [btn] Volver a «Solicitar turnos en ANSES»
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```

## Paso 3 — escribe «volvé»

- [+ 38.9s] 💬 Persona: volvé
- [+ 40.4s] 💬 JEF: Volviendo.
- [+ 40.4s] 🔊 «Volviendo.»
- [+ 41.1s] 📄 Cargó https://www.argentina.gob.ar/servicio/solicitar-turnos-en-anses — «Solicitar turnos en ANSES» (paginas/04.txt)
- [+ 41.1s] 💬 JEF: De vuelta en «Solicitar turnos en ANSES», Argentina.gob.ar.
- [+ 41.1s] 🔊 «De vuelta en «Solicitar turnos en ANSES», Argentina.gob.ar.»
- [+ 41.1s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses turnos
  4 [txt] Buscando: anses turnos.
  5 [txt] Estás en los resultados de «anses turnos». Los 3 más probables:
  6 [H] Vos: Turnos Anses
  7 [txt] Abriendo Solicitar turnos en ANSES — www.argentina.gob.ar.
  8 [txt] Abriendo Pedir turno.
  9 [txt] Esta es la página de turnos de ANSES donde puedes realizar diversos trámites previsionales y de seguridad social. Si ya tienes un turno, puedes consultarlo o reprogramarlo directamente aquí. ¿Qué trámite necesitas gestionar?
 10 [H] Vos: volvé
 11 [txt] Volviendo.
 12 [txt] De vuelta en «Solicitar turnos en ANSES», Argentina.gob.ar.
 13 [btn] Leer la página  (Primera de 4 opciones.)
 14 [btn] Resumir la página
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```

## Paso 4 — escribe «Sacar turno»

- [+ 49.1s] 💬 Persona: Sacar turno
- [+ 50.4s] 💬 JEF: Abriendo «Pedir turno».
- [+ 50.4s] 🔊 «Abriendo «Pedir turno».»
- [+ 53.2s] 📄 Cargó https://servicioswww.anses.gob.ar/TurnosInternet/Burbujas/Prestaciones — «ANSES | Turnos - Prestaciones» (paginas/05.txt)
- [+ 54.7s] 💬 JEF: Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. ¿Qué trámite necesitas realizar?
- [+ 54.7s] 🔊 «Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. ¿Qué trámite necesitas realizar?»
- [+ 54.7s] 🔘 Botones: [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Solicitud de Pensión] · [Pensión no Contributiva por Invalidez Laboral] · [Ver más opciones (16)]
- [+ 54.7s] 🔘 Botones: [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Solicitud de Pensión] · [Pensión no Contributiva por Invalidez Laboral] · [Ver más opciones (16)] · [Volver a «Solicitar turnos en ANSES»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses turnos
  4 [txt] Buscando: anses turnos.
  5 [txt] Estás en los resultados de «anses turnos». Los 3 más probables:
  6 [H] Vos: Turnos Anses
  7 [txt] Abriendo Solicitar turnos en ANSES — www.argentina.gob.ar.
  8 [txt] Abriendo Pedir turno.
  9 [txt] Esta es la página de turnos de ANSES donde puedes realizar diversos trámites previsionales y de seguridad social. Si ya tienes un turno, puedes consultarlo o reprogramarlo directamente aquí. ¿Qué trámite necesitas gestionar?
 10 [H] Vos: volvé
 11 [txt] Volviendo.
 12 [txt] De vuelta en «Solicitar turnos en ANSES», Argentina.gob.ar.
 13 [H] Vos: Sacar turno
 14 [txt] Abriendo «Pedir turno».
 15 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. ¿Qué trámite necesitas realizar?
 16 [btn] Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…  (Primera de 7 opciones.)
 17 [btn] Solicitud de Jubilación
 18 [btn] Solicitud de Pensión
 19 [btn] Pensión no Contributiva por Invalidez Laboral
 20 [btn] Ver más opciones (16)
 21 [btn] Volver a «Solicitar turnos en ANSES»
 22 [btn] Otra cosa
 23 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 24 [btn] Enviar
```
