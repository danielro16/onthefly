# carrito-con-boletin

**Quién:** Ciega, compra por internet. En la página de un producto pide agregarlo al carrito.

**Qué quiere:** Que JEF vaya al botón «Agregar al carrito» (suelto, sin formulario) y no al formulario del boletín del pie de la página. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/producto.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/producto.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:8765/producto.html — «Pava eléctrica 1,7 litros — Casa Ferreira» (paginas/01.txt)
- [+ 16.7s] 💬 JEF: Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria; cuesta $ 48.900.
- [+ 16.7s] 🔊 «Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria; cuesta $ 48.900.»
- [+ 16.7s] 🔘 Botones: [Agregar al carrito] · [Resumir la página]
- [+ 16.7s] 🔘 Botones: [Agregar al carrito] · [Resumir la página] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria; cuesta $ 48.900.
  6 [btn] Agregar al carrito  (Primera de 3 opciones.)
  7 [btn] Resumir la página
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 23.6s] 💬 Persona: agregalo al carrito
- [+ 39.6s] 💬 JEF: Sin conexión. No puedo entender lo que pedís sin internet.
- [+ 39.6s] 🔊 «Sin conexión. No puedo entender lo que pedís sin internet.»
- [+ 39.6s] 🔘 Botones: [Agregar al carrito] · [Resumir la página] · [Otra cosa]

Al terminar el paso (24 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria; cuesta $ 48.900.
  6 [H] Vos: agregalo al carrito
  7 [txt] Sin conexión. No puedo entender lo que pedís sin internet.
  8 [btn] Agregar al carrito  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
