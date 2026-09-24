# cajas-usps

**Quién:** Vive en Estados Unidos, habla español, ciega. Quiere pedir cajas gratis al correo para mandar un paquete.

**Qué quiere:** Que JEF encuentre en USPS dónde se piden las cajas gratis aunque el botón diga «Order Now», y la lleve ahí.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «usps.com»

- [+  6.6s] 💬 Persona: usps.com
- [+  6.6s] 💬 JEF: Abriendo usps.com.
- [+  6.6s] 🔊 «Abriendo usps.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.6s] 📄 Cargó https://www.usps.com/ — «Welcome | USPS» (paginas/01.txt)
- [+ 14.0s] 💬 JEF: Estás en la página principal de USPS, el servicio postal de Estados Unidos. Desde aquí se pueden enviar paquetes con Click-N-Ship, comprar estampillas, usar Informed Delivery, rastrear envíos y hacer trámites como cambiar de dirección o alquilar un apartado de correo. Hay un aviso sobre estafas: si recibes un mensaje de texto o correo que dice ser de USPS sobre un paquete pendiente, no lo abras y bórralo.
- [+ 14.0s] 🔊 «Estás en la página principal de USPS, el servicio postal de Estados Unidos. Desde aquí se pueden enviar paquetes con Click-N-Ship, comprar estampillas, usar Informed Delivery, rastrear envíos y hacer trámites como cambiar de dirección o alquilar un apartado de correo. Hay un aviso sobre estafas: si recibes un mensaje de texto o correo que dice ser de USPS sobre un paquete pendiente, no lo abras y bórralo.»
- [+ 14.0s] 🔘 Botones: [Leer la nota] · [Resumir la nota]
- [+ 14.0s] 🔘 Botones: [Leer la nota] · [Resumir la nota] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: usps.com
  4 [txt] Abriendo usps.com.
  5 [txt] Estás en la página principal de USPS, el servicio postal de Estados Unidos. Desde aquí se pueden enviar paquetes con Click-N-Ship, comprar estampillas, usar Informed Delivery, rastrear envíos y hacer trámites como cambiar de dirección o alquilar un apartado de correo. Hay un aviso sobre estafas: si recibes un mensaje de texto o correo que dice ser de USPS sobre un paquete pendiente, no lo abras y bórralo.
  6 [btn] Leer la nota  (Primera de 3 opciones.)
  7 [btn] Resumir la nota
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «quiero cajas gratis para mandar un paquete»

- [+ 21.8s] 💬 Persona: quiero cajas gratis para mandar un paquete
- [+ 25.5s] 💬 JEF: Abriendo FREE BOXES.
- [+ 25.5s] 🔊 «Abriendo FREE BOXES.»
- [+ 29.1s] 📄 Cargó https://www.usps.com/search/results.htm?keyword=Free%20Boxes&PNO=1&Nrpp=&navFolder=&navSteps=0&navDisplayName=&mainDirName= — «Search Results Page | USPS» (paginas/02.txt)
- [+ 29.6s] 💬 JEF: No encuentro «Free Supplies» en esta página. ¿Lo busco en internet?
- [+ 29.6s] 🔊 «No encuentro «Free Supplies» en esta página. ¿Lo busco en internet?»
- [+ 29.6s] 🔘 Botones: [Buscarlo en internet] · [Completar «Search or Enter a Tracking Number»] · [Leer los titulares] · [Volver a «Search Results Page»] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: usps.com
  4 [txt] Abriendo usps.com.
  5 [txt] Estás en la página principal de USPS, el servicio postal de Estados Unidos. Desde aquí se pueden enviar paquetes con Click-N-Ship, comprar estampillas, usar Informed Delivery, rastrear envíos y hacer trámites como cambiar de dirección o alquilar un apartado de correo. Hay un aviso sobre estafas: si recibes un mensaje de texto o correo que dice ser de USPS sobre un paquete pendiente, no lo abras y bórralo.
  6 [H] Vos: quiero cajas gratis para mandar un paquete
  7 [txt] Abriendo FREE BOXES.
  8 [txt] No encuentro «Free Supplies» en esta página. ¿Lo busco en internet?
  9 [btn] Buscarlo en internet  (Primera de 5 opciones.)
 10 [btn] Completar «Search or Enter a Tracking Number»
 11 [btn] Leer los titulares
 12 [btn] Volver a «Search Results Page»
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
