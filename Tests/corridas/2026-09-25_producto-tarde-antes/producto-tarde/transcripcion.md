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
- [+ 10.0s] 💬 JEF: Tienda Norte es una tienda, pero esta página no muestra productos ni detalles; solo aparecen las opciones para agregar al carrito y abrir el carrito.
- [+ 10.0s] 🔊 «Tienda Norte es una tienda, pero esta página no muestra productos ni detalles; solo aparecen las opciones para agregar al carrito y abrir el carrito.»
- [+ 10.0s] 🔘 Botones: [Agregar al carrito] · [Abrir «Carrito»]
- [+ 10.0s] 🔘 Botones: [Agregar al carrito] · [Abrir «Carrito»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Tienda Norte es una tienda, pero esta página no muestra productos ni detalles; solo aparecen las opciones para agregar al carrito y abrir el carrito.
  6 [btn] Agregar al carrito  (Primera de 3 opciones.)
  7 [btn] Abrir «Carrito»
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «¿cuánto cuesta?»

- [+ 16.7s] 💬 Persona: ¿cuánto cuesta?
- [+ 24.5s] 💬 JEF: No está en esta página.
- [+ 24.5s] 🔊 «No está en esta página.»
- [+ 24.5s] 💬 JEF: Buscando: precio del producto en Tienda Norte.
- [+ 24.5s] 🔊 «Buscando: precio del producto en Tienda Norte.»  ⟶ en cola: empieza a sonar a los +26.1s
- [+ 26.5s] 📄 Cargó https://www.google.com/search?q=precio%20del%20producto%20en%20Tienda%20Norte&gl=us&hl=es — «precio del producto en Tienda Norte» (paginas/02.txt)
- [+ 26.7s] 💬 JEF: Estás en los resultados de «precio del producto en Tienda Norte». Los 3 más probables:
- [+ 26.7s] 🔊 «Estás en los resultados de «precio del producto en Tienda Norte». Los 3 más probables: 1. Tienda Norte, compratiendanorte.com. 2. Tienda, nortestore.com. 3. RETAIL NORTE MAYORISTA, retailnorte.com»  ⟶ en cola: empieza a sonar a los +29.4s
- [+ 26.7s] 🔘 Botones: [Tienda Norte — www.compratiendanorte.com] · [Tienda — nortestore.com] · [RETAIL NORTE MAYORISTA — retailnorte.com] · [Ver más opciones (4)]
- [+ 26.7s] 🔘 Botones: [Tienda Norte — www.compratiendanorte.com] · [Tienda — nortestore.com] · [RETAIL NORTE MAYORISTA — retailnorte.com] · [Ver más opciones (4)] · [Otra cosa]
- [+ 28.1s] 📄 Cargó https://www.google.com/search?q=precio%20del%20producto%20en%20Tienda%20Norte&gl=us&hl=es&sei=BaS2apGKH_ik2roP_5SMwAk — «precio del producto en Tienda Norte» (paginas/03.txt)

Al terminar el paso (19 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Tienda Norte es una tienda, pero esta página no muestra productos ni detalles; solo aparecen las opciones para agregar al carrito y abrir el carrito.
  6 [H] Vos: ¿cuánto cuesta?
  7 [txt] No está en esta página.
  8 [txt] Buscando: precio del producto en Tienda Norte.
  9 [txt] Estás en los resultados de «precio del producto en Tienda Norte». Los 3 más probables:
 10 [btn] Tienda Norte — www.compratiendanorte.com  (Primera de 5 opciones.)
 11 [btn] Tienda — nortestore.com
 12 [btn] RETAIL NORTE MAYORISTA — retailnorte.com
 13 [btn] Ver más opciones (4)
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```
