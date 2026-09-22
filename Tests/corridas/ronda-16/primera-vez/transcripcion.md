# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
- [+  7.7s] 🔊 «Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~61%)
- [+  7.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  4 [btn] Llevame a La Nación  (Primera de 4 opciones.)
  5 [btn] ¿A cuánto está el dólar hoy?
  6 [btn] ¿Cómo va a estar el tiempo mañana?
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Llevame a La Nación»

- [+ 15.1s] 💬 Persona: Llevame a La Nación
- [+ 15.1s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 15.1s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 18.7s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 19.7s] 💬 JEF: Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
- [+ 19.7s] 🔊 «Estás en la portada de La Nación. Los titulares principales: 1. Trump afirmó que deberá decidir entre alcanzar un acuerdo con Irán o llevar a ese país “al infierno”. 2. Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo de las Américas. 3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil. 4. Quién es Laura De Marinis, la jueza que declaró inconstitucional el nuevo régimen penal juvenil en la Ciudad.»
- [+ 19.7s] 🔘 Botones: [Abrir «Trump afirmó que deberá decidir entre alcanzar un acuerdo con Irán o llevar a ese país “al infierno”»] · [Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»] · [Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»] · [Abrir «Quién es Laura De Marinis, la jueza que declaró inconstitucional el nuevo régimen penal juvenil en…»]
- [+ 19.7s] 🔘 Botones: [Abrir «Trump afirmó que deberá decidir entre alcanzar un acuerdo con Irán o llevar a ese país “al infierno”»] · [Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»] · [Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»] · [Abrir «Quién es Laura De Marinis, la jueza que declaró inconstitucional el nuevo régimen penal juvenil en…»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: hola, ¿qué podés hacer?
  4 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  5 [H] Vos: Llevame a La Nación
  6 [txt] Abriendo lanacion.com.ar.
  7 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  8 [btn] Abrir «Trump afirmó que deberá decidir entre alcanzar un acuerdo con Irán o llevar a ese país “al infierno”»  (Primera de 5 opciones.)
  9 [btn] Abrir «Milei llegó a Nueva York y podría tener un encuentro con Trump: coincidirán en la sesión del Escudo…»
 10 [btn] Abrir «La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil»
 11 [btn] Abrir «Quién es Laura De Marinis, la jueza que declaró inconstitucional el nuevo régimen penal juvenil en…»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 28.1s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 29.1s] 💬 JEF: Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
- [+ 29.1s] 🔊 «Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.»
- [+ 29.1s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: hola, ¿qué podés hacer?
  4 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  5 [H] Vos: Llevame a La Nación
  6 [txt] Abriendo lanacion.com.ar.
  7 [txt] Estás en la portada de La Nación. Los titulares principales son las primeras opciones.
  8 [H] Vos: no entiendo, ¿dónde estoy?
  9 [txt] Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
 10 [btn] Leer los titulares  (Primera de 3 opciones.)
 11 [btn] Resumir la portada
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
