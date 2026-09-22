# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.2s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.3s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.3s] 🔊 «Buscando: dólar blue hoy.»
- [+ 10.4s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.4s] 💬 JEF: Estás en los resultados de «dólar blue hoy». Los 3 más probables:
- [+ 10.4s] 🔊 «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue, Cotización del dólar Blue | Dolarhoy.com, dolarhoy.com. 2. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 3. Cotización del dólar, dólar blue y mayorista - El Cronista, cronista.com»
- [+ 10.4s] 🔘 Botones: [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (6)]
- [+ 10.4s] 🔘 Botones: [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [btn] Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com  (Primera de 5 opciones.)
  7 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  8 [btn] Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com»

- [+ 16.5s] 💬 Persona: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
- [+ 16.5s] 💬 JEF: Abriendo dolarhoy.com.
- [+ 16.5s] 🔊 «Abriendo dolarhoy.com.»
- [+ 19.3s] 📄 Cargó https://dolarhoy.com/cotizaciondolarblue — «Dólar Blue, Cotización del dólar Blue | Dolarhoy.com» (paginas/02.txt)
- [+ 19.3s] 💬 JEF: En Dolarhoy.com.
- [+ 19.3s] 🔊 «En Dolarhoy.com.»
- [+ 20.5s] 💬 JEF: El dólar blue hoy, o dólar libre, cotiza a $1.530,00 para la compra y $1.550,00 para la venta.
- [+ 20.5s] 🔊 «El dólar blue hoy, o dólar libre, cotiza a $1.530 para la compra y $1.550 para la venta.»
- [+ 20.5s] 🔘 Botones: [¿Y el dólar mayorista?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [H] Vos: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  7 [txt] Abriendo dolarhoy.com.
  8 [txt] En Dolarhoy.com.
  9 [txt] El dólar blue hoy, o dólar libre, cotiza a $1.530,00 para la compra y $1.550,00 para la venta.
 10 [btn] ¿Y el dólar mayorista?  (Primera de 5 opciones.)
 11 [btn] Leer los titulares
 12 [btn] Resumir la portada
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 27.8s] 💬 Persona: ¿y el oficial?
- [+ 29.8s] 💬 JEF: La página no muestra la cotización del dólar oficial. Te puedo decir el Dólar Mayorista, que está a $1.438,00 para la compra y $1.439,00 para la venta. Este dato está actualizado a ayer a las 12:18 AM.
- [+ 29.8s] 🔊 «La página no muestra la cotización del dólar oficial. Te puedo decir el Dólar Mayorista, que está a $1.438 para la compra y $1.439 para la venta. Este dato está actualizado a ayer a las 12:18 AM.»
- [+ 29.8s] 🔘 Botones: [¿Qué otras cotizaciones hay?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [H] Vos: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  7 [txt] Abriendo dolarhoy.com.
  8 [txt] En Dolarhoy.com.
  9 [txt] El dólar blue hoy, o dólar libre, cotiza a $1.530,00 para la compra y $1.550,00 para la venta.
 10 [H] Vos: ¿y el oficial?
 11 [txt] La página no muestra la cotización del dólar oficial. Te puedo decir el Dólar Mayorista, que está a $1.438,00 para la compra y $1.439,00 para la venta. Este dato está actualizado a ayer a las 12:18 AM.
 12 [btn] ¿Qué otras cotizaciones hay?  (Primera de 5 opciones.)
 13 [btn] Leer los titulares
 14 [btn] Resumir la portada
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
