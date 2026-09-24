# cookies-correos

**Quién:** Vive en España, ciega. Entra a Correos y le sale el aviso de cookies.

**Qué quiere:** Que los botones del aviso sean lo primero, que al rechazar se cierre y queden los pasos de la página, y que después pueda seguir su envío.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «correos.es»

- [+  6.6s] 💬 Persona: correos.es
- [+  6.6s] 💬 JEF: Abriendo correos.es.
- [+  6.6s] 🔊 «Abriendo correos.es.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.5s] ❌ Error de carga: No readable content found (undefined is not an object (evaluating 'page.blocks.length')).
- [+  9.5s] 💬 JEF: No pude abrir esa página. Puede ser la conexión o el sitio.
- [+  9.5s] 🔊 «No pude abrir esa página. Puede ser la conexión o el sitio.»
- [+  9.5s] 🔘 Botones: [Intentar de nuevo] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: correos.es
  4 [txt] Abriendo correos.es.
  5 [txt] No pude abrir esa página. Puede ser la conexión o el sitio.
  6 [btn] Intentar de nuevo  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — {"tocar": "Rechaz"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Rechaz'; hay: ['Cerrar el asistente', 'Intentar de nuevo', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: correos.es
  4 [txt] Abriendo correos.es.
  5 [txt] No pude abrir esa página. Puede ser la conexión o el sitio.
  6 [btn] Intentar de nuevo  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```
