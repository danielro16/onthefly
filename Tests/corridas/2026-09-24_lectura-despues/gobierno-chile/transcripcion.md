# gobierno-chile

**Quién:** Vive en Chile, ciego. Entra al sitio del gobierno.

**Qué quiere:** Que JEF sepa qué tipo de sitio y de página es, y que los pasos que ofrece sean los probables para ese tipo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «www.gob.cl»

- [+  6.6s] 💬 Persona: www.gob.cl
- [+  6.6s] 💬 JEF: Abriendo gob.cl.
- [+  6.6s] 🔊 «Abriendo gob.cl.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.3s] 📄 Cargó https://www.gob.cl/ — «Un momento…» (paginas/01.txt)
- [+ 10.9s] 💬 JEF: Estás en el sitio del Gobierno de Chile, en una página de verificación de seguridad; indica que está comprobando que no eres un bot malicioso. No aparece aquí el contenido del sitio.
- [+ 10.9s] 🔊 «Estás en el sitio del Gobierno de Chile, en una página de verificación de seguridad; indica que está comprobando que no eres un bot malicioso. No aparece aquí el contenido del sitio.»
- [+ 10.9s] 🔘 Botones: [Abrir «Privacidad»]
- [+ 10.9s] 🔘 Botones: [Abrir «Privacidad»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: www.gob.cl
  4 [txt] Abriendo gob.cl.
  5 [txt] Estás en el sitio del Gobierno de Chile, en una página de verificación de seguridad; indica que está comprobando que no eres un bot malicioso. No aparece aquí el contenido del sitio.
  6 [btn] Abrir «Privacidad»  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```
