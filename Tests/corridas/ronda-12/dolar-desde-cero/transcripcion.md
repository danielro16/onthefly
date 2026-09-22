# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.5s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.5s] 🔊 «Buscando: dólar blue hoy.»
- [+ 10.5s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en los resultados de «dólar blue hoy». Los 3 más probables:
- [+ 10.5s] 🔊 «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 2. Dólar Blue, Cotización del dólar Blue | Dolarhoy.com, dolarhoy.com. 3. Cotización del dólar, dólar blue y mayorista - El Cronista, cronista.com»
- [+ 10.5s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (3)]
- [+ 10.5s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar  (Primera de 5 opciones.)
  6 [btn] Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  7 [btn] Cotización del dólar, dólar blue y mayorista - El Cronista — www.cronista.com
  8 [btn] Ver más opciones (3)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar»

- [+ 16.1s] 💬 Persona: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
- [+ 16.1s] 💬 JEF: Abriendo dolarinfohoy.com.ar.
- [+ 16.1s] 🔊 «Abriendo dolarinfohoy.com.ar.»
- [+ 19.0s] 📄 Cargó https://dolarinfohoy.com.ar/ — «Dólar Blue Hoy $1550 | Cotización en tiempo real» (paginas/02.txt)
- [+ 19.0s] 💬 JEF: En DolarInfoHoy.
- [+ 19.0s] 🔊 «En DolarInfoHoy.»
- [+ 20.3s] 💬 JEF: El dólar blue hoy se compra a $1.530,00 y se vende a $1.550,00, actualizado a las 15:00 de hoy.
- [+ 20.3s] 🔊 «El dólar blue hoy se compra a $1.530 y se vende a $1.550, actualizado a las 15:00 de hoy.»
- [+ 20.3s] 🔘 Botones: [¿A cuánto está el dólar oficial?] · [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy se compra a $1.530,00 y se vende a $1.550,00, actualizado a las 15:00 de hoy.
  9 [btn] ¿A cuánto está el dólar oficial?  (Primera de 5 opciones.)
 10 [btn] Leer la página
 11 [btn] Resumir la página
 12 [btn] Volver a los resultados
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 27.4s] 💬 Persona: ¿y el oficial?
- [+ 29.0s] 💬 JEF: El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. Se actualizó hoy a las 11:03.
- [+ 29.0s] 🔊 «El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. Se actualizó hoy a las 11:03.»
- [+ 29.0s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy se compra a $1.530,00 y se vende a $1.550,00, actualizado a las 15:00 de hoy.
  9 [H] Vos: ¿y el oficial?
 10 [txt] El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. Se actualizó hoy a las 11:03.
 11 [btn] Leer la página  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```
