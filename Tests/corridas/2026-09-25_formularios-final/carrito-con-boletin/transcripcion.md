# carrito-con-boletin

**Quién:** Ciega, compra por internet. En la página de un producto pide agregarlo al carrito.

**Qué quiere:** Que JEF vaya al botón «Agregar al carrito» (suelto, sin formulario) y no al formulario del boletín del pie de la página. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/producto.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/producto.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/producto.html — «Pava eléctrica 1,7 litros — Casa Ferreira» (paginas/01.txt)
- [+ 11.3s] 💬 JEF: Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria. Cuesta $ 48.900.
- [+ 11.3s] 🔊 «Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria. Cuesta $ 48.900.»
- [+ 11.3s] 🔘 Botones: [Agregar al carrito]
- [+ 11.3s] 🔘 Botones: [Agregar al carrito] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria. Cuesta $ 48.900.
  6 [btn] Agregar al carrito  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 18.5s] 💬 Persona: agregalo al carrito
- [+ 25.2s] 💬 JEF: «Agregar al carrito» puede confirmar algo: queda abajo, para tocarlo.
- [+ 25.2s] 🔊 ««Agregar al carrito» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 25.2s] 🔘 Botones: [Pulsar «Agregar al carrito»]
- [+ 25.2s] 🔘 Botones: [Pulsar «Agregar al carrito»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de una pava eléctrica de 1,7 litros, de acero inoxidable, con corte automático y base giratoria. Cuesta $ 48.900.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Agregar al carrito» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Agregar al carrito»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
