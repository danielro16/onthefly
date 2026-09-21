# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.5s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 💬 JEF: Buscando: tiempo mañana córdoba.
- [+  7.6s] 🔊 «Buscando: tiempo mañana córdoba.»
- [+ 10.7s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=tiempo%20ma%C3%B1ana%20c%C3%B3rdoba&kl=ar-es — «tiempo mañana córdoba at DuckDuckGo» (paginas/01.txt)
- [+ 10.7s] 💬 JEF: Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
- [+ 10.7s] 🔊 «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables: 1. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com. 2. Tiempo en Córdoba mañana - Meteored Argentina, meteored.com.ar. 3. Clima en Córdoba para mañana - es.meteocast.net, es.meteocast.net»
- [+ 10.7s] 🔘 Botones: [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Clima en Córdoba para mañana - es.meteocast.net — es.meteocast.net] · [Ver más opciones (3)]
- [+ 10.7s] 🔘 Botones: [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Clima en Córdoba para mañana - es.meteocast.net — es.meteocast.net] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [btn] Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com  (Primera de 5 opciones.)
  6 [btn] Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  7 [btn] Clima en Córdoba para mañana - es.meteocast.net — es.meteocast.net
  8 [btn] Ver más opciones (3)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com»

- [+ 16.1s] 💬 Persona: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
- [+ 16.1s] 💬 JEF: Abriendo eltiempoen.com.
- [+ 16.1s] 🔊 «Abriendo eltiempoen.com.»
- [+ 18.8s] 📄 Cargó https://eltiempoen.com/argentina/cordoba/cordoba/manana — «Clima mañana en Córdoba, Cordoba» (paginas/02.txt)
- [+ 18.8s] 💬 JEF: En eltiempoen.com.
- [+ 18.8s] 🔊 «En eltiempoen.com.»
- [+ 20.4s] 💬 JEF: Mañana en Córdoba se esperan unas condiciones de nubes. La máxima va a ser de 63º y la mínima de 40º. No hay probabilidad de precipitaciones y la humedad relativa será del 31%. El viento soplará del NE a 13 mph.
- [+ 20.4s] 🔊 «Mañana en Córdoba se esperan unas condiciones de nubes. La máxima va a ser de 63º y la mínima de 40º. No hay probabilidad de precipitaciones y la humedad relativa será del 31%. El viento soplará del NE a 13 mph.»
- [+ 20.4s] 🔘 Botones: [¿A qué hora amanece?] · [¿Cómo estará por la noche?] · [Completar «Selecionar localidad»] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  6 [txt] Abriendo eltiempoen.com.
  7 [txt] En eltiempoen.com.
  8 [txt] Mañana en Córdoba se esperan unas condiciones de nubes. La máxima va a ser de 63º y la mínima de 40º. No hay probabilidad de precipitaciones y la humedad relativa será del 31%. El viento soplará del NE a 13 mph.
  9 [btn] ¿A qué hora amanece?  (Primera de 5 opciones.)
 10 [btn] ¿Cómo estará por la noche?
 11 [btn] Completar «Selecionar localidad»
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 27.4s] 💬 Persona: ¿va a llover?
- [+ 29.1s] 💬 JEF: No va a llover mañana en Córdoba. La probabilidad de lluvia es del 0%, y las lluvias se indican en 0 in.
- [+ 29.1s] 🔊 «No va a llover mañana en Córdoba. La probabilidad de lluvia es del 0%, y las lluvias se indican en 0 in.»
- [+ 29.1s] 🔘 Botones: [¿Qué clima hará mañana en Córdoba?] · [¿A qué hora amanece y atardece?] · [Completar «Selecionar localidad»] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  6 [txt] Abriendo eltiempoen.com.
  7 [txt] En eltiempoen.com.
  8 [txt] Mañana en Córdoba se esperan unas condiciones de nubes. La máxima va a ser de 63º y la mínima de 40º. No hay probabilidad de precipitaciones y la humedad relativa será del 31%. El viento soplará del NE a 13 mph.
  9 [H] Vos: ¿va a llover?
 10 [txt] No va a llover mañana en Córdoba. La probabilidad de lluvia es del 0%, y las lluvias se indican en 0 in.
 11 [btn] ¿Qué clima hará mañana en Córdoba?  (Primera de 5 opciones.)
 12 [btn] ¿A qué hora amanece y atardece?
 13 [btn] Completar «Selecionar localidad»
 14 [btn] Volver a la página anterior
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 17 [btn] Enviar
```
