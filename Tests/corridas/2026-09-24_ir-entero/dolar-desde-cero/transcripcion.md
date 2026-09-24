# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.6s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.6s] 💬 JEF: Buscando: ¿a cuánto está el dólar blue hoy?.
- [+  6.6s] 🔊 «Buscando: ¿a cuánto está el dólar blue hoy?.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.7s] 📄 Cargó https://www.google.com/search?q=%C2%BFa%20cu%C3%A1nto%20est%C3%A1%20el%20d%C3%B3lar%20blue%20hoy%3F&gl=us&hl=es — «¿a cuánto está el dólar blue hoy?» (paginas/01.txt)
- [+ 12.0s] 💬 JEF: El dólar blue cotiza a $1.540 para la compra y $1.560 para la venta.
- [+ 12.0s] 🔊 «El dólar blue cotiza a $1.540 para la compra y $1.560 para la venta.»
- [+ 12.0s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)]
- [+ 12.0s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [txt] www.google.com quiere utilizar tu ubicación actual
  2 [txt] Este sitio web utilizará tu ubicación exacta porque actualmente JEF tiene acceso a este dato.
  3 [btn] No permitir
  4 [btn] Permitir
```

## Paso 2 — toca el botón 1: «No permitir»


Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue cotiza a $1.540 para la compra y $1.560 para la venta.
  6 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 5 opciones.)
  7 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar
  8 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  9 [btn] Ver más opciones (4)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 28.2s] 💬 Persona: ¿y el oficial?
- [+ 33.3s] 💬 JEF: El dólar oficial figura a $1.490 para la compra y $1.540 para la venta, según Dolarhoy.com. La página también muestra otra cotización del dólar oficial de $1540,00, sin indicar el precio de compra.
- [+ 33.3s] 🔊 «El dólar oficial figura a $1.490 para la compra y $1.540 para la venta, según Dolarhoy.com. La página también muestra otra cotización del dólar oficial de $1540, sin indicar el precio de compra.»
- [+ 33.3s] 🔘 Botones: [¿Cuánto está el dólar tarjeta?] · [¿Cuánto está el dólar MEP?] · [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue cotiza a $1.540 para la compra y $1.560 para la venta.
  6 [H] Vos: ¿y el oficial?
  7 [txt] El dólar oficial figura a $1.490 para la compra y $1.540 para la venta, según Dolarhoy.com. La página también muestra otra cotización del dólar oficial de $1540,00, sin indicar el precio de compra.
  8 [btn] ¿Cuánto está el dólar tarjeta?  (Primera de 6 opciones.)
  9 [btn] ¿Cuánto está el dólar MEP?
 10 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com
 11 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar
 12 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
