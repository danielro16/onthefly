# clima-cordoba

**Quién:** Ciega, usa VoiceOver todos los días.

**Qué quiere:** Saber cómo va a estar el tiempo mañana en Córdoba y si va a llover.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿cómo va a estar el tiempo mañana en córdoba?»

- [+  6.6s] 💬 Persona: ¿cómo va a estar el tiempo mañana en córdoba?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Buscando: tiempo mañana córdoba.
- [+  7.5s] 🔊 «Buscando: tiempo mañana córdoba.»
- [+ 10.5s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=tiempo%20ma%C3%B1ana%20c%C3%B3rdoba&kl=ar-es — «tiempo mañana córdoba at DuckDuckGo» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
- [+ 10.5s] 🔊 «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables: 1. Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo…, tiempomañana.net. 2. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com. 3. Tiempo en Córdoba mañana - Meteored Argentina, meteored.com.ar»
- [+ 10.5s] 🔘 Botones: [Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Ver más opciones (3)]
- [+ 10.5s] 🔘 Botones: [Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net] · [Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com] · [Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [btn] Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net  (Primera de 5 opciones.)
  6 [btn] Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com
  7 [btn] Tiempo en Córdoba mañana - Meteored Argentina — www.meteored.com.ar
  8 [btn] Ver más opciones (3)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net»

- [+ 16.1s] 💬 Persona: Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net
- [+ 16.1s] 💬 JEF: Abriendo tiempomañana.net.
- [+ 16.1s] 🔊 «Abriendo tiempomañana.net.»
- [+ 20.1s] 📄 Cargó https://www.xn--tiempomaana-8db.net/ciudad/cordoba-argentina — «Tiempo Mañana en Córdoba» (paginas/02.txt)
- [+ 20.1s] 💬 JEF: En xn--tiempomaana-8db.net.
- [+ 20.1s] 🔊 «En xn--tiempomaana-8db.net.»
- [+ 21.3s] 💬 JEF: Mañana en Córdoba, va a haber nubes dispersas, con una mínima de 8° y una máxima de 27°. El viento va a estar a 17 km/h.
- [+ 21.3s] 🔊 «Mañana en Córdoba, va a haber nubes dispersas, con una mínima de 8° y una máxima de 27°. El viento va a estar a 17 km/h.»
- [+ 21.3s] 🔘 Botones: [¿Y pasado mañana?] · [¿Qué tiempo hace ahora?] · [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net
  6 [txt] Abriendo tiempomañana.net.
  7 [txt] En xn--tiempomaana-8db.net.
  8 [txt] Mañana en Córdoba, va a haber nubes dispersas, con una mínima de 8° y una máxima de 27°. El viento va a estar a 17 km/h.
  9 [btn] ¿Y pasado mañana?  (Primera de 6 opciones.)
 10 [btn] ¿Qué tiempo hace ahora?
 11 [btn] Leer la página
 12 [btn] Resumir la página
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿va a llover?»

- [+ 29.2s] 💬 Persona: ¿va a llover?
- [+ 30.7s] 💬 JEF: No, la página no indica que vaya a llover en Córdoba mañana. Muestra que va a estar con nubes dispersas.
- [+ 30.7s] 🔊 «No, la página no indica que vaya a llover en Córdoba mañana. Muestra que va a estar con nubes dispersas.»
- [+ 30.8s] 🔘 Botones: [¿Qué temperatura va a hacer?] · [¿Y pasado mañana?] · [Leer la página] · [Resumir la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: ¿cómo va a estar el tiempo mañana en córdoba?
  3 [txt] Buscando: tiempo mañana córdoba.
  4 [txt] Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:
  5 [H] Vos: Tiempo Mañana en Córdoba — Pronóstico del Tiempo | Tiempo Mañana — www.tiempomañana.net
  6 [txt] Abriendo tiempomañana.net.
  7 [txt] En xn--tiempomaana-8db.net.
  8 [txt] Mañana en Córdoba, va a haber nubes dispersas, con una mínima de 8° y una máxima de 27°. El viento va a estar a 17 km/h.
  9 [H] Vos: ¿va a llover?
 10 [txt] No, la página no indica que vaya a llover en Córdoba mañana. Muestra que va a estar con nubes dispersas.
 11 [btn] ¿Qué temperatura va a hacer?  (Primera de 6 opciones.)
 12 [btn] ¿Y pasado mañana?
 13 [btn] Leer la página
 14 [btn] Resumir la página
 15 [btn] Volver a los resultados
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
