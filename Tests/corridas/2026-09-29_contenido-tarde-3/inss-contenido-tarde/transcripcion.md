# inss-contenido-tarde

**Quién:** Vive en Brasil, habla español, ciego. Quiere pedir la jubilación en el INSS.

**Qué quiere:** Que JEF camine hasta Meu INSS, que arma su página después de cargar, y siga con la jubilación en vez de decir que no hay nada para abrir.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:50720/portal.html»

- [+  6.6s] 💬 Persona: http://localhost:50720/portal.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.9s] 📄 Cargó http://localhost:50720/portal.html — «Meu INSS: passo a passo para pedir aposentadoria» (paginas/01.txt)
- [+ 10.7s] 💬 JEF: Este artículo explica cómo solicitar la jubilación por el portal Meu INSS: entrar con la contraseña gov.br y elegir el tipo de jubilación en «Nuevo pedido». También menciona cambios en la previsión social para 2026.
- [+ 10.7s] 🔊 «Este artículo explica cómo solicitar la jubilación por el portal Meu INSS: entrar con la contraseña gov.br y elegir el tipo de jubilación en «Nuevo pedido». También menciona cambios en la previsión social para 2026.»
- [+ 10.7s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Abrir «Notícias»]
- [+ 10.7s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Abrir «Notícias»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50720/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Este artículo explica cómo solicitar la jubilación por el portal Meu INSS: entrar con la contraseña gov.br y elegir el tipo de jubilación en «Nuevo pedido». También menciona cambios en la previsión social para 2026.
  6 [btn] Abrir «https://meu.inss.gov.br/»  (Primera de 4 opciones.)
  7 [btn] Leer la nota
  8 [btn] Abrir «Notícias»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «quiero pedir la jubilación»

- [+ 19.2s] 💬 Persona: quiero pedir la jubilación
- [+ 25.2s] 💬 JEF: Abriendo https://meu.inss.gov.br/.
- [+ 25.2s] 🔊 «Abriendo https://meu.inss.gov.br/.»
- [+ 25.9s] 📄 Cargó http://localhost:50720/inss.html — «Meu INSS» (paginas/02.txt)
- [+ 27.4s] 📄 Cargó http://localhost:50720/inss.html#/login — «Meu INSS» (paginas/03.txt)
- [+ 30.1s] 💬 JEF: Esta página de Meu INSS sirve para iniciar tu solicitud de jubilación desde «Novo Pedido».
- [+ 30.1s] 🔊 «Esta página de Meu INSS sirve para iniciar tu solicitud de jubilación desde «Novo Pedido».»
- [+ 30.1s] 🔘 Botones: [Abrir «Novo Pedido»] · [Abrir «Mais Serviços»]
- [+ 32.6s] 💬 JEF: «Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.
- [+ 32.6s] 🔊 ««Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.»  ⟶ en cola: empieza a sonar a los +36.6s
- [+ 32.6s] 🔘 Botones: [Pulsar «Novo Pedido»]
- [+ 32.6s] 🔘 Botones: [Pulsar «Novo Pedido»] · [Volver a «Meu INSS: passo a passo para pedir aposentadoria»] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50720/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Este artículo explica cómo solicitar la jubilación por el portal Meu INSS: entrar con la contraseña gov.br y elegir el tipo de jubilación en «Nuevo pedido». También menciona cambios en la previsión social para 2026.
  6 [H] Vos: quiero pedir la jubilación
  7 [txt] Abriendo https://meu.inss.gov.br/.
  8 [txt] Esta página de Meu INSS sirve para iniciar tu solicitud de jubilación desde «Novo Pedido».
  9 [txt] «Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.
 10 [btn] Pulsar «Novo Pedido»  (Primera de 3 opciones.)
 11 [btn] Volver a «Meu INSS: passo a passo para pedir aposentadoria»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
