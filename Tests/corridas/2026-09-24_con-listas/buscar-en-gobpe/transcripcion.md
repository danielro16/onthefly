# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.pe»

- [+  6.6s] 💬 Persona: www.gob.pe
- [+  6.6s] 💬 JEF: Abriendo gob.pe.
- [+  6.6s] 🔊 «Abriendo gob.pe.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.3s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/01.txt)
- [+ 13.7s] 💬 JEF: Estás en Gob.pe, la plataforma digital del Estado Peruano, que reúne trámites, servicios, normas y noticias del gobierno. Aquí puedes buscar trámites como obtener tu Certificado Único Laboral o consultar el estado de tu DNI, y acceder a información de las entidades del Estado. La página también tiene un buscador en la parte superior.
- [+ 13.7s] 🔊 «Estás en Gob.pe, la plataforma digital del Estado Peruano, que reúne trámites, servicios, normas y noticias del gobierno. Aquí puedes buscar trámites como obtener tu Certificado Único Laboral o consultar el estado de tu DNI, y acceder a información de las entidades del Estado. La página también tiene un buscador en la parte superior.»
- [+ 13.7s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Obtener tu Certificado Único Laboral (CUL)»]
- [+ 13.7s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Obtener tu Certificado Único Laboral (CUL)»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital del Estado Peruano, que reúne trámites, servicios, normas y noticias del gobierno. Aquí puedes buscar trámites como obtener tu Certificado Único Laboral o consultar el estado de tu DNI, y acceder a información de las entidades del Estado. La página también tiene un buscador en la parte superior.
  6 [btn] Buscar en Gob.pe  (Primera de 4 opciones.)
  7 [btn] Abrir «Ver todos los trámites y servicios»
  8 [btn] Abrir «Obtener tu Certificado Único Laboral (CUL)»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca «Buscar en Gob.pe»

- [+ 26.0s] 💬 Persona: Buscar en Gob.pe
- [+ 26.0s] 💬 JEF: «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 26.0s] 🔊 ««Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 26.0s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Obtener tu Certificado Único Laboral (CUL)»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital del Estado Peruano, que reúne trámites, servicios, normas y noticias del gobierno. Aquí puedes buscar trámites como obtener tu Certificado Único Laboral o consultar el estado de tu DNI, y acceder a información de las entidades del Estado. La página también tiene un buscador en la parte superior.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [btn] Buscar en Gob.pe  (Primera de 4 opciones.)
  9 [btn] Abrir «Ver todos los trámites y servicios»
 10 [btn] Abrir «Obtener tu Certificado Único Laboral (CUL)»
 11 [btn] Otra cosa
 12 [campo] Pedido  = Escribir: Texto de búsqueda en gob.pe  (Va directo al campo «Texto de búsqueda en gob.pe» de la página.)
 13 [btn] Enviar
```

## Paso 3 — escribe «pasaporte»

- [+ 35.6s] 💬 Persona: Texto de búsqueda en gob.pe terminado en rte
- [+ 36.4s] 💬 JEF: Buscando «pasaporte».
- [+ 36.4s] 🔊 «Buscando «pasaporte».»
- [+ 37.8s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/02.txt)
- [+ 40.2s] 📄 Cargó https://www.gob.pe/busquedas?term=pasaporte&institucion=&topic_id=&contenido=&sort_by=none — «Resultados de búsqueda» (paginas/03.txt)
- [+ 41.0s] 💬 JEF: Estás en Gob.pe, la Plataforma Digital Única del Estado Peruano, donde se puede hacer trámites, consultar servicios del Estado y revisar noticias y normas. La página muestra los trámites más vistos, como el Certificado Único Laboral y la consulta del estado del DNI, además de un buscador en la parte superior y temas destacados como ayuda social, licencias de conducir y denuncias.
- [+ 41.0s] 🔊 «Estás en Gob.pe, la Plataforma Digital Única del Estado Peruano, donde se puede hacer trámites, consultar servicios del Estado y revisar noticias y normas. La página muestra los trámites más vistos, como el Certificado Único Laboral y la consulta del estado del DNI, además de un buscador en la parte superior y temas destacados como ayuda social, licencias de conducir y denuncias.»
- [+ 41.0s] 🔘 Botones: [Buscar trámites en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»]
- [+ 41.0s] 🔘 Botones: [Buscar trámites en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital del Estado Peruano, que reúne trámites, servicios, normas y noticias del gobierno. Aquí puedes buscar trámites como obtener tu Certificado Único Laboral o consultar el estado de tu DNI, y acceder a información de las entidades del Estado. La página también tiene un buscador en la parte superior.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [H] Vos: Texto de búsqueda en gob.pe terminado en rte
  9 [txt] Buscando «pasaporte».
 10 [txt] Estás en Gob.pe, la Plataforma Digital Única del Estado Peruano, donde se puede hacer trámites, consultar servicios del Estado y revisar noticias y normas. La página muestra los trámites más vistos, como el Certificado Único Laboral y la consulta del estado del DNI, además de un buscador en la parte superior y temas destacados como ayuda social, licencias de conducir y denuncias.
 11 [btn] Buscar trámites en Gob.pe  (Primera de 5 opciones.)
 12 [btn] Abrir «Ver todos los trámites y servicios»
 13 [btn] Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»
 14 [btn] Volver a la portada
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
 18 [grp] Barra de herramientas
```
