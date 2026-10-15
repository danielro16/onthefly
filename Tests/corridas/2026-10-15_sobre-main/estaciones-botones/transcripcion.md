# estaciones-botones

**Quién:** Ciega. Elige estaciones tocando los botones que ofrece JEF.

**Qué quiere:** Que tocar una opción la elija en la página, y que «Ver más opciones» muestre el resto de la lista. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/estaciones.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/estaciones.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/01.txt)
- [+  9.7s] 💬 JEF: Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
- [+  9.7s] 🔊 «Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.»
- [+  9.7s] 🔘 Botones: [Buscar un viaje en Treni]
- [+  9.7s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «poné Roma en partenza»

- [+ 18.4s] 💬 Persona: poné Roma en partenza
- [+ 20.9s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/02.txt)
- [+ 21.3s] 💬 JEF: Hay 6 opciones para «Roma». ¿Cuál?
- [+ 21.3s] 🔊 «Hay 6 opciones para «Roma». ¿Cuál? Roma (Tutte le stazioni). Roma Termini. Roma Tiburtina»
- [+ 21.3s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)]
- [+ 21.3s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: poné Roma en partenza
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [btn] Roma (Tutte le stazioni)  (Primera de 5 opciones.)
  9 [btn] Roma Termini
 10 [btn] Roma Tiburtina
 11 [btn] Ver más opciones (3)
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
 15 [grp] Barra de herramientas
```

## Paso 3 — toca el botón Tiburtina: «Roma Tiburtina»

- [+ 27.0s] 💬 Persona: Roma Tiburtina
- [+ 27.6s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/03.txt)
- [+ 27.6s] 💬 JEF: Listo: elegí «Roma Tiburtina».
- [+ 27.6s] 🔊 «Listo: elegí «Roma Tiburtina».»
- [+ 27.6s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: poné Roma en partenza
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [H] Vos: Roma Tiburtina
  9 [txt] Listo: elegí «Roma Tiburtina».
 10 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 4 — escribe «poné Milano en arrivo»

- [+ 36.5s] 💬 Persona: poné Milano en arrivo
- [+ 40.0s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/04.txt)
- [+ 40.3s] 💬 JEF: Hay 4 opciones para «Milano». ¿Cuál?
- [+ 40.3s] 🔊 «Hay 4 opciones para «Milano». ¿Cuál? Milano (Tutte le stazioni). Milano Centrale. Milano Porta Garibaldi»
- [+ 40.3s] 🔘 Botones: [Milano (Tutte le stazioni)] · [Milano Centrale] · [Milano Porta Garibaldi] · [Ver más opciones (1)]
- [+ 40.3s] 🔘 Botones: [Milano (Tutte le stazioni)] · [Milano Centrale] · [Milano Porta Garibaldi] · [Ver más opciones (1)] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: poné Roma en partenza
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [H] Vos: Roma Tiburtina
  9 [txt] Listo: elegí «Roma Tiburtina».
 10 [H] Vos: poné Milano en arrivo
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

## Paso 5 — toca el botón Ver más: «Ver más opciones (1)»

- [+ 48.0s] 💬 Persona: Ver más opciones (1)
- [+ 48.0s] 💬 JEF: Más opciones.
- [+ 48.0s] 🔊 «Más opciones: Milano Rogoredo»
- [+ 48.0s] 🔘 Botones: [Milano Rogoredo]
- [+ 48.0s] 🔘 Botones: [Milano Rogoredo] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [btn] Volver
  2 [btn] Abrir el asistente  = localhost
  3 [grp] Barra de herramientas
```

## Paso 6 — {"boton": "Rogoredo"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Rogoredo'; hay: ['Volver', 'Abrir el asistente']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-06.txt, captura en paso-06.jpg):
```
  1 [btn] Volver
  2 [btn] Abrir el asistente  = localhost
  3 [grp] Barra de herramientas
```
