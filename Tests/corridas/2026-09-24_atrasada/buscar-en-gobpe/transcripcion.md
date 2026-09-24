# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.pe»

- [+  6.2s] 💬 Persona: www.gob.pe
- [+  6.2s] 💬 JEF: Abriendo gob.pe.
- [+  6.2s] 🔊 «Abriendo gob.pe.»
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.7s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/01.txt)
- [+ 11.6s] 💬 JEF: Estás en Gob.pe, la plataforma digital única del Estado peruano, que reúne trámites, servicios, normas e información de las entidades. En la portada se destacan los trámites más vistos, como obtener el Certificado Único Laboral o consultar el estado de tu DNI, y hay buscador arriba y catálogos por temas. También hay noticias, entre ellas una sobre 400 mil becas del Ministerio de Trabajo con Fundación Romero para fortalecer la empleabilidad.
- [+ 11.6s] 🔊 «Estás en Gob.pe, la plataforma digital única del Estado peruano, que reúne trámites, servicios, normas e información de las entidades. En la portada se destacan los trámites más vistos, como obtener el Certificado Único Laboral o consultar el estado de tu DNI, y hay buscador arriba y catálogos por temas. También hay noticias, entre ellas una sobre 400 mil becas del Ministerio de Trabajo con Fundación Romero para fortalecer la empleabilidad.»
- [+ 11.6s] 🔘 Botones: [Abrir «Ver todos los trámites y servicios»] · [Buscar en Gob.pe] · [Ir al catálogo]
- [+ 11.6s] 🔘 Botones: [Abrir «Ver todos los trámites y servicios»] · [Buscar en Gob.pe] · [Ir al catálogo] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado peruano, que reúne trámites, servicios, normas e información de las entidades. En la portada se destacan los trámites más vistos, como obtener el Certificado Único Laboral o consultar el estado de tu DNI, y hay buscador arriba y catálogos por temas. También hay noticias, entre ellas una sobre 400 mil becas del Ministerio de Trabajo con Fundación Romero para fortalecer la empleabilidad.
  6 [btn] Abrir «Ver todos los trámites y servicios»  (Primera de 4 opciones.)
  7 [btn] Buscar en Gob.pe
  8 [btn] Ir al catálogo
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca «Buscar en Gob.pe»

- [+ 21.1s] 💬 Persona: Buscar en Gob.pe
- [+ 21.1s] 💬 JEF: «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 21.1s] 🔊 ««Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 21.1s] 🔘 Botones: [Abrir «Ver todos los trámites y servicios»] · [Buscar en Gob.pe] · [Ir al catálogo] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado peruano, que reúne trámites, servicios, normas e información de las entidades. En la portada se destacan los trámites más vistos, como obtener el Certificado Único Laboral o consultar el estado de tu DNI, y hay buscador arriba y catálogos por temas. También hay noticias, entre ellas una sobre 400 mil becas del Ministerio de Trabajo con Fundación Romero para fortalecer la empleabilidad.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [btn] Abrir «Ver todos los trámites y servicios»  (Primera de 4 opciones.)
  9 [btn] Buscar en Gob.pe
 10 [btn] Ir al catálogo
 11 [btn] Otra cosa
 12 [campo] Pedido  = Escribir: Texto de búsqueda en gob.pe  (Va directo al campo «Texto de búsqueda en gob.pe» de la página.)
 13 [btn] Enviar
```

## Paso 3 — escribe «pasaporte»

- [+ 30.8s] 💬 Persona: Texto de búsqueda en gob.pe terminado en rte
- [+ 31.4s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/02.txt)
- [+ 31.5s] 💬 JEF: Buscando «pasaporte».
- [+ 31.5s] 🔊 «Buscando «pasaporte».»
- [+ 33.2s] 📄 Cargó https://www.gob.pe/busquedas?term=pasaporte&institucion=&topic_id=&contenido=&sort_by=none — «Resultados de búsqueda» (paginas/03.txt)
- [+ 36.0s] 💬 JEF: Estás en Gob.pe, el portal del Estado peruano, en la página de resultados de búsqueda de «pasaporte»: hay 3,619 resultados, sobre todo trámites de Migraciones y de Cancillería. El primero explica cómo bloquear el pasaporte electrónico si lo pierdes o te lo roban, operación que es gratuita; también hay resultados sobre el pasaporte para mayores y menores de edad, viajes de urgencia con trámite hasta dos días hábiles antes del vuelo, y pasaporte desde el extranjero en consulados. Puedes afinar la búsqueda con el buscador o abrir el resultado que te interese.
- [+ 36.0s] 🔊 «Estás en Gob.pe, el portal del Estado peruano, en la página de resultados de búsqueda de «pasaporte»: hay 3,619 resultados, sobre todo trámites de Migraciones y de Cancillería. El primero explica cómo bloquear el pasaporte electrónico si lo pierdes o te lo roban, operación que es gratuita; también hay resultados sobre el pasaporte para mayores y menores de edad, viajes de urgencia con trámite hasta dos días hábiles antes del vuelo, y pasaporte desde el extranjero en consulados. Puedes afinar la búsqueda con el buscador o abrir el resultado que te interese.»
- [+ 36.0s] 🔘 Botones: [Abrir «MIGRACIONES - Superintendencia Nacional de Migraciones»]
- [+ 36.0s] 🔘 Botones: [Abrir «MIGRACIONES - Superintendencia Nacional de Migraciones»] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado peruano, que reúne trámites, servicios, normas e información de las entidades. En la portada se destacan los trámites más vistos, como obtener el Certificado Único Laboral o consultar el estado de tu DNI, y hay buscador arriba y catálogos por temas. También hay noticias, entre ellas una sobre 400 mil becas del Ministerio de Trabajo con Fundación Romero para fortalecer la empleabilidad.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [H] Vos: Texto de búsqueda en gob.pe terminado en rte
  9 [txt] Buscando «pasaporte».
 10 [txt] Estás en Gob.pe, el portal del Estado peruano, en la página de resultados de búsqueda de «pasaporte»: hay 3,619 resultados, sobre todo trámites de Migraciones y de Cancillería. El primero explica cómo bloquear el pasaporte electrónico si lo pierdes o te lo roban, operación que es gratuita; también hay resultados sobre el pasaporte para mayores y menores de edad, viajes de urgencia con trámite hasta dos días hábiles antes del vuelo, y pasaporte desde el extranjero en consulados. Puedes afinar la búsqueda con el buscador o abrir el resultado que te interese.
 11 [btn] Abrir «MIGRACIONES - Superintendencia Nacional de Migraciones»  (Primera de 3 opciones.)
 12 [btn] Volver a la portada
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
 16 [grp] Barra de herramientas
```
