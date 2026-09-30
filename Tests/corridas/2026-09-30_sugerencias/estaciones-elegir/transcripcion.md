# estaciones-elegir

**Quién:** Ciega, habla castellano, en Italia. Busca un tren y no sabe los nombres de las estaciones.

**Qué quiere:** Que JEF, al escribir «Roma», no diga «Listo» sin estación elegida: que pregunte cuál, con las primeras como botones; que entienda «Termini» dicho en palabras y un botón tocado, y que siga con el resto del pedido. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/estaciones.html»

- [+  6.7s] 💬 Persona: http://localhost:8765/estaciones.html
- [+  6.7s] 💬 JEF: Abriendo localhost.
- [+  6.7s] 🔊 «Abriendo localhost.»
- [+  6.8s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.3s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/01.txt)
- [+ 12.1s] 💬 JEF: Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
- [+ 12.1s] 🔊 «Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.»
- [+ 12.1s] 🔘 Botones: [Buscar un viaje en Treni]
- [+ 12.1s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
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

## Paso 2 — escribe «quiero un tren de Roma a Milano»

- [+ 20.8s] 💬 Persona: quiero un tren de Roma a Milano
- [+ 25.9s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/02.txt)
- [+ 26.2s] 💬 JEF: Hay 6 opciones para «Roma». ¿Cuál?
- [+ 26.2s] 🔊 «Hay 6 opciones para «Roma». ¿Cuál? Roma (Tutte le stazioni). Roma Termini. Roma Tiburtina»
- [+ 26.2s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)]
- [+ 26.2s] 💬 JEF: Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
- [+ 26.2s] 🔊 «Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».»  ⟶ en cola: empieza a sonar a los +32.6s
- [+ 26.2s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
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

- [+ 34.7s] 💬 Persona: Termini
- [+ 35.2s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/03.txt)
- [+ 35.2s] 💬 JEF: Listo: elegí «Roma Termini».
- [+ 35.2s] 🔊 «Listo: elegí «Roma Termini».»
- [+ 43.4s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/04.txt)
- [+ 43.6s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/05.txt)
- [+ 43.7s] 💬 JEF: Hay 6 opciones para «Roma». ¿Cuál?
- [+ 43.7s] 🔊 «Hay 6 opciones para «Roma». ¿Cuál? Roma (Tutte le stazioni). Roma Termini. Roma Tiburtina»
- [+ 43.7s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)]
- [+ 43.7s] 💬 JEF: Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
- [+ 43.7s] 🔊 «Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».»  ⟶ en cola: empieza a sonar a los +50.1s
- [+ 43.7s] 🔘 Botones: [Roma (Tutte le stazioni)] · [Roma Termini] · [Roma Tiburtina] · [Ver más opciones (3)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
  9 [H] Vos: Termini
 10 [txt] Listo: elegí «Roma Termini».
 11 [txt] Hay 6 opciones para «Roma». ¿Cuál?
 12 [txt] Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
 13 [btn] Roma (Tutte le stazioni)  (Primera de 5 opciones.)
 14 [btn] Roma Termini
 15 [btn] Roma Tiburtina
 16 [btn] Ver más opciones (3)
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
 20 [grp] Barra de herramientas
```

## Paso 4 — {"boton": "Centrale"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Centrale'; hay: ['Cerrar el asistente', 'Roma (Tutte le stazioni)', 'Roma Termini', 'Roma Tiburtina', 'Ver más opciones (3)', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el formulario de Treni para buscar un viaje; pide el lugar de partida y el de llegada.
  6 [H] Vos: quiero un tren de Roma a Milano
  7 [txt] Hay 6 opciones para «Roma». ¿Cuál?
  8 [txt] Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
  9 [H] Vos: Termini
 10 [txt] Listo: elegí «Roma Termini».
 11 [txt] Hay 6 opciones para «Roma». ¿Cuál?
 12 [txt] Cuando elijas, sigo con «Inserisci Milano come arrivo e cerca un treno.».
 13 [btn] Roma (Tutte le stazioni)  (Primera de 5 opciones.)
 14 [btn] Roma Termini
 15 [btn] Roma Tiburtina
 16 [btn] Ver más opciones (3)
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
 20 [grp] Barra de herramientas
```
