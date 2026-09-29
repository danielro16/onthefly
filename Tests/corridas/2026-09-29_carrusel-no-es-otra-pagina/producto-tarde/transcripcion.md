# producto-tarde

**Quién:** Ciega, compra por internet. Abre la página de un producto que carga el producto un rato después que la página.

**Qué quiere:** Que JEF cuente el producto (licuadora, $ 62.300), no la tienda vacía, y que después sepa el precio. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/producto-tarde.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/producto-tarde.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/producto-tarde.html — «Tienda Norte» (paginas/01.txt)
- [+  9.2s] 📄 Cargó http://localhost:8765/producto-tarde.html — «Licuadora de vaso de vidrio 1,5 litros» (paginas/02.txt)
- [+ 13.4s] 💬 JEF: Estás en la página de producto de Tienda Norte: una licuadora con vaso de vidrio de 1,5 litros, motor de 800 W, cinco velocidades, función de pulso y cuchillas desmontables de acero inoxidable; cuesta $ 62.300.
- [+ 13.4s] 🔊 «Estás en la página de producto de Tienda Norte: una licuadora con vaso de vidrio de 1,5 litros, motor de 800 W, cinco velocidades, función de pulso y cuchillas desmontables de acero inoxidable; cuesta $ 62.300.»
- [+ 13.4s] 🔘 Botones: [Agregar al carrito] · [Abrir «Carrito»]
- [+ 13.4s] 🔘 Botones: [Agregar al carrito] · [Abrir «Carrito»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de producto de Tienda Norte: una licuadora con vaso de vidrio de 1,5 litros, motor de 800 W, cinco velocidades, función de pulso y cuchillas desmontables de acero inoxidable; cuesta $ 62.300.
  6 [btn] Agregar al carrito  (Primera de 3 opciones.)
  7 [btn] Abrir «Carrito»
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «¿cuánto cuesta?»

- [+ 20.5s] 💬 Persona: ¿cuánto cuesta?
- [+ 25.7s] 💬 JEF: La licuadora cuesta $ 62.300.
- [+ 25.7s] 🔊 «La licuadora cuesta $ 62.300.»
- [+ 25.7s] 🔘 Botones: [Agregar al carrito] · [Abrir «Carrito»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de producto de Tienda Norte: una licuadora con vaso de vidrio de 1,5 litros, motor de 800 W, cinco velocidades, función de pulso y cuchillas desmontables de acero inoxidable; cuesta $ 62.300.
  6 [H] Vos: ¿cuánto cuesta?
  7 [txt] La licuadora cuesta $ 62.300.
  8 [btn] Agregar al carrito  (Primera de 3 opciones.)
  9 [btn] Abrir «Carrito»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
