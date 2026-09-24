# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.2s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.2s] 💬 JEF: Buscando: ¿a cuánto está el dólar blue hoy?.
- [+  6.2s] 🔊 «Buscando: ¿a cuánto está el dólar blue hoy?.»
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.6s] 📄 Cargó https://www.google.com/search?q=%C2%BFa%20cu%C3%A1nto%20est%C3%A1%20el%20d%C3%B3lar%20blue%20hoy%3F&gl=us&hl=es — «¿a cuánto está el dólar blue hoy?» (paginas/01.txt)
- [+ 12.8s] 💬 JEF: El dólar blue está a $1.540 para la compra y $1.560 para la venta.
- [+ 12.8s] 🔊 «El dólar blue está a $1.540 para la compra y $1.560 para la venta.»
- [+ 12.8s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Ver más opciones (4)]
- [+ 12.8s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar] · [Ver más opciones (4)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue está a $1.540 para la compra y $1.560 para la venta.
  6 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 5 opciones.)
  7 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  8 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 24 de septiembre — www.lanacion.com.ar
  9 [btn] Ver más opciones (4)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Cotización del dólar, dólar blue y mayorista — www.cronista.com»

- [+ 18.5s] 💬 Persona: Cotización del dólar, dólar blue y mayorista — www.cronista.com
- [+ 18.5s] 💬 JEF: Abriendo cronista.com.
- [+ 18.5s] 🔊 «Abriendo cronista.com.»
- [+ 21.2s] 📄 Cargó https://www.cronista.com/MercadosOnline/dolar.html — «Cotización del dólar, dólar blue y mayorista» (paginas/02.txt)
- [+ 24.2s] 💬 JEF: El Cronista muestra la cotización del dólar blue: se ofrece a $1.560,00 y se compra a $1.540,00; el cambio figura sin variación, con el dato actualizado a las 17:09 hs. Hay un aviso de privacidad que cubre la página.
- [+ 24.2s] 🔊 «El Cronista muestra la cotización del dólar blue: se ofrece a $1.560 y se compra a $1.540; el cambio figura sin variación, con el dato actualizado a las 17:09 hs. Hay un aviso de privacidad que cubre la página.»
- [+ 24.2s] 🔘 Botones: [Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»] · [Abrir «Monedas»]
- [+ 24.2s] 🔘 Botones: [“Centro de Privacidad”] · [Centro de Privacidad] · [De Acuerdo y Cerrar] · [Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»] · [Abrir «Monedas»]
- [+ 24.2s] 🔘 Botones: [“Centro de Privacidad”] · [Centro de Privacidad] · [De Acuerdo y Cerrar] · [Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»] · [Abrir «Monedas»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue está a $1.540 para la compra y $1.560 para la venta.
  6 [H] Vos: Cotización del dólar, dólar blue y mayorista — www.cronista.com
  7 [txt] Abriendo cronista.com.
  8 [txt] El Cronista muestra la cotización del dólar blue: se ofrece a $1.560,00 y se compra a $1.540,00; el cambio figura sin variación, con el dato actualizado a las 17:09 hs. Hay un aviso de privacidad que cubre la página.
  9 [btn] “Centro de Privacidad”  (Primera de 7 opciones.)
 10 [btn] Centro de Privacidad
 11 [btn] De Acuerdo y Cerrar
 12 [btn] Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»
 13 [btn] Abrir «Monedas»
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 31.9s] 💬 Persona: ¿y el oficial?
- [+ 36.6s] 💬 JEF: El dólar oficial del Banco Nación se vende a $1.540,00 y se compra a $1.490,00.
- [+ 36.6s] 🔊 «El dólar oficial del Banco Nación se vende a $1.540 y se compra a $1.490.»
- [+ 36.6s] 🔘 Botones: [Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»] · [Abrir «Monedas»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: ¿a cuánto está el dólar blue hoy?.
  5 [txt] El dólar blue está a $1.540 para la compra y $1.560 para la venta.
  6 [H] Vos: Cotización del dólar, dólar blue y mayorista — www.cronista.com
  7 [txt] Abriendo cronista.com.
  8 [txt] El Cronista muestra la cotización del dólar blue: se ofrece a $1.560,00 y se compra a $1.540,00; el cambio figura sin variación, con el dato actualizado a las 17:09 hs. Hay un aviso de privacidad que cubre la página.
  9 [H] Vos: ¿y el oficial?
 10 [txt] El dólar oficial del Banco Nación se vende a $1.540,00 y se compra a $1.490,00.
 11 [btn] Abrir «Dólar blue cotiza sin cambios: a cuánto se ofrece el jueves 24 de septiembre con el MEP y el CCL»  (Primera de 4 opciones.)
 12 [btn] Abrir «Monedas»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```
