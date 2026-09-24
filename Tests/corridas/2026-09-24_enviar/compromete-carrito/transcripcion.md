# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.4s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.4s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.4s] 🔊 «Abriendo demoblaze.com.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.1s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 11.7s] 💬 JEF: Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.
- [+ 11.7s] 🔊 «Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.»
- [+ 11.7s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»]
- [+ 11.7s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.
  6 [btn] Abrir «Add to cart»  (Primera de 3 opciones.)
  7 [btn] Abrir «Cart»
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 20.3s] 💬 Persona: agregalo al carrito
- [+ 22.8s] 💬 JEF: «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
- [+ 22.8s] 🔊 ««Add to cart» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 22.8s] 🔘 Botones: [Pulsar «Add to cart»]
- [+ 22.8s] 🔘 Botones: [Pulsar «Add to cart»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Add to cart»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Add to cart»»

- [+ 29.1s] 💬 Persona: Pulsar «Add to cart»
- [+ 29.1s] 💬 JEF: Pulsando «Add to cart».
- [+ 29.1s] 🔊 «Pulsando «Add to cart».»
- [+ 30.2s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1# — «STORE» (paginas/02.txt)
- [+ 32.5s] 💬 JEF: Listo: la página confirmó «Product added», así que el Samsung Galaxy S6 de 360 dólares ya quedó agregado al carrito. Si quieres, puedes abrir el carrito del menú para revisar tu pedido o seguir viendo productos de la tienda.
- [+ 32.5s] 🔊 «Listo: la página confirmó «Product added», así que el Samsung Galaxy S6 de 360 dólares ya quedó agregado al carrito. Si quieres, puedes abrir el carrito del menú para revisar tu pedido o seguir viendo productos de la tienda.»
- [+ 32.5s] 🔘 Botones: [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Abrir «Contact»]
- [+ 32.5s] 🔘 Botones: [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Abrir «Contact»] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] Listo: la página confirmó «Product added», así que el Samsung Galaxy S6 de 360 dólares ya quedó agregado al carrito. Si quieres, puedes abrir el carrito del menú para revisar tu pedido o seguir viendo productos de la tienda.
 11 [btn] Abrir «Cart»  (Primera de 5 opciones.)
 12 [btn] Abrir «PRODUCT STORE»
 13 [btn] Abrir «Contact»
 14 [btn] Volver a «STORE»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 40.6s] 💬 Persona: llevame al carrito
- [+ 44.4s] 💬 JEF: Abriendo Cart.
- [+ 44.4s] 🔊 «Abriendo Cart.»
- [+ 45.5s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/03.txt)
- [+ 46.3s] 💬 JEF: Abriendo Cart.
- [+ 46.3s] 🔊 «Abriendo Cart.»
- [+ 48.0s] 📄 Cargó https://www.demoblaze.com/cart.html# — «STORE» (paginas/04.txt)
- [+ 48.4s] 💬 JEF: No encuentro «carrito» en esta página. ¿Lo busco en internet?
- [+ 48.4s] 🔊 «No encuentro «carrito» en esta página. ¿Lo busco en internet?»
- [+ 48.4s] 🔘 Botones: [Buscarlo en internet] · [Leer la página] · [Resumir la página] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (16 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Están en la tienda Product Store, en la página del Samsung Galaxy S6. El teléfono cuesta 360 dólares con impuestos incluidos, y según la descripción tiene procesador octa-core de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno, que no se puede ampliar. En la página hay un botón de «Add to cart» para agregarlo al carrito.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] Listo: la página confirmó «Product added», así que el Samsung Galaxy S6 de 360 dólares ya quedó agregado al carrito. Si quieres, puedes abrir el carrito del menú para revisar tu pedido o seguir viendo productos de la tienda.
 11 [H] Vos: llevame al carrito
 12 [txt] Abriendo Cart.
 13 [txt] Abriendo Cart.
 14 [txt] No encuentro «carrito» en esta página. ¿Lo busco en internet?
 15 [btn] Buscarlo en internet  (Primera de 5 opciones.)
 16 [btn] Leer la página
 17 [btn] Resumir la página
 18 [btn] Volver a «STORE»
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```
