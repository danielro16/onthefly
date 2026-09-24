# cookies-renfe

**Quién:** Vive en España, con baja visión. Entra a Renfe y le sale el aviso de privacidad.

**Qué quiere:** Que los botones del aviso sean lo primero y que al contestar se cierre y queden los pasos de la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «renfe.com»

- [+  6.6s] 💬 Persona: renfe.com
- [+  6.6s] 💬 JEF: Abriendo renfe.com.
- [+  6.6s] 🔊 «Abriendo renfe.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.1s] 📄 Cargó https://www.renfe.com/es/en — «Renfe | Train tickets AVE, Avlo Low Cost (with No Booking Fees)» (paginas/01.txt)
- [+ 10.4s] 📄 Cargó https://www.renfe.com/es/en — «Renfe | Train tickets AVE, Avlo Low Cost (with No Booking Fees)» (paginas/02.txt)
- [+ 19.7s] 💬 JEF: Estás en la página principal de Renfe, donde puedes buscar billetes de tren indicando las estaciones de salida y llegada; también hay accesos a Cercanías y a la gestión de viajes. Aparece un aviso de cookies que permite configurarlas, rechazarlas o aceptarlas.
- [+ 19.7s] 🔊 «Estás en la página principal de Renfe, donde puedes buscar billetes de tren indicando las estaciones de salida y llegada; también hay accesos a Cercanías y a la gestión de viajes. Aparece un aviso de cookies que permite configurarlas, rechazarlas o aceptarlas.»
- [+ 19.7s] 🔘 Botones: [Abrir «Cercanías (Commuter)»]
- [+ 19.8s] 🔘 Botones: [Abrir «Cercanías (Commuter)»] · [Otra cosa]

Al terminar el paso (20 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: renfe.com
  4 [txt] Abriendo renfe.com.
  5 [txt] Estás en la página principal de Renfe, donde puedes buscar billetes de tren indicando las estaciones de salida y llegada; también hay accesos a Cercanías y a la gestión de viajes. Aparece un aviso de cookies que permite configurarlas, rechazarlas o aceptarlas.
  6 [btn] Abrir «Cercanías (Commuter)»  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — {"tocar": "Reject"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Reject'; hay: ['Cerrar el asistente', 'Abrir «Cercanías (Commuter)»', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: renfe.com
  4 [txt] Abriendo renfe.com.
  5 [txt] Estás en la página principal de Renfe, donde puedes buscar billetes de tren indicando las estaciones de salida y llegada; también hay accesos a Cercanías y a la gestión de viajes. Aparece un aviso de cookies que permite configurarlas, rechazarlas o aceptarlas.
  6 [btn] Abrir «Cercanías (Commuter)»  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```
