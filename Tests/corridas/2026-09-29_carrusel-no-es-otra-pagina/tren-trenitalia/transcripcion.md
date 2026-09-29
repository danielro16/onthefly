# tren-trenitalia

**Quién:** Ciega, habla castellano, está de viaje en Italia. Quiere un tren de Roma a Milán para mañana.

**Qué quiere:** Que JEF abra el formulario de verdad (detrás de «Biglietti»), lo complete con lo que ella dijo y busque, sin apretar un botón equivocado y sin inventar un formulario con los casilleros de muestra de la portada.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «trenitalia.com»

- [+  6.6s] 💬 Persona: trenitalia.com
- [+  6.6s] 💬 JEF: Abriendo trenitalia.com.
- [+  6.6s] 🔊 «Abriendo trenitalia.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.4s] 📄 Cargó https://www.trenitalia.com/it.html — «Home Trenitalia» (paginas/01.txt)
- [+ 14.2s] 💬 JEF: Estás en la página principal de Trenitalia, donde puedes consultar la circulación y buscar billetes de tren. La circulación es regular en la red de alta velocidad.
- [+ 14.2s] 🔊 «Estás en la página principal de Trenitalia, donde puedes consultar la circulación y buscar billetes de tren. La circulación es regular en la red de alta velocidad.»
- [+ 14.2s] 🔘 Botones: [Abrir «Biglietti»] · [Abrir «Infotraffico»] · [Abrir «Offerte, servizi e collegamenti — Vedi di più»]
- [+ 14.2s] 🔘 Botones: [Abrir «Biglietti»] · [Abrir «Infotraffico»] · [Abrir «Offerte, servizi e collegamenti — Vedi di più»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: trenitalia.com
  4 [txt] Abriendo trenitalia.com.
  5 [txt] Estás en la página principal de Trenitalia, donde puedes consultar la circulación y buscar billetes de tren. La circulación es regular en la red de alta velocidad.
  6 [btn] Abrir «Biglietti»  (Primera de 4 opciones.)
  7 [btn] Abrir «Infotraffico»
  8 [btn] Abrir «Offerte, servizi e collegamenti — Vedi di più»
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — escribe «quiero un tren de Roma a Milán mañana»

- [+ 22.1s] 💬 Persona: quiero un tren de Roma a Milán mañana
- [+ 33.5s] ❌ Error de carga: {'tipo': 'error', 't': 1790705222.763008, 'detalle': 'unusable', 'donde': 'decidir'}
- [+ 35.1s] 💬 JEF: Abriendo Biglietti.
- [+ 35.1s] 🔊 «Abriendo Biglietti.»
- [+ 35.9s] 📄 Cargó https://www.trenitalia.com/it.html — «Home Trenitalia» (paginas/02.txt)
- [+ 40.4s] 💬 JEF: Al pulsar «Biglietti», se muestra el formulario de billetes de Trenitalia, pero no aparece una confirmación de que se haya abierto la búsqueda. Esta página sirve para buscar el tren de Roma a Milán: el formulario permite indicar las estaciones de salida y llegada; la fecha que aparece ahora es 29 de septiembre de 2026.
- [+ 40.4s] 🔊 «Al pulsar «Biglietti», se muestra el formulario de billetes de Trenitalia, pero no aparece una confirmación de que se haya abierto la búsqueda. Esta página sirve para buscar el tren de Roma a Milán: el formulario permite indicar las estaciones de salida y llegada; la fecha que aparece ahora es 29 de septiembre de 2026.»
- [+ 40.4s] 🔘 Botones: [Buscar trenes Roma-Milán para mañana en Trenitalia] · [29 Settembre 2026, Mercoledì] · [Orario]
- [+ 40.4s] 🔘 Botones: [Buscar trenes Roma-Milán para mañana en Trenitalia] · [29 Settembre 2026, Mercoledì] · [Orario] · [Otra cosa]

Al terminar el paso (26 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: trenitalia.com
  4 [txt] Abriendo trenitalia.com.
  5 [txt] Estás en la página principal de Trenitalia, donde puedes consultar la circulación y buscar billetes de tren. La circulación es regular en la red de alta velocidad.
  6 [H] Vos: quiero un tren de Roma a Milán mañana
  7 [txt] Abriendo Biglietti.
  8 [txt] Al pulsar «Biglietti», se muestra el formulario de billetes de Trenitalia, pero no aparece una confirmación de que se haya abierto la búsqueda. Esta página sirve para buscar el tren de Roma a Milán: el formulario permite indicar las estaciones de salida y llegada; la fecha que aparece ahora es 29 de septiembre de 2026.
  9 [btn] Buscar trenes Roma-Milán para mañana en Trenitalia  (Primera de 4 opciones.)
 10 [btn] 29 Settembre 2026, Mercoledì
 11 [btn] Orario
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
