# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.5s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 💬 JEF: Buscando: a cuánto está el dólar blue hoy.
- [+  7.2s] 🔊 «Buscando: a cuánto está el dólar blue hoy.»
- [+ 10.3s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=a%20cu%C3%A1nto%20est%C3%A1%20el%20d%C3%B3lar%20blue%20hoy&kl=ar-es — «a cuánto está el dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.3s] 💬 JEF: Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
- [+ 10.3s] 🔊 «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 2. Dólar hoy - InfoDolar.com, infodolar.com. 3. Dólar hoy: blue, oficial, MEP y tarjeta, con el promedio ya…, chequea.ar»
- [+ 10.3s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar hoy - InfoDolar.com — www.infodolar.com] · [Dólar hoy: blue, oficial, MEP y tarjeta, con el promedio ya calculado ... — chequea.ar] · [Ver más opciones (4)]
- [+ 10.3s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar hoy - InfoDolar.com — www.infodolar.com] · [Dólar hoy: blue, oficial, MEP y tarjeta, con el promedio ya calculado ... — chequea.ar] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar  (Primera de 5 opciones.)
  6 [btn] Dólar hoy - InfoDolar.com — www.infodolar.com
  7 [btn] Dólar hoy: blue, oficial, MEP y tarjeta, con el promedio ya calculado ... — chequea.ar
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
- [+ 20.4s] 💬 JEF: El dólar blue hoy tiene un valor de venta de $1.550,00 y de compra de $1.530,00. No tuvo variación en el día.
- [+ 20.4s] 🔊 «El dólar blue hoy tiene un valor de venta de $1.550 y de compra de $1.530. No tuvo variación en el día.»
- [+ 20.4s] 🔘 Botones: [¿A cuánto está el dólar oficial?] · [¿Y el dólar MEP?] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy tiene un valor de venta de $1.550,00 y de compra de $1.530,00. No tuvo variación en el día.
  9 [btn] ¿A cuánto está el dólar oficial?  (Primera de 5 opciones.)
 10 [btn] ¿Y el dólar MEP?
 11 [btn] Leer la página
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 27.3s] 💬 Persona: ¿y el oficial?
- [+ 28.5s] 💬 JEF: La página no dice cuándo se fundó el dólar blue.
- [+ 28.5s] 🔊 «La página no dice cuándo se fundó el dólar blue.»
- [+ 28.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: a cuánto está el dólar blue hoy.
  4 [txt] Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:
  5 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  6 [txt] Abriendo dolarinfohoy.com.ar.
  7 [txt] En DolarInfoHoy.
  8 [txt] El dólar blue hoy tiene un valor de venta de $1.550,00 y de compra de $1.530,00. No tuvo variación en el día.
  9 [H] Vos: ¿y el oficial?
 10 [txt] La página no dice cuándo se fundó el dólar blue.
 11 [btn] Leer la página  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a la página anterior
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 16 [btn] Enviar
```
