# busca-tarde

**Quién:** Cualquiera: busca en un sitio cuyo buscador cambia de página un rato después de enviar.

**Qué quiere:** Que JEF no diga que la página no cambió: que espere los resultados y los cuente. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/busca-tarde.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/busca-tarde.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/busca-tarde.html — «Biblioteca del club» (paginas/01.txt)
- [+ 11.8s] 💬 JEF: Estás en la biblioteca del club, en su página de búsqueda. Sirve para buscar libros por título, autor o género, con un cuadro de búsqueda y su botón Buscar.
- [+ 11.8s] 🔊 «Estás en la biblioteca del club, en su página de búsqueda. Sirve para buscar libros por título, autor o género, con un cuadro de búsqueda y su botón Buscar.»
- [+ 11.8s] 🔘 Botones: [Buscar un libro]
- [+ 11.8s] 🔘 Botones: [Buscar un libro] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/busca-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la biblioteca del club, en su página de búsqueda. Sirve para buscar libros por título, autor o género, con un cuadro de búsqueda y su botón Buscar.
  6 [btn] Buscar un libro  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «buscá novelas policiales»

- [+ 18.7s] 💬 Persona: buscá novelas policiales
- [+ 30.9s] 💬 JEF: Listo, escrito en Buscar en la biblioteca.
- [+ 31.0s] 🔊 «Listo, escrito en Buscar en la biblioteca.»
- [+ 31.0s] 🔘 Botones: [Buscar un libro] · [Otra cosa]

Al terminar el paso (19 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/busca-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la biblioteca del club, en su página de búsqueda. Sirve para buscar libros por título, autor o género, con un cuadro de búsqueda y su botón Buscar.
  6 [H] Vos: buscá novelas policiales
  7 [txt] Listo, escrito en Buscar en la biblioteca.
  8 [btn] Buscar un libro  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
