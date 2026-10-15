# inss-contenido-tarde

**Quién:** Vive en Brasil, habla español, ciego. Quiere pedir la jubilación en el INSS.

**Qué quiere:** Que JEF camine hasta Meu INSS, que arma su página después de cargar, y siga con la jubilación en vez de decir que no hay nada para abrir.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:50704/portal.html»

- [+  6.3s] 💬 Persona: http://localhost:50704/portal.html
- [+  6.3s] 💬 JEF: Abriendo localhost.
- [+  6.3s] 🔊 «Abriendo localhost.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 📄 Cargó http://localhost:50704/portal.html — «Meu INSS: passo a passo para pedir aposentadoria» (paginas/01.txt)
- [+ 10.3s] 💬 JEF: Esta página serve para saber como pedir aposentadoria pelo portal Meu INSS. O passo a passo informa que é preciso entrar com a senha gov.br, selecionar “Novo Pedido” e escolher o tipo de aposentadoria.
- [+ 10.3s] 🔊 «Esta página serve para saber como pedir aposentadoria pelo portal Meu INSS. O passo a passo informa que é preciso entrar com a senha gov.br, selecionar “Novo Pedido” e escolher o tipo de aposentadoria.»
- [+ 10.3s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota]
- [+ 10.3s] 🔘 Botones: [Abrir «https://meu.inss.gov.br/»] · [Leer la nota] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50704/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Esta página serve para saber como pedir aposentadoria pelo portal Meu INSS. O passo a passo informa que é preciso entrar com a senha gov.br, selecionar “Novo Pedido” e escolher o tipo de aposentadoria.
  6 [btn] Abrir «https://meu.inss.gov.br/»  (Primera de 3 opciones.)
  7 [btn] Leer la nota
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «quiero pedir la jubilación»

- [+ 18.7s] 💬 Persona: quiero pedir la jubilación
- [+ 22.8s] 💬 JEF: Buscando: quiero pedir la jubilación.
- [+ 22.8s] 🔊 «Buscando: quiero pedir la jubilación.»
- [+ 25.9s] 📄 Cargó https://www.google.com/search?q=quiero%20pedir%20la%20jubilaci%C3%B3n&gl=us&hl=es — «quiero pedir la jubilación - Buscar con Google» (paginas/02.txt)
- [+ 26.1s] 💬 JEF: Estás en los resultados de «quiero pedir la jubilación». Los 3 más probables:
- [+ 26.1s] 🔊 «Estás en los resultados de «quiero pedir la jubilación». Los 3 más probables: 1. Planificador de beneficios: Jubilación | ¿Qué documentos…, ssa.gov. 2. Beneficios por Jubilación | SSA, ssa.gov. 3. Prepararse para la jubilación, usa.gov»
- [+ 26.1s] 🔘 Botones: [Planificador de beneficios: Jubilación | ¿Qué documentos necesitará ... — www.ssa.gov] · [Beneficios por Jubilación | SSA — www.ssa.gov] · [Prepararse para la jubilación — www.usa.gov] · [Ver más opciones (4)]
- [+ 26.1s] 🔘 Botones: [Planificador de beneficios: Jubilación | ¿Qué documentos necesitará ... — www.ssa.gov] · [Beneficios por Jubilación | SSA — www.ssa.gov] · [Prepararse para la jubilación — www.usa.gov] · [Ver más opciones (4)] · [Otra cosa]
- [+ 27.2s] 📄 Cargó https://www.google.com/search?q=quiero%20pedir%20la%20jubilaci%C3%B3n&gl=us&hl=es — «quiero pedir la jubilación - Buscar con Google» (paginas/03.txt)

Al terminar el paso (16 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:50704/portal.html
  4 [txt] Abriendo localhost.
  5 [txt] Esta página serve para saber como pedir aposentadoria pelo portal Meu INSS. O passo a passo informa que é preciso entrar com a senha gov.br, selecionar “Novo Pedido” e escolher o tipo de aposentadoria.
  6 [H] Vos: quiero pedir la jubilación
  7 [txt] Buscando: quiero pedir la jubilación.
  8 [txt] Estás en los resultados de «quiero pedir la jubilación». Los 3 más probables:
  9 [btn] Planificador de beneficios: Jubilación | ¿Qué documentos necesitará ... — www.ssa.gov  (Primera de 5 opciones.)
 10 [btn] Beneficios por Jubilación | SSA — www.ssa.gov
 11 [btn] Prepararse para la jubilación — www.usa.gov
 12 [btn] Ver más opciones (4)
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
