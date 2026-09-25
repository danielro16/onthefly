# anti-robot-codigo-dibujado

**Quién:** Ciega. Entra a un sistema del Estado que pide copiar un código dibujado en una imagen.

**Qué quiere:** Que JEF reconozca el código dibujado por el nombre que le da el código de la página, y diga que hay que resolverlo en la página, en vez de preguntar qué escribir.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:64997/codigo-dibujado.html»

- [+  6.6s] 💬 Persona: http://localhost:64997/codigo-dibujado.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó http://localhost:64997/codigo-dibujado.html — «Clave de la Seguridad Social» (paginas/01.txt)
- [+  7.9s] 💬 JEF: El sitio web pide copiar un código dibujado en una imagen, y eso no lo puedo hacer yo: hace falta resolverlo en la página. Cuando esté resuelto, seguimos.
- [+  7.9s] 🔊 «El sitio web pide copiar un código dibujado en una imagen, y eso no lo puedo hacer yo: hace falta resolverlo en la página. Cuando esté resuelto, seguimos.»
- [+  7.9s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:64997/codigo-dibujado.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide copiar un código dibujado en una imagen, y eso no lo puedo hacer yo: hace falta resolverlo en la página. Cuando esté resuelto, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```
