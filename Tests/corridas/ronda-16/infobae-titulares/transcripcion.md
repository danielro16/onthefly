# infobae-titulares

**Quién:** Ciega, usa VoiceOver todos los días. Lee Infobae, que JEF nunca probó.

**Qué quiere:** Entrar a Infobae, escuchar los titulares y abrir uno.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «abrí infobae»

- [+  7.0s] 💬 Persona: abrí infobae
- [+  7.0s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.5s] 💬 JEF: Buscando: infobae.
- [+  8.5s] 🔊 «Buscando: infobae.»
- [+ 12.2s] 📄 Cargó https://www.google.com/search?q=infobae&gl=ar&hl=es — «infobae - Buscar con Google» (paginas/01.txt)
- [+ 12.2s] 💬 JEF: Estás en los resultados de «infobae». Los 2 más probables:
- [+ 12.2s] 🔊 «Estás en los resultados de «infobae». Los 2 más probables: 1. Infobae, infobae.com. 2. Infobae - Wikipedia, la enciclopedia libre, es.wikipedia.org»
- [+ 12.2s] 🔘 Botones: [Infobae — www.infobae.com] · [Infobae - Wikipedia, la enciclopedia libre — es.wikipedia.org]
- [+ 12.2s] 🔘 Botones: [Infobae — www.infobae.com] · [Infobae - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: abrí infobae
  4 [txt] Buscando: infobae.
  5 [txt] Estás en los resultados de «infobae». Los 2 más probables:
  6 [btn] Infobae — www.infobae.com  (Primera de 3 opciones.)
  7 [btn] Infobae - Wikipedia, la enciclopedia libre — es.wikipedia.org
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Infobae — www.infobae.com»

- [+ 17.9s] 💬 Persona: Infobae — www.infobae.com
- [+ 17.9s] 💬 JEF: Abriendo google.com.
- [+ 17.9s] 🔊 «Abriendo google.com.»
- [+ 21.6s] 📄 Cargó https://www.infobae.com/?noredirect — «Hacemos periodismo» (paginas/02.txt)
- [+ 22.9s] 💬 JEF: Estás en la portada de Infobae. Los titulares principales son las primeras opciones.
- [+ 22.9s] 🔊 «Estás en la portada de Infobae. Los titulares principales: 1. Trump: “Tengo que tomar una decisión muy importante, hacemos un trato o aniquilo a la República Islámica de Irán”. 2. Milei llegó a New York y elogió el discurso de Trump en la ONU: "Pocos entienden la magnitud de su liderazgo". 3. Pity Álvarez manejaba sin registro, chocó en una estación de servicio y escapó: el video del hecho. 4. Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan.»
- [+ 23.0s] 🔘 Botones: [Abrir «Trump: “Tengo que tomar una decisión muy importante, hacemos un trato o aniquilo a la República…»] · [Abrir «Milei llegó a New York y elogió el discurso de Trump en la ONU: "Pocos entienden la magnitud de su…»] · [Abrir «Pity Álvarez manejaba sin registro, chocó en una estación de servicio y escapó: el video del hecho»] · [Abrir «Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan»]
- [+ 23.0s] 🔘 Botones: [Abrir «Trump: “Tengo que tomar una decisión muy importante, hacemos un trato o aniquilo a la República…»] · [Abrir «Milei llegó a New York y elogió el discurso de Trump en la ONU: "Pocos entienden la magnitud de su…»] · [Abrir «Pity Álvarez manejaba sin registro, chocó en una estación de servicio y escapó: el video del hecho»] · [Abrir «Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan»] · [Volver a los resultados] · [Otra cosa]
- [+ 23.7s] 📄 Cargó https://www.infobae.com/?noredirect — «Hacemos periodismo» (paginas/03.txt)

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: abrí infobae
  4 [txt] Buscando: infobae.
  5 [txt] Estás en los resultados de «infobae». Los 2 más probables:
  6 [H] Vos: Infobae — www.infobae.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Infobae. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Trump: “Tengo que tomar una decisión muy importante, hacemos un trato o aniquilo a la República…»  (Primera de 6 opciones.)
 10 [btn] Abrir «Milei llegó a New York y elogió el discurso de Trump en la ONU: "Pocos entienden la magnitud de su…»
 11 [btn] Abrir «Pity Álvarez manejaba sin registro, chocó en una estación de servicio y escapó: el video del hecho»
 12 [btn] Abrir «Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿qué titulares hay?»

- [+ 31.9s] 💬 Persona: ¿qué titulares hay?
- [+ 34.7s] 💬 JEF: En la portada de Infobae destacan las declaraciones de Trump sobre Irán, el viaje de Milei a Nueva York y el choque de Pity Álvarez. También informan sobre la llegada de los aviones F-16 a Argentina y la interna en el peronismo.
- [+ 34.7s] 🔊 «En la portada de Infobae destacan las declaraciones de Trump sobre Irán, el viaje de Milei a Nueva York y el choque de Pity Álvarez. También informan sobre la llegada de los aviones F-16 a Argentina y la interna en el peronismo.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~49%)
- [+ 34.7s] 🔘 Botones: [¿A cuánto cotiza el dólar blue?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: abrí infobae
  4 [txt] Buscando: infobae.
  5 [txt] Estás en los resultados de «infobae». Los 2 más probables:
  6 [H] Vos: Infobae — www.infobae.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Infobae. Los titulares principales son las primeras opciones.
  9 [H] Vos: ¿qué titulares hay?
 10 [txt] En la portada de Infobae destacan las declaraciones de Trump sobre Irán, el viaje de Milei a Nueva York y el choque de Pity Álvarez. También informan sobre la llegada de los aviones F-16 a Argentina y la interna en el peronismo.
 11 [btn] ¿A cuánto cotiza el dólar blue?  (Primera de 5 opciones.)
 12 [btn] Leer los titulares
 13 [btn] Resumir la portada
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 4 — toca el botón 1: «¿A cuánto cotiza el dólar blue?»

- [+ 40.6s] 💬 Persona: ¿A cuánto cotiza el dólar blue?
- [+ 42.6s] 💬 JEF: El dólar blue cotiza a $1.555, según los datos actualizados de Infobae.
- [+ 42.6s] 🔊 «El dólar blue cotiza a $1.555, según los datos actualizados de Infobae.»
- [+ 42.7s] 🔘 Botones: [¿Y el dólar oficial?] · [¿A cuánto está el riesgo país?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: abrí infobae
  4 [txt] Buscando: infobae.
  5 [txt] Estás en los resultados de «infobae». Los 2 más probables:
  6 [H] Vos: Infobae — www.infobae.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Infobae. Los titulares principales son las primeras opciones.
  9 [H] Vos: ¿qué titulares hay?
 10 [txt] En la portada de Infobae destacan las declaraciones de Trump sobre Irán, el viaje de Milei a Nueva York y el choque de Pity Álvarez. También informan sobre la llegada de los aviones F-16 a Argentina y la interna en el peronismo.
 11 [H] Vos: ¿A cuánto cotiza el dólar blue?
 12 [txt] El dólar blue cotiza a $1.555, según los datos actualizados de Infobae.
 13 [btn] ¿Y el dólar oficial?  (Primera de 6 opciones.)
 14 [btn] ¿A cuánto está el riesgo país?
 15 [btn] Leer los titulares
 16 [btn] Resumir la portada
 17 [btn] Volver a los resultados
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```
