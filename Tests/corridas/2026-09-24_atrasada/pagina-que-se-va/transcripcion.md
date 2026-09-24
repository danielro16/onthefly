# pagina-que-se-va

**Quién:** Cualquiera: la página cambia sola mientras JEF la piensa.

**Qué quiere:** Que JEF cuente la página que quedó (los resultados de novelas policiales), no la portada que se fue. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/redirige.html»

- [+  6.3s] 💬 Persona: http://localhost:8765/redirige.html
- [+  6.3s] 💬 JEF: Abriendo localhost.
- [+  6.3s] 🔊 «Abriendo localhost.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 📄 Cargó http://localhost:8765/redirige.html — «Portada que se va» (paginas/01.txt)
- [+  9.6s] 📄 Cargó http://localhost:8765/redirigido.html — «Resultados: novelas policiales» (paginas/02.txt)
- [+ 12.2s] 💬 JEF: Encontré los resultados de la búsqueda de «novelas policiales» en la biblioteca del club: hay 3 libros, de Agatha Christie, Jorge Luis Borges y Raymond Chandler. ¿Cuál de los 3 libros necesitas?
- [+ 12.2s] 🔊 «Encontré los resultados de la búsqueda de «novelas policiales» en la biblioteca del club: hay 3 libros, de Agatha Christie, Jorge Luis Borges y Raymond Chandler. ¿Cuál de los 3 libros necesitas?»
- [+ 12.2s] 🔘 Botones: [El asesinato de Roger Ackroyd — Agatha Christie] · [La muerte y la brújula — Jorge Luis Borges] · [El largo adiós — Raymond Chandler]
- [+ 12.2s] 🔘 Botones: [El asesinato de Roger Ackroyd — Agatha Christie] · [La muerte y la brújula — Jorge Luis Borges] · [El largo adiós — Raymond Chandler] · [Volver a «Portada que se va»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/redirige.html
  4 [txt] Abriendo localhost.
  5 [txt] Encontré los resultados de la búsqueda de «novelas policiales» en la biblioteca del club: hay 3 libros, de Agatha Christie, Jorge Luis Borges y Raymond Chandler. ¿Cuál de los 3 libros necesitas?
  6 [btn] El asesinato de Roger Ackroyd — Agatha Christie  (Primera de 5 opciones.)
  7 [btn] La muerte y la brújula — Jorge Luis Borges
  8 [btn] El largo adiós — Raymond Chandler
  9 [btn] Volver a «Portada que se va»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 6 s (resuelve algo en la página)


Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/redirige.html
  4 [txt] Abriendo localhost.
  5 [txt] Encontré los resultados de la búsqueda de «novelas policiales» en la biblioteca del club: hay 3 libros, de Agatha Christie, Jorge Luis Borges y Raymond Chandler. ¿Cuál de los 3 libros necesitas?
  6 [btn] El asesinato de Roger Ackroyd — Agatha Christie  (Primera de 5 opciones.)
  7 [btn] La muerte y la brújula — Jorge Luis Borges
  8 [btn] El largo adiós — Raymond Chandler
  9 [btn] Volver a «Portada que se va»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
