# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.3s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.3s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.3s] 🔊 «Abriendo demoblaze.com.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.7s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 11.4s] 💬 JEF: Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.
- [+ 11.4s] 🔊 «Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.»
- [+ 11.4s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»]
- [+ 11.4s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.
  6 [btn] Abrir «Add to cart»  (Primera de 4 opciones.)
  7 [btn] Abrir «Cart»
  8 [btn] Abrir «PRODUCT STORE»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 18.5s] 💬 Persona: agregalo al carrito
- [+ 21.6s] 💬 JEF: Acá no hay un formulario para enviar.
- [+ 21.6s] 🔊 «Acá no hay un formulario para enviar.»
- [+ 21.6s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.
  6 [H] Vos: agregalo al carrito
  7 [txt] Acá no hay un formulario para enviar.
  8 [btn] Abrir «Add to cart»  (Primera de 4 opciones.)
  9 [btn] Abrir «Cart»
 10 [btn] Abrir «PRODUCT STORE»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Abrir «Add to cart»»

- [+ 27.2s] 💬 Persona: Abrir «Add to cart»
- [+ 27.2s] 💬 JEF: Abriendo «Add to cart».
- [+ 27.2s] 🔊 «Abriendo «Add to cart».»
- [+ 28.3s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1# — «STORE» (paginas/02.txt)
- [+ 31.0s] 💬 JEF: Ya está: la página confirmó «Product added», así que el Samsung Galaxy S6 quedó agregado al carrito. Estás en la página del producto en Product Store, donde se vende el Galaxy S6 a 360 dólares con impuestos incluidos. Puedes revisar el carrito desde el menú para confirmarlo o continuar.
- [+ 31.0s] 🔊 «Ya está: la página confirmó «Product added», así que el Samsung Galaxy S6 quedó agregado al carrito. Estás en la página del producto en Product Store, donde se vende el Galaxy S6 a 360 dólares con impuestos incluidos. Puedes revisar el carrito desde el menú para confirmarlo o continuar.»
- [+ 31.0s] 🔘 Botones: [Abrir «Cart»] · [Resumir la página]
- [+ 31.0s] 🔘 Botones: [Abrir «Cart»] · [Resumir la página] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.
  6 [H] Vos: agregalo al carrito
  7 [txt] Acá no hay un formulario para enviar.
  8 [H] Vos: Abrir «Add to cart»
  9 [txt] Abriendo «Add to cart».
 10 [txt] Ya está: la página confirmó «Product added», así que el Samsung Galaxy S6 quedó agregado al carrito. Estás en la página del producto en Product Store, donde se vende el Galaxy S6 a 360 dólares con impuestos incluidos. Puedes revisar el carrito desde el menú para confirmarlo o continuar.
 11 [btn] Abrir «Cart»  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a «STORE»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 38.7s] 💬 Persona: llevame al carrito
- [+ 40.8s] 💬 JEF: Abriendo «Cart».
- [+ 40.8s] 🔊 «Abriendo «Cart».»
- [+ 41.9s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/03.txt)
- [+ 44.9s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/04.txt)
- [+ 50.1s] 💬 JEF: Estás en el carrito de Product Store, y el producto ya quedó agregado: el carrito tiene muchos productos, con muchas copias repetidas del Samsung galaxy s6 de 360, además de otros teléfonos y una MacBook air de 700. El total dice 53570. Si quieres, puedes eliminar productos del carrito o finalizar la compra con el botón Place Order.
- [+ 50.1s] 🔊 «Estás en el carrito de Product Store, y el producto ya quedó agregado: el carrito tiene muchos productos, con muchas copias repetidas del Samsung galaxy s6 de 360, además de otros teléfonos y una MacBook air de 700. El total dice 53570. Si quieres, puedes eliminar productos del carrito o finalizar la compra con el botón Place Order.»
- [+ 50.1s] 🔘 Botones: [Place Order] · [Abrir «Delete»] · [Resumir la página]
- [+ 50.1s] 🔘 Botones: [Place Order] · [Abrir «Delete»] · [Resumir la página] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (19 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, que cuesta 360 dólares con impuestos incluidos. El teléfono tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. En la página hay un botón para agregarlo al carrito y en el menú están el carrito, inicio de sesión y contacto.
  6 [H] Vos: agregalo al carrito
  7 [txt] Acá no hay un formulario para enviar.
  8 [H] Vos: Abrir «Add to cart»
  9 [txt] Abriendo «Add to cart».
 10 [txt] Ya está: la página confirmó «Product added», así que el Samsung Galaxy S6 quedó agregado al carrito. Estás en la página del producto en Product Store, donde se vende el Galaxy S6 a 360 dólares con impuestos incluidos. Puedes revisar el carrito desde el menú para confirmarlo o continuar.
 11 [H] Vos: llevame al carrito
 12 [txt] Abriendo «Cart».
 13 [txt] Estás en el carrito de Product Store, y el producto ya quedó agregado: el carrito tiene muchos productos, con muchas copias repetidas del Samsung galaxy s6 de 360, además de otros teléfonos y una MacBook air de 700. El total dice 53570. Si quieres, puedes eliminar productos del carrito o finalizar la compra con el botón Place Order.
 14 [btn] Place Order  (Primera de 5 opciones.)
 15 [btn] Abrir «Delete»
 16 [btn] Resumir la página
 17 [btn] Volver a «STORE»
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
