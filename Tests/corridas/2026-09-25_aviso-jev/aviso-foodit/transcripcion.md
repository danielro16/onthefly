# aviso-foodit

**Quién:** Vive en Argentina, con baja visión. Entra a un sitio de recetas.

**Qué quiere:** Que Jev diga qué pide el aviso que tapa la página, y que sólo un aviso que pide una decisión (cookies, edad) vaya primero.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «foodit.lanacion.com.ar»

- [+  6.5s] 💬 Persona: foodit.lanacion.com.ar
- [+  6.5s] 💬 JEF: Abriendo foodit.lanacion.com.ar.
- [+  6.5s] 🔊 «Abriendo foodit.lanacion.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.3s] 📄 Cargó https://foodit.lanacion.com.ar/ — «Recetas fáciles, qué cocinar hoy y menú semanal | Foodit» (paginas/01.txt)
- [+ 13.5s] 📄 Cargó https://foodit.lanacion.com.ar/ — «Recetas fáciles, qué cocinar hoy y menú semanal | Foodit» (paginas/02.txt)
- [+ 16.4s] 💬 JEF: Estás en la página de inicio de Foodit, una plataforma de recetas, guías de cocina, clases con chefs y menús semanales; desde aquí puedes buscar recetas y organizar comidas.
- [+ 16.4s] 🔊 «Estás en la página de inicio de Foodit, una plataforma de recetas, guías de cocina, clases con chefs y menús semanales; desde aquí puedes buscar recetas y organizar comidas.»
- [+ 16.4s] 🔘 Botones: [Buscar recetas en Foodit] · [Abrir «Todas las recetas»] · [Abrir «Mi menú semanal»]
- [+ 16.4s] 🔘 Botones: [Buscar recetas en Foodit] · [Abrir «Todas las recetas»] · [Abrir «Mi menú semanal»] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: foodit.lanacion.com.ar
  4 [txt] Abriendo foodit.lanacion.com.ar.
  5 [txt] Estás en la página de inicio de Foodit, una plataforma de recetas, guías de cocina, clases con chefs y menús semanales; desde aquí puedes buscar recetas y organizar comidas.
  6 [btn] Buscar recetas en Foodit  (Primera de 4 opciones.)
  7 [btn] Abrir «Todas las recetas»
  8 [btn] Abrir «Mi menú semanal»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
