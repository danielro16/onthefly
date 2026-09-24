# compromete-carrito

**Quién:** Ciega, compra por internet. Pide las cosas con palabras.

**Qué quiere:** Que JEF no toque solo un botón que compromete fuera de un formulario («Add to cart» hecho con JavaScript): que lo deje para que lo toque ella, y que al tocarlo se apriete. Y después, en el carrito, que el producto esté.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «https://www.demoblaze.com/prod.html?idp_=1»

- [+  6.8s] 💬 Persona: https://www.demoblaze.com/prod.html?idp_=1
- [+  6.8s] 💬 JEF: Abriendo demoblaze.com.
- [+  6.8s] 🔊 «Abriendo demoblaze.com.»
- [+  6.8s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.4s] 📄 Cargó https://www.demoblaze.com/prod.html?idp_=1 — «STORE» (paginas/01.txt)
- [+ 11.3s] 💬 JEF: Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.
- [+ 11.3s] 🔊 «Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.»
- [+ 11.3s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Contact»] · [Abrir «About us»]
- [+ 11.3s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Contact»] · [Abrir «About us»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.
  6 [btn] Abrir «PRODUCT STORE»  (Primera de 4 opciones.)
  7 [btn] Abrir «Contact»
  8 [btn] Abrir «About us»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «agregalo al carrito»

- [+ 18.9s] 💬 Persona: agregalo al carrito
- [+ 21.8s] 💬 JEF: Buscando: demoblaze.com.
- [+ 21.8s] 🔊 «Buscando: demoblaze.com.»
- [+ 23.7s] 📄 Cargó https://www.google.com/search?q=demoblaze%2Ecom&gl=us&hl=es — «demoblaze.com - Buscar con Google» (paginas/02.txt)
- [+ 24.0s] 💬 JEF: Estás en los resultados de «demoblaze.com». Los 3 más probables:
- [+ 24.0s] 🔊 «Estás en los resultados de «demoblaze.com». Los 3 más probables: 1. Demo Blaze, demoblaze.com. 2. How to Sign in to Demoblaze?, kopyst.com. 3. Automated demoblaze.com site using Page Object Model and ..., github.com»
- [+ 24.0s] 🔘 Botones: [Demo Blaze — www.demoblaze.com] · [How to Sign in to Demoblaze? — www.kopyst.com] · [Automated demoblaze.com site using Page Object Model and ... — github.com] · [Ver más opciones (3)]
- [+ 24.0s] 💬 JEF: Cuando elijas, sigo con «agrégalo al carrito».
- [+ 24.0s] 🔊 «Cuando elijas, sigo con «agrégalo al carrito».»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 24.0s] 🔘 Botones: [Demo Blaze — www.demoblaze.com] · [How to Sign in to Demoblaze? — www.kopyst.com] · [Automated demoblaze.com site using Page Object Model and ... — github.com] · [Ver más opciones (3)] · [Otra cosa]
- [+ 27.3s] 📄 Cargó https://www.google.com/search?q=demoblaze%2Ecom&gl=us&hl=es&sei=17S1aueIN4irxc8PpYbvuQg — «demoblaze.com - Buscar con Google» (paginas/03.txt)

Al terminar el paso (16 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.
  6 [H] Vos: agregalo al carrito
  7 [txt] Buscando: demoblaze.com.
  8 [txt] Estás en los resultados de «demoblaze.com». Los 3 más probables:
  9 [txt] Cuando elijas, sigo con «agrégalo al carrito».
 10 [btn] Demo Blaze — www.demoblaze.com  (Primera de 5 opciones.)
 11 [btn] How to Sign in to Demoblaze? — www.kopyst.com
 12 [btn] Automated demoblaze.com site using Page Object Model and ... — github.com
 13 [btn] Ver más opciones (3)
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Demo Blaze — www.demoblaze.com»

- [+ 37.6s] 💬 Persona: Demo Blaze — www.demoblaze.com
- [+ 37.6s] 💬 JEF: Abriendo demoblaze.com.
- [+ 37.6s] 🔊 «Abriendo demoblaze.com.»
- [+ 38.8s] 📄 Cargó https://www.demoblaze.com/ — «STORE» (paginas/04.txt)
- [+ 38.8s] 💬 JEF: Estás en www.demoblaze.com.
- [+ 38.8s] 🔊 «Estás en www.demoblaze.com.»
- [+ 42.7s] 💬 JEF: Estás en «STORE», www.demoblaze.com. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
- [+ 42.7s] 🔊 «Estás en «STORE», www.demoblaze.com. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.»
- [+ 42.7s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (16 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.
  6 [H] Vos: agregalo al carrito
  7 [txt] Buscando: demoblaze.com.
  8 [txt] Estás en los resultados de «demoblaze.com». Los 3 más probables:
  9 [txt] Cuando elijas, sigo con «agrégalo al carrito».
 10 [H] Vos: Demo Blaze — www.demoblaze.com
 11 [txt] Abriendo demoblaze.com.
 12 [txt] Estás en www.demoblaze.com.
 13 [txt] Estás en «STORE», www.demoblaze.com. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
 14 [btn] Leer la página  (Primera de 4 opciones.)
 15 [btn] Resumir la página
 16 [btn] Volver a los resultados
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```

## Paso 4 — escribe «llevame al carrito»

- [+ 50.7s] 💬 Persona: llevame al carrito
- [+ 54.3s] 💬 JEF: Abriendo Cart.
- [+ 54.3s] 🔊 «Abriendo Cart.»
- [+ 55.3s] 📄 Cargó https://www.demoblaze.com/cart.html — «STORE» (paginas/05.txt)
- [+ 58.5s] 💬 JEF: Estás en la página principal de Product Store; aquí se muestran productos y se puede acceder al carrito. No aparece ningún producto en la página, así que todavía no se ha agregado nada al carrito.
- [+ 58.5s] 🔊 «Estás en la página principal de Product Store; aquí se muestran productos y se puede acceder al carrito. No aparece ningún producto en la página, así que todavía no se ha agregado nada al carrito.»
- [+ 58.5s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Cart»]
- [+ 58.5s] 🔘 Botones: [Abrir «PRODUCT STORE»] · [Abrir «Cart»] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: https://www.demoblaze.com/prod.html?idp_=1
  4 [txt] Abriendo demoblaze.com.
  5 [txt] Estás en la página de inicio de Product Store. Aquí puedes entrar a la tienda de productos y consultar información de contacto o sobre la empresa; también aparece una dirección, un teléfono y un correo electrónico.
  6 [H] Vos: agregalo al carrito
  7 [txt] Buscando: demoblaze.com.
  8 [txt] Estás en los resultados de «demoblaze.com». Los 3 más probables:
  9 [txt] Cuando elijas, sigo con «agrégalo al carrito».
 10 [H] Vos: Demo Blaze — www.demoblaze.com
 11 [txt] Abriendo demoblaze.com.
 12 [txt] Estás en www.demoblaze.com.
 13 [txt] Estás en «STORE», www.demoblaze.com. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
 14 [H] Vos: llevame al carrito
 15 [txt] Abriendo Cart.
 16 [txt] Estás en la página principal de Product Store; aquí se muestran productos y se puede acceder al carrito. No aparece ningún producto en la página, así que todavía no se ha agregado nada al carrito.
 17 [btn] Abrir «PRODUCT STORE»  (Primera de 4 opciones.)
 18 [btn] Abrir «Cart»
 19 [btn] Volver a la portada
 20 [btn] Otra cosa
 21 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 22 [btn] Enviar
```
