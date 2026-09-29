# inss-contenido-tarde

**Quién:** Vive en Brasil, habla español, ciego. Quiere pedir la jubilación en el INSS.

**Qué quiere:** Que JEF camine hasta Meu INSS, que arma su página después de cargar, y siga con la jubilación en vez de decir que no hay nada para abrir.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:50620/portal.html»

- [+  6.3s] 💬 Persona: http://localhost:50620/portal.html
- [+  6.3s] 💬 JEF: Abriendo localhost.
- [+  6.3s] 🔊 «Abriendo localhost.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó http://localhost:50620/portal.html — «Meu INSS: passo a passo para pedir aposentadoria» (paginas/01.txt)
- [+ 10.8s] 💬 JEF: Estás en una nota sobre cómo solicitar la jubilación por el portal Meu INSS: indica entrar con la contraseña de gov.br, seleccionar «Nuevo pedido» y elegir el tipo de jubilación. También menciona cambios en la previsión social para 2026.
- [+ 10.8s] 🔊 «Estás en una nota sobre cómo solicitar la jubilación por el portal Meu INSS: indica entrar con la contraseña de gov.br, seleccionar «Nuevo pedido» y elegir el tipo de jubilación. También menciona cambios en la previsión social para 2026.»
- [+ 10.8s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Resumir la nota]
- [+ 10.8s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Resumir la nota] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50620/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en una nota sobre cómo solicitar la jubilación por el portal Meu INSS: indica entrar con la contraseña de gov.br, seleccionar «Nuevo pedido» y elegir el tipo de jubilación. También menciona cambios en la previsión social para 2026.
  6 [btn] Abrir «https://meu.inss.gov.br/»  (Primera de 4 opciones.)
  7 [btn] Leer la nota
  8 [btn] Resumir la nota
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «quiero pedir la jubilación»

- [+ 18.8s] 💬 Persona: quiero pedir la jubilación
- [+ 23.9s] 💬 JEF: Abriendo https://meu.inss.gov.br/.
- [+ 23.9s] 🔊 «Abriendo https://meu.inss.gov.br/.»
- [+ 24.5s] 📄 Cargó http://localhost:50620/inss.html — «Meu INSS» (paginas/02.txt)
- [+ 24.5s] 💬 JEF: Esta página no ofrece nada que pueda abrir.
- [+ 24.5s] 🔊 «Esta página no ofrece nada que pueda abrir.»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 24.5s] 🔘 Botones: [Volver a «Meu INSS: passo a passo para pedir aposentadoria»] · [Otra cosa]
- [+ 26.1s] 📄 Cargó http://localhost:50620/inss.html#/login — «Meu INSS» (paginas/03.txt)
- [+ 26.1s] 💬 JEF: La página cambió: ahora estás en «Meu INSS», localhost.
- [+ 26.1s] 🔊 «La página cambió: ahora estás en «Meu INSS», localhost.»
- [+ 26.1s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a «Meu INSS: passo a passo para pedir aposentadoria»] · [Otra cosa]

Al terminar el paso (16 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50620/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en una nota sobre cómo solicitar la jubilación por el portal Meu INSS: indica entrar con la contraseña de gov.br, seleccionar «Nuevo pedido» y elegir el tipo de jubilación. También menciona cambios en la previsión social para 2026.
  6 [H] Vos: quiero pedir la jubilación
  7 [txt] Abriendo https://meu.inss.gov.br/.
  8 [txt] Esta página no ofrece nada que pueda abrir.
  9 [txt] La página cambió: ahora estás en «Meu INSS», localhost.
 10 [btn] Leer la página  (Primera de 4 opciones.)
 11 [btn] Resumir la página
 12 [btn] Volver a «Meu INSS: passo a passo para pedir aposentadoria»
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
