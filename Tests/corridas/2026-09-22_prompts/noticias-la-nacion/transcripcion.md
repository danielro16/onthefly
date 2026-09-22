# noticias-la-nacion

**Quién:** Ciega hace veinte años, usa VoiceOver todos los días y lee La Nación cada mañana.

**Qué quiere:** Enterarse de lo principal del día en La Nación, abrir una noticia, que se la resuman y volver.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «llevame a la nación»

- [+  6.5s] 💬 Persona: llevame a la nación
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Buscando: la nación.
- [+  7.7s] 🔊 «Buscando: la nación.»
- [+ 13.3s] 📄 Cargó https://www.google.com/search?q=la%20naci%C3%B3n&gl=ar&hl=es&sei=j_WyatK9GrOohvcPrti8-Aw — «la nación - Buscar con Google» (paginas/01.txt)
- [+ 13.3s] 💬 JEF: Estás en los resultados de «la nación». Los 2 más probables:
- [+ 13.3s] 🔊 «Estás en los resultados de «la nación». Los 2 más probables: 1. La Nación, lanacion.com.ar. 2. La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre, es.wikipedia.org»
- [+ 13.3s] 🔘 Botones: [La Nación — www.lanacion.com.ar] · [La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre — es.wikipedia.org]
- [+ 13.3s] 🔘 Botones: [La Nación — www.lanacion.com.ar] · [La Nación (Buenos Aires) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
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
- [+ 18.5s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 18.5s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 24.6s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/02.txt)
- [+ 26.8s] 💬 JEF: Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
- [+ 26.8s] 🔊 «Estás en la portada de La Nación. Los titulares principales: 1. "Una gran victoria en la Argentina". Milei coincidió con Trump en la sesión del Escudo de las Américas. 2. Tras el boicot de la TV, Trump recurre a un clásico del manual de Hugo Chávez. 3. Trump se reunió con el primer ministro británico y hablaron sobre Malvinas. 4. La letra fina del proyecto Malvinas. El Gobierno pondera las diferencias con la ley actual, la forma de aplicación y los “derribos”.»
- [+ 26.8s] 🔘 Botones: [Abrir «Una gran victoria en la Argentina". Milei coincidió con Trump en la sesión del Escudo de las…»] · [Abrir «Tras el boicot de la TV, Trump recurre a un clásico del manual de Hugo Chávez»] · [Abrir «Trump se reunió con el primer ministro británico y hablaron sobre Malvinas»] · [Abrir «La letra fina del proyecto Malvinas. El Gobierno pondera las diferencias con la ley actual, la…»]
- [+ 26.8s] 🔘 Botones: [Abrir «Una gran victoria en la Argentina". Milei coincidió con Trump en la sesión del Escudo de las…»] · [Abrir «Tras el boicot de la TV, Trump recurre a un clásico del manual de Hugo Chávez»] · [Abrir «Trump se reunió con el primer ministro británico y hablaron sobre Malvinas»] · [Abrir «La letra fina del proyecto Malvinas. El Gobierno pondera las diferencias con la ley actual, la…»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Una gran victoria en la Argentina". Milei coincidió con Trump en la sesión del Escudo de las…»  (Primera de 6 opciones.)
 10 [btn] Abrir «Tras el boicot de la TV, Trump recurre a un clásico del manual de Hugo Chávez»
 11 [btn] Abrir «Trump se reunió con el primer ministro británico y hablaron sobre Malvinas»
 12 [btn] Abrir «La letra fina del proyecto Malvinas. El Gobierno pondera las diferencias con la ley actual, la…»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «dame los titulares»

- [+ 35.0s] 💬 Persona: dame los titulares
- [+ 36.8s] ❌ Error de carga: {'donde': 'decidir', 't': 1790113195.702241, 'tipo': 'error', 'detalle': 'unusable'}
- [+ 39.0s] 💬 JEF: Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.
- [+ 39.0s] 🔊 «Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~38%)
- [+ 39.0s] 🔘 Botones: [¿Cuál es el valor actual del dólar blue?] · [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.
 11 [btn] ¿Cuál es el valor actual del dólar blue?  (Primera de 5 opciones.)
 12 [btn] Leer los titulares
 13 [btn] Resumir la portada
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 4 — toca el botón 1: «¿Cuál es el valor actual del dólar blue?»

- [+ 48.0s] 💬 Persona: ¿Cuál es el valor actual del dólar blue?
- [+ 49.7s] 💬 JEF: Buscando: valor dólar blue en Buenos Aires.
- [+ 49.7s] 🔊 «Buscando: valor dólar blue en Buenos Aires.»
- [+ 54.9s] 📄 Cargó https://www.google.com/search?q=valor%20d%C3%B3lar%20blue%20en%20Buenos%20Aires&gl=ar&hl=es&sei=uPWyavCcM5S2hvcPyY6D-QE — «valor dólar blue en Buenos Aires» (paginas/03.txt)
- [+ 56.4s] 💬 JEF: El dólar blue en Buenos Aires cotiza hoy a $1.535 para la compra y $1.555 para la venta. Estas son las cifras reflejadas en los resultados de búsqueda actuales.
- [+ 56.4s] 🔊 «El dólar blue en Buenos Aires cotiza hoy a $1.535 para la compra y $1.555 para la venta. Estas son las cifras reflejadas en los resultados de búsqueda actuales.»
- [+ 56.4s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (5)]
- [+ 56.4s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.
 11 [H] Vos: ¿Cuál es el valor actual del dólar blue?
 12 [txt] Buscando: valor dólar blue en Buenos Aires.
 13 [txt] El dólar blue en Buenos Aires cotiza hoy a $1.535 para la compra y $1.555 para la venta. Estas son las cifras reflejadas en los resultados de búsqueda actuales.
 14 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 5 opciones.)
 15 [btn] Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com
 16 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
 17 [btn] Ver más opciones (5)
 18 [btn] Otra cosa
 19 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 20 [btn] Enviar
```

## Paso 5 — escribe «resumime la nota»

- [+ 64.6s] 💬 Persona: resumime la nota
- [+ 68.5s] 💬 JEF: Resumen de la página: Además de la cotización que ya conocés, otros portales como Ámbito informan un valor de 1530,00 pesos para el dólar blue, mientras que La Nación registra el dólar oficial a 1535,00 pesos. El Banco Nación detalla para hoy que el dólar estadounidense cotiza a 1485,00 pesos para la compra y 1535,00 pesos para la venta.
- [+ 68.5s] 🔊 «Resumen de la página: Además de la cotización que ya conocés, otros portales como Ámbito informan un valor de 1530 pesos para el dólar blue, mientras que La Nación registra el dólar oficial a 1535 pesos. El Banco Nación detalla para hoy que el dólar estadounidense cotiza a 1485 pesos para la compra y 1535 pesos para la venta.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~39%)
- [+ 68.5s] 🔘 Botones: [Cotización del dólar, dólar blue y mayorista — www.cronista.com] · [Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com] · [Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.
 11 [H] Vos: ¿Cuál es el valor actual del dólar blue?
 12 [txt] Buscando: valor dólar blue en Buenos Aires.
 13 [txt] El dólar blue en Buenos Aires cotiza hoy a $1.535 para la compra y $1.555 para la venta. Estas son las cifras reflejadas en los resultados de búsqueda actuales.
 14 [H] Vos: resumime la nota
 15 [txt] Resumen de la página: Además de la cotización que ya conocés, otros portales como Ámbito informan un valor de 1530,00 pesos para el dólar blue, mientras que La Nación registra el dólar oficial a 1535,00 pesos. El Banco Nación detalla para hoy que el dólar estadounidense cotiza a 1485,00 pesos para la compra y 1535,00 pesos para la venta.
 16 [btn] Cotización del dólar, dólar blue y mayorista — www.cronista.com  (Primera de 4 opciones.)
 17 [btn] Cotización del dólar hoy, dólar blue | Ámbito — www.ambito.com
 18 [btn] Dólar hoy, Cotización del dólar | Dolarhoy.com — dolarhoy.com
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```

## Paso 6 — escribe «volvé»

- [+ 76.5s] 💬 Persona: volvé
- [+ 77.6s] 💬 JEF: Volviendo.
- [+ 77.6s] 🔊 «Volviendo.»
- [+ 78.5s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/04.txt)
- [+ 78.5s] 💬 JEF: De vuelta en la portada de LA NACION.
- [+ 78.5s] 🔊 «De vuelta en la portada de LA NACION.»
- [+ 78.5s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-06.txt, captura en paso-06.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: llevame a la nación
  4 [txt] Buscando: la nación.
  5 [txt] Estás en los resultados de «la nación». Los 2 más probables:
  6 [H] Vos: La Nación — www.lanacion.com.ar
  7 [txt] Abriendo lanacion.com.ar.
  8 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Hoy en La Nación, los titulares destacados incluyen el encuentro de Milei con Trump en la sesión del Escudo de las Américas, los detalles sobre el proyecto Malvinas y la orden judicial al Hospital Italiano tras un caso de abuso. También se informa sobre la renuncia del presidente del tribunal en el caso Loan y la condena judicial que intima al Gobierno a actualizar salarios universitarios.
 11 [H] Vos: ¿Cuál es el valor actual del dólar blue?
 12 [txt] Buscando: valor dólar blue en Buenos Aires.
 13 [txt] El dólar blue en Buenos Aires cotiza hoy a $1.535 para la compra y $1.555 para la venta. Estas son las cifras reflejadas en los resultados de búsqueda actuales.
 14 [H] Vos: resumime la nota
 15 [txt] Resumen de la página: Además de la cotización que ya conocés, otros portales como Ámbito informan un valor de 1530,00 pesos para el dólar blue, mientras que La Nación registra el dólar oficial a 1535,00 pesos. El Banco Nación detalla para hoy que el dólar estadounidense cotiza a 1485,00 pesos para la compra y 1535,00 pesos para la venta.
 16 [H] Vos: volvé
 17 [txt] Volviendo.
 18 [txt] De vuelta en la portada de LA NACION.
 19 [btn] Leer los titulares  (Primera de 4 opciones.)
 20 [btn] Resumir la portada
 21 [btn] Volver a los resultados
 22 [btn] Otra cosa
 23 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 24 [btn] Enviar
```
