# bloqueo-lanacion

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lanacion.com.ar»

- [+  6.6s] 💬 Persona: lanacion.com.ar
- [+  6.6s] 💬 JEF: Abriendo lanacion.com.ar.
- [+  6.6s] 🔊 «Abriendo lanacion.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.1s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 14.2s] 💬 JEF: Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo, incluidas dos coberturas en vivo sobre las medidas de Milei y el dólar hoy. Los titulares principales son las primeras opciones.
- [+ 14.2s] 🔊 «Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo, incluidas dos coberturas en vivo sobre las medidas de Milei y el dólar hoy. Los titulares principales: 1. Entre la pompa y las tensiones. Trump recibe a Xi Jinping en la Casa Blanca y anticipa que discutirán “temas apremiantes”. 2. Renunció el administrador de la obra social de los militares y el gremio estatal tomó el edificio. 3. Del uso estratégico a un papelón masivo. Los futuros profesionales se forman con inteligencia artificial y surge un nuevo terror entre universitarios. 4. Una por una, las obras de infraestructura acordadas entre la Argentina y Estados Unidos.»
- [+ 14.2s] 🔘 Botones: [Abrir «Entre la pompa y las tensiones. Trump recibe a Xi Jinping en la Casa Blanca y anticipa que…»] · [Abrir «Renunció el administrador de la obra social de los militares y el gremio estatal tomó el edificio»] · [Abrir «Del uso estratégico a un papelón masivo. Los futuros profesionales se forman con inteligencia…»] · [Abrir «Una por una, las obras de infraestructura acordadas entre la Argentina y Estados Unidos»]
- [+ 14.2s] 🔘 Botones: [Abrir «Entre la pompa y las tensiones. Trump recibe a Xi Jinping en la Casa Blanca y anticipa que…»] · [Abrir «Renunció el administrador de la obra social de los militares y el gremio estatal tomó el edificio»] · [Abrir «Del uso estratégico a un papelón masivo. Los futuros profesionales se forman con inteligencia…»] · [Abrir «Una por una, las obras de infraestructura acordadas entre la Argentina y Estados Unidos»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lanacion.com.ar
  4 [txt] Abriendo lanacion.com.ar.
  5 [txt] Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo, incluidas dos coberturas en vivo sobre las medidas de Milei y el dólar hoy. Los titulares principales son las primeras opciones.
  6 [btn] Abrir «Entre la pompa y las tensiones. Trump recibe a Xi Jinping en la Casa Blanca y anticipa que…»  (Primera de 5 opciones.)
  7 [btn] Abrir «Renunció el administrador de la obra social de los militares y el gremio estatal tomó el edificio»
  8 [btn] Abrir «Del uso estratégico a un papelón masivo. Los futuros profesionales se forman con inteligencia…»
  9 [btn] Abrir «Una por una, las obras de infraestructura acordadas entre la Argentina y Estados Unidos»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
