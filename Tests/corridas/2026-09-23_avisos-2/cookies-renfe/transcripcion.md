# cookies-renfe

**Quién:** Vive en España, con baja visión. Entra a Renfe y le sale el aviso de privacidad.

**Qué quiere:** Que los botones del aviso sean lo primero y que al contestar se cierre y queden los pasos de la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «renfe.com»

- [+  6.6s] 💬 Persona: renfe.com
- [+  6.6s] 💬 JEF: Abriendo renfe.com.
- [+  6.6s] 🔊 «Abriendo renfe.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.7s] 📄 Cargó https://www.renfe.com/es/en — «Renfe | Train tickets AVE, Avlo Low Cost (with No Booking Fees)» (paginas/01.txt)
- [+ 14.5s] 💬 JEF: Estás en la web de Renfe, la operadora de trenes española. Sirve para lo que buscas: hay una sección de Cercanías con 15 zonas, desde Asturias hasta Zaragoza. La página te pide aceptar o rechazar las cookies para continuar navegando. ¿Para qué zona quieres Cercanías? Hay 15 disponibles
- [+ 14.5s] 🔊 «Estás en la web de Renfe, la operadora de trenes española. Sirve para lo que buscas: hay una sección de Cercanías con 15 zonas, desde Asturias hasta Zaragoza. La página te pide aceptar o rechazar las cookies para continuar navegando. ¿Para qué zona quieres Cercanías? Hay 15 disponibles»
- [+ 14.6s] 🔘 Botones: [Asturias] · [Bilbao] · [Cadiz] · [Cantabria] · [Ver más opciones (11)]
- [+ 14.6s] 🔘 Botones: [Asturias] · [Bilbao] · [Cadiz] · [Cantabria] · [Ver más opciones (11)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: renfe.com
  4 [txt] Abriendo renfe.com.
  5 [txt] Estás en la web de Renfe, la operadora de trenes española. Sirve para lo que buscas: hay una sección de Cercanías con 15 zonas, desde Asturias hasta Zaragoza. La página te pide aceptar o rechazar las cookies para continuar navegando. ¿Para qué zona quieres Cercanías? Hay 15 disponibles
  6 [btn] Asturias  (Primera de 6 opciones.)
  7 [btn] Bilbao
  8 [btn] Cadiz
  9 [btn] Cantabria
 10 [btn] Ver más opciones (11)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 2 — {"tocar": "Reject"}
> ⚠️ El paso no se pudo hacer: no hay opción 'Reject'; hay: ['Cerrar el asistente', 'Asturias', 'Bilbao', 'Cadiz', 'Cantabria', 'Ver más opciones (11)', 'Otra cosa']


Al terminar el paso (0 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: renfe.com
  4 [txt] Abriendo renfe.com.
  5 [txt] Estás en la web de Renfe, la operadora de trenes española. Sirve para lo que buscas: hay una sección de Cercanías con 15 zonas, desde Asturias hasta Zaragoza. La página te pide aceptar o rechazar las cookies para continuar navegando. ¿Para qué zona quieres Cercanías? Hay 15 disponibles
  6 [btn] Asturias  (Primera de 6 opciones.)
  7 [btn] Bilbao
  8 [btn] Cadiz
  9 [btn] Cantabria
 10 [btn] Ver más opciones (11)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
