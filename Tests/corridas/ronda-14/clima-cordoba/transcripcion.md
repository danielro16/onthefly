# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 12.5s] 💬 JEF: Buscando: tiempo mañana córdoba.
- [+ 12.5s] 🔊 «Buscando: tiempo mañana córdoba.»
- [+ 15.6s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=tiempo%20ma%C3%B1ana%20c%C3%B3rdoba&kl=ar-es — «tiempo mañana córdoba at DuckDuckGo» (paginas/01.txt)
- [+ 15.6s] 💬 JEF: Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
- [+ 15.6s] 🔊 «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables: 1. El tiempo en Córdoba mañana - Meteored España, tiempo.com. 2. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com. 3. Tiempo en Córdoba mañana - Meteored Argentina, meteored.com.ar»
- [+ 15.6s] 🔘 Botones: [El tiempo en Córdoba mañana - Meteored España — www.tiempo.com] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Ver más opciones (5)]
- [+ 15.6s] 🔘 Botones: [El tiempo en Córdoba mañana - Meteored España — www.tiempo.com] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: tiempo mañana córdoba.
  5 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  6 [btn] El tiempo en Córdoba mañana - Meteored España — www.tiempo.com  (Primera de 5 opciones.)
  7 [btn] Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  8 [btn] Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  9 [btn] Ver más opciones (5)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «El tiempo en Córdoba mañana - Meteored España — www.tiempo.com»

- [+ 22.2s] 💬 Persona: El tiempo en Córdoba mañana - Meteored España — www.tiempo.com
- [+ 22.2s] 💬 JEF: Abriendo tiempo.com.
- [+ 22.2s] 🔊 «Abriendo tiempo.com.»
- [+ 25.7s] 📄 Cargó https://www.tiempo.com/cordoba/manana — «El tiempo en Córdoba mañana - Meteored España» (paginas/02.txt)
- [+ 25.7s] 💬 JEF: En tiempo.com.
- [+ 25.7s] 🔊 «En tiempo.com.»
- [+ 28.1s] 💬 JEF: Mañana en Córdoba el cielo va a estar soleado la mayor parte del día, con temperaturas de entre 19 °C y 37 °C, y el viento soplará desde el sur con rachas de hasta 24 km/h.
- [+ 28.1s] 🔊 «Mañana en Córdoba el cielo va a estar soleado la mayor parte del día, con temperaturas de entre 19 °C y 37 °C, y el viento soplará desde el sur con rachas de hasta 24 km/h.»
- [+ 28.1s] 🔘 Botones: [¿Qué va a pasar por la mañana?] · [Leer la nota] · [Resumir la nota] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: tiempo mañana córdoba.
  5 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  6 [H] Vos: El tiempo en Córdoba mañana - Meteored España — www.tiempo.com
  7 [txt] Abriendo tiempo.com.
  8 [txt] En tiempo.com.
  9 [txt] Mañana en Córdoba el cielo va a estar soleado la mayor parte del día, con temperaturas de entre 19 °C y 37 °C, y el viento soplará desde el sur con rachas de hasta 24 km/h.
 10 [btn] ¿Qué va a pasar por la mañana?  (Primera de 5 opciones.)
 11 [btn] Leer la nota
 12 [btn] Resumir la nota
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 35.3s] 💬 Persona: ¿va a llover?
- [+ 36.8s] 💬 JEF: No. Mañana va a estar soleado en Córdoba, con cielos despejados la mayor parte del día, aunque con algunas nubes de madrugada.
- [+ 36.8s] 🔊 «No. Mañana va a estar soleado en Córdoba, con cielos despejados la mayor parte del día, aunque con algunas nubes de madrugada.»
- [+ 36.8s] 🔘 Botones: [¿Qué temperatura va a hacer?] · [Leer la nota] · [Resumir la nota] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  4 [txt] Buscando: tiempo mañana córdoba.
  5 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  6 [H] Vos: El tiempo en Córdoba mañana - Meteored España — www.tiempo.com
  7 [txt] Abriendo tiempo.com.
  8 [txt] En tiempo.com.
  9 [txt] Mañana en Córdoba el cielo va a estar soleado la mayor parte del día, con temperaturas de entre 19 °C y 37 °C, y el viento soplará desde el sur con rachas de hasta 24 km/h.
 10 [H] Vos: ¿va a llover?
 11 [txt] No. Mañana va a estar soleado en Córdoba, con cielos despejados la mayor parte del día, aunque con algunas nubes de madrugada.
 12 [btn] ¿Qué temperatura va a hacer?  (Primera de 5 opciones.)
 13 [btn] Leer la nota
 14 [btn] Resumir la nota
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
