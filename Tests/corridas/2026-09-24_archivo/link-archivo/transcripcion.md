# link-archivo

**Quién:** Cualquiera: toca un link que baja un archivo.

**Qué quiere:** Que JEF no se quede sin página: que siga en la misma y cuente que el link es un archivo. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/descarga.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/descarga.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:8765/descarga.html — «Documentos del club» (paginas/01.txt)
- [+ 10.4s] 💬 JEF: Estás en la página de documentos del Club de Lectura, donde puedes acceder al reglamento y al catálogo de libros.
- [+ 10.4s] 🔊 «Estás en la página de documentos del Club de Lectura, donde puedes acceder al reglamento y al catálogo de libros.»
- [+ 10.4s] 🔘 Botones: [Abrir «Bajar el reglamento del club»] · [Abrir «Ver el catálogo de libros»]
- [+ 10.4s] 🔘 Botones: [Abrir «Bajar el reglamento del club»] · [Abrir «Ver el catálogo de libros»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/descarga.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de documentos del Club de Lectura, donde puedes acceder al reglamento y al catálogo de libros.
  6 [btn] Abrir «Bajar el reglamento del club»  (Primera de 3 opciones.)
  7 [btn] Abrir «Ver el catálogo de libros»
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «abrí el reglamento»

- [+ 18.5s] 💬 Persona: abrí el reglamento
- [+ 21.3s] 💬 JEF: Abriendo Bajar el reglamento del club.
- [+ 21.3s] 🔊 «Abriendo Bajar el reglamento del club.»
- [+ 21.6s] 📄 Cargó http://localhost:8765/descarga.html — «Documentos del club» (paginas/02.txt)
- [+ 23.9s] 💬 JEF: El enlace al reglamento es un archivo ZIP que el navegador no pudo mostrar, así que no se abrió ni se descargó. Esta página del club contiene sus documentos, pero no permite leer aquí el reglamento.
- [+ 23.9s] 🔊 «El enlace al reglamento es un archivo ZIP que el navegador no pudo mostrar, así que no se abrió ni se descargó. Esta página del club contiene sus documentos, pero no permite leer aquí el reglamento.»
- [+ 23.9s] 🔘 Botones: [Abrir «Ver el catálogo de libros»] · [Resumir la página]
- [+ 23.9s] 🔘 Botones: [Abrir «Ver el catálogo de libros»] · [Resumir la página] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/descarga.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de documentos del Club de Lectura, donde puedes acceder al reglamento y al catálogo de libros.
  6 [H] Vos: abrí el reglamento
  7 [txt] Abriendo Bajar el reglamento del club.
  8 [txt] El enlace al reglamento es un archivo ZIP que el navegador no pudo mostrar, así que no se abrió ni se descargó. Esta página del club contiene sus documentos, pero no permite leer aquí el reglamento.
  9 [btn] Abrir «Ver el catálogo de libros»  (Primera de 3 opciones.)
 10 [btn] Resumir la página
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
