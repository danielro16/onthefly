# busca-tarde

**Quién:** Cualquiera: busca en un sitio cuyo buscador cambia de página un rato después de enviar.

**Qué quiere:** Que JEF no diga que la página no cambió: que espere los resultados y los cuente. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/busca-tarde.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/busca-tarde.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 📄 Cargó http://localhost:8765/busca-tarde.html — «Biblioteca del club» (paginas/01.txt)
- [+ 10.3s] 💬 JEF: Estás en la página de la biblioteca del club, donde se busca un libro por título, autor o género. Hay un buscador para escribir eso mismo y un botón Buscar. Dime qué libro, autor o género querés buscar.
- [+ 10.3s] 🔊 «Estás en la página de la biblioteca del club, donde se busca un libro por título, autor o género. Hay un buscador para escribir eso mismo y un botón Buscar. Dime qué libro, autor o género querés buscar.»
- [+ 10.3s] 🔘 Botones: [Buscar libros] · [Resumir la página]
- [+ 10.3s] 🔘 Botones: [Buscar libros] · [Resumir la página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/busca-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de la biblioteca del club, donde se busca un libro por título, autor o género. Hay un buscador para escribir eso mismo y un botón Buscar. Dime qué libro, autor o género querés buscar.
  6 [btn] Buscar libros  (Primera de 3 opciones.)
  7 [btn] Resumir la página
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Buscar libros»

- [+ 18.6s] 💬 Persona: Buscar libros
- [+ 18.6s] 💬 JEF: «Buscar libros»: ¿qué escribo? Se puede escribir o dictar acá abajo.
- [+ 18.6s] 🔊 ««Buscar libros»: ¿qué escribo? Se puede escribir o dictar acá abajo.»
- [+ 18.6s] 🔘 Botones: [Buscar libros] · [Resumir la página] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/busca-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de la biblioteca del club, donde se busca un libro por título, autor o género. Hay un buscador para escribir eso mismo y un botón Buscar. Dime qué libro, autor o género querés buscar.
  6 [H] Vos: Buscar libros
  7 [txt] «Buscar libros»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [btn] Buscar libros  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = Escribir: Buscar en la biblioteca  (Va directo al campo «Buscar en la biblioteca» de la página.)
 12 [btn] Enviar
```

## Paso 3 — escribe «novelas policiales»

- [+ 28.2s] 💬 Persona: Buscar en la biblioteca terminado en les
- [+ 28.9s] 💬 JEF: Buscando «novelas policiales».
- [+ 28.9s] 🔊 «Buscando «novelas policiales».»
- [+ 31.1s] 📄 Cargó http://localhost:8765/redirigido.html — «Resultados: novelas policiales» (paginas/02.txt)
- [+ 34.4s] 💬 JEF: Encontré 3 libros de novelas policiales en la biblioteca del club: El asesinato de Roger Ackroyd de Agatha Christie, La muerte y la brújula de Jorge Luis Borges y El largo adiós de Raymond Chandler. Puedes abrir cualquiera de ellos con los botones.
- [+ 34.4s] 🔊 «Encontré 3 libros de novelas policiales en la biblioteca del club: El asesinato de Roger Ackroyd de Agatha Christie, La muerte y la brújula de Jorge Luis Borges y El largo adiós de Raymond Chandler. Puedes abrir cualquiera de ellos con los botones.»
- [+ 34.4s] 🔘 Botones: [Abrir «El asesinato de Roger Ackroyd — Agatha Christie»] · [Abrir «La muerte y la brújula — Jorge Luis Borges»] · [Abrir «El largo adiós — Raymond Chandler»]
- [+ 34.4s] 🔘 Botones: [Abrir «El asesinato de Roger Ackroyd — Agatha Christie»] · [Abrir «La muerte y la brújula — Jorge Luis Borges»] · [Abrir «El largo adiós — Raymond Chandler»] · [Volver a «Biblioteca del club»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/busca-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de la biblioteca del club, donde se busca un libro por título, autor o género. Hay un buscador para escribir eso mismo y un botón Buscar. Dime qué libro, autor o género querés buscar.
  6 [H] Vos: Buscar libros
  7 [txt] «Buscar libros»: ¿qué escribo? Se puede escribir o dictar acá abajo.
  8 [H] Vos: Buscar en la biblioteca terminado en les
  9 [txt] Buscando «novelas policiales».
 10 [txt] Encontré 3 libros de novelas policiales en la biblioteca del club: El asesinato de Roger Ackroyd de Agatha Christie, La muerte y la brújula de Jorge Luis Borges y El largo adiós de Raymond Chandler. Puedes abrir cualquiera de ellos con los botones.
 11 [btn] Abrir «El asesinato de Roger Ackroyd — Agatha Christie»  (Primera de 5 opciones.)
 12 [btn] Abrir «La muerte y la brújula — Jorge Luis Borges»
 13 [btn] Abrir «El largo adiós — Raymond Chandler»
 14 [btn] Volver a «Biblioteca del club»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
