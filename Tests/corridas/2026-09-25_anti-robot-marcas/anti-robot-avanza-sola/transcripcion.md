# anti-robot-avanza-sola

**Quién:** Ciega, usa VoiceOver todos los días. Sabe resolver el reCAPTCHA con la opción de audio.

**Qué quiere:** Llegar a una lista de auriculares que está detrás de una prueba anti-robot: resolverla cuando el asistente lo pida, y que el asistente siga solo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:61281/captcha.html»

- [+  6.5s] 💬 Persona: http://localhost:61281/captcha.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~97%)
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:61281/captcha.html — «Verificación de seguridad» (paginas/01.txt)
- [+  7.8s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  7.8s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~89%)
- [+  7.8s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61281/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 15 s (resuelve algo en la página)

- [+ 19.8s] 📄 Cargó http://localhost:61281/resuelto.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 19.8s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 19.8s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 24.6s] 💬 JEF: Esta tienda muestra tres modelos de auriculares Bluetooth con envío gratis a todo el país, ordenados del menor al mayor precio. ¿Cuál de estos auriculares necesitas?
- [+ 24.6s] 🔊 «Esta tienda muestra tres modelos de auriculares Bluetooth con envío gratis a todo el país, ordenados del menor al mayor precio. ¿Cuál de estos auriculares necesitas?»
- [+ 24.6s] 🔘 Botones: [Auriculares In Ear Bluetooth Básicos] · [Auriculares Vincha Bluetooth con Micrófono] · [Auriculares con Cancelación de Ruido]
- [+ 24.6s] 🔘 Botones: [Auriculares In Ear Bluetooth Básicos] · [Auriculares Vincha Bluetooth con Micrófono] · [Auriculares con Cancelación de Ruido] · [Volver a «Verificación de seguridad»] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61281/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [txt] Listo, ya pasamos la verificación.
  7 [txt] Esta tienda muestra tres modelos de auriculares Bluetooth con envío gratis a todo el país, ordenados del menor al mayor precio. ¿Cuál de estos auriculares necesitas?
  8 [btn] Auriculares In Ear Bluetooth Básicos  (Primera de 5 opciones.)
  9 [btn] Auriculares Vincha Bluetooth con Micrófono
 10 [btn] Auriculares con Cancelación de Ruido
 11 [btn] Volver a «Verificación de seguridad»
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto sale el más barato?»

- [+ 38.3s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 42.3s] 💬 JEF: El más barato, los Auriculares In Ear Bluetooth Básicos, sale $12.499.
- [+ 42.3s] 🔊 «El más barato, los Auriculares In Ear Bluetooth Básicos, sale $12.499.»
- [+ 42.3s] 🔘 Botones: [Abrir «Auriculares In Ear Bluetooth Básicos»] · [Abrir «Auriculares Vincha Bluetooth con Micrófono»] · [Abrir «Auriculares con Cancelación de Ruido»] · [Volver a «Verificación de seguridad»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61281/captcha.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [txt] Listo, ya pasamos la verificación.
  7 [txt] Esta tienda muestra tres modelos de auriculares Bluetooth con envío gratis a todo el país, ordenados del menor al mayor precio. ¿Cuál de estos auriculares necesitas?
  8 [H] Vos: ¿cuánto sale el más barato?
  9 [txt] El más barato, los Auriculares In Ear Bluetooth Básicos, sale $12.499.
 10 [btn] Abrir «Auriculares In Ear Bluetooth Básicos»  (Primera de 5 opciones.)
 11 [btn] Abrir «Auriculares Vincha Bluetooth con Micrófono»
 12 [btn] Abrir «Auriculares con Cancelación de Ruido»
 13 [btn] Volver a «Verificación de seguridad»
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```
