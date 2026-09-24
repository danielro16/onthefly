# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.6s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.6s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.6s] 🔊 «Abriendo demoblaze.com.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.7s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 14.4s] 💬 JEF: Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.
- [+ 14.4s] 🔊 «Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.»
- [+ 14.4s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»]
- [+ 14.4s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.
  6 [btn] Abrir «Add to cart»  (Primera de 4 opciones.)
  7 [btn] Abrir «Cart»
  8 [btn] Abrir «PRODUCT STORE»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 22.3s] 💬 Persona: agregalo al carrito
- [+ 28.0s] 💬 JEF: «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
- [+ 28.0s] 🔊 ««Add to cart» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 28.0s] 🔘 Botones: [Pulsar «Add to cart»]
- [+ 28.0s] 🔘 Botones: [Pulsar «Add to cart»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Add to cart»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Add to cart»»

- [+ 34.5s] 💬 Persona: Pulsar «Add to cart»
- [+ 34.5s] 💬 JEF: Pulsando «Add to cart».
- [+ 34.5s] 🔊 «Pulsando «Add to cart».»
- [+ 35.6s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1# — «STORE» (paginas/02.txt)
- [+ 39.3s] 💬 JEF: Estás en la página del producto Samsung Galaxy S6 de Product Store: cuesta 360 dólares e incluye impuestos. El teléfono tiene procesador octa-core de 1,5 GHz, 3 GB de memoria RAM y 32 GB de almacenamiento interno no ampliable. Para agregarlo al carrito, uso el botón «Add to cart» que está debajo de la descripción, y te aviso cuando lo haga.
- [+ 39.3s] 🔊 «Estás en la página del producto Samsung Galaxy S6 de Product Store: cuesta 360 dólares e incluye impuestos. El teléfono tiene procesador octa-core de 1,5 GHz, 3 GB de memoria RAM y 32 GB de almacenamiento interno no ampliable. Para agregarlo al carrito, uso el botón «Add to cart» que está debajo de la descripción, y te aviso cuando lo haga.»
- [+ 39.3s] 🔘 Botones: [Abrir «Cart»]
- [+ 39.3s] 🔘 Botones: [Abrir «Cart»] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store: cuesta 360 dólares e incluye impuestos. El teléfono tiene procesador octa-core de 1,5 GHz, 3 GB de memoria RAM y 32 GB de almacenamiento interno no ampliable. Para agregarlo al carrito, uso el botón «Add to cart» que está debajo de la descripción, y te aviso cuando lo haga.
 11 [btn] Abrir «Cart»  (Primera de 3 opciones.)
 12 [btn] Volver a «STORE»
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 47.9s] 💬 Persona: llevame al carrito
- [+ 49.6s] 💬 JEF: Abriendo «Cart».
- [+ 49.6s] 🔊 «Abriendo «Cart».»
- [+ 50.7s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/03.txt)
- [+ 53.8s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/04.txt)
- [+ 54.7s] 💬 JEF: Estás en la tienda Product Store, en la página del carrito, pero no veo ningún producto cargado todavía; la página solo muestra el total y el botón Place Order, así que no puedo agregar nada desde aquí. Para agregar un producto hay que ir al catálogo y elegir uno desde allí.
- [+ 54.7s] 🔊 «Estás en la tienda Product Store, en la página del carrito, pero no veo ningún producto cargado todavía; la página solo muestra el total y el botón Place Order, así que no puedo agregar nada desde aquí. Para agregar un producto hay que ir al catálogo y elegir uno desde allí.»
- [+ 54.7s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Place Order] · [Abrir «Cart»]
- [+ 54.7s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Place Order] · [Abrir «Cart»] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la tienda Product Store, en la página del producto Samsung Galaxy S6, con un precio de 360 dólares que incluye impuestos. El teléfono tiene un procesador octa-core Samsung Exynos 7420 de 1.5GHz, 3GB de memoria RAM y 32GB de almacenamiento interno que no se puede ampliar. Abajo aparece un botón para agregarlo al carrito, además de los datos de contacto de la tienda.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store: cuesta 360 dólares e incluye impuestos. El teléfono tiene procesador octa-core de 1,5 GHz, 3 GB de memoria RAM y 32 GB de almacenamiento interno no ampliable. Para agregarlo al carrito, uso el botón «Add to cart» que está debajo de la descripción, y te aviso cuando lo haga.
 11 [H] Vos: llevame al carrito
 12 [txt] Abriendo «Cart».
 13 [txt] Estás en la tienda Product Store, en la página del carrito, pero no veo ningún producto cargado todavía; la página solo muestra el total y el botón Place Order, así que no puedo agregar nada desde aquí. Para agregar un producto hay que ir al catálogo y elegir uno desde allí.
 14 [btn] Abrir «PRODUCT STORE»  (Primera de 5 opciones.)
 15 [btn] Place Order
 16 [btn] Abrir «Cart»
 17 [btn] Volver a «STORE»
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
