# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.6s] 💬 Persona: lanacion.com.ar
- [+  6.6s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.6s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.2s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 13.0s] 💬 JEF: Estás en la portada de noticias de LA NACION, con titulares de Argentina y el mundo. Arriba aparecen las noticias en vivo; la principal informa que el riesgo país subió 50 puntos en el día y ya supera los 600. Aquí también están las medidas de Milei y la cotización del dólar.
- [+ 13.0s] 🔊 «Estás en la portada de noticias de LA NACION, con titulares de Argentina y el mundo. Arriba aparecen las noticias en vivo; la principal informa que el riesgo país subió 50 puntos en el día y ya supera los 600. Aquí también están las medidas de Milei y la cotización del dólar.»
- [+ 13.0s] 🔘 Botones: [Abrir «La muerte del "Negro" González Oro»] · [Abrir «Tensión en los mercados financieros. El riesgo país sube 50 puntos en el día y ya se ubica por…»] · [Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»] · [Abrir «Patricia Bullrich se opuso al juicio político contra las juezas que frenaron el régimen penal…»] · [Leer los titulares]
- [+ 13.0s] 🔘 Botones: [Abrir «La muerte del "Negro" González Oro»] · [Abrir «Tensión en los mercados financieros. El riesgo país sube 50 puntos en el día y ya se ubica por…»] · [Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»] · [Abrir «Patricia Bullrich se opuso al juicio político contra las juezas que frenaron el régimen penal…»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] Estás en la portada de noticias de LA NACION, con titulares de Argentina y el mundo. Arriba aparecen las noticias en vivo; la principal informa que el riesgo país subió 50 puntos en el día y ya supera los 600. Aquí también están las medidas de Milei y la cotización del dólar.
  6 [btn] Abrir «La muerte del "Negro" González Oro»  (Primera de 6 opciones.)
  7 [btn] Abrir «Tensión en los mercados financieros. El riesgo país sube 50 puntos en el día y ya se ubica por…»
  8 [btn] Abrir «Murió el “Negro” González Oro, una de las grandes figuras de la radio»
  9 [btn] Abrir «Patricia Bullrich se opuso al juicio político contra las juezas que frenaron el régimen penal…»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
