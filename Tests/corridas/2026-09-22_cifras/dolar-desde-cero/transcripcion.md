# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.5s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Buscando: dólar blue hoy en Buenos Aires.
- [+  7.7s] 🔊 «Buscando: dólar blue hoy en Buenos Aires.»
- [+ 12.3s] 📄 Cargó https://www.google.com/search?q=d%C3%B3lar%20blue%20hoy%20en%20Buenos%20Aires&gl=ar&hl=es — «dólar blue hoy en Buenos Aires» (paginas/01.txt)
- [+ 13.4s] 💬 JEF: El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.
- [+ 13.4s] 🔊 «El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.»
- [+ 13.4s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 22 de septiembre — www.lanacion.com.ar] · [Ver más opciones (5)]
- [+ 13.4s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 22 de septiembre — www.lanacion.com.ar] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy en Buenos Aires.
  5 [txt] El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.
  6 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 5 opciones.)
  7 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  8 [btn] Últimas noticias de Cotización del Dólar Hoy, Precio del Dólar el 22 de septiembre — www.lanacion.com.ar
  9 [btn] Ver más opciones (5)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Cotización del dólar, dólar blue y mayorista — www.cronista.com»

- [+ 18.5s] 💬 Persona: Cotización del dólar, dólar blue y mayorista — www.cronista.com
- [+ 18.5s] 💬 JEF: Abriendo www.cronista.com.
- [+ 18.5s] 🔊 «Abriendo www.cronista.com.»
- [+ 22.6s] 📄 Cargó https://www.cronista.com/MercadosOnline/dolar.html — «Cotización del dólar, dólar blue y mayorista» (paginas/02.txt)
- [+ 23.8s] 💬 JEF: Estás en la sección de cotizaciones del dólar en El Cronista, donde el dólar blue cotiza a $ 1.555. Los titulares principales son las primeras opciones.
- [+ 23.8s] 🔊 «Estás en la sección de cotizaciones del dólar en El Cronista, donde el dólar blue cotiza a $ 1.555. Los titulares principales: 1. Dólar Tarjeta $ 1.995,5 0.00%. 2. Dólar MEP $ 1.536,36 0.32%. 3. Dólar hoy y dólar blue hoy: cuál es la cotización del martes 22 de septiembre minuto a minuto. 4. La cosecha de dólares: qué cultivos liderarán las exportaciones en 2027.»
- [+ 23.8s] 🔘 Botones: [Abrir «Dólar Tarjeta $ 1.995,5 0.00%»] · [Abrir «Dólar MEP $ 1.536,36 0.32%»] · [Abrir «Dólar hoy y dólar blue hoy: cuál es la cotización del martes 22 de septiembre minuto a minuto»] · [Abrir «La cosecha de dólares: qué cultivos liderarán las exportaciones en 2027»]
- [+ 23.8s] 🔘 Botones: [Abrir «Dólar Tarjeta $ 1.995,5 0.00%»] · [Abrir «Dólar MEP $ 1.536,36 0.32%»] · [Abrir «Dólar hoy y dólar blue hoy: cuál es la cotización del martes 22 de septiembre minuto a minuto»] · [Abrir «La cosecha de dólares: qué cultivos liderarán las exportaciones en 2027»] · [Volver a los resultados] · [Otra cosa]
- [+ 23.9s] 📄 Cargó https://www.cronista.com/MercadosOnline/dolar.html — «Cotización del dólar, dólar blue y mayorista» (paginas/03.txt)

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy en Buenos Aires.
  5 [txt] El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.
  6 [H] Vos: Cotización del dólar, dólar blue y mayorista — www.cronista.com
  7 [txt] Abriendo www.cronista.com.
  8 [txt] Estás en la sección de cotizaciones del dólar en El Cronista, donde el dólar blue cotiza a $ 1.555. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Dólar Tarjeta $ 1.995,5 0.00%»  (Primera de 6 opciones.)
 10 [btn] Abrir «Dólar MEP $ 1.536,36 0.32%»
 11 [btn] Abrir «Dólar hoy y dólar blue hoy: cuál es la cotización del martes 22 de septiembre minuto a minuto»
 12 [btn] Abrir «La cosecha de dólares: qué cultivos liderarán las exportaciones en 2027»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 31.7s] 💬 Persona: ¿y el oficial?
- [+ 34.3s] 💬 JEF: El dólar oficial en el Banco Nación cotiza a $1.485 para la compra y $1.535 para la venta, actualizado a las 13:15 hs.
- [+ 34.3s] 🔊 «El dólar oficial en el Banco Nación cotiza a $1.485 para la compra y $1.535 para la venta, actualizado a las 13:15 hs.»
- [+ 34.3s] 🔘 Botones: [¿A cuánto está el CCL?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy en Buenos Aires.
  5 [txt] El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.
  6 [H] Vos: Cotización del dólar, dólar blue y mayorista — www.cronista.com
  7 [txt] Abriendo www.cronista.com.
  8 [txt] Estás en la sección de cotizaciones del dólar en El Cronista, donde el dólar blue cotiza a $ 1.555. Los titulares principales son las primeras opciones.
  9 [H] Vos: ¿y el oficial?
 10 [txt] El dólar oficial en el Banco Nación cotiza a $1.485 para la compra y $1.535 para la venta, actualizado a las 13:15 hs.
 11 [btn] ¿A cuánto está el CCL?  (Primera de 5 opciones.)
 12 [btn] Leer los titulares
 13 [btn] Resumir la portada
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
