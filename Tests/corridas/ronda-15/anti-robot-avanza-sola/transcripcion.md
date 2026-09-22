# anti-robot-avanza-sola

**Quién:** Ciega, usa VoiceOver todos los días. Sabe resolver el reCAPTCHA con la opción de audio.

**Qué quiere:** Llegar a una lista de auriculares que está detrás de una prueba anti-robot: resolverla cuando el asistente lo pida, y que el asistente siga solo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:56712/captcha.html»

- [+  6.8s] 💬 Persona: http://localhost:56712/captcha.html
- [+  6.8s] 💬 JEF: Abriendo localhost.
- [+  6.8s] 🔊 «Abriendo localhost.»
- [+  6.9s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.3s] 📄 Cargó http://localhost:56712/captcha.html — «Verificación de seguridad» (paginas/01.txt)
- [+  9.3s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  9.3s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~79%)
- [+  9.3s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56712/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 15 s (resuelve algo en la página)

- [+ 20.1s] 📄 Cargó http://localhost:56712/resuelto.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 20.1s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 20.1s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 22.2s] 💬 JEF: Estás en la tienda de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados de menor a mayor precio: los In Ear Básicos a $12.499, los de Vincha con Micrófono a $24.990 y los que tienen Cancelación de Ruido a $89.900.
- [+ 22.2s] 🔊 «Estás en la tienda de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados de menor a mayor precio: los In Ear Básicos a $12.499, los de Vincha con Micrófono a $24.990 y los que tienen Cancelación de Ruido a $89.900.»
- [+ 22.2s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a «Verificación de seguridad»] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56712/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [txt] Listo, ya pasamos la verificación.
  7 [txt] Estás en la tienda de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados de menor a mayor precio: los In Ear Básicos a $12.499, los de Vincha con Micrófono a $24.990 y los que tienen Cancelación de Ruido a $89.900.
  8 [btn] Leer la página  (Primera de 4 opciones.)
  9 [btn] Resumir la página
 10 [btn] Volver a «Verificación de seguridad»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto sale el más barato?»

- [+ 38.9s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 41.5s] 💬 JEF: El más barato cuesta $12.499 y se trata del modelo de auriculares In Ear Bluetooth básicos.
- [+ 41.5s] 🔊 «El más barato cuesta $12.499 y se trata del modelo de auriculares In Ear Bluetooth básicos.»
- [+ 41.5s] 🔘 Botones: [¿Cuánto salen los de vincha?] · [Leer la página] · [Resumir la página] · [Volver a «Verificación de seguridad»] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56712/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [txt] Listo, ya pasamos la verificación.
  7 [txt] Estás en la tienda de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados de menor a mayor precio: los In Ear Básicos a $12.499, los de Vincha con Micrófono a $24.990 y los que tienen Cancelación de Ruido a $89.900.
  8 [H] Vos: ¿cuánto sale el más barato?
  9 [txt] El más barato cuesta $12.499 y se trata del modelo de auriculares In Ear Bluetooth básicos.
 10 [btn] ¿Cuánto salen los de vincha?  (Primera de 5 opciones.)
 11 [btn] Leer la página
 12 [btn] Resumir la página
 13 [btn] Volver a «Verificación de seguridad»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```
