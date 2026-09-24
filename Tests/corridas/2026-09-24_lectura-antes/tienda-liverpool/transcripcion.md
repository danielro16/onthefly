# tienda-liverpool

**Quién:** Vive en México, con baja visión. Entra a una tienda.

**Qué quiere:** Que JEF sepa qué tipo de sitio y de página es, y que los pasos que ofrece sean los probables para ese tipo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «liverpool.com.mx»

- [+  6.6s] 💬 Persona: liverpool.com.mx
- [+  6.6s] 💬 JEF: Abriendo liverpool.com.mx.
- [+  6.6s] 🔊 «Abriendo liverpool.com.mx.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.3s] 📄 Cargó https://www.liverpool.com.mx/tienda/home — «Liverpool | Hasta 50% de descuento + 9 MSI | Envío gratis» (paginas/01.txt)
- [+ 12.9s] 💬 JEF: Liverpool es la tienda en línea para buscar productos y explorar categorías; también ofrece opciones como compras, crédito y recogida en tienda.
- [+ 12.9s] 🔊 «Liverpool es la tienda en línea para buscar productos y explorar categorías; también ofrece opciones como compras, crédito y recogida en tienda.»
- [+ 12.9s] 🔘 Botones: [Buscar en Liverpool] · [Categorías chevron_right] · [Abrir «Hyunjin x Guess | Prepara el outfit para tu concierto»]
- [+ 12.9s] 🔘 Botones: [Buscar en Liverpool] · [Categorías chevron_right] · [Abrir «Hyunjin x Guess | Prepara el outfit para tu concierto»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: liverpool.com.mx
  4 [txt] Abriendo liverpool.com.mx.
  5 [txt] Liverpool es la tienda en línea para buscar productos y explorar categorías; también ofrece opciones como compras, crédito y recogida en tienda.
  6 [btn] Buscar en Liverpool  (Primera de 4 opciones.)
  7 [btn] Categorías chevron_right
  8 [btn] Abrir «Hyunjin x Guess | Prepara el outfit para tu concierto»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
