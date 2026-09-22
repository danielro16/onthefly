# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 💬 JEF: Buscando: clima mañana en córdoba.
- [+  7.8s] 🔊 «Buscando: clima mañana en córdoba.»
- [+ 12.8s] 📄 Cargó https://www.google.com/search?q=clima%20ma%C3%B1ana%20en%20c%C3%B3rdoba&gl=ar&hl=es — «clima mañana en córdoba - Buscar con Google» (paginas/01.txt)
- [+ 14.0s] 💬 JEF: Mañana miércoles será un día soleado en Córdoba, con una temperatura mínima de 9 °C y una máxima que llegará a los 28 °C.
- [+ 14.0s] 🔊 «Mañana miércoles será un día soleado en Córdoba, con una temperatura mínima de 9 °C y una máxima que llegará a los 28 °C.»
- [+ 14.0s] 🔘 Botones: [Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar] · [Tiempo diario en Córdoba, Córdoba, Argentina — www.accuweather.com] · [Tiempo en Córdoba mañana — www.meteored.com.ar] · [Ver más opciones (5)]
- [+ 14.0s] 🔘 Botones: [Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar] · [Tiempo diario en Córdoba, Córdoba, Argentina — www.accuweather.com] · [Tiempo en Córdoba mañana — www.meteored.com.ar] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: clima mañana en córdoba.
  5 [txt] Mañana miércoles será un día soleado en Córdoba, con una temperatura mínima de 9 °C y una máxima que llegará a los 28 °C.
  6 [btn] Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar  (Primera de 5 opciones.)
  7 [btn] Tiempo diario en Córdoba, Córdoba, Argentina — www.accuweather.com
  8 [btn] Tiempo en Córdoba mañana — www.meteored.com.ar
  9 [btn] Ver más opciones (5)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar»

- [+ 20.3s] 💬 Persona: Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar
- [+ 20.3s] 💬 JEF: Abriendo www.meteored.com.ar.
- [+ 20.3s] 🔊 «Abriendo www.meteored.com.ar.»
- [+ 24.9s] 📄 Cargó https://www.meteored.com.ar/tiempo-en_Cordoba-America+Sur-Argentina-Cordoba-SACO-1-13585.html — «Tiempo en Córdoba» (paginas/02.txt)
- [+ 25.9s] 💬 JEF: En Córdoba, mañana miércoles 23 de septiembre la temperatura máxima será de 27° y la mínima de 9°. Hay un aviso de cookies que cubre parte de la pantalla.
- [+ 25.9s] 🔊 «En Córdoba, mañana miércoles 23 de septiembre la temperatura máxima será de 27° y la mínima de 9°. Hay un aviso de cookies que cubre parte de la pantalla.»
- [+ 25.9s] 🔘 Botones: [Abrir «Por horas, Cielos despejados en las próximas horas»] · [Abrir «Más información»]
- [+ 25.9s] 🔘 Botones: [Completar «Introduce tu email»] · [Abrir «Por horas, Cielos despejados en las próximas horas»] · [Abrir «Más información»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: clima mañana en córdoba.
  5 [txt] Mañana miércoles será un día soleado en Córdoba, con una temperatura mínima de 9 °C y una máxima que llegará a los 28 °C.
  6 [H] Vos: Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar
  7 [txt] Abriendo www.meteored.com.ar.
  8 [txt] En Córdoba, mañana miércoles 23 de septiembre la temperatura máxima será de 27° y la mínima de 9°. Hay un aviso de cookies que cubre parte de la pantalla.
  9 [btn] Completar «Introduce tu email»  (Primera de 5 opciones.)
 10 [btn] Abrir «Por horas, Cielos despejados en las próximas horas»
 11 [btn] Abrir «Más información»
 12 [btn] Volver a los resultados
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 33.5s] 💬 Persona: ¿va a llover?
- [+ 35.5s] 💬 JEF: No, mañana no se esperan lluvias en Córdoba. El cielo estará despejado, aunque sí se prevé que empiece a llover a partir del próximo sábado.
- [+ 35.5s] 🔊 «No, mañana no se esperan lluvias en Córdoba. El cielo estará despejado, aunque sí se prevé que empiece a llover a partir del próximo sábado.»
- [+ 35.5s] 🔘 Botones: [¿Cómo estará el tiempo el fin de semana?] · [¿Qué temperatura hará el jueves?] · [Completar «Introduce tu email»] · [Leer la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: clima mañana en córdoba.
  5 [txt] Mañana miércoles será un día soleado en Córdoba, con una temperatura mínima de 9 °C y una máxima que llegará a los 28 °C.
  6 [H] Vos: Tiempo en Córdoba. Clima a 14 días — www.meteored.com.ar
  7 [txt] Abriendo www.meteored.com.ar.
  8 [txt] En Córdoba, mañana miércoles 23 de septiembre la temperatura máxima será de 27° y la mínima de 9°. Hay un aviso de cookies que cubre parte de la pantalla.
  9 [H] Vos: ¿va a llover?
 10 [txt] No, mañana no se esperan lluvias en Córdoba. El cielo estará despejado, aunque sí se prevé que empiece a llover a partir del próximo sábado.
 11 [btn] ¿Cómo estará el tiempo el fin de semana?  (Primera de 6 opciones.)
 12 [btn] ¿Qué temperatura hará el jueves?
 13 [btn] Completar «Introduce tu email»
 14 [btn] Leer la página
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
