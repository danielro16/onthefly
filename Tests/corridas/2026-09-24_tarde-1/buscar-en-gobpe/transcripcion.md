# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.pe»

- [+  6.4s] 💬 Persona: www.gob.pe
- [+  6.4s] 💬 JEF: Abriendo gob.pe.
- [+  6.4s] 🔊 «Abriendo gob.pe.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.9s] 📄 Cargó https://www.gob.pe/ — «Plataforma del Estado Peruano» (paginas/01.txt)
- [+ 15.6s] 💬 JEF: Estás en la portada de Gob.pe, la plataforma digital del Estado Peruano, con trámites, servicios, normas e información de entidades. Ofrece los trámites más vistos, como el Certificado Único Laboral o la consulta del estado de tu DNI, temas como ayuda social y conducción, y noticias del Estado; también hay un buscador y un chat llamado YachAIbot.
- [+ 15.6s] 🔊 «Estás en la portada de Gob.pe, la plataforma digital del Estado Peruano, con trámites, servicios, normas e información de entidades. Ofrece los trámites más vistos, como el Certificado Único Laboral o la consulta del estado de tu DNI, temas como ayuda social y conducción, y noticias del Estado; también hay un buscador y un chat llamado YachAIbot.»
- [+ 15.6s] 🔘 Botones: [Texto de búsqueda en gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»] · [Abrir chat con YachAIbot]
- [+ 15.6s] 🔘 Botones: [Texto de búsqueda en gob.pe] · [Abrir «Ver todos los trámites y servicios»] · [Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»] · [Abrir chat con YachAIbot] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en la portada de Gob.pe, la plataforma digital del Estado Peruano, con trámites, servicios, normas e información de entidades. Ofrece los trámites más vistos, como el Certificado Único Laboral o la consulta del estado de tu DNI, temas como ayuda social y conducción, y noticias del Estado; también hay un buscador y un chat llamado YachAIbot.
  6 [btn] Texto de búsqueda en gob.pe  (Primera de 5 opciones.)
  7 [btn] Abrir «Ver todos los trámites y servicios»
  8 [btn] Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»
  9 [btn] Abrir chat con YachAIbot
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — {"tocar": "Buscar"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Buscar'; hay: ['Cerrar el asistente', 'Texto de búsqueda en gob.pe', 'Abrir «Ver todos los trámites y servicios»', 'Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»', 'Abrir chat con YachAIbot', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] Estás en la portada de Gob.pe, la plataforma digital del Estado Peruano, con trámites, servicios, normas e información de entidades. Ofrece los trámites más vistos, como el Certificado Único Laboral o la consulta del estado de tu DNI, temas como ayuda social y conducción, y noticias del Estado; también hay un buscador y un chat llamado YachAIbot.
  6 [btn] Texto de búsqueda en gob.pe  (Primera de 5 opciones.)
  7 [btn] Abrir «Ver todos los trámites y servicios»
  8 [btn] Abrir «Ayuda social, Consultas e inscripciones a programas y bonos.»
  9 [btn] Abrir chat con YachAIbot
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
