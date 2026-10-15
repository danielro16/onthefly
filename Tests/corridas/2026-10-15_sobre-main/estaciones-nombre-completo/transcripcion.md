# estaciones-nombre-completo

**Quién:** Ciega. Ya sabe el nombre exacto de la estación.

**Qué quiere:** Que JEF elija sola la estación cuando la persona la nombró completa, y lo diga. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/estaciones.html»

- [+  6.5s] 💬 Persona: http://localhost:8765/estaciones.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/01.txt)
- [+ 10.0s] 💬 JEF: Treni sirve para buscar un viaje en tren; el formulario pide el lugar de partida y el de llegada.
- [+ 10.0s] 🔊 «Treni sirve para buscar un viaje en tren; el formulario pide el lugar de partida y el de llegada.»
- [+ 10.0s] 🔘 Botones: [Buscar un viaje en Treni]
- [+ 10.0s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni sirve para buscar un viaje en tren; el formulario pide el lugar de partida y el de llegada.
  6 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «poné Roma Termini en partenza»

- [+ 18.4s] 💬 Persona: poné Roma Termini en partenza
- [+ 21.1s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/02.txt)
- [+ 22.0s] 📄 Cargó http://localhost:8765/estaciones.html — «Treni — Cerca il tuo viaggio» (paginas/03.txt)
- [+ 22.0s] 💬 JEF: Listo: elegí «Roma Termini».
- [+ 22.0s] 🔊 «Listo: elegí «Roma Termini».»
- [+ 22.0s] 🔘 Botones: [Buscar un viaje en Treni] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/estaciones.html
  4 [txt] Abriendo localhost.
  5 [txt] Treni sirve para buscar un viaje en tren; el formulario pide el lugar de partida y el de llegada.
  6 [H] Vos: poné Roma Termini en partenza
  7 [txt] Listo: elegí «Roma Termini».
  8 [btn] Buscar un viaje en Treni  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
