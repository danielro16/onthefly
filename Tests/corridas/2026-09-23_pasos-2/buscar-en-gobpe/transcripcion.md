# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.pe»

- [+  6.7s] 💬 Persona: www.gob.pe
- [+  6.7s] 💬 JEF: Abriendo gob.pe.
- [+  6.7s] 🔊 «Abriendo gob.pe.»
- [+  6.8s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.1s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/01.txt)
- [+ 13.3s] 💬 JEF: Estás en Gob.pe, la plataforma digital única del Estado Peruano, donde se encuentra información sobre trámites, servicios y normas. Aquí puedes ver los trámites y servicios más vistos, como el Certificado Único Laboral o la consulta del estado de entrega del DNI, y acceder a temas de ayuda social, conducir o denuncias, entre otros. También hay información de las entidades del Estado, como la Presidencia, el Congreso, el Poder Judicial, los gobiernos regionales y las municipalidades.
- [+ 13.3s] 🔊 «Estás en Gob.pe, la plataforma digital única del Estado Peruano, donde se encuentra información sobre trámites, servicios y normas. Aquí puedes ver los trámites y servicios más vistos, como el Certificado Único Laboral o la consulta del estado de entrega del DNI, y acceder a temas de ayuda social, conducir o denuncias, entre otros. También hay información de las entidades del Estado, como la Presidencia, el Congreso, el Poder Judicial, los gobiernos regionales y las municipalidades.»
- [+ 13.3s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Explora todos los temas»]
- [+ 13.3s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Explora todos los temas»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado Peruano, donde se encuentra información sobre trámites, servicios y normas. Aquí puedes ver los trámites y servicios más vistos, como el Certificado Único Laboral o la consulta del estado de entrega del DNI, y acceder a temas de ayuda social, conducir o denuncias, entre otros. También hay información de las entidades del Estado, como la Presidencia, el Congreso, el Poder Judicial, los gobiernos regionales y las municipalidades.
  6 [btn] Buscar en Gob.pe  (Primera de 4 opciones.)
  7 [btn] Abrir «Ver todos los trámites y servicios»
  8 [btn] Abrir «Explora todos los temas»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca «Buscar en Gob.pe»

- [+ 22.0s] 💬 Persona: Buscar en Gob.pe
- [+ 22.0s] 💬 JEF: «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 22.0s] 🔊 ««Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 22.0s] 🔘 Botones: [Buscar en Gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Explora todos los temas»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado Peruano, donde se encuentra información sobre trámites, servicios y normas. Aquí puedes ver los trámites y servicios más vistos, como el Certificado Único Laboral o la consulta del estado de entrega del DNI, y acceder a temas de ayuda social, conducir o denuncias, entre otros. También hay información de las entidades del Estado, como la Presidencia, el Congreso, el Poder Judicial, los gobiernos regionales y las municipalidades.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [btn] Buscar en Gob.pe  (Primera de 4 opciones.)
  9 [btn] Abrir «Ver todos los trámites y servicios»
 10 [btn] Abrir «Explora todos los temas»
 11 [btn] Otra cosa
 12 [campo] Pedido  = Escribir: Texto de búsqueda en gob.pe  (Va directo al campo «Texto de búsqueda en gob.pe» de la página.)
 13 [btn] Enviar
```

## Paso 3 — escribe «pasaporte»

- [+ 31.6s] 💬 Persona: Texto de búsqueda en gob.pe terminado en rte
- [+ 32.3s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/02.txt)
- [+ 32.4s] 💬 JEF: Buscando «pasaporte».
- [+ 32.4s] 🔊 «Buscando «pasaporte».»
- [+ 36.9s] 📄 Cargó https://www.gob.pe/busquedas?term=pasaporte&institucion=&topic_id=&contenido=&sort_by=none — «Resultados de búsqueda» (paginas/03.txt)
- [+ 40.6s] 💬 JEF: Estás en Gob.pe, el portal del Estado peruano, viendo los resultados de buscar pasaporte: hay 3,617 resultados, en su mayoría trámites de Migraciones y de Relaciones Exteriores. Hay trámites para tramitar el pasaporte electrónico, para perderlo o robo, citas de urgencia, pasaportes para menores y pasaportes desde el extranjero. ¿Cuál necesitas?
- [+ 40.6s] 🔊 «Estás en Gob.pe, el portal del Estado peruano, viendo los resultados de buscar pasaporte: hay 3,617 resultados, en su mayoría trámites de Migraciones y de Relaciones Exteriores. Hay trámites para tramitar el pasaporte electrónico, para perderlo o robo, citas de urgencia, pasaportes para menores y pasaportes desde el extranjero. ¿Cuál necesitas?»
- [+ 40.6s] 🔘 Botones: [MIGRACIONES - Superintendencia Nacional de Migraciones] · [RREE - Ministerio de Relaciones Exteriores] · [RREE - Ministerio de Relaciones Exteriores] · [MIGRACIONES - Superintendencia Nacional de Migraciones] · [Ver más opciones (1)]
- [+ 40.6s] 🔘 Botones: [MIGRACIONES - Superintendencia Nacional de Migraciones] · [RREE - Ministerio de Relaciones Exteriores] · [RREE - Ministerio de Relaciones Exteriores] · [MIGRACIONES - Superintendencia Nacional de Migraciones] · [Ver más opciones (1)] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en Gob.pe, la plataforma digital única del Estado Peruano, donde se encuentra información sobre trámites, servicios y normas. Aquí puedes ver los trámites y servicios más vistos, como el Certificado Único Laboral o la consulta del estado de entrega del DNI, y acceder a temas de ayuda social, conducir o denuncias, entre otros. También hay información de las entidades del Estado, como la Presidencia, el Congreso, el Poder Judicial, los gobiernos regionales y las municipalidades.
  6 [H] Vos: Buscar en Gob.pe
  7 [txt] «Buscar en Gob.pe»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [H] Vos: Texto de búsqueda en gob.pe terminado en rte
  9 [txt] Buscando «pasaporte».
 10 [txt] Estás en Gob.pe, el portal del Estado peruano, viendo los resultados de buscar pasaporte: hay 3,617 resultados, en su mayoría trámites de Migraciones y de Relaciones Exteriores. Hay trámites para tramitar el pasaporte electrónico, para perderlo o robo, citas de urgencia, pasaportes para menores y pasaportes desde el extranjero. ¿Cuál necesitas?
 11 [btn] MIGRACIONES - Superintendencia Nacional de Migraciones  (Primera de 7 opciones.)
 12 [btn] RREE - Ministerio de Relaciones Exteriores
 13 [btn] RREE - Ministerio de Relaciones Exteriores
 14 [btn] MIGRACIONES - Superintendencia Nacional de Migraciones
 15 [btn] Ver más opciones (1)
 16 [btn] Volver a la portada
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
 20 [grp] Barra de herramientas
```
