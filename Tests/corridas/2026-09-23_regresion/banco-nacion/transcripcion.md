# banco-nacion

**Quién:** Ciega hace veinte años. Hace sus trámites del banco sola.

**Qué quiere:** Entrar al home banking del Banco Nación: llegar al ingreso y cargar el DNI.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «quiero entrar al home banking del banco nación»

- [+  6.6s] 💬 Persona: quiero entrar al home banking del banco nación
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Buscando: banco nación home banking.
- [+  7.7s] 🔊 «Buscando: banco nación home banking.»
- [+ 11.4s] 📄 Cargó https://www.google.com/search?q=banco%20naci%C3%B3n%20home%20banking&gl=us&hl=es — «banco nación home banking - Buscar con Google» (paginas/01.txt)
- [+ 12.0s] 💬 JEF: Estás en los resultados de «banco nación home banking». Los 3 más probables:
- [+ 12.0s] 🔊 «Estás en los resultados de «banco nación home banking». Los 3 más probables: 1. Home Banking, bna.com.ar. 2. Home banking, digital.bna.com.ar. 3. Banco de la Nación Argentina, bna.com.ar»
- [+ 12.0s] 🔘 Botones: [Home Banking — bna.com.ar] · [Home banking — digital.bna.com.ar] · [Banco de la Nación Argentina — www.bna.com.ar] · [Ver más opciones (3)]
- [+ 12.0s] 🔘 Botones: [Home Banking — bna.com.ar] · [Home banking — digital.bna.com.ar] · [Banco de la Nación Argentina — www.bna.com.ar] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero entrar al home banking del banco nación
  4 [txt] Buscando: banco nación home banking.
  5 [txt] Estás en los resultados de «banco nación home banking». Los 3 más probables:
  6 [btn] Home Banking — bna.com.ar  (Primera de 5 opciones.)
  7 [btn] Home banking — digital.bna.com.ar
  8 [btn] Banco de la Nación Argentina — www.bna.com.ar
  9 [btn] Ver más opciones (3)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Home Banking — bna.com.ar»

- [+ 18.7s] 💬 Persona: Home Banking — bna.com.ar
- [+ 18.7s] 💬 JEF: Abriendo bna.com.ar.
- [+ 18.7s] 🔊 «Abriendo bna.com.ar.»
- [+ 23.3s] 📄 Cargó https://bna.com.ar/Personas/Homebanking — «Banco de la Nación Argentina» (paginas/02.txt)
- [+ 24.8s] 💬 JEF: Esta es la página principal del Banco de la Nación Argentina, pero el sitio no se encuentra disponible en este momento y no es posible acceder al home banking. ¿Desea intentar acceder nuevamente al home banking o prefiere revisar alguna de estas opciones?
- [+ 24.8s] 🔊 «Esta es la página principal del Banco de la Nación Argentina, pero el sitio no se encuentra disponible en este momento y no es posible acceder al home banking. ¿Desea intentar acceder nuevamente al home banking o prefiere revisar alguna de estas opciones?»
- [+ 24.8s] 🔘 Botones: [Home] · [Home Banking] · [InterPyme] · [BNA Digital] · [Ver más opciones (1)]
- [+ 24.8s] 🔘 Botones: [Home] · [Home Banking] · [InterPyme] · [BNA Digital] · [Ver más opciones (1)] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero entrar al home banking del banco nación
  4 [txt] Buscando: banco nación home banking.
  5 [txt] Estás en los resultados de «banco nación home banking». Los 3 más probables:
  6 [H] Vos: Home Banking — bna.com.ar
  7 [txt] Abriendo bna.com.ar.
  8 [txt] Esta es la página principal del Banco de la Nación Argentina, pero el sitio no se encuentra disponible en este momento y no es posible acceder al home banking. ¿Desea intentar acceder nuevamente al home banking o prefiere revisar alguna de estas opciones?
  9 [btn] Home  (Primera de 7 opciones.)
 10 [btn] Home Banking
 11 [btn] InterPyme
 12 [btn] BNA Digital
 13 [btn] Ver más opciones (1)
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 3 — {"tocar": "DNI"}
> ⚠️ El paso no se pudo hacer: no hay opción 'DNI'; hay: ['Cerrar el asistente', 'Home', 'Home Banking', 'InterPyme', 'BNA Digital', 'Ver más opciones (1)', 'Volver a los resultados', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: quiero entrar al home banking del banco nación
  4 [txt] Buscando: banco nación home banking.
  5 [txt] Estás en los resultados de «banco nación home banking». Los 3 más probables:
  6 [H] Vos: Home Banking — bna.com.ar
  7 [txt] Abriendo bna.com.ar.
  8 [txt] Esta es la página principal del Banco de la Nación Argentina, pero el sitio no se encuentra disponible en este momento y no es posible acceder al home banking. ¿Desea intentar acceder nuevamente al home banking o prefiere revisar alguna de estas opciones?
  9 [btn] Home  (Primera de 7 opciones.)
 10 [btn] Home Banking
 11 [btn] InterPyme
 12 [btn] BNA Digital
 13 [btn] Ver más opciones (1)
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
