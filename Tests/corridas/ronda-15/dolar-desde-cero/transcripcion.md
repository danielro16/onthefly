# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.6s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.4s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.4s] 🔊 «Buscando: dólar blue hoy.»
- [+ 10.4s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+ 10.4s] 💬 JEF: Estás en los resultados de «dólar blue hoy». Los 3 más probables:
- [+ 10.4s] 🔊 «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar. 2. Dólar Blue, Cotización del dólar Blue | Dolarhoy.com, dolarhoy.com. 3. Cotización del dólar hoy, dólar blue | Ámbito, ambito.com»
- [+ 10.4s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Ver más opciones (6)]
- [+ 10.4s] 🔘 Botones: [Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar] · [Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [btn] Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar  (Primera de 5 opciones.)
  7 [btn] Dólar Blue, Cotización del dólar Blue | Dolarhoy.com — dolarhoy.com
  8 [btn] Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar»

- [+ 17.2s] 💬 Persona: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
- [+ 17.2s] 💬 JEF: Abriendo dolarinfohoy.com.ar.
- [+ 17.2s] 🔊 «Abriendo dolarinfohoy.com.ar.»
- [+ 20.4s] 📄 Cargó https://dolarinfohoy.com.ar/ — «Dólar Blue Hoy $1555 | Cotización en tiempo real» (paginas/02.txt)
- [+ 20.4s] 💬 JEF: En DolarInfoHoy.
- [+ 20.4s] 🔊 «En DolarInfoHoy.»
- [+ 21.8s] 💬 JEF: El dólar blue hoy se encuentra a $1.535,00 para la compra y $1.555,00 para la venta, según DolarInfoHoy actualizado a las 09:00 hs.
- [+ 21.8s] 🔊 «El dólar blue hoy se encuentra a $1.535 para la compra y $1.555 para la venta, según DolarInfoHoy actualizado a las 09:00 hs.»
- [+ 21.8s] 🔘 Botones: [¿Y el dólar oficial?] · [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  7 [txt] Abriendo dolarinfohoy.com.ar.
  8 [txt] En DolarInfoHoy.
  9 [txt] El dólar blue hoy se encuentra a $1.535,00 para la compra y $1.555,00 para la venta, según DolarInfoHoy actualizado a las 09:00 hs.
 10 [btn] ¿Y el dólar oficial?  (Primera de 5 opciones.)
 11 [btn] Leer la página
 12 [btn] Resumir la página
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 28.8s] 💬 Persona: ¿y el oficial?
- [+ 30.8s] 💬 JEF: El dólar oficial cotiza hoy a $1.482,07 para la compra y $1.533,87 para la venta, según los datos actualizados a las 08:43 hs en DolarInfoHoy.
- [+ 30.8s] 🔊 «El dólar oficial cotiza hoy a $1.482,07 para la compra y $1.533,87 para la venta, según los datos actualizados a las 08:43 hs en DolarInfoHoy.»
- [+ 30.8s] 🔘 Botones: [¿Y el dólar tarjeta?] · [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] Estás en los resultados de «dólar blue hoy». Los 3 más probables:
  6 [H] Vos: Dólar Blue Hoy $1550 | Cotización en tiempo real — dolarinfohoy.com.ar
  7 [txt] Abriendo dolarinfohoy.com.ar.
  8 [txt] En DolarInfoHoy.
  9 [txt] El dólar blue hoy se encuentra a $1.535,00 para la compra y $1.555,00 para la venta, según DolarInfoHoy actualizado a las 09:00 hs.
 10 [H] Vos: ¿y el oficial?
 11 [txt] El dólar oficial cotiza hoy a $1.482,07 para la compra y $1.533,87 para la venta, según los datos actualizados a las 08:43 hs en DolarInfoHoy.
 12 [btn] ¿Y el dólar tarjeta?  (Primera de 5 opciones.)
 13 [btn] Leer la página
 14 [btn] Resumir la página
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
