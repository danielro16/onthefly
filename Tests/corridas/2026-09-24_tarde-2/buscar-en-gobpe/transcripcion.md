# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.pe»

- [+  6.6s] 💬 Persona: www.gob.pe
- [+  6.6s] 💬 JEF: Abriendo gob.pe.
- [+  6.6s] 🔊 «Abriendo gob.pe.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.1s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/01.txt)
- [+ 12.7s] 💬 JEF: Estás en Gob.pe, la plataforma digital del Estado Peruano; aquí puedes hacer trámites y servicios en línea, como obtener el Certificado Único Laboral, consultar el estado de tu DNI o tu licencia de conducir, y también buscar noticias, normativa y entidades del Estado.
- [+ 12.7s] 🔊 «Estás en Gob.pe, la plataforma digital del Estado Peruano; aquí puedes hacer trámites y servicios en línea, como obtener el Certificado Único Laboral, consultar el estado de tu DNI o tu licencia de conducir, y también buscar noticias, normativa y entidades del Estado.»
- [+ 12.7s] 🔘 Botones: [Abrir «Obtener tu Certificado Único Laboral (CUL)»] · [Abrir «Consultar estado de tu trámite para la entrega de tu DNI»] · [Abrir «Emitir recibo por honorarios electrónico»] · [Abrir «Consultar el estado de mi licencia de conducir en el MTC»] · [Leer los titulares]
- [+ 12.7s] 🔘 Botones: [Abrir «Obtener tu Certificado Único Laboral (CUL)»] · [Abrir «Consultar estado de tu trámite para la entrega de tu DNI»] · [Abrir «Emitir recibo por honorarios electrónico»] · [Abrir «Consultar el estado de mi licencia de conducir en el MTC»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [btn] Volver
  2 [btn] Abrir el asistente  = gob.pe
```

## Paso 2 — {"tocar": "Buscar"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Buscar'; hay: ['Volver', 'Abrir el asistente']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [campo] Pedido  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  4 [btn] Enviar
```
