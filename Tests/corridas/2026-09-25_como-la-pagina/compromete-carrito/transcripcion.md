# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.6s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.6s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.6s] 🔊 «Abriendo demoblaze.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.6s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 11.8s] 💬 JEF: Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
- [+ 11.8s] 🔊 «Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.»
- [+ 11.8s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»]
- [+ 11.8s] 🔘 Botones: [Abrir «Add to cart»] · [Abrir «Cart»] · [Abrir «PRODUCT STORE»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página del producto Samsung Galaxy S6 de Product Store. Cuesta $360, impuestos incluidos; la descripción indica que tiene un procesador Samsung Exynos 7420 de ocho núcleos a 1.5GHz, 3GB de RAM y 32GB de almacenamiento interno no ampliable.
  6 [btn] Abrir «Add to cart»  (Primera de 4 opciones.)
  7 [btn] Abrir «Cart»
  8 [btn] Abrir «PRODUCT STORE»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 20.3s] 💬 Persona: agregalo al carrito
- [+ 26.8s] 💬 JEF: «Add to cart» puede confirmar algo: queda abajo, para tocarlo.
- [+ 26.8s] 🔊 ««Add to cart» puede confirmar algo: queda abajo, para tocarlo.»
- [+ 26.8s] 🔘 Botones: [Pulsar «Add to cart»]
- [+ 26.8s] 🔘 Botones: [Pulsar «Add to cart»] · [Otra cosa]

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

- [+ 32.5s] 💬 Persona: Pulsar «Add to cart»
- [+ 32.5s] 💬 JEF: Pulsando «Add to cart».
- [+ 32.5s] 🔊 «Pulsando «Add to cart».»
- [+ 33.6s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1# — «STORE» (paginas/02.txt)
- [+ 36.3s] 💬 JEF: Se añadió el producto al carrito. Estás en la página del Samsung Galaxy S6 de Product Store; cuesta $360, impuestos incluidos, y la descripción indica que tiene 3GB de RAM y 32GB de almacenamiento interno.
- [+ 36.3s] 🔊 «Se añadió el producto al carrito. Estás en la página del Samsung Galaxy S6 de Product Store; cuesta $360, impuestos incluidos, y la descripción indica que tiene 3GB de RAM y 32GB de almacenamiento interno.»
- [+ 36.3s] 🔘 Botones: [Abrir «Cart»] · [Leer la página]
- [+ 36.3s] 🔘 Botones: [Abrir «Cart»] · [Leer la página] · [Volver a «STORE»] · [Otra cosa]

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
 10 [txt] Se añadió el producto al carrito. Estás en la página del Samsung Galaxy S6 de Product Store; cuesta $360, impuestos incluidos, y la descripción indica que tiene 3GB de RAM y 32GB de almacenamiento interno.
 11 [btn] Abrir «Cart»  (Primera de 4 opciones.)
 12 [btn] Leer la página
 13 [btn] Volver a «STORE»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 43.8s] 💬 Persona: llevame al carrito
- [+ 46.7s] 💬 JEF: Abriendo Cart.
- [+ 46.7s] 🔊 «Abriendo Cart.»
- [+ 47.7s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/03.txt)
- [+ 50.3s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/04.txt)
- [+ 52.9s] 💬 JEF: Esta página de Product Store sirve para agregar productos al carrito, pero no indica que se haya agregado uno: muestra un carrito con muchos artículos y un total de 88990.
- [+ 52.9s] 🔊 «Esta página de Product Store sirve para agregar productos al carrito, pero no indica que se haya agregado uno: muestra un carrito con muchos artículos y un total de 88990.»
- [+ 52.9s] 🔘 Botones: [Abrir «PRODUCT STORE»]
- [+ 52.9s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Volver a «STORE»] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
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
 10 [txt] Se añadió el producto al carrito. Estás en la página del Samsung Galaxy S6 de Product Store; cuesta $360, impuestos incluidos, y la descripción indica que tiene 3GB de RAM y 32GB de almacenamiento interno.
 11 [H] Vos: llevame al carrito
 12 [txt] Abriendo Cart.
 13 [txt] Esta página de Product Store sirve para agregar productos al carrito, pero no indica que se haya agregado uno: muestra un carrito con muchos artículos y un total de 88990.
 14 [btn] Abrir «PRODUCT STORE»  (Primera de 3 opciones.)
 15 [btn] Volver a «STORE»
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
