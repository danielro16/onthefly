# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.4s] 💬 JEF: Buscando: tiempo mañana córdoba.
- [+  7.4s] 🔊 «Buscando: tiempo mañana córdoba.»
- [+ 10.5s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=tiempo%20ma%C3%B1ana%20c%C3%B3rdoba&kl=ar-es — «tiempo mañana córdoba at DuckDuckGo» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
- [+ 10.5s] 🔊 «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables: 1. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com. 2. Tiempo en Córdoba mañana - Meteored Argentina, meteored.com.ar. 3. Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo…, xn--tiempomaana-8db.net»
- [+ 10.5s] 🔘 Botones: [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.xn--tiempomaana-8db.net] · [Ver más opciones (5)]
- [+ 10.5s] 🔘 Botones: [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.xn--tiempomaana-8db.net] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [btn] Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com  (Primera de 5 opciones.)
  6 [btn] Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  7 [btn] Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.xn--tiempomaana-8db.net
  8 [btn] Ver más opciones (5)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com»

- [+ 16.1s] 💬 Persona: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
- [+ 16.1s] 💬 JEF: Abriendo eltiempoen.com.
- [+ 16.1s] 🔊 «Abriendo eltiempoen.com.»
- [+ 18.9s] 📄 Cargó https://eltiempoen.com/argentina/cordoba/cordoba/manana — «Clima mañana en Córdoba, Cordoba» (paginas/02.txt)
- [+ 18.9s] 💬 JEF: En eltiempoen.com.
- [+ 18.9s] 🔊 «En eltiempoen.com.»
- [+ 20.4s] 💬 JEF: Mañana en Córdoba se espera un clima nublado con una probabilidad de lluvia del 0%. La temperatura máxima será de 17 °C y la mínima de 4 °C. El viento soplará desde el noreste a una velocidad media de 21 km/h.
- [+ 20.4s] 🔊 «Mañana en Córdoba se espera un clima nublado con una probabilidad de lluvia del 0%. La temperatura máxima será de 17 °C y la mínima de 4 °C. El viento soplará desde el noreste a una velocidad media de 21 km/h.»
- [+ 20.4s] 🔘 Botones: [¿A qué hora amanece y atardece?] · [Completar «Selecionar localidad»] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  6 [txt] Abriendo eltiempoen.com.
  7 [txt] En eltiempoen.com.
  8 [txt] Mañana en Córdoba se espera un clima nublado con una probabilidad de lluvia del 0%. La temperatura máxima será de 17 °C y la mínima de 4 °C. El viento soplará desde el noreste a una velocidad media de 21 km/h.
  9 [btn] ¿A qué hora amanece y atardece?  (Primera de 5 opciones.)
 10 [btn] Completar «Selecionar localidad»
 11 [btn] Leer la página
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 27.3s] 💬 Persona: ¿va a llover?
- [+ 28.8s] 💬 JEF: No, la probabilidad de lluvia para mañana en Córdoba es del 0%.
- [+ 28.8s] 🔊 «No, la probabilidad de lluvia para mañana en Córdoba es del 0%.»
- [+ 28.8s] 🔘 Botones: [¿Qué clima hará?] · [¿Y cómo es el viento?] · [Completar «Selecionar localidad»] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  6 [txt] Abriendo eltiempoen.com.
  7 [txt] En eltiempoen.com.
  8 [txt] Mañana en Córdoba se espera un clima nublado con una probabilidad de lluvia del 0%. La temperatura máxima será de 17 °C y la mínima de 4 °C. El viento soplará desde el noreste a una velocidad media de 21 km/h.
  9 [H] Vos: ¿va a llover?
 10 [txt] No, la probabilidad de lluvia para mañana en Córdoba es del 0%.
 11 [btn] ¿Qué clima hará?  (Primera de 6 opciones.)
 12 [btn] ¿Y cómo es el viento?
 13 [btn] Completar «Selecionar localidad»
 14 [btn] Leer la página
 15 [btn] Volver a la página anterior
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
