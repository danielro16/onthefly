# cookies-lemonde

**Quién:** Vive en Francia. Entra a Le Monde y le sale el aviso de cookies.

**Qué quiere:** Que JEF conteste el aviso de cookies como eligió la persona (por ahora, aceptar todas) sin decir nada, y cuente la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «lemonde.fr»

- [+  6.6s] 💬 Persona: lemonde.fr
- [+  6.6s] 💬 JEF: Abriendo lemonde.fr.
- [+  6.6s] 🔊 «Abriendo lemonde.fr.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.2s] 📄 Cargó https://www.lemonde.fr/en/ — «Le Monde - World news, culture and opinion from the unique perspective of the leading French newspaper» (paginas/01.txt)
- [+ 11.8s] 💬 JEF: Le Monde es la portada del diario, con noticias internacionales, cultura y opinión. La noticia principal informa que el papa León XIV condenó la gestación subrogada, la compra de órganos y la idea de «organizar la propia muerte» durante un discurso en París, después de reunirse con Emmanuel Macron.
- [+ 11.8s] 🔊 «Le Monde es la portada del diario, con noticias internacionales, cultura y opinión. La noticia principal informa que el papa León XIV condenó la gestación subrogada, la compra de órganos y la idea de «organizar la propia muerte» durante un discurso en París, después de reunirse con Emmanuel Macron.»
- [+ 11.8s] 🔘 Botones: [Abrir «Pope Leo XIV stands firm on bioethics and AI in Paris speech»] · [Abrir «Netanyahu overflies French airspace again despite ICC arrest warrant»] · [Abrir «Goncourt removes novel from longlist after claims of using AI»] · [Abrir «Far-right suspected killer of Argentine rugby star asks for forgiveness ahead…»] · [Leer los titulares]
- [+ 11.8s] 🔘 Botones: [Abrir «Pope Leo XIV stands firm on bioethics and AI in Paris speech»] · [Abrir «Netanyahu overflies French airspace again despite ICC arrest warrant»] · [Abrir «Goncourt removes novel from longlist after claims of using AI»] · [Abrir «Far-right suspected killer of Argentine rugby star asks for forgiveness ahead…»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: lemonde.fr
  4 [txt] Abriendo lemonde.fr.
  5 [txt] Le Monde es la portada del diario, con noticias internacionales, cultura y opinión. La noticia principal informa que el papa León XIV condenó la gestación subrogada, la compra de órganos y la idea de «organizar la propia muerte» durante un discurso en París, después de reunirse con Emmanuel Macron.
  6 [btn] Abrir «Pope Leo XIV stands firm on bioethics and AI in Paris speech»  (Primera de 6 opciones.)
  7 [btn] Abrir «Netanyahu overflies French airspace again despite ICC arrest warrant»
  8 [btn] Abrir «Goncourt removes novel from longlist after claims of using AI»
  9 [btn] Abrir «Far-right suspected killer of Argentine rugby star asks for forgiveness ahead…»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
