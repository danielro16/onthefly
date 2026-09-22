# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.3s] 💬 JEF: Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
- [+  7.3s] 🔊 «Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~58%)
- [+  7.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
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

- [+ 14.3s] 💬 Persona: Llevame a La Nación
- [+ 14.3s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 14.3s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 18.4s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 19.9s] 💬 JEF: Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La cotización del dólar oficial es de $1535,00, el dólar blue está en $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1538,32. Te leo los titulares: Los titulares principales son las primeras opciones.
- [+ 19.9s] 🔊 «Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La cotización del dólar oficial es de $1535, el dólar blue está en $1550, el dólar tarjeta a $1995,50 y el dólar MEP a $1538,32. Te leo los titulares: Los titulares principales: 1. Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”. 2. Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a un adolescente. 3. Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes presupuestarios. 4. La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su padre soy yo".»
- [+ 19.9s] 🔘 Botones: [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»] · [Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»] · [Abrir «Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes…»] · [Abrir «La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su…»]
- [+ 19.9s] 🔘 Botones: [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»] · [Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»] · [Abrir «Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes…»] · [Abrir «La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su…»] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La cotización del dólar oficial es de $1535,00, el dólar blue está en $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1538,32. Te leo los titulares: Los titulares principales son las primeras opciones.
  7 [btn] Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”»  (Primera de 5 opciones.)
  8 [btn] Abrir «Una jueza declaró la inconstitucionalidad de la ley que bajó la punibilidad a 14 años y sobreseyó a…»
  9 [btn] Abrir «Renunció el secretario de Discapacidad en medio de la interna del Gobierno por los recortes…»
 10 [btn] Abrir «La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su…»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 27.3s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 27.9s] 💬 JEF: Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
- [+ 27.9s] 🔊 «Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.»
- [+ 28.0s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.
  4 [H] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La cotización del dólar oficial es de $1535,00, el dólar blue está en $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1538,32. Te leo los titulares: Los titulares principales son las primeras opciones.
  7 [H] Vos: no entiendo, ¿dónde estoy?
  8 [txt] Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
  9 [btn] Leer los titulares  (Primera de 3 opciones.)
 10 [btn] Resumir la portada
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
