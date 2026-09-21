# anti-robot-avanza-sola

**Quién:** Ciega, usa VoiceOver todos los días. Sabe resolver el reCAPTCHA con la opción de audio.

**Qué quiere:** Llegar a una lista de auriculares que está detrás de una prueba anti-robot: resolverla cuando el asistente lo pida, y que el asistente siga solo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:50241/captcha.html»

- [+  6.5s] 💬 Persona: http://localhost:50241/captcha.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó http://localhost:50241/captcha.html — «Verificación de seguridad» (paginas/01.txt)
- [+  9.0s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  9.0s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~80%)
- [+  9.0s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:50241/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  5 [btn] Ir a la prueba  (Primera de 3 opciones.)
  6 [btn] Ya la resolví
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 15 s (resuelve algo en la página)

- [+ 19.8s] 📄 Cargó http://localhost:50241/resuelto.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 19.9s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 19.9s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 21.2s] 💬 JEF: Estás en localhost, en una página con tres modelos de auriculares bluetooth. Son Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.
- [+ 21.2s] 🔊 «Estás en localhost, en una página con tres modelos de auriculares bluetooth. Son Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.»
- [+ 21.2s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:50241/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  5 [txt] Listo, ya pasamos la verificación.
  6 [txt] Estás en localhost, en una página con tres modelos de auriculares bluetooth. Son Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.
  7 [btn] Leer la página  (Primera de 4 opciones.)
  8 [btn] Resumir la página
  9 [btn] Volver a la página anterior
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto sale el más barato?»

- [+ 37.4s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 39.2s] 💬 JEF: El más barato es el Auricular In Ear Bluetooth Básico y sale 12.499 pesos.
- [+ 39.2s] 🔊 «El más barato es el Auricular In Ear Bluetooth Básico y sale 12.499 pesos.»
- [+ 39.2s] 🔘 Botones: [¿Y el de vincha?] · [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:50241/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  5 [txt] Listo, ya pasamos la verificación.
  6 [txt] Estás en localhost, en una página con tres modelos de auriculares bluetooth. Son Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.
  7 [H] Vos: ¿cuánto sale el más barato?
  8 [txt] El más barato es el Auricular In Ear Bluetooth Básico y sale 12.499 pesos.
  9 [btn] ¿Y el de vincha?  (Primera de 5 opciones.)
 10 [btn] Leer la página
 11 [btn] Resumir la página
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
