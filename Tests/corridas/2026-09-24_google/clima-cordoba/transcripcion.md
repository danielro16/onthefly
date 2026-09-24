# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.4s] 💬 JEF: Buscando: el tiempo mañana en Córdoba.
- [+ 10.4s] 🔊 «Buscando: el tiempo mañana en Córdoba.»
- [+ 14.6s] 📄 Cargó https://www.google.com/search?q=el%20tiempo%20ma%C3%B1ana%20en%20C%C3%B3rdoba&gl=us&hl=es — «el tiempo mañana en Córdoba» (paginas/01.txt)
- [+ 17.6s] 💬 JEF: Según Google Clima, en Córdoba, España mañana viernes estará parcialmente soleado, con una máxima de 99 grados y una mínima de 64 grados. Ten en cuenta que la página también muestra resultados de Córdoba, Argentina, donde otros sitios como Meteored anuncian mañana soleado con entre 18 y 28 grados. Si querías la de Argentina, dime y te lo detallo.
- [+ 17.6s] 🔊 «Según Google Clima, en Córdoba, España mañana viernes estará parcialmente soleado, con una máxima de 99 grados y una mínima de 64 grados. Ten en cuenta que la página también muestra resultados de Córdoba, Argentina, donde otros sitios como Meteored anuncian mañana soleado con entre 18 y 28 grados. Si querías la de Argentina, dime y te lo detallo.»
- [+ 17.6s] 🔘 Botones: [El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es] · [El Tiempo en Córdoba (Argentina). Predicción a 14 días — www.tiempo.com] · [Clima en Córdoba hoy y pronóstico del tiempo a 14 días — www.clima.com] · [Ver más opciones (6)]
- [+ 17.6s] 🔘 Botones: [El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es] · [El Tiempo en Córdoba (Argentina). Predicción a 14 días — www.tiempo.com] · [Clima en Córdoba hoy y pronóstico del tiempo a 14 días — www.clima.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (20 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: el tiempo mañana en Córdoba.
  5 [txt] Según Google Clima, en Córdoba, España mañana viernes estará parcialmente soleado, con una máxima de 99 grados y una mínima de 64 grados. Ten en cuenta que la página también muestra resultados de Córdoba, Argentina, donde otros sitios como Meteored anuncian mañana soleado con entre 18 y 28 grados. Si querías la de Argentina, dime y te lo detallo.
  6 [btn] El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es  (Primera de 5 opciones.)
  7 [btn] El Tiempo en Córdoba (Argentina). Predicción a 14 días — www.tiempo.com
  8 [btn] Clima en Córdoba hoy y pronóstico del tiempo a 14 días — www.clima.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es»

- [+ 28.0s] 💬 Persona: El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es
- [+ 28.0s] 💬 JEF: Abriendo aemet.es.
- [+ 28.0s] 🔊 «Abriendo aemet.es.»
- [+ 30.5s] 📄 Cargó https://www.aemet.es/es/eltiempo/prediccion/municipios/cordoba-id14021 — «El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla - Agencia Estatal de Meteorología - AEMET. Gobierno de España» (paginas/02.txt)
- [+ 33.5s] 💬 JEF: Estás en la página de la Agencia Estatal de Meteorología con la predicción para Córdoba capital. Para mañana, viernes 25, la página da una mínima de 17 grados y una máxima de 39 grados, sin probabilidad de lluvia y con viento calmo. Hay un aviso de nivel bajo por temperaturas máximas para la Campiña cordobesa; la página muestra encima un aviso de uso de cookies.
- [+ 33.5s] 🔊 «Estás en la página de la Agencia Estatal de Meteorología con la predicción para Córdoba capital. Para mañana, viernes 25, la página da una mínima de 17 grados y una máxima de 39 grados, sin probabilidad de lluvia y con viento calmo. Hay un aviso de nivel bajo por temperaturas máximas para la Campiña cordobesa; la página muestra encima un aviso de uso de cookies.»
- [+ 33.5s] 🔘 Botones: [Leer la nota] · [Abrir «Ver tabla detallada»]
- [+ 33.5s] 🔘 Botones: [Leer la nota] · [Abrir «Ver tabla detallada»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: el tiempo mañana en Córdoba.
  5 [txt] Según Google Clima, en Córdoba, España mañana viernes estará parcialmente soleado, con una máxima de 99 grados y una mínima de 64 grados. Ten en cuenta que la página también muestra resultados de Córdoba, Argentina, donde otros sitios como Meteored anuncian mañana soleado con entre 18 y 28 grados. Si querías la de Argentina, dime y te lo detallo.
  6 [H] Vos: El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es
  7 [txt] Abriendo aemet.es.
  8 [txt] Estás en la página de la Agencia Estatal de Meteorología con la predicción para Córdoba capital. Para mañana, viernes 25, la página da una mínima de 17 grados y una máxima de 39 grados, sin probabilidad de lluvia y con viento calmo. Hay un aviso de nivel bajo por temperaturas máximas para la Campiña cordobesa; la página muestra encima un aviso de uso de cookies.
  9 [btn] Leer la nota  (Primera de 4 opciones.)
 10 [btn] Abrir «Ver tabla detallada»
 11 [btn] Volver a los resultados
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 42.8s] 💬 Persona: ¿va a llover?
- [+ 48.0s] 💬 JEF: Mañana viernes, 25 de septiembre, no va a llover en Córdoba: la probabilidad de precipitación es del 0%. El aviso para ese día es solo por temperaturas máximas, que llegarán a 39 grados.
- [+ 48.0s] 🔊 «Mañana viernes, 25 de septiembre, no va a llover en Córdoba: la probabilidad de precipitación es del 0%. El aviso para ese día es solo por temperaturas máximas, que llegarán a 39 grados.»
- [+ 48.0s] 🔘 Botones: [¿Y el sábado?] · [¿Qué temperatura hará mañana?] · [Leer la nota] · [Abrir «Ver tabla detallada»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: el tiempo mañana en Córdoba.
  5 [txt] Según Google Clima, en Córdoba, España mañana viernes estará parcialmente soleado, con una máxima de 99 grados y una mínima de 64 grados. Ten en cuenta que la página también muestra resultados de Córdoba, Argentina, donde otros sitios como Meteored anuncian mañana soleado con entre 18 y 28 grados. Si querías la de Argentina, dime y te lo detallo.
  6 [H] Vos: El Tiempo: Córdoba (Córdoba) - Predicción 7 días - Tabla — www.aemet.es
  7 [txt] Abriendo aemet.es.
  8 [txt] Estás en la página de la Agencia Estatal de Meteorología con la predicción para Córdoba capital. Para mañana, viernes 25, la página da una mínima de 17 grados y una máxima de 39 grados, sin probabilidad de lluvia y con viento calmo. Hay un aviso de nivel bajo por temperaturas máximas para la Campiña cordobesa; la página muestra encima un aviso de uso de cookies.
  9 [H] Vos: ¿va a llover?
 10 [txt] Mañana viernes, 25 de septiembre, no va a llover en Córdoba: la probabilidad de precipitación es del 0%. El aviso para ese día es solo por temperaturas máximas, que llegarán a 39 grados.
 11 [btn] ¿Y el sábado?  (Primera de 6 opciones.)
 12 [btn] ¿Qué temperatura hará mañana?
 13 [btn] Leer la nota
 14 [btn] Abrir «Ver tabla detallada»
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
