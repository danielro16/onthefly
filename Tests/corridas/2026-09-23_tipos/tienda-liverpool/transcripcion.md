# tienda-liverpool

**Quién:** Vive en México, con baja visión. Entra a una tienda.

**Qué quiere:** Que JEF sepa qué tipo de sitio y de página es, y que los pasos que ofrece sean los probables para ese tipo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «liverpool.com.mx»

- [+  6.6s] 💬 Persona: liverpool.com.mx
- [+  6.6s] 💬 JEF: Abriendo liverpool.com.mx.
- [+  6.6s] 🔊 «Abriendo liverpool.com.mx.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 14.4s] 📄 Cargó https://www.liverpool.com.mx/tienda/home — «Liverpool | Hasta 50% de descuento + 9 MSI | Envío gratis» (paginas/01.txt)
- [+ 18.5s] 💬 JEF: Estás en la tienda en línea de Liverpool, en su página principal, donde puedes comprar productos y ver promociones como descuentos de hasta 50% y meses sin intereses. Hay secciones de productos en tendencia, más vendidos y categorías en el menú. Un aviso que promueve la app de Liverpool tapa la página y puedes cerrarlo.
- [+ 18.6s] 🔊 «Estás en la tienda en línea de Liverpool, en su página principal, donde puedes comprar productos y ver promociones como descuentos de hasta 50% y meses sin intereses. Hay secciones de productos en tendencia, más vendidos y categorías en el menú. Un aviso que promueve la app de Liverpool tapa la página y puedes cerrarlo.»
- [+ 18.6s] 🔘 Botones: [Close banner] · [Buscar productos en Liverpool] · [Categorías chevron_right]
- [+ 18.6s] 🔘 Botones: [Close banner, Compra con tu celular, Liverpool pocket, Ratin] · [Close banner] · [Descarga] · [Buscar productos en Liverpool] · [Categorías chevron_right]
- [+ 18.6s] 🔘 Botones: [Close banner, Compra con tu celular, Liverpool pocket, Ratin] · [Close banner] · [Descarga] · [Buscar productos en Liverpool] · [Categorías chevron_right] · [Otra cosa]
- [+ 21.5s] 📄 Cargó https://www.liverpool.com.mx/tienda/home — «Liverpool | Hasta 50% de descuento + 9 MSI | Envío gratis» (paginas/02.txt)

Al terminar el paso (23 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: liverpool.com.mx
  4 [txt] Abriendo liverpool.com.mx.
  5 [txt] Estás en la tienda en línea de Liverpool, en su página principal, donde puedes comprar productos y ver promociones como descuentos de hasta 50% y meses sin intereses. Hay secciones de productos en tendencia, más vendidos y categorías en el menú. Un aviso que promueve la app de Liverpool tapa la página y puedes cerrarlo.
  6 [btn] Close banner, Compra con tu celular, Liverpool pocket, Ratin  (Primera de 6 opciones.)
  7 [btn] Close banner
  8 [btn] Descarga
  9 [btn] Buscar productos en Liverpool
 10 [btn] Categorías chevron_right
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
