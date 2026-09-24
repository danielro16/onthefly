# bloqueo-elmundo

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «elmundo.es»

- [+  6.6s] 💬 Persona: elmundo.es
- [+  6.6s] 💬 JEF: Abriendo elmundo.es.
- [+  6.6s] 🔊 «Abriendo elmundo.es.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.4s] 📄 Cargó https://www.elmundo.es/ — «EL MUNDO - Diario online líder de información en español» (paginas/01.txt)
- [+ 10.9s] 📄 Cargó https://www.elmundo.es/ — «EL MUNDO - Diario online líder de información en español» (paginas/02.txt)
- [+ 14.4s] 💬 JEF: Estás en la portada de EL MUNDO, un diario online. La noticia principal alerta de que la CIA teme un ataque ruso con drones contra España, Francia o Italia; la portada también destaca que Bruselas reconoce ataques híbridos de Rusia contra Estados de la Unión Europea.
- [+ 14.4s] 🔊 «Estás en la portada de EL MUNDO, un diario online. La noticia principal alerta de que la CIA teme un ataque ruso con drones contra España, Francia o Italia; la portada también destaca que Bruselas reconoce ataques híbridos de Rusia contra Estados de la Unión Europea.»
- [+ 14.4s] 🔘 Botones: [Abrir «Portada del viernes 25 de septiembre»] · [Abrir «Asamblea General de la ONU»] · [Abrir «Delcy: la caza de la legitimidad»] · [Abrir «Completa el tablero descifrando las definiciones»] · [Leer los titulares]
- [+ 14.4s] 🔘 Botones: [Abrir «Portada del viernes 25 de septiembre»] · [Abrir «Asamblea General de la ONU»] · [Abrir «Delcy: la caza de la legitimidad»] · [Abrir «Completa el tablero descifrando las definiciones»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: elmundo.es
  4 [txt] Abriendo elmundo.es.
  5 [txt] Estás en la portada de EL MUNDO, un diario online. La noticia principal alerta de que la CIA teme un ataque ruso con drones contra España, Francia o Italia; la portada también destaca que Bruselas reconoce ataques híbridos de Rusia contra Estados de la Unión Europea.
  6 [btn] Abrir «Portada del viernes 25 de septiembre»  (Primera de 6 opciones.)
  7 [btn] Abrir «Asamblea General de la ONU»
  8 [btn] Abrir «Delcy: la caza de la legitimidad»
  9 [btn] Abrir «Completa el tablero descifrando las definiciones»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
