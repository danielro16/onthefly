# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.6s] 💬 Persona: lanacion.com.ar
- [+  6.6s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.6s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.3s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 13.0s] 💬 JEF: Estás en la portada de La Nación, el diario de noticias. La nota principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre, con 2 millones de pobres nuevos. También hay en vivo sobre las medidas de Milei y el dólar, actualizado hace 3 minutos.
- [+ 13.0s] 🔊 «Estás en la portada de La Nación, el diario de noticias. La nota principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre, con 2 millones de pobres nuevos. También hay en vivo sobre las medidas de Milei y el dólar, actualizado hace 3 minutos.»
- [+ 13.0s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»] · [Abrir «Delegaciones abandonan la sala antes del discurso de Netanyahu y él las acusa de “cobardes”»] · [Abrir «Mientras más argentinos se sumergen en la pobreza, se descartan 73 millones de kilos de alimentos…»] · [Leer los titulares] · [Resumir la página]
- [+ 13.0s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»] · [Abrir «Delegaciones abandonan la sala antes del discurso de Netanyahu y él las acusa de “cobardes”»] · [Abrir «Mientras más argentinos se sumergen en la pobreza, se descartan 73 millones de kilos de alimentos…»] · [Leer los titulares] · [Resumir la página] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] Estás en la portada de La Nación, el diario de noticias. La nota principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre, con 2 millones de pobres nuevos. También hay en vivo sobre las medidas de Milei y el dólar, actualizado hace 3 minutos.
  6 [btn] Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»  (Primera de 7 opciones.)
  7 [btn] Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»
  8 [btn] Abrir «Delegaciones abandonan la sala antes del discurso de Netanyahu y él las acusa de “cobardes”»
  9 [btn] Abrir «Mientras más argentinos se sumergen en la pobreza, se descartan 73 millones de kilos de alimentos…»
 10 [btn] Leer los titulares
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
