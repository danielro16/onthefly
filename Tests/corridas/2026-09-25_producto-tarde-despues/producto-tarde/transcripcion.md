# producto-tarde

**Quién:** Ciega, compra por internet. Abre la página de un producto que carga el producto un rato después que la página.

**Qué quiere:** Que JEF cuente el producto (licuadora, $ 62.300), no la tienda vacía, y que después sepa el precio. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/producto-tarde.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/producto-tarde.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:8765/producto-tarde.html — «Tienda Norte» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Tienda Norte es una tienda; la página muestra el acceso al carrito, pero no indica ningún producto ni confirma que se haya agregado algo.
- [+ 10.5s] 🔊 «Tienda Norte es una tienda; la página muestra el acceso al carrito, pero no indica ningún producto ni confirma que se haya agregado algo.»
- [+ 10.5s] 🔘 Botones: [Abrir «Carrito»] · [Abrir «Tienda Norte»]
- [+ 10.5s] 🔘 Botones: [Abrir «Carrito»] · [Abrir «Tienda Norte»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Tienda Norte es una tienda; la página muestra el acceso al carrito, pero no indica ningún producto ni confirma que se haya agregado algo.
  6 [btn] Abrir «Carrito»  (Primera de 3 opciones.)
  7 [btn] Abrir «Tienda Norte»
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «¿cuánto cuesta?»

- [+ 18.5s] 💬 Persona: ¿cuánto cuesta?
- [+ 24.0s] 💬 JEF: Eso no aparece en esta página.
- [+ 24.0s] 🔊 «Eso no aparece en esta página.»
- [+ 24.0s] 🔘 Botones: [Buscarlo en internet] · [Abrir «Carrito»] · [Abrir «Tienda Norte»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/producto-tarde.html
  4 [txt] Abriendo localhost.
  5 [txt] Tienda Norte es una tienda; la página muestra el acceso al carrito, pero no indica ningún producto ni confirma que se haya agregado algo.
  6 [H] Vos: ¿cuánto cuesta?
  7 [txt] Eso no aparece en esta página.
  8 [btn] Buscarlo en internet  (Primera de 4 opciones.)
  9 [btn] Abrir «Carrito»
 10 [btn] Abrir «Tienda Norte»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
