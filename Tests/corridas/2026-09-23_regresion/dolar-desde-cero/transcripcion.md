# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  6.6s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 💬 JEF: Buscando: dólar blue hoy.
- [+  7.8s] 🔊 «Buscando: dólar blue hoy.»
- [+ 11.6s] 📄 Cargó https://www.google.com/search?q=d%C3%B3lar%20blue%20hoy&gl=us&hl=es — «dólar blue hoy - Buscar con Google» (paginas/01.txt)
- [+ 13.2s] 💬 JEF: El dólar blue cotiza hoy a $1.560 para la venta según los resultados de búsqueda más recientes en Google. Algunas fuentes también registran un valor de compra de $1.540.
- [+ 13.2s] 🔊 «El dólar blue cotiza hoy a $1.560 para la venta según los resultados de búsqueda más recientes en Google. Algunas fuentes también registran un valor de compra de $1.540.»
- [+ 13.3s] 🔘 Botones: [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Ver más opciones (2)]
- [+ 13.3s] 🔘 Botones: [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Ver más opciones (2)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] El dólar blue cotiza hoy a $1.560 para la venta según los resultados de búsqueda más recientes en Google. Algunas fuentes también registran un valor de compra de $1.540.
  6 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com  (Primera de 5 opciones.)
  7 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com
  8 [btn] Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com
  9 [btn] Ver más opciones (2)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com»

- [+ 21.4s] 💬 Persona: Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
- [+ 21.4s] 💬 JEF: Abriendo dolarhoy.com.
- [+ 21.4s] 🔊 «Abriendo dolarhoy.com.»
- [+ 25.1s] 📄 Cargó https://dolarhoy.com/ — «Dólar hoy, Cotización del dólar | Dolarhoy.com» (paginas/02.txt)
- [+ 26.8s] 💬 JEF: El dólar blue hoy tiene una cotización de 1.540 pesos para la compra y 1.560 pesos para la venta. Los titulares principales son las primeras opciones.
- [+ 26.8s] 🔊 «El dólar blue hoy tiene una cotización de 1.540 pesos para la compra y 1.560 pesos para la venta. Los titulares principales: 1. Los bonos argentinos vuelven a caer y el riesgo país encadena ocho jornadas en alza. 2. Cedears: Microsoft aumentó su dividendo en dólares un 8% y su renta se volvió atractiva. 3. Alerta en PBA: se perdieron 106.000 empleos y cerraron más de 8.400 empresas desde 2023. 4. Apple se acerca a USD 5 billones: el récord que celebra John Ternus.»
- [+ 26.8s] 🔘 Botones: [Abrir «Los bonos argentinos vuelven a caer y el riesgo país encadena ocho jornadas en alza»] · [Abrir «Cedears: Microsoft aumentó su dividendo en dólares un 8% y su renta se volvió atractiva»] · [Abrir «Alerta en PBA: se perdieron 106.000 empleos y cerraron más de 8.400 empresas desde 2023»] · [Abrir «Apple se acerca a USD 5 billones: el récord que celebra John Ternus»]
- [+ 26.8s] 🔘 Botones: [Abrir «Los bonos argentinos vuelven a caer y el riesgo país encadena ocho jornadas en alza»] · [Abrir «Cedears: Microsoft aumentó su dividendo en dólares un 8% y su renta se volvió atractiva»] · [Abrir «Alerta en PBA: se perdieron 106.000 empleos y cerraron más de 8.400 empresas desde 2023»] · [Abrir «Apple se acerca a USD 5 billones: el récord que celebra John Ternus»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] El dólar blue cotiza hoy a $1.560 para la venta según los resultados de búsqueda más recientes en Google. Algunas fuentes también registran un valor de compra de $1.540.
  6 [H] Vos: Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  7 [txt] Abriendo dolarhoy.com.
  8 [txt] El dólar blue hoy tiene una cotización de 1.540 pesos para la compra y 1.560 pesos para la venta. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Los bonos argentinos vuelven a caer y el riesgo país encadena ocho jornadas en alza»  (Primera de 6 opciones.)
 10 [btn] Abrir «Cedears: Microsoft aumentó su dividendo en dólares un 8% y su renta se volvió atractiva»
 11 [btn] Abrir «Alerta en PBA: se perdieron 106.000 empleos y cerraron más de 8.400 empresas desde 2023»
 12 [btn] Abrir «Apple se acerca a USD 5 billones: el récord que celebra John Ternus»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 34.5s] 💬 Persona: ¿y el oficial?
- [+ 38.7s] 💬 JEF: El dólar oficial cotiza hoy a $1.485 para la compra y $1.535 para la venta.
- [+ 38.7s] 🔊 «El dólar oficial cotiza hoy a $1.485 para la compra y $1.535 para la venta.»
- [+ 38.7s] 🔘 Botones: [¿Cuál es el valor del dólar MEP hoy?] · [¿Cuánto cotiza el dólar tarjeta?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿a cuánto está el dólar blue hoy?
  4 [txt] Buscando: dólar blue hoy.
  5 [txt] El dólar blue cotiza hoy a $1.560 para la venta según los resultados de búsqueda más recientes en Google. Algunas fuentes también registran un valor de compra de $1.540.
  6 [H] Vos: Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
  7 [txt] Abriendo dolarhoy.com.
  8 [txt] El dólar blue hoy tiene una cotización de 1.540 pesos para la compra y 1.560 pesos para la venta. Los titulares principales son las primeras opciones.
  9 [H] Vos: ¿y el oficial?
 10 [txt] El dólar oficial cotiza hoy a $1.485 para la compra y $1.535 para la venta.
 11 [btn] ¿Cuál es el valor del dólar MEP hoy?  (Primera de 6 opciones.)
 12 [btn] ¿Cuánto cotiza el dólar tarjeta?
 13 [btn] Leer los titulares
 14 [btn] Resumir la portada
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
