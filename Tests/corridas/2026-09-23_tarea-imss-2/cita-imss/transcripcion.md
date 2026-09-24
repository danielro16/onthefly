# cita-imss

**Quién:** Trabajador en México, ciego. Quiere sacar una cita en el IMSS; contesta escribiendo y en un momento vuelve atrás.

**Qué quiere:** Que la tarea (sacar una cita en el IMSS) siga viva en cada paso: al contestar, al volver, y que lo que se ofrece en cada página apunte a sacar la cita.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «quiero sacar una cita en el IMSS»

- [+  6.6s] 💬 Persona: quiero sacar una cita en el IMSS
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.1s] 💬 JEF: Buscando: cita IMSS.
- [+  8.1s] 🔊 «Buscando: cita IMSS.»
- [+ 13.0s] 📄 Cargó https://www.google.com/search?q=cita%20IMSS&gl=us&hl=es — «cita IMSS - Buscar con Google» (paginas/01.txt)
- [+ 13.7s] 💬 JEF: Estás en los resultados de «cita IMSS». Los 3 más probables:
- [+ 13.7s] 🔊 «Estás en los resultados de «cita IMSS». Los 3 más probables: 1. Agenda tu Cita Médica Digital, imss.gob.mx. 2. Cita Médica - IMSS, citamedicadigital.imss.gob.mx. 3. Cita Médica, imss.gob.mx»
- [+ 13.7s] 🔘 Botones: [Agenda tu Cita Médica Digital — www.imss.gob.mx] · [Cita Médica - IMSS — citamedicadigital.imss.gob.mx] · [Cita Médica — www.imss.gob.mx]
- [+ 13.7s] 🔘 Botones: [Agenda tu Cita Médica Digital — www.imss.gob.mx] · [Cita Médica - IMSS — citamedicadigital.imss.gob.mx] · [Cita Médica — www.imss.gob.mx] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero sacar una cita en el IMSS
  4 [txt] Buscando: cita IMSS.
  5 [txt] Estás en los resultados de «cita IMSS». Los 3 más probables:
  6 [btn] Agenda tu Cita Médica Digital — www.imss.gob.mx  (Primera de 4 opciones.)
  7 [btn] Cita Médica - IMSS — citamedicadigital.imss.gob.mx
  8 [btn] Cita Médica — www.imss.gob.mx
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca «Cita Médica — www.imss.gob.mx»

- [+ 21.9s] 💬 Persona: Cita Médica — www.imss.gob.mx
- [+ 21.9s] 💬 JEF: Abriendo imss.gob.mx.
- [+ 21.9s] 🔊 «Abriendo imss.gob.mx.»
- [+ 26.1s] 📄 Cargó https://www.imss.gob.mx/tags/cita-m%C3%A9dica — «Sitio Web "Acercando el IMSS al Ciudadano"» (paginas/02.txt)
- [+ 27.7s] 💬 JEF: Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.
- [+ 27.7s] 🔊 «Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.»
- [+ 27.7s] 🔘 Botones: [Abrir «Cita Médica»] · [Leer sobre citas digitales] · [Abrir «Sitio Web "Acercando el IMSS al Ciudadano"»]
- [+ 27.7s] 🔘 Botones: [Abrir «Cita Médica»] · [Leer sobre citas digitales] · [Abrir «Sitio Web "Acercando el IMSS al Ciudadano"»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero sacar una cita en el IMSS
  4 [txt] Buscando: cita IMSS.
  5 [txt] Estás en los resultados de «cita IMSS». Los 3 más probables:
  6 [H] Vos: Cita Médica — www.imss.gob.mx
  7 [txt] Abriendo imss.gob.mx.
  8 [txt] Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.
  9 [btn] Abrir «Cita Médica»  (Primera de 5 opciones.)
 10 [btn] Leer sobre citas digitales
 11 [btn] Abrir «Sitio Web "Acercando el IMSS al Ciudadano"»
 12 [btn] Volver a los resultados
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — escribe «medicina familiar»

- [+ 34.9s] 💬 Persona: medicina familiar
- [+ 36.9s] 💬 JEF: Abriendo Suscribirse a cita médica.
- [+ 36.9s] 🔊 «Abriendo Suscribirse a cita médica.»
- [+ 37.5s] ❌ Error de carga: Could not load the page: Carga del marco interrumpida
- [+ 37.5s] 💬 JEF: Todavía no hay una página cargada.
- [+ 37.5s] 🔊 «Todavía no hay una página cargada.»  ⟶ en cola: empieza a sonar a los +39.4s
- [+ 37.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero sacar una cita en el IMSS
  4 [txt] Buscando: cita IMSS.
  5 [txt] Estás en los resultados de «cita IMSS». Los 3 más probables:
  6 [H] Vos: Cita Médica — www.imss.gob.mx
  7 [txt] Abriendo imss.gob.mx.
  8 [txt] Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.
  9 [H] Vos: medicina familiar
 10 [txt] Abriendo Suscribirse a cita médica.
 11 [txt] Todavía no hay una página cargada.
 12 [btn] Llevame a La Nación  (Primera de 4 opciones.)
 13 [btn] ¿A cuánto está el dólar hoy?
 14 [btn] ¿Cómo va a estar el tiempo mañana?
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 4 — escribe «volvé»

- [+ 45.0s] 💬 Persona: volvé
- [+ 46.4s] 💬 JEF: No tengo historial para volver, pero puedo ayudarte a buscar el sitio para tu cita en el IMSS.
- [+ 46.4s] 🔊 «No tengo historial para volver, pero puedo ayudarte a buscar el sitio para tu cita en el IMSS.»
- [+ 46.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero sacar una cita en el IMSS
  4 [txt] Buscando: cita IMSS.
  5 [txt] Estás en los resultados de «cita IMSS». Los 3 más probables:
  6 [H] Vos: Cita Médica — www.imss.gob.mx
  7 [txt] Abriendo imss.gob.mx.
  8 [txt] Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.
  9 [H] Vos: medicina familiar
 10 [txt] Abriendo Suscribirse a cita médica.
 11 [txt] Todavía no hay una página cargada.
 12 [H] Vos: volvé
 13 [txt] No tengo historial para volver, pero puedo ayudarte a buscar el sitio para tu cita en el IMSS.
 14 [btn] Llevame a La Nación  (Primera de 4 opciones.)
 15 [btn] ¿A cuánto está el dólar hoy?
 16 [btn] ¿Cómo va a estar el tiempo mañana?
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```

## Paso 5 — escribe «¿qué necesito para la cita?»

- [+ 55.2s] 💬 Persona: ¿qué necesito para la cita?
- [+ 56.4s] 💬 JEF: Buscando: requisitos cita IMSS.
- [+ 56.4s] 🔊 «Buscando: requisitos cita IMSS.»
- [+ 60.9s] 📄 Cargó https://www.google.com/search?q=requisitos%20cita%20IMSS&gl=us&hl=es — «requisitos cita IMSS - Buscar con Google» (paginas/03.txt)
- [+ 62.7s] 💬 JEF: Para agendar una cita en el IMSS necesitas tu CURP, tu Número de Seguridad Social, un correo electrónico personal y estar vigente en el instituto. Puedes realizar el trámite a través de la aplicación IMSS Digital, el portal oficial o llamando al teléfono 800 681 2525.
- [+ 62.7s] 🔊 «Para agendar una cita en el IMSS necesitas tu CURP, tu Número de Seguridad Social, un correo electrónico personal y estar vigente en el instituto. Puedes realizar el trámite a través de la aplicación IMSS Digital, el portal oficial o llamando al teléfono 800 681 2525.»
- [+ 62.7s] 🔘 Botones: [¿Lo sabías...? En el #IMSS existen 4⃣ vías para agendar cita con el 𝐌é𝐝𝐢𝐜𝐨 𝐅𝐚𝐦𝐢𝐥𝐢𝐚𝐫. 📱Desde la app #IMSSDigital 💻Desde el sitio web: — www.imss.gob.mx] · [Agenda tu Cita Médica Digital — www.imss.gob.mx] · [Cita Médica - IMSS — citamedicadigital.imss.gob.mx] · [Ver más opciones (4)]
- [+ 62.7s] 🔘 Botones: [¿Lo sabías...? En el #IMSS existen 4⃣ vías para agendar cita con el 𝐌é𝐝𝐢𝐜𝐨 𝐅𝐚𝐦𝐢𝐥𝐢𝐚𝐫. 📱Desde la app #IMSSDigital 💻Desde el sitio web: — www.imss.gob.mx] · [Agenda tu Cita Médica Digital — www.imss.gob.mx] · [Cita Médica - IMSS — citamedicadigital.imss.gob.mx] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero sacar una cita en el IMSS
  4 [txt] Buscando: cita IMSS.
  5 [txt] Estás en los resultados de «cita IMSS». Los 3 más probables:
  6 [H] Vos: Cita Médica — www.imss.gob.mx
  7 [txt] Abriendo imss.gob.mx.
  8 [txt] Esta página te permite agendar tu cita médica en el IMSS, la cual puedes solicitar desde el apartado de Cita Médica.
  9 [H] Vos: medicina familiar
 10 [txt] Abriendo Suscribirse a cita médica.
 11 [txt] Todavía no hay una página cargada.
 12 [H] Vos: volvé
 13 [txt] No tengo historial para volver, pero puedo ayudarte a buscar el sitio para tu cita en el IMSS.
 14 [H] Vos: ¿qué necesito para la cita?
 15 [txt] Buscando: requisitos cita IMSS.
 16 [txt] Para agendar una cita en el IMSS necesitas tu CURP, tu Número de Seguridad Social, un correo electrónico personal y estar vigente en el instituto. Puedes realizar el trámite a través de la aplicación IMSS Digital, el portal oficial o llamando al teléfono 800 681 2525.
 17 [btn] ¿Lo sabías...? En el #IMSS existen 4⃣ vías para agendar cita con el 𝐌é𝐝𝐢𝐜𝐨 𝐅𝐚𝐦𝐢𝐥𝐢𝐚𝐫. 📱Desde la app #IMSSDigital 💻Desde el sitio web: — www.imss.gob.mx  (Primera de 5 opciones.)
 18 [btn] Agenda tu Cita Médica Digital — www.imss.gob.mx
 19 [btn] Cita Médica - IMSS — citamedicadigital.imss.gob.mx
 20 [btn] Ver más opciones (4)
 21 [btn] Otra cosa
 22 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 23 [btn] Enviar
```
