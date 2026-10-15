# tren-trenitalia

**Quién:** Ciega, habla castellano, está de viaje en Italia. Quiere un tren de Roma a Milán para mañana.

**Qué quiere:** Que JEF abra el formulario de verdad (detrás de «Biglietti»), lo complete con lo que ella dijo y busque, sin apretar un botón equivocado y sin inventar un formulario con los casilleros de muestra de la portada.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «trenitalia.com»

- [+  6.4s] 💬 Persona: trenitalia.com
- [+  6.4s] 💬 JEF: Abriendo trenitalia.com.
- [+  6.4s] 🔊 «Abriendo trenitalia.com.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.4s] 📄 Cargó https://www.trenitalia.com/it.html — «Home Trenitalia» (paginas/01.txt)
- [+ 13.0s] 💬 JEF: Estás en la página de inicio de Trenitalia, donde puedes consultar el tráfico y buscar billetes. Infotraffico indica que la circulación en la red de alta velocidad es regular. Una nota sobre privacidad y cookies cubre la página.
- [+ 13.0s] 🔊 «Estás en la página de inicio de Trenitalia, donde puedes consultar el tráfico y buscar billetes. Infotraffico indica que la circulación en la red de alta velocidad es regular. Una nota sobre privacidad y cookies cubre la página.»
- [+ 13.0s] 🔘 Botones: [Abrir «Infotraffico»] · [Abrir «Biglietti»]
- [+ 13.0s] 🔘 Botones: [Accetta] · [Rifiuta tutti] · [Gestisci preferenza, Apre la finestra di dialogo del centro preferenze] · [Chiudi] · [Abrir «Infotraffico»] · [Abrir «Biglietti»]
- [+ 13.0s] 🔘 Botones: [Accetta] · [Rifiuta tutti] · [Gestisci preferenza, Apre la finestra di dialogo del centro preferenze] · [Chiudi] · [Abrir «Infotraffico»] · [Abrir «Biglietti»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: trenitalia.com
  4 [txt] Abriendo trenitalia.com.
  5 [txt] Estás en la página de inicio de Trenitalia, donde puedes consultar el tráfico y buscar billetes. Infotraffico indica que la circulación en la red de alta velocidad es regular. Una nota sobre privacidad y cookies cubre la página.
  6 [btn] Accetta  (Primera de 7 opciones.)
  7 [btn] Rifiuta tutti
  8 [btn] Gestisci preferenza, Apre la finestra di dialogo del centro preferenze
  9 [btn] Chiudi
 10 [btn] Abrir «Infotraffico»
 11 [btn] Abrir «Biglietti»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 2 — escribe «quiero un tren de Roma a Milán mañana»

- [+ 20.0s] 💬 Persona: quiero un tren de Roma a Milán mañana
- [+ 33.2s] ❌ Error de carga: {'tipo': 'error', 'detalle': 'unusable', 't': 1790707021.34943, 'donde': 'decidir'}
- [+ 33.5s] 💬 JEF: Abriendo Biglietti.
- [+ 33.5s] 🔊 «Abriendo Biglietti.»
- [+ 34.6s] 📄 Cargó https://www.trenitalia.com/it.html — «Home Trenitalia» (paginas/02.txt)
- [+ 39.2s] 💬 JEF: Al pulsar «Biglietti», se abrió en Trenitalia el formulario para buscar billetes de tren. Esta página sirve para buscar el viaje que quieres: el formulario permite indicar las estaciones de salida y llegada, y la fecha visible es el 29 de septiembre de 2026, no mañana; hay un aviso de cookies que puede cerrarse.
- [+ 39.2s] 🔊 «Al pulsar «Biglietti», se abrió en Trenitalia el formulario para buscar billetes de tren. Esta página sirve para buscar el viaje que quieres: el formulario permite indicar las estaciones de salida y llegada, y la fecha visible es el 29 de septiembre de 2026, no mañana; hay un aviso de cookies que puede cerrarse.»
- [+ 39.2s] 🔘 Botones: [Buscar trenes en Trenitalia] · [29 Settembre 2026, Mercoledì]
- [+ 39.2s] 🔘 Botones: [Buscar trenes en Trenitalia] · [29 Settembre 2026, Mercoledì] · [Otra cosa]

Al terminar el paso (27 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: trenitalia.com
  4 [txt] Abriendo trenitalia.com.
  5 [txt] Estás en la página de inicio de Trenitalia, donde puedes consultar el tráfico y buscar billetes. Infotraffico indica que la circulación en la red de alta velocidad es regular. Una nota sobre privacidad y cookies cubre la página.
  6 [H] Vos: quiero un tren de Roma a Milán mañana
  7 [txt] Abriendo Biglietti.
  8 [txt] Al pulsar «Biglietti», se abrió en Trenitalia el formulario para buscar billetes de tren. Esta página sirve para buscar el viaje que quieres: el formulario permite indicar las estaciones de salida y llegada, y la fecha visible es el 29 de septiembre de 2026, no mañana; hay un aviso de cookies que puede cerrarse.
  9 [btn] Buscar trenes en Trenitalia  (Primera de 3 opciones.)
 10 [btn] 29 Settembre 2026, Mercoledì
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
