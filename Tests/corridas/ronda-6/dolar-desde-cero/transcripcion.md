# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.3s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.5s] 🔊 «Buscando: dólar blue hoy.»
- [+ 10.6s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.6s] 💬 JEF: Estás en los resultados de «dólar blue hoy». Los 3 más probables:
- [+ 10.6s] 🔊 «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue, Cotización del dólar Blue | Dolarhoy.com, dolarhoy.com. 2. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 3. Cotización del dólar, dólar blue y mayorista - El Cronista, cronista.com»
- [+ 10.6s] 🔘 Botones: [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (5)]
- [+ 10.6s] 🔘 Botones: [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [btn] Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com  (Primera de 5 opciones.)
  6 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  7 [btn] Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com
  8 [btn] Ver más opciones (5)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com»

- [+ 15.9s] 💬 Persona: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
- [+ 15.9s] 💬 JEF: Abriendo dolarhoy.com.
- [+ 15.9s] 🔊 «Abriendo dolarhoy.com.»
- [+ 18.7s] 📄 Cargó https://dolarhoy.com/cotizaciondolarblue — «Dólar Blue, Cotización del dólar Blue | Dolarhoy.com» (paginas/02.txt)
- [+ 18.7s] 💬 JEF: En Dolarhoy.com.
- [+ 18.7s] 🔊 «En Dolarhoy.com.»
- [+ 20.1s] 💬 JEF: El dólar blue hoy está a $1.530,00 para la compra y $1.550,00 para la venta. Esta cotización se actualizó por última vez el 21/09/26 a las 05:28 PM.
- [+ 20.1s] 🔊 «El dólar blue hoy está a $1.530 para la compra y $1.550 para la venta. Esta cotización se actualizó por última vez el 21/09/26 a las 05:28 PM.»
- [+ 20.1s] 🔘 Botones: [¿A cuánto está el dólar mayorista?] · [¿A cuánto está el dólar MEP?] · [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  6 [txt] Abriendo dolarhoy.com.
  7 [txt] En Dolarhoy.com.
  8 [txt] El dólar blue hoy está a $1.530,00 para la compra y $1.550,00 para la venta. Esta cotización se actualizó por última vez el 21/09/26 a las 05:28 PM.
  9 [btn] ¿A cuánto está el dólar mayorista?  (Primera de 5 opciones.)
 10 [btn] ¿A cuánto está el dólar MEP?
 11 [btn] Leer los titulares
 12 [btn] Resumir la portada
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 27.1s] 💬 Persona: ¿y el oficial?
- [+ 28.9s] 💬 JEF: Buscando: Dólar oficial Dolarhoy.com.
- [+ 28.9s] 🔊 «Buscando: Dólar oficial Dolarhoy.com.»
- [+ 31.6s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=D%C3%B3lar%20oficial%20Dolarhoy%2Ecom&kl=ar-es — «Dólar oficial Dolarhoy.com at DuckDuckGo» (paginas/03.txt)
- [+ 31.6s] 💬 JEF: Estás en los resultados de «Dólar oficial Dolarhoy.com». Los 3 más probables:
- [+ 31.6s] 🔊 «Estás en los resultados de «Dólar oficial Dolarhoy.com». Los 3 más probables: 1. Dólar Oficial, Cotización del dólar oficial | Dolarhoy.com, dolarhoy.com. 2. Dólar Oficial Hoy | Cotización en tiempo real — DolarInfoHoy, dolarinfohoy.com.ar. 3. Dólar Oficial Hoy en Argentina - BCRA Cotización…, dolarhoy.net»
- [+ 31.6s] 🔘 Botones: [Dólar Oficial, Cotización del dólar oficial | Dolarhoy.com — dolarhoy.com] · [Dólar Oficial Hoy | Cotización en tiempo real — DolarInfoHoy — dolarinfohoy.com.ar] · [Dólar Oficial Hoy en Argentina - BCRA Cotización - dolarhoy.net — dolarhoy.net] · [Ver más opciones (2)]
- [+ 31.6s] 🔘 Botones: [Dólar Oficial, Cotización del dólar oficial | Dolarhoy.com — dolarhoy.com] · [Dólar Oficial Hoy | Cotización en tiempo real — DolarInfoHoy — dolarinfohoy.com.ar] · [Dólar Oficial Hoy en Argentina - BCRA Cotización - dolarhoy.net — dolarhoy.net] · [Ver más opciones (2)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  6 [txt] Abriendo dolarhoy.com.
  7 [txt] En Dolarhoy.com.
  8 [txt] El dólar blue hoy está a $1.530,00 para la compra y $1.550,00 para la venta. Esta cotización se actualizó por última vez el 21/09/26 a las 05:28 PM.
  9 [H] Vos: ¿y el oficial?
 10 [txt] Buscando: Dólar oficial Dolarhoy.com.
 11 [txt] Estás en los resultados de «Dólar oficial Dolarhoy.com». Los 3 más probables:
 12 [btn] Dólar Oficial, Cotización del dólar oficial | Dolarhoy.com — dolarhoy.com  (Primera de 5 opciones.)
 13 [btn] Dólar Oficial Hoy | Cotización en tiempo real — DolarInfoHoy — dolarinfohoy.com.ar
 14 [btn] Dólar Oficial Hoy en Argentina - BCRA Cotización - dolarhoy.net — dolarhoy.net
 15 [btn] Ver más opciones (2)
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 18 [btn] Enviar
```
