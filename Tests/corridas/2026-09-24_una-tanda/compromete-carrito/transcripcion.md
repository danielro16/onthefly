# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.7s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.7s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.7s] 🔊 «Abriendo demoblaze.com.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.5s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 11.5s] 💬 JEF: Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
- [+ 11.5s] 🔊 «Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.»
- [+ 11.5s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Leer la página]
- [+ 11.5s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Leer la página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
  6 [btn] Abrir «Add to cart»  (Primera de 4 opciones.)
  7 [btn] Abrir «Cart»
  8 [btn] Leer la página
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 18.7s] 💬 Persona: agregalo al carrito
- [+ 25.0s] 💬 JEF: «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
- [+ 25.0s] 🔊 ««Add to cart» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 25.0s] 🔘 Botones: [Pulsar «Add to cart»]
- [+ 25.0s] 🔘 Botones: [Pulsar «Add to cart»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [btn] Pulsar «Add to cart»  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Pulsar «Add to cart»»

- [+ 30.9s] 💬 Persona: Pulsar «Add to cart»
- [+ 30.9s] 💬 JEF: Pulsando «Add to cart».
- [+ 30.9s] 🔊 «Pulsando «Add to cart».»
- [+ 32.0s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1# — «STORE» (paginas/02.txt)
- [+ 34.3s] 💬 JEF: El sitio de la tienda confirmó que el producto se agregó al carrito. Estás en la página del Samsung Galaxy S6, que cuesta $360 con impuestos incluidos; la descripción indica que tiene 3 GB de RAM y 32 GB de almacenamiento interno.
- [+ 34.3s] 🔊 «El sitio de la tienda confirmó que el producto se agregó al carrito. Estás en la página del Samsung Galaxy S6, que cuesta $360 con impuestos incluidos; la descripción indica que tiene 3 GB de RAM y 32 GB de almacenamiento interno.»
- [+ 34.3s] 🔘 Botones: [Abrir «Cart»] · [Leer la página]
- [+ 34.3s] 🔘 Botones: [Abrir «Cart»] · [Leer la página] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] El sitio de la tienda confirmó que el producto se agregó al carrito. Estás en la página del Samsung Galaxy S6, que cuesta $360 con impuestos incluidos; la descripción indica que tiene 3 GB de RAM y 32 GB de almacenamiento interno.
 11 [btn] Abrir «Cart»  (Primera de 4 opciones.)
 12 [btn] Leer la página
 13 [btn] Volver a «STORE»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 42.2s] 💬 Persona: llevame al carrito
- [+ 45.3s] 💬 JEF: Abriendo Cart.
- [+ 45.4s] 🔊 «Abriendo Cart.»
- [+ 46.3s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/03.txt)
- [+ 49.1s] 💬 JEF: Esta tienda no muestra ningún producto agregado al carrito: solo aparecen los encabezados de productos y el botón «Place Order». No puedo confirmar que se haya agregado algo; la tienda ofrece ver sus productos y abrir el carrito.
- [+ 49.1s] 🔊 «Esta tienda no muestra ningún producto agregado al carrito: solo aparecen los encabezados de productos y el botón «Place Order». No puedo confirmar que se haya agregado algo; la tienda ofrece ver sus productos y abrir el carrito.»
- [+ 49.1s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Cart»]
- [+ 49.1s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Cart»] · [Volver a «STORE»] · [Otra cosa]
- [+ 49.2s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/04.txt)

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
  6 [H] Vos: agregalo al carrito
  7 [txt] «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
  8 [H] Vos: Pulsar «Add to cart»
  9 [txt] Pulsando «Add to cart».
 10 [txt] El sitio de la tienda confirmó que el producto se agregó al carrito. Estás en la página del Samsung Galaxy S6, que cuesta $360 con impuestos incluidos; la descripción indica que tiene 3 GB de RAM y 32 GB de almacenamiento interno.
 11 [H] Vos: llevame al carrito
 12 [txt] Abriendo Cart.
 13 [txt] Esta tienda no muestra ningún producto agregado al carrito: solo aparecen los encabezados de productos y el botón «Place Order». No puedo confirmar que se haya agregado algo; la tienda ofrece ver sus productos y abrir el carrito.
 14 [btn] Abrir «PRODUCT STORE»  (Primera de 4 opciones.)
 15 [btn] Abrir «Cart»
 16 [btn] Volver a «STORE»
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```
