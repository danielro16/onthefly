# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.3s] 💬 Persona: lanacion.com.ar
- [+  6.3s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.3s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.3s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 11.9s] 💬 JEF: Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La noticia principal informa que murió a los 74 años Oscar “el Negro” González Oro, una de las grandes figuras de la radio.
- [+ 11.9s] 🔊 «Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La noticia principal informa que murió a los 74 años Oscar “el Negro” González Oro, una de las grandes figuras de la radio.»
- [+ 11.9s] 🔘 Botones: [Abrir «La muerte del "Negro" González Oro»] · [Abrir «Revocaron el fallo que sobreseyó a un chico de 14 años y apartaron del caso a la jueza»] · [Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»] · [Abrir «Choque de poderes por los "ñoquis". La Justicia cita a 10 exsenadores y pide investigar si la…»] · [Leer los titulares] · [Resumir la página]
- [+ 11.9s] 🔘 Botones: [Abrir «La muerte del "Negro" González Oro»] · [Abrir «Revocaron el fallo que sobreseyó a un chico de 14 años y apartaron del caso a la jueza»] · [Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»] · [Abrir «Choque de poderes por los "ñoquis". La Justicia cita a 10 exsenadores y pide investigar si la…»] · [Leer los titulares] · [Resumir la página] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. La noticia principal informa que murió a los 74 años Oscar “el Negro” González Oro, una de las grandes figuras de la radio.
  6 [btn] Abrir «La muerte del "Negro" González Oro»  (Primera de 7 opciones.)
  7 [btn] Abrir «Revocaron el fallo que sobreseyó a un chico de 14 años y apartaron del caso a la jueza»
  8 [btn] Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»
  9 [btn] Abrir «Choque de poderes por los "ñoquis". La Justicia cita a 10 exsenadores y pide investigar si la…»
 10 [btn] Leer los titulares
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
