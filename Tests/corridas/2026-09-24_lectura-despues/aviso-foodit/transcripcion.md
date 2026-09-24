# aviso-foodit

**Quién:** Vive en Argentina, con baja visión. Entra a un sitio de recetas.

**Qué quiere:** Que Jev diga qué pide el aviso que tapa la página, y que sólo un aviso que pide una decisión (cookies, edad) vaya primero.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «foodit.lanacion.com.ar»

- [+  6.6s] 💬 Persona: foodit.lanacion.com.ar
- [+  6.6s] 💬 JEF: Abriendo foodit.lanacion.com.ar.
- [+  6.6s] 🔊 «Abriendo foodit.lanacion.com.ar.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.7s] 📄 Cargó https://foodit.lanacion.com.ar/ — «Recetas fáciles, qué cocinar hoy y menú semanal | Foodit» (paginas/01.txt)
- [+ 12.0s] 💬 JEF: Foodit es la página principal de una plataforma de recetas, guías y menús semanales; ofrece ideas para cocinar, tutoriales y recetas de nutricionistas y chefs. Un aviso de “PROMO EXCLUSIVA” cubre la página.
- [+ 12.0s] 🔊 «Foodit es la página principal de una plataforma de recetas, guías y menús semanales; ofrece ideas para cocinar, tutoriales y recetas de nutricionistas y chefs. Un aviso de “PROMO EXCLUSIVA” cubre la página.»
- [+ 12.0s] 🔘 Botones: [Abrir «Todas las recetas»] · [Buscar o preguntar a Foodit] · [Abrir «Almuerzos»]
- [+ 12.0s] 🔘 Botones: [Abrir «Todas las recetas»] · [Buscar o preguntar a Foodit] · [Abrir «Almuerzos»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: foodit.lanacion.com.ar
  4 [txt] Abriendo foodit.lanacion.com.ar.
  5 [txt] Foodit es la página principal de una plataforma de recetas, guías y menús semanales; ofrece ideas para cocinar, tutoriales y recetas de nutricionistas y chefs. Un aviso de “PROMO EXCLUSIVA” cubre la página.
  6 [btn] Abrir «Todas las recetas»  (Primera de 4 opciones.)
  7 [btn] Buscar o preguntar a Foodit
  8 [btn] Abrir «Almuerzos»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
