# estaciones-elegir

**Quién:** Ciega, habla castellano, en Italia. Busca un tren y no sabe los nombres de las estaciones.

**Qué quiere:** Que JEF, al escribir «Roma», no diga «Listo» sin estación elegida: que pregunte cuál, con las primeras como botones; que entienda «Termini» dicho en palabras y un botón tocado, y que siga con el resto del pedido. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/estaciones.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/estaciones.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/01.txt)
- [+ 10.3s] 💬 JEF: Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.
- [+ 10.3s] 🔊 «Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.»
- [+ 10.3s] 🔘 Botones: [Buscar un viaje en Treni]
- [+ 10.3s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.
  6 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «quiero un tren de Roma a Milano»

- [+ 18.3s] 💬 Persona: quiero un tren de Roma a Milano
- [+ 24.1s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/02.txt)
- [+ 24.4s] 💬 JEF: Hay 6 opciones para «Roma». ¿Cuál?
- [+ 24.4s] 🔊 «Hay 6 opciones para «Roma». ¿Cuál? Roma (Tutte le stazioni). Roma Termini. Roma Tiburtina»
- [+ 24.4s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)]
- [+ 24.4s] 💬 JEF: Cuando elijas, sigo con «Inserisci Milano nel campo Arrivo e premi Cerca.».
- [+ 24.4s] 🔊 «Cuando elijas, sigo con «Inserisci Milano nel campo Arrivo e premi Cerca.».»  ⟶ en cola: empieza a sonar a los +30.8s
- [+ 24.4s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano nel campo Arrivo e premi Cerca.».
  9 [btn] Roma (Tutte le stazioni)  (Primera de 5 opciones.)
 10 [btn] Roma Termini
 11 [btn] Roma Tiburtina
 12 [btn] Ver más opciones (3)
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
 16 [grp] Barra de herramientas
```

## Paso 3 — escribe «Termini»

- [+ 32.2s] 💬 Persona: Termini
- [+ 32.7s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/03.txt)
- [+ 32.7s] 💬 JEF: Listo: elegí «Roma Termini».
- [+ 32.7s] 🔊 «Listo: elegí «Roma Termini».»
- [+ 35.3s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/04.txt)
- [+ 35.6s] 💬 JEF: Hay 4 opciones para «Milano». ¿Cuál?
- [+ 35.6s] 🔊 «Hay 4 opciones para «Milano». ¿Cuál? Milano (Tutte le stazioni). Milano Centrale. Milano Porta Garibaldi»
- [+ 35.6s] 🔘 Botones: [Milano (Tutte le stazioni)] · [Milano Centrale] · [Milano Porta Garibaldi] · [Ver más opciones (1)]
- [+ 35.6s] 🔘 Botones: [Milano (Tutte le stazioni)] · [Milano Centrale] · [Milano Porta Garibaldi] · [Ver más opciones (1)] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano nel campo Arrivo e premi Cerca.».
  9 [H] Vos: Termini
 10 [txt] Listo: elegí «Roma Termini».
 11 [txt] Hay 4 opciones para «Milano». ¿Cuál?
 12 [btn] Milano (Tutte le stazioni)  (Primera de 5 opciones.)
 13 [btn] Milano Centrale
 14 [btn] Milano Porta Garibaldi
 15 [btn] Ver más opciones (1)
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
 19 [grp] Barra de herramientas
```

## Paso 4 — toca el botón Centrale: «Milano Centrale»

- [+ 42.6s] 💬 Persona: Milano Centrale
- [+ 43.1s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/05.txt)
- [+ 43.1s] 💬 JEF: Listo: elegí «Milano Centrale».
- [+ 43.1s] 🔊 «Listo: elegí «Milano Centrale».»
- [+ 43.1s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni es una página para buscar un viaje en tren; el formulario pide el lugar de partida y el destino.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano nel campo Arrivo e premi Cerca.».
  9 [H] Vos: Termini
 10 [txt] Listo: elegí «Roma Termini».
 11 [txt] Hay 4 opciones para «Milano». ¿Cuál?
 12 [H] Vos: Milano Centrale
 13 [txt] Listo: elegí «Milano Centrale».
 14 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
