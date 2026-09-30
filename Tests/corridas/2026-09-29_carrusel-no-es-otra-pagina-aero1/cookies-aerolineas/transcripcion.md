# cookies-aerolineas

**Quién:** Entra a Aerolíneas Argentinas y le sale el aviso de cookies.

**Qué quiere:** Que JEF conteste el aviso de cookies como eligió la persona (por ahora, aceptar todas) sin decir nada, y cuente la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «aerolineas.com.ar»

- [+  6.6s] 💬 Persona: aerolineas.com.ar
- [+  6.6s] 💬 JEF: Abriendo aerolineas.com.ar.
- [+  6.6s] 🔊 «Abriendo aerolineas.com.ar.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 12.5s] 📄 Cargó https://aerolineas.com.ar/ — «Aerolíneas Argentinas» (paginas/01.txt)
- [+ 13.8s] 📄 Cargó https://aerolineas.com.ar/ — «Aerolíneas Argentinas» (paginas/02.txt)
- [+ 17.1s] 📄 Cargó https://aerolineas.com.ar/ — «Aerolíneas Argentinas» (paginas/03.txt)
- [+ 19.0s] 💬 JEF: Estás en la página de inicio de Aerolíneas Argentinas, donde puedes buscar vuelos, hacer el check-in, consultar el estado de un vuelo o gestionar una reserva.
- [+ 19.0s] 🔊 «Estás en la página de inicio de Aerolíneas Argentinas, donde puedes buscar vuelos, hacer el check-in, consultar el estado de un vuelo o gestionar una reserva.»
- [+ 19.0s] 🔘 Botones: [Buscar vuelos en Aerolíneas Argentinas] · [CHECK IN] · [ESTADO DE VUELO]
- [+ 19.0s] 🔘 Botones: [Buscar vuelos en Aerolíneas Argentinas] · [CHECK IN] · [ESTADO DE VUELO] · [Otra cosa]
- [+ 20.4s] 📄 Cargó https://aerolineas.com.ar/ — «Aerolíneas Argentinas» (paginas/04.txt)

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: aerolineas.com.ar
  4 [txt] Abriendo aerolineas.com.ar.
  5 [txt] Estás en la página de inicio de Aerolíneas Argentinas, donde puedes buscar vuelos, hacer el check-in, consultar el estado de un vuelo o gestionar una reserva.
  6 [btn] Buscar vuelos en Aerolíneas Argentinas  (Primera de 4 opciones.)
  7 [btn] CHECK IN
  8 [btn] ESTADO DE VUELO
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
