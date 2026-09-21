# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.6s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.7s] 🔊 «Buscando: dólar blue hoy.»
- [+ 10.8s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.8s] 💬 JEF: Estás en los resultados de «dólar blue hoy». Los 3 más probables:
- [+ 10.8s] 🔊 «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 2. Cotización del dólar, dólar blue y mayorista - El Cronista, cronista.com. 3. Dólar Blue, Cotización del dólar Blue | Dolarhoy.com, dolarhoy.com»
- [+ 10.8s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)]
- [+ 10.8s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar  (Primera de 5 opciones.)
  6 [btn] Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com
  7 [btn] Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  8 [btn] Ver más opciones (4)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar»

- [+ 16.1s] 💬 Persona: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
- [+ 16.1s] 💬 JEF: Abriendo dolarinfohoy.com.ar.
- [+ 16.1s] 🔊 «Abriendo dolarinfohoy.com.ar.»
- [+ 19.0s] 📄 Cargó https://dolarinfohoy.com.ar/ — «Dólar Blue Hoy $1550 | Cotización en tiempo real» (paginas/02.txt)
- [+ 19.1s] 💬 JEF: En DolarInfoHoy.
- [+ 19.1s] 🔊 «En DolarInfoHoy.»
- [+ 20.7s] 💬 JEF: El dólar blue hoy se vende a $1.550,00 y se compra a $1.530,00.
- [+ 20.7s] 🔊 «El dólar blue hoy se vende a $1.550 y se compra a $1.530.»
- [+ 20.7s] 🔘 Botones: [¿Y el dólar oficial?] · [¿Y el MEP?] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy se vende a $1.550,00 y se compra a $1.530,00.
  9 [btn] ¿Y el dólar oficial?  (Primera de 5 opciones.)
 10 [btn] ¿Y el MEP?
 11 [btn] Leer la página
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 29.0s] 💬 Persona: ¿y el oficial?
- [+ 31.0s] 💬 JEF: El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. La última actualización fue el 21 de septiembre a las 11:03 hs.
- [+ 31.0s] 🔊 «El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. La última actualización fue el 21 de septiembre a las 11:03 hs.»
- [+ 31.0s] 🔘 Botones: [¿Y el MEP?] · [¿Y el CCL?] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy se vende a $1.550,00 y se compra a $1.530,00.
  9 [H] Vos: ¿y el oficial?
 10 [txt] El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. La última actualización fue el 21 de septiembre a las 11:03 hs.
 11 [btn] ¿Y el MEP?  (Primera de 5 opciones.)
 12 [btn] ¿Y el CCL?
 13 [btn] Leer la página
 14 [btn] Volver a la página anterior
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 17 [btn] Enviar
```
