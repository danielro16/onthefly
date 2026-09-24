# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.3s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.3s] 💬 JEF: Buscando: ¿a cuánto está el dólar blue hoy?.
- [+  6.3s] 🔊 «Buscando: ¿a cuánto está el dólar blue hoy?.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.4s] 📄 Cargó https://www.google.com/search?q=%C2%BFa%20cu%C3%A1nto%20est%C3%A1%20el%20d%C3%B3lar%20blue%20hoy%3F&gl=us&hl=es — «¿a cuánto está el dólar blue hoy?» (paginas/01.txt)
- [+ 11.9s] 💬 JEF: El dólar blue está a $1.540 para la compra y $1.560 para la venta.
- [+ 11.9s] 🔊 «El dólar blue está a $1.540 para la compra y $1.560 para la venta.»
- [+ 11.9s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)]
- [+ 11.9s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
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
  5 [txt] El dólar blue está a $1.540 para la compra y $1.560 para la venta.
  6 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 5 opciones.)
  7 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar
  8 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  9 [btn] Ver más opciones (4)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 29.2s] 💬 Persona: ¿y el oficial?
- [+ 33.7s] 💬 JEF: El dólar oficial figura a $1.490 para la compra y $1.540 para la venta.
- [+ 33.7s] 🔊 «El dólar oficial figura a $1.490 para la compra y $1.540 para la venta.»
- [+ 33.7s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue está a $1.540 para la compra y $1.560 para la venta.
  6 [H] Vos: ¿y el oficial?
  7 [txt] El dólar oficial figura a $1.490 para la compra y $1.540 para la venta.
  8 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 4 opciones.)
  9 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar
 10 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
