# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.5s] 💬 Persona: lanacion.com.ar
- [+  6.5s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.5s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.3s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 14.0s] 💬 JEF: La Nación es la portada de noticias de Argentina y el mundo. La noticia principal informa que la pobreza llegó al 32,3% en el primer semestre y que hay 2 millones de personas pobres más; también aparece en vivo “Medidas de Milei”.
- [+ 14.0s] 🔊 «La Nación es la portada de noticias de Argentina y el mundo. La noticia principal informa que la pobreza llegó al 32,3% en el primer semestre y que hay 2 millones de personas pobres más; también aparece en vivo “Medidas de Milei”.»
- [+ 14.0s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «En un trámite inesperado y veloz, el Senado sancionó el recorte de subsidios al gas»] · [Abrir «Milei se reunió con Netanyahu: hablaron de Malvinas e intercambiaron fuertes elogios»] · [Abrir «El provocador “regalo” que el representante de Israel quiso entregarle a Irán en la ONU»] · [Leer los titulares]
- [+ 14.0s] 🔘 Botones: [Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»] · [Abrir «En un trámite inesperado y veloz, el Senado sancionó el recorte de subsidios al gas»] · [Abrir «Milei se reunió con Netanyahu: hablaron de Malvinas e intercambiaron fuertes elogios»] · [Abrir «El provocador “regalo” que el representante de Israel quiso entregarle a Irán en la ONU»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] La Nación es la portada de noticias de Argentina y el mundo. La noticia principal informa que la pobreza llegó al 32,3% en el primer semestre y que hay 2 millones de personas pobres más; también aparece en vivo “Medidas de Milei”.
  6 [btn] Abrir «La pobreza creció a 32,3% en el primer semestre y hay 2 millones de pobres nuevos»  (Primera de 6 opciones.)
  7 [btn] Abrir «En un trámite inesperado y veloz, el Senado sancionó el recorte de subsidios al gas»
  8 [btn] Abrir «Milei se reunió con Netanyahu: hablaron de Malvinas e intercambiaron fuertes elogios»
  9 [btn] Abrir «El provocador “regalo” que el representante de Israel quiso entregarle a Irán en la ONU»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
