# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.5s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 💬 JEF: Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
- [+  7.5s] 🔊 «Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~61%)
- [+  7.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

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

- [+ 15.0s] 💬 Persona: Llevame a La Nación
- [+ 15.0s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 15.0s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 19.0s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 20.6s] 💬 JEF: Estás en la portada de LA NACION, con los principales titulares. Los titulares principales son las primeras opciones.
- [+ 20.6s] 🔊 «Estás en la portada de LA NACION, con los principales titulares. Los titulares principales: 1. Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a un adolescente. 2. Con el apoyo del Reino Unido, el gobierno de Malvinas extiende por cinco años todas las licencias petroleras. 3. Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”. 4. Ante inversores financieros, Caputo buscó dar certidumbre sobre el plan económico de cara a 2027.»
- [+ 20.6s] 🔘 Botones: [Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»] · [Abrir «Con el apoyo del Reino Unido, el gobierno de Malvinas extiende por cinco años todas las licencias…»] · [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»] · [Abrir «Ante inversores financieros, Caputo buscó dar certidumbre sobre el plan económico de cara a 2027»]
- [+ 20.6s] 🔘 Botones: [Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»] · [Abrir «Con el apoyo del Reino Unido, el gobierno de Malvinas extiende por cinco años todas las licencias…»] · [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»] · [Abrir «Ante inversores financieros, Caputo buscó dar certidumbre sobre el plan económico de cara a 2027»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: hola, ¿qué podés hacer?
  4 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  5 [H] Vos: Llevame a La Nación
  6 [txt] Abriendo lanacion.com.ar.
  7 [txt] Estás en la portada de LA NACION, con los principales titulares. Los titulares principales son las primeras opciones.
  8 [btn] Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»  (Primera de 5 opciones.)
  9 [btn] Abrir «Con el apoyo del Reino Unido, el gobierno de Malvinas extiende por cinco años todas las licencias…»
 10 [btn] Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»
 11 [btn] Abrir «Ante inversores financieros, Caputo buscó dar certidumbre sobre el plan económico de cara a 2027»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 28.0s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 28.8s] 💬 JEF: Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
- [+ 28.8s] 🔊 «Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.»
- [+ 28.8s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: hola, ¿qué podés hacer?
  4 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  5 [H] Vos: Llevame a La Nación
  6 [txt] Abriendo lanacion.com.ar.
  7 [txt] Estás en la portada de LA NACION, con los principales titulares. Los titulares principales son las primeras opciones.
  8 [H] Vos: no entiendo, ¿dónde estoy?
  9 [txt] Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
 10 [btn] Leer los titulares  (Primera de 3 opciones.)
 11 [btn] Resumir la portada
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
