# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Buscando: tiempo mañana córdoba.
- [+  7.5s] 🔊 «Buscando: tiempo mañana córdoba.»
- [+ 10.7s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=tiempo%20ma%C3%B1ana%20c%C3%B3rdoba&kl=ar-es — «tiempo mañana córdoba at DuckDuckGo» (paginas/01.txt)
- [+ 10.7s] 💬 JEF: Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
- [+ 10.7s] 🔊 «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables: 1. Tiempo en Córdoba mañana - Meteored Argentina, meteored.com.ar. 2. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com. 3. Tiempo cada hora en Cordoba, Córdoba, Argentina |…, accuweather.com»
- [+ 10.7s] 🔘 Botones: [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo cada hora en Cordoba, Córdoba, Argentina | AccuWeather — www.accuweather.com] · [Ver más opciones (3)]
- [+ 10.7s] 🔘 Botones: [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo cada hora en Cordoba, Córdoba, Argentina | AccuWeather — www.accuweather.com] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [btn] Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar  (Primera de 5 opciones.)
  6 [btn] Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  7 [btn] Tiempo cada hora en Cordoba, Córdoba, Argentina | AccuWeather — www.accuweather.com
  8 [btn] Ver más opciones (3)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar»

- [+ 16.1s] 💬 Persona: Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
- [+ 16.1s] 💬 JEF: Abriendo meteored.com.ar.
- [+ 16.1s] 🔊 «Abriendo meteored.com.ar.»
- [+ 19.1s] 📄 Cargó https://www.meteored.com.ar/manana/tiempo-en_Cordoba-America+Sur-Argentina-Cordoba-SACO-1-13585.html — «Tiempo en Córdoba mañana - Meteored Argentina» (paginas/02.txt)
- [+ 19.1s] 💬 JEF: En meteored.com.ar.
- [+ 19.1s] 🔊 «En meteored.com.ar.»
- [+ 20.9s] 💬 JEF: Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque con algunas nubes de madrugada. La temperatura va a ir de 7°C a 19°C, y la máxima se va a alcanzar alrededor de las 16:00. El viento va a ser moderado del norte, con rachas de hasta 35 km/h por la noche.
- [+ 20.9s] 🔊 «Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque con algunas nubes de madrugada. La temperatura va a ir de 7°C a 19°C, y la máxima se va a alcanzar alrededor de las 16:00. El viento va a ser moderado del norte, con rachas de hasta 35 km/h por la noche.»
- [+ 20.9s] 🔘 Botones: [¿A qué hora sale el sol?] · [¿Cómo estará la temperatura por la noche?] · [Leer la nota] · [Resumir la nota] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  6 [txt] Abriendo meteored.com.ar.
  7 [txt] En meteored.com.ar.
  8 [txt] Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque con algunas nubes de madrugada. La temperatura va a ir de 7°C a 19°C, y la máxima se va a alcanzar alrededor de las 16:00. El viento va a ser moderado del norte, con rachas de hasta 35 km/h por la noche.
  9 [btn] ¿A qué hora sale el sol?  (Primera de 5 opciones.)
 10 [btn] ¿Cómo estará la temperatura por la noche?
 11 [btn] Leer la nota
 12 [btn] Resumir la nota
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 29.1s] 💬 Persona: ¿va a llover?
- [+ 30.7s] 💬 JEF: No va a llover. Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque la madrugada estará nubosa.
- [+ 30.7s] 🔊 «No va a llover. Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque la madrugada estará nubosa.»
- [+ 30.7s] 🔘 Botones: [¿Qué temperaturas habrá?] · [¿Cómo va a estar el viento?] · [Leer la nota] · [Resumir la nota] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  6 [txt] Abriendo meteored.com.ar.
  7 [txt] En meteored.com.ar.
  8 [txt] Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque con algunas nubes de madrugada. La temperatura va a ir de 7°C a 19°C, y la máxima se va a alcanzar alrededor de las 16:00. El viento va a ser moderado del norte, con rachas de hasta 35 km/h por la noche.
  9 [H] Vos: ¿va a llover?
 10 [txt] No va a llover. Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados, aunque la madrugada estará nubosa.
 11 [btn] ¿Qué temperaturas habrá?  (Primera de 5 opciones.)
 12 [btn] ¿Cómo va a estar el viento?
 13 [btn] Leer la nota
 14 [btn] Resumir la nota
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 17 [btn] Enviar
```
