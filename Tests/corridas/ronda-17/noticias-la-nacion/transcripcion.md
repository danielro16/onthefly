# noticias-la-nacion

**Quién:** Ciega hace veinte años, usa VoiceOver todos los días y lee La Nación cada mañana.

**Qué quiere:** Enterarse de lo principal del día en La Nación, abrir una noticia, que se la resuman y volver.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «llevame a la nación»

- [+  6.2s] 💬 Persona: llevame a la nación
- [+  6.2s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Buscando: la nación.
- [+  7.5s] 🔊 «Buscando: la nación.»
- [+ 12.7s] 📄 Cargó https://www.google.com/search?q=la%20naci%C3%B3n&gl=ar&hl=es — «la nación - Buscar con Google» (paginas/01.txt)
- [+ 12.7s] 💬 JEF: Estás en los resultados de «la nación». Los 2 más probables:
- [+ 12.7s] 🔊 «Estás en los resultados de «la nación». Los 2 más probables: 1. La Nación, lanacion.com.ar. 2. La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre, es.wikipedia.org»
- [+ 12.7s] 🔘 Botones: [La Nación — www.lanacion.com.ar] · [La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre — es.wikipedia.org]
- [+ 12.7s] 🔘 Botones: [La Nación — www.lanacion.com.ar] · [La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [btn] La Nación — www.lanacion.com.ar  (Primera de 3 opciones.)
  7 [btn] La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre — es.wikipedia.org
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca el botón 1: «La Nación — www.lanacion.com.ar»

- [+ 18.5s] 💬 Persona: La Nación — www.lanacion.com.ar
- [+ 18.5s] 💬 JEF: Abriendo www.lanacion.com.ar.
- [+ 18.5s] 🔊 «Abriendo www.lanacion.com.ar.»
- [+ 22.7s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/02.txt)
- [+ 23.8s] 💬 JEF: Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
- [+ 23.8s] 🔊 «Estás en la portada de La Nación. Los titulares principales: 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba. 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas. 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil. 4. Jorge Macri activa un proceso para destituir a la jueza que evitó aplicar el régimen penal juvenil.»
- [+ 23.8s] 🔘 Botones: [Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»] · [Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»] · [Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»] · [Abrir «Jorge Macri activa un proceso para destituir a la jueza que evitó aplicar el régimen penal juvenil»]
- [+ 23.8s] 🔘 Botones: [Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»] · [Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»] · [Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»] · [Abrir «Jorge Macri activa un proceso para destituir a la jueza que evitó aplicar el régimen penal juvenil»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo www.lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»  (Primera de 6 opciones.)
 10 [btn] Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»
 11 [btn] Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»
 12 [btn] Abrir «Jorge Macri activa un proceso para destituir a la jueza que evitó aplicar el régimen penal juvenil»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «dame los titulares»

- [+ 31.9s] 💬 Persona: dame los titulares
- [+ 33.3s] 💬 JEF: Titulares 1 a 3:
- [+ 33.3s] 🔊 «Titulares 1 a 3:»
- [+ 33.3s] 💬 JEF: 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba
- [+ 33.3s] 🔊 «1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba»
- [+ 33.3s] 💬 JEF: 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas
- [+ 33.3s] 🔊 «2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas»  ⟶ en cola: empieza a sonar a los +42.5s
- [+ 33.3s] 💬 JEF: 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil
- [+ 33.3s] 🔊 «3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 33.3s] 🔘 Botones: [Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»] · [Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»] · [Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»] · [Seguir con los titulares] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo www.lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba
 12 [txt] 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas
 13 [txt] 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil
 14 [btn] Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»  (Primera de 6 opciones.)
 15 [btn] Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»
 16 [btn] Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»
 17 [btn] Seguir con los titulares
 18 [btn] Volver a los resultados
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```

## Paso 4 — toca el botón 1: «Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»»

- [+ 43.4s] 💬 Persona: Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»
- [+ 43.4s] 💬 JEF: Abriendo.
- [+ 43.4s] 🔊 «Abriendo.»
- [+ 46.6s] 📄 Cargó https://www.lanacion.com.ar/el-mundo/donald-trump-sobre-iran-los-arrastro-al-infierno-sin-posibilidad-de-supervivencia-nid22092026/ — «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba» (paginas/03.txt)
- [+ 48.1s] 💬 JEF: Estás en la nota de LA NACION donde Donald Trump amenaza con aniquilar a Irán si no acepta un acuerdo y defiende sus intervenciones en Venezuela y Cuba. El mandatario también abordó el conflicto en Ucrania, la situación en la región y anunció la construcción de bases militares en Groenlandia. Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.
- [+ 48.1s] 🔊 «Estás en la nota de LA NACION donde Donald Trump amenaza con aniquilar a Irán si no acepta un acuerdo y defiende sus intervenciones en Venezuela y Cuba. El mandatario también abordó el conflicto en Ucrania, la situación en la región y anunció la construcción de bases militares en Groenlandia. Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.»
- [+ 48.1s] 🔘 Botones: [Leer la nota] · [Resumir la nota]
- [+ 48.1s] 🔘 Botones: [Leer la nota] · [Resumir la nota] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo www.lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba
 12 [txt] 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas
 13 [txt] 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil
 14 [H] Vos: Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»
 15 [txt] Abriendo.
 16 [txt] Estás en la nota de LA NACION donde Donald Trump amenaza con aniquilar a Irán si no acepta un acuerdo y defiende sus intervenciones en Venezuela y Cuba. El mandatario también abordó el conflicto en Ucrania, la situación en la región y anunció la construcción de bases militares en Groenlandia. Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.
 17 [btn] Leer la nota  (Primera de 4 opciones.)
 18 [btn] Resumir la nota
 19 [btn] Volver a la portada
 20 [btn] Otra cosa
 21 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 22 [btn] Enviar
```

## Paso 5 — escribe «resumime la nota»

- [+ 56.5s] 💬 Persona: resumime la nota
- [+ 59.2s] 💬 JEF: Resumen de la nota: La delegación iraní abandonó la sala ante las amenazas de Trump, quien también llamó a los miembros de la Corte Penal Internacional a retirarse de inmediato. Además, anunció la construcción de dos bases militares en Groenlandia tras un acuerdo con Dinamarca.
- [+ 59.2s] 🔊 «Resumen de la nota: La delegación iraní abandonó la sala ante las amenazas de Trump, quien también llamó a los miembros de la Corte Penal Internacional a retirarse de inmediato. Además, anunció la construcción de dos bases militares en Groenlandia tras un acuerdo con Dinamarca.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~44%)
- [+ 59.2s] 🔘 Botones: [Leer la nota] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo www.lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba
 12 [txt] 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas
 13 [txt] 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil
 14 [H] Vos: Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»
 15 [txt] Abriendo.
 16 [txt] Estás en la nota de LA NACION donde Donald Trump amenaza con aniquilar a Irán si no acepta un acuerdo y defiende sus intervenciones en Venezuela y Cuba. El mandatario también abordó el conflicto en Ucrania, la situación en la región y anunció la construcción de bases militares en Groenlandia. Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.
 17 [H] Vos: resumime la nota
 18 [txt] Resumen de la nota: La delegación iraní abandonó la sala ante las amenazas de Trump, quien también llamó a los miembros de la Corte Penal Internacional a retirarse de inmediato. Además, anunció la construcción de dos bases militares en Groenlandia tras un acuerdo con Dinamarca.
 19 [btn] Leer la nota  (Primera de 3 opciones.)
 20 [btn] Volver a la portada
 21 [btn] Otra cosa
 22 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 23 [btn] Enviar
```

## Paso 6 — escribe «volvé»

- [+ 66.8s] 💬 Persona: volvé
- [+ 67.9s] 💬 JEF: Volviendo.
- [+ 67.9s] 🔊 «Volviendo.»
- [+ 68.7s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/04.txt)
- [+ 68.7s] 💬 JEF: De vuelta en la portada de LA NACION.
- [+ 68.7s] 🔊 «De vuelta en la portada de LA NACION.»
- [+ 68.8s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-06.txt, captura en paso-06.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo www.lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en Venezuela y Cuba
 12 [txt] 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas
 13 [txt] 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil
 14 [H] Vos: Abrir «Trump amenazó con “aniquilar” a Irán si no acepta un acuerdo y defendió sus intervenciones en…»
 15 [txt] Abriendo.
 16 [txt] Estás en la nota de LA NACION donde Donald Trump amenaza con aniquilar a Irán si no acepta un acuerdo y defiende sus intervenciones en Venezuela y Cuba. El mandatario también abordó el conflicto en Ucrania, la situación en la región y anunció la construcción de bases militares en Groenlandia. Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.
 17 [H] Vos: resumime la nota
 18 [txt] Resumen de la nota: La delegación iraní abandonó la sala ante las amenazas de Trump, quien también llamó a los miembros de la Corte Penal Internacional a retirarse de inmediato. Además, anunció la construcción de dos bases militares en Groenlandia tras un acuerdo con Dinamarca.
 19 [H] Vos: volvé
 20 [txt] Volviendo.
 21 [txt] De vuelta en la portada de LA NACION.
 22 [btn] Leer los titulares  (Primera de 4 opciones.)
 23 [btn] Resumir la portada
 24 [btn] Volver a los resultados
 25 [btn] Otra cosa
 26 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 27 [btn] Enviar
```
