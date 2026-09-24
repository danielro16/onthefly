# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.4s] 💬 Persona: lanacion.com.ar
- [+  6.4s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.4s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.1s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 16.3s] 💬 JEF: Estás en la portada de LA NACION, el diario de noticias de Argentina y el mundo. La historia principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos. Al pie de la página hay avisos de suscripción y descargas de la aplicación que no cubren el contenido.
- [+ 16.3s] 🔊 «Estás en la portada de LA NACION, el diario de noticias de Argentina y el mundo. La historia principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos. Al pie de la página hay avisos de suscripción y descargas de la aplicación que no cubren el contenido.»
- [+ 16.3s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «El oficialismo logró aprobar la reforma del Banco Central, pero volverá con modificaciones a…»] · [Abrir «Le Priol no nació siendo Hannibal Lecter", dijo su abogado: visualiza una pena "cercana a los 25…»] · [Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»] · [Leer los titulares]
- [+ 16.3s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «El oficialismo logró aprobar la reforma del Banco Central, pero volverá con modificaciones a…»] · [Abrir «Le Priol no nació siendo Hannibal Lecter", dijo su abogado: visualiza una pena "cercana a los 25…»] · [Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] Estás en la portada de LA NACION, el diario de noticias de Argentina y el mundo. La historia principal es un dato oficial: la pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos. Al pie de la página hay avisos de suscripción y descargas de la aplicación que no cubren el contenido.
  6 [btn] Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»  (Primera de 6 opciones.)
  7 [btn] Abrir «El oficialismo logró aprobar la reforma del Banco Central, pero volverá con modificaciones a…»
  8 [btn] Abrir «Le Priol no nació siendo Hannibal Lecter", dijo su abogado: visualiza una pena "cercana a los 25…»
  9 [btn] Abrir «En EE.UU. Milei, ante inversores: “Si somos reelectos, 2028 será el mejor año económico de la…»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
