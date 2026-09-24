# buscar-en-gobpe

**Quién:** Vive en Perú, con baja visión. Quiere buscar en el sitio del Estado cómo sacar el pasaporte.

**Qué quiere:** Que el buscador del sitio sea un solo botón «Buscar en…», que pregunte qué buscar y busque, sin «Completar» ni «Pulsar».

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «gob.pe»

- [+  7.6s] 💬 Persona: gob.pe
- [+  7.6s] 💬 JEF: Abriendo gob.pe.
- [+  7.6s] 🔊 «Abriendo gob.pe.»
- [+  7.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.1s] ❌ Error de carga: Could not load the page: No se ha encontrado ningún servidor con el nombre de host especificado.
- [+  8.1s] 💬 JEF: No pude abrir esa página. Puede ser la conexión o el sitio.
- [+  8.1s] 🔊 «No pude abrir esa página. Puede ser la conexión o el sitio.»
- [+  8.1s] 🔘 Botones: [Intentar de nuevo] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] No pude abrir esa página. Puede ser la conexión o el sitio.
  6 [btn] Intentar de nuevo  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — {"tocar": "Buscar"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Buscar'; hay: ['Cerrar el asistente', 'Intentar de nuevo', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: gob.pe
  4 [txt] Abriendo gob.pe.
  5 [txt] No pude abrir esa página. Puede ser la conexión o el sitio.
  6 [btn] Intentar de nuevo  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```
