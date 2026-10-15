# inss-contenido-tarde

**Quién:** Vive en Brasil, habla español, ciego. Quiere pedir la jubilación en el INSS.

**Qué quiere:** Que JEF camine hasta Meu INSS, que arma su página después de cargar, y siga con la jubilación en vez de decir que no hay nada para abrir.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:52347/portal.html»

- [+  6.1s] 💬 Persona: http://localhost:52347/portal.html
- [+  6.1s] 💬 JEF: Abriendo localhost.
- [+  6.1s] 🔊 «Abriendo localhost.»
- [+  6.2s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.3s] 📄 Cargó http://localhost:52347/portal.html — «Meu INSS: passo a passo para pedir aposentadoria» (paginas/01.txt)
- [+  9.8s] 💬 JEF: Esta página do Meu INSS explica como pedir aposentadoria pelo portal: acessar o Meu INSS, entrar com a senha gov.br e escolher o tipo de aposentadoria em «Novo Pedido».
- [+  9.8s] 🔊 «Esta página do Meu INSS explica como pedir aposentadoria pelo portal: acessar o Meu INSS, entrar com a senha gov.br e escolher o tipo de aposentadoria em «Novo Pedido».»
- [+  9.8s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota]
- [+  9.8s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:52347/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Esta página do Meu INSS explica como pedir aposentadoria pelo portal: acessar o Meu INSS, entrar com a senha gov.br e escolher o tipo de aposentadoria em «Novo Pedido».
  6 [btn] Abrir «https://meu.inss.gov.br/»  (Primera de 3 opciones.)
  7 [btn] Leer la nota
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «quiero pedir la jubilación»

- [+ 18.0s] 💬 Persona: quiero pedir la jubilación
- [+ 22.8s] 💬 JEF: Abriendo https://meu.inss.gov.br/.
- [+ 22.8s] 🔊 «Abriendo https://meu.inss.gov.br/.»
- [+ 23.4s] 📄 Cargó http://localhost:52347/inss.html — «Meu INSS» (paginas/02.txt)
- [+ 24.9s] 📄 Cargó http://localhost:52347/inss.html#/login — «Meu INSS» (paginas/03.txt)
- [+ 28.3s] 💬 JEF: Meu INSS es el portal de servicios del gobierno; sirve para iniciar un pedido, consultar el calendario de pagos y encontrar una agencia. Esta página permite avanzar con la solicitud de jubilación desde «Novo Pedido».
- [+ 28.3s] 🔊 «Meu INSS es el portal de servicios del gobierno; sirve para iniciar un pedido, consultar el calendario de pagos y encontrar una agencia. Esta página permite avanzar con la solicitud de jubilación desde «Novo Pedido».»
- [+ 28.3s] 🔘 Botones: [Abrir «Novo Pedido»] · [Abrir «Mais Serviços»]
- [+ 30.9s] 💬 JEF: «Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.
- [+ 30.9s] 🔊 ««Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.»  ⟶ en cola: empieza a sonar a los +43.7s
- [+ 30.9s] 🔘 Botones: [Pulsar «Novo Pedido»]
- [+ 30.9s] 🔘 Botones: [Pulsar «Novo Pedido»] · [Volver a «Meu INSS: passo a passo para pedir aposentadoria»] · [Otra cosa]

Al terminar el paso (20 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:52347/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Esta página do Meu INSS explica como pedir aposentadoria pelo portal: acessar o Meu INSS, entrar com a senha gov.br e escolher o tipo de aposentadoria em «Novo Pedido».
  6 [H] Vos: quiero pedir la jubilación
  7 [txt] Abriendo https://meu.inss.gov.br/.
  8 [txt] Meu INSS es el portal de servicios del gobierno; sirve para iniciar un pedido, consultar el calendario de pagos y encontrar una agencia. Esta página permite avanzar con la solicitud de jubilación desde «Novo Pedido».
  9 [txt] «Novo Pedido» puede confirmar algo: queda abajo, para tocarlo.
 10 [btn] Pulsar «Novo Pedido»  (Primera de 3 opciones.)
 11 [btn] Volver a «Meu INSS: passo a passo para pedir aposentadoria»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
