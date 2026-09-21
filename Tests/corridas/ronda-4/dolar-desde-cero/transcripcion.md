# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.4s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 💬 JEF: Buscando: a cuánto está el dólar blue hoy.
- [+  7.2s] 🔊 «Buscando: a cuánto está el dólar blue hoy.»
- [+ 10.6s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=a%20cu%C3%A1nto%20est%C3%A1%20el%20d%C3%B3lar%20blue%20hoy&kl=ar-es — «a cuánto está el dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.6s] 💬 JEF: Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
- [+ 10.6s] 🔊 «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 2. Dólar Blue Hoy - Cotización del Dólar Paralelo en Argentina, dolarhoy.net. 3. La Cotización del Dólar Blue en Argentina | Actualizado hoy, valordolarblue.com.ar»
- [+ 10.6s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue Hoy - Cotización del Dólar Paralelo en Argentina — dolarhoy.net] · [La Cotización del Dólar Blue en Argentina | Actualizado hoy — www.valordolarblue.com.ar] · [Ver más opciones (3)]
- [+ 10.6s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue Hoy - Cotización del Dólar Paralelo en Argentina — dolarhoy.net] · [La Cotización del Dólar Blue en Argentina | Actualizado hoy — www.valordolarblue.com.ar] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar  (Primera de 5 opciones.)
  6 [btn] Dólar Blue Hoy - Cotización del Dólar Paralelo en Argentina — dolarhoy.net
  7 [btn] La Cotización del Dólar Blue en Argentina | Actualizado hoy — www.valordolarblue.com.ar
  8 [btn] Ver más opciones (3)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar»

- [+ 15.1s] 💬 Persona: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
- [+ 15.1s] 💬 JEF: Abriendo dolarinfohoy.com.ar.
- [+ 15.1s] 🔊 «Abriendo dolarinfohoy.com.ar.»
- [+ 18.2s] 📄 Cargó https://dolarinfohoy.com.ar/ — «Dólar Blue Hoy $1550 | Cotización en tiempo real» (paginas/02.txt)
- [+ 18.2s] 💬 JEF: En DolarInfoHoy.
- [+ 18.2s] 🔊 «En DolarInfoHoy.»
- [+ 19.5s] 💬 JEF: El dólar blue hoy tiene un valor de compra de $1.530,00 y de venta de $1.550,00.
- [+ 19.5s] 🔊 «El dólar blue hoy tiene un valor de compra de $1.530 y de venta de $1.550.»
- [+ 19.5s] 🔘 Botones: [¿Y el dólar oficial?] · [¿Hay variación?] · [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy tiene un valor de compra de $1.530,00 y de venta de $1.550,00.
  9 [btn] ¿Y el dólar oficial?  (Primera de 5 opciones.)
 10 [btn] ¿Hay variación?
 11 [btn] Leer la página
 12 [btn] Resumir la página
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 26.5s] 💬 Persona: ¿y el oficial?
- [+ 27.1s] 💬 JEF: Buscando: dólar blue oficial hoy.
- [+ 27.1s] 🔊 «Buscando: dólar blue oficial hoy.»
- [+ 29.6s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20oficial%20hoy&kl=ar-es — «dólar blue oficial hoy at DuckDuckGo» (paginas/03.txt)
- [+ 29.6s] 💬 JEF: Estás en los resultados de «dólar blue oficial hoy». Los 3 más probables:
- [+ 29.6s] 🔊 «Estás en los resultados de «dólar blue oficial hoy». Los 3 más probables: 1. Cotización del dólar, dólar blue y mayorista - El Cronista, cronista.com. 2. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 3. El Dólar Ahora | Dólar, finanzas y noticias económicas, eldolarahora.com»
- [+ 29.6s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [El Dólar Ahora | Dólar, finanzas y noticias económicas — www.eldolarahora.com] · [Ver más opciones (4)]
- [+ 29.6s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [El Dólar Ahora | Dólar, finanzas y noticias económicas — www.eldolarahora.com] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy tiene un valor de compra de $1.530,00 y de venta de $1.550,00.
  9 [H] Vos: ¿y el oficial?
 10 [txt] Buscando: dólar blue oficial hoy.
 11 [txt] Estás en los resultados de «dólar blue oficial hoy». Los 3 más probables:
 12 [btn] Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com  (Primera de 5 opciones.)
 13 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
 14 [btn] El Dólar Ahora | Dólar, finanzas y noticias económicas — www.eldolarahora.com
 15 [btn] Ver más opciones (4)
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 18 [btn] Enviar
```
