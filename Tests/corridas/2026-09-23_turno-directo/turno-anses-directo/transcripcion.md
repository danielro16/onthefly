# turno-anses-directo

**Quién:** Jubilada, ciega. Entra a la página de turnos de ANSES y pide un turno con sus palabras.

**Qué quiere:** Que JEF pregunte para qué trámite, encuentre lo que ella escribe entre los trámites, y que lo que no está lo busque afuera.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «anses.gob.ar/turnos»

- [+  6.3s] 💬 Persona: anses.gob.ar/turnos
- [+  6.3s] 💬 JEF: Abriendo anses.gob.ar.
- [+  6.3s] 🔊 «Abriendo anses.gob.ar.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.7s] 📄 Cargó https://www.anses.gob.ar/turnos — «Turnos | ANSES» (paginas/01.txt)
- [+ 12.6s] 💬 JEF: Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
- [+ 12.6s] 🔊 «Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.»
- [+ 12.6s] 🔘 Botones: [Abrir «Solicitar un turno»] · [Abrir «mi ANSES»] · [Abrir «Atención Virtual»]
- [+ 12.6s] 🔘 Botones: [Completar «buscador»] · [Pulsar «Search»] · [Abrir «Solicitar un turno»] · [Abrir «mi ANSES»] · [Abrir «Atención Virtual»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [btn] Completar «buscador»  (Primera de 6 opciones.)
  7 [btn] Pulsar «Search»
  8 [btn] Abrir «Solicitar un turno»
  9 [btn] Abrir «mi ANSES»
 10 [btn] Abrir «Atención Virtual»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 2 — escribe «quiero sacar un turno»

- [+ 20.0s] 💬 Persona: quiero sacar un turno
- [+ 21.8s] 💬 JEF: Abriendo «Solicitar un turno».
- [+ 21.8s] 🔊 «Abriendo «Solicitar un turno».»
- [+ 25.3s] 📄 Cargó https://servicioswww.anses.gob.ar/TurnosInternet/Burbujas/Prestaciones — «ANSES | Turnos - Prestaciones» (paginas/02.txt)
- [+ 27.2s] 💬 JEF: Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
- [+ 27.2s] 🔊 «Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?»
- [+ 27.2s] 🔘 Botones: [CONSULTAR TURNO] · [Reprogramación] · [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Ver más opciones (16)]
- [+ 27.2s] 🔘 Botones: [CONSULTAR TURNO] · [Reprogramación] · [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [Solicitud de Jubilación] · [Ver más opciones (16)] · [Volver a «Turnos | ANSES»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [H] Vos: quiero sacar un turno
  7 [txt] Abriendo «Solicitar un turno».
  8 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
  9 [btn] CONSULTAR TURNO  (Primera de 7 opciones.)
 10 [btn] Reprogramación
 11 [btn] Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…
 12 [btn] Solicitud de Jubilación
 13 [btn] Ver más opciones (16)
 14 [btn] Volver a «Turnos | ANSES»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 3 — escribe «jubilación»

- [+ 35.5s] 💬 Persona: jubilación
- [+ 37.4s] 💬 JEF: Abriendo Solicitud de Jubilación, , ver sub-trámites.
- [+ 37.4s] 🔊 «Abriendo Solicitud de Jubilación, , ver sub-trámites.»
- [+ 39.6s] 📄 Cargó https://servicioswww.anses.gob.ar/TurnosInternet/g/edaf401ff5984235a0c3b0ac1f39b7eb/Burbujas/SubPrestaciones?idBurbuja=1 — «ANSES | Turnos - Solicitud de Jubilación» (paginas/03.txt)
- [+ 40.3s] 💬 JEF: Abriendo Jubilación.
- [+ 40.3s] 🔊 «Abriendo Jubilación.»
- [+ 43.2s] 📄 Cargó https://servicioscorp.anses.gob.ar/clavelogon/logon.aspx?system=turnoscvss — «Clave de la Seguridad Social» (paginas/04.txt)
- [+ 43.8s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.
- [+ 43.8s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~56%)
- [+ 43.8s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Volver a «ANSES | Turnos - Solicitud de Jubilación»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [H] Vos: quiero sacar un turno
  7 [txt] Abriendo «Solicitar un turno».
  8 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
  9 [H] Vos: jubilación
 10 [txt] Abriendo Solicitud de Jubilación, , ver sub-trámites.
 11 [txt] Abriendo Jubilación.
 12 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.
 13 [btn] Ir a la prueba  (Primera de 4 opciones.)
 14 [btn] Ya la resolví
 15 [btn] Volver a «ANSES | Turnos - Solicitud de Jubilación»
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```

## Paso 4 — escribe «volvé»

- [+ 51.0s] 💬 Persona: volvé
- [+ 52.3s] 💬 JEF: Volviendo.
- [+ 52.3s] 🔊 «Volviendo.»
- [+ 53.0s] 📄 Cargó https://servicioswww.anses.gob.ar/TurnosInternet/g/edaf401ff5984235a0c3b0ac1f39b7eb/Burbujas/SubPrestaciones?idBurbuja=1 — «ANSES | Turnos - Solicitud de Jubilación» (paginas/05.txt)
- [+ 53.0s] 💬 JEF: De vuelta en «Turnos», servicioswww.anses.gob.ar.
- [+ 53.0s] 🔊 «De vuelta en «Turnos», servicioswww.anses.gob.ar.»
- [+ 53.0s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a «ANSES | Turnos - Prestaciones»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [H] Vos: quiero sacar un turno
  7 [txt] Abriendo «Solicitar un turno».
  8 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
  9 [H] Vos: jubilación
 10 [txt] Abriendo Solicitud de Jubilación, , ver sub-trámites.
 11 [txt] Abriendo Jubilación.
 12 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.
 13 [H] Vos: volvé
 14 [txt] Volviendo.
 15 [txt] De vuelta en «Turnos», servicioswww.anses.gob.ar.
 16 [btn] Leer la página  (Primera de 4 opciones.)
 17 [btn] Resumir la página
 18 [btn] Volver a «ANSES | Turnos - Prestaciones»
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```

## Paso 5 — escribe «quiero cobrar por mi hijo»

- [+ 61.3s] 💬 Persona: quiero cobrar por mi hijo
- [+ 63.7s] 💬 JEF: No está en esta página.
- [+ 63.7s] 🔊 «No está en esta página.»
- [+ 63.7s] 💬 JEF: Buscando: anses cobrar asignacion por hijo.
- [+ 63.7s] 🔊 «Buscando: anses cobrar asignacion por hijo.»  ⟶ en cola: empieza a sonar a los +65.3s
- [+ 68.9s] 📄 Cargó https://www.google.com/search?q=anses%20cobrar%20asignacion%20por%20hijo&gl=us&hl=es — «anses cobrar asignacion por hijo» (paginas/06.txt)
- [+ 70.4s] 💬 JEF: Para consultar el cobro de tu asignación, debés ingresar a Mi ANSES con tu CUIL y Clave de la Seguridad Social. Una vez dentro, seleccioná la opción Hijas e Hijos y luego Mis Asignaciones para verificar el estado de tus pagos y fechas de cobro.
- [+ 70.4s] 🔊 «Para consultar el cobro de tu asignación, debés ingresar a Mi ANSES con tu CUIL y Clave de la Seguridad Social. Una vez dentro, seleccioná la opción Hijas e Hijos y luego Mis Asignaciones para verificar el estado de tus pagos y fechas de cobro.»
- [+ 70.4s] 🔘 Botones: [Asignación Universal por Hijo — www.anses.gob.ar] · [Asignación Familiar por Hijo — www.anses.gob.ar] · [Solicitud de cobro de asignaciones por hijo a cargo — www.anses.gob.ar] · [Ver más opciones (5)]
- [+ 70.4s] 🔘 Botones: [Asignación Universal por Hijo — www.anses.gob.ar] · [Asignación Familiar por Hijo — www.anses.gob.ar] · [Solicitud de cobro de asignaciones por hijo a cargo — www.anses.gob.ar] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [H] Vos: quiero sacar un turno
  7 [txt] Abriendo «Solicitar un turno».
  8 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
  9 [H] Vos: jubilación
 10 [txt] Abriendo Solicitud de Jubilación, , ver sub-trámites.
 11 [txt] Abriendo Jubilación.
 12 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.
 13 [H] Vos: volvé
 14 [txt] Volviendo.
 15 [txt] De vuelta en «Turnos», servicioswww.anses.gob.ar.
 16 [H] Vos: quiero cobrar por mi hijo
 17 [txt] No está en esta página.
 18 [txt] Buscando: anses cobrar asignacion por hijo.
 19 [txt] Para consultar el cobro de tu asignación, debés ingresar a Mi ANSES con tu CUIL y Clave de la Seguridad Social. Una vez dentro, seleccioná la opción Hijas e Hijos y luego Mis Asignaciones para verificar el estado de tus pagos y fechas de cobro.
 20 [btn] Asignación Universal por Hijo — www.anses.gob.ar  (Primera de 5 opciones.)
 21 [btn] Asignación Familiar por Hijo — www.anses.gob.ar
 22 [btn] Solicitud de cobro de asignaciones por hijo a cargo — www.anses.gob.ar
 23 [btn] Ver más opciones (5)
 24 [btn] Otra cosa
 25 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 26 [btn] Enviar
```

## Paso 6 — escribe «buscame vuelos baratos a Madrid»

- [+ 78.7s] 💬 Persona: buscame vuelos baratos a Madrid
- [+ 80.0s] 💬 JEF: Buscando: vuelos baratos a Madrid.
- [+ 80.0s] 🔊 «Buscando: vuelos baratos a Madrid.»
- [+ 87.8s] 📄 Cargó https://www.google.com/search?q=vuelos%20baratos%20a%20Madrid&gl=us&hl=es&sei=pFW0aqmCD86Kxc8P1437sA8&dlnr=1 — «vuelos baratos a Madrid - Buscar con Google» (paginas/07.txt)
- [+ 88.0s] 💬 JEF: Estás en los resultados de «vuelos baratos a Madrid». Hay 6 anuncios: los salteo. Los 3 más probables:
- [+ 88.0s] 🔊 «Estás en los resultados de «vuelos baratos a Madrid». Hay 6 anuncios: los salteo. Los 3 más probables: 1. Vuelos baratos de San Francisco (SFO) a Aeropuerto de…, expedia.com. 2. Vuelos baratos de San Francisco (SFO) a Madrid (MAD), iberia.com. 3. Vuelos baratos desde San Francisco a Madrid (SFO - MAD), es.kayak.com»
- [+ 88.0s] 🔘 Botones: [Vuelos baratos de San Francisco (SFO) a Aeropuerto de Madrid-Adolfo Suárez ... — www.expedia.com] · [Vuelos baratos de San Francisco (SFO) a Madrid (MAD) — www.iberia.com] · [Vuelos baratos desde San Francisco a Madrid (SFO - MAD) — www.es.kayak.com] · [Ver más opciones (6)]
- [+ 88.0s] 🔘 Botones: [Vuelos baratos de San Francisco (SFO) a Aeropuerto de Madrid-Adolfo Suárez ... — www.expedia.com] · [Vuelos baratos de San Francisco (SFO) a Madrid (MAD) — www.iberia.com] · [Vuelos baratos desde San Francisco a Madrid (SFO - MAD) — www.es.kayak.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-06.txt, captura en paso-06.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: anses.gob.ar/turnos
  4 [txt] Abriendo anses.gob.ar.
  5 [txt] Esta página de ANSES sirve para gestionar turnos presenciales en sus oficinas, y la opción para solicitar uno se encuentra en el cuerpo principal.
  6 [H] Vos: quiero sacar un turno
  7 [txt] Abriendo «Solicitar un turno».
  8 [txt] Esta es la página de turnos de ANSES donde puedes gestionar tu solicitud. Hay 20 trámites disponibles para los que puedes sacar un turno, ¿cuál de ellos necesitas realizar? ¿Qué trámite deseas realizar?
  9 [H] Vos: jubilación
 10 [txt] Abriendo Solicitud de Jubilación, , ver sub-trámites.
 11 [txt] Abriendo Jubilación.
 12 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.
 13 [H] Vos: volvé
 14 [txt] Volviendo.
 15 [txt] De vuelta en «Turnos», servicioswww.anses.gob.ar.
 16 [H] Vos: quiero cobrar por mi hijo
 17 [txt] No está en esta página.
 18 [txt] Buscando: anses cobrar asignacion por hijo.
 19 [txt] Para consultar el cobro de tu asignación, debés ingresar a Mi ANSES con tu CUIL y Clave de la Seguridad Social. Una vez dentro, seleccioná la opción Hijas e Hijos y luego Mis Asignaciones para verificar el estado de tus pagos y fechas de cobro.
 20 [H] Vos: buscame vuelos baratos a Madrid
 21 [txt] Buscando: vuelos baratos a Madrid.
 22 [txt] Estás en los resultados de «vuelos baratos a Madrid». Hay 6 anuncios: los salteo. Los 3 más probables:
 23 [btn] Vuelos baratos de San Francisco (SFO) a Aeropuerto de Madrid-Adolfo Suárez ... — www.expedia.com  (Primera de 5 opciones.)
 24 [btn] Vuelos baratos de San Francisco (SFO) a Madrid (MAD) — www.iberia.com
 25 [btn] Vuelos baratos desde San Francisco a Madrid (SFO - MAD) — www.es.kayak.com
 26 [btn] Ver más opciones (6)
 27 [btn] Otra cosa
 28 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 29 [btn] Enviar
```
