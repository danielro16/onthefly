# anti-robot-avanza-sola

**Quién:** Ciega, usa VoiceOver todos los días. Sabe resolver el reCAPTCHA con la opción de audio.

**Qué quiere:** Llegar a una lista de auriculares que está detrás de una prueba anti-robot: resolverla cuando el asistente lo pida, y que el asistente siga solo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:52211/captcha.html»

- [+  6.5s] 💬 Persona: http://localhost:52211/captcha.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.9s] 📄 Cargó http://localhost:52211/captcha.html — «Verificación de seguridad» (paginas/01.txt)
- [+  8.9s] 💬 JEF: El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
- [+  8.9s] 🔊 «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.»
- [+  8.9s] 🔘 Botones: [Ya la resolví] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:52211/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [btn] Ya la resolví  (Primera de 2 opciones.)
  6 [btn] Otra cosa
  7 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  8 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 15 s (resuelve algo en la página)

- [+ 20.9s] 📄 Cargó http://localhost:52211/resuelto.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 20.9s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 20.9s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 22.6s] 💬 JEF: Estás en localhost, en una página con tres auriculares bluetooth disponibles con envío gratis a todo el país, ordenados por precio de menor a mayor. Son los Auriculares In Ear Bluetooth Básicos a $12.499, los Auriculares Vincha Bluetooth con Micrófono a $24.990 y los Auriculares con Cancelación de Ruido a $89.900.
- [+ 22.6s] 🔊 «Estás en localhost, en una página con tres auriculares bluetooth disponibles con envío gratis a todo el país, ordenados por precio de menor a mayor. Son los Auriculares In Ear Bluetooth Básicos a $12.499, los Auriculares Vincha Bluetooth con Micrófono a $24.990 y los Auriculares con Cancelación de Ruido a $89.900.»
- [+ 22.6s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:52211/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [txt] Listo, ya pasamos la verificación.
  6 [txt] Estás en localhost, en una página con tres auriculares bluetooth disponibles con envío gratis a todo el país, ordenados por precio de menor a mayor. Son los Auriculares In Ear Bluetooth Básicos a $12.499, los Auriculares Vincha Bluetooth con Micrófono a $24.990 y los Auriculares con Cancelación de Ruido a $89.900.
  7 [btn] Leer la página  (Primera de 4 opciones.)
  8 [btn] Resumir la página
  9 [btn] Volver a la página anterior
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 12 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto sale el más barato?»

- [+ 37.4s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 39.1s] 💬 JEF: El más barato es el Auriculares In Ear Bluetooth Básicos, que sale $12.499.
- [+ 39.1s] 🔊 «El más barato es el Auriculares In Ear Bluetooth Básicos, que sale $12.499.»
- [+ 39.1s] 🔘 Botones: [¿Y el siguiente más barato?] · [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:52211/captcha.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [txt] Listo, ya pasamos la verificación.
  6 [txt] Estás en localhost, en una página con tres auriculares bluetooth disponibles con envío gratis a todo el país, ordenados por precio de menor a mayor. Son los Auriculares In Ear Bluetooth Básicos a $12.499, los Auriculares Vincha Bluetooth con Micrófono a $24.990 y los Auriculares con Cancelación de Ruido a $89.900.
  7 [H] Vos: ¿cuánto sale el más barato?
  8 [txt] El más barato es el Auriculares In Ear Bluetooth Básicos, que sale $12.499.
  9 [btn] ¿Y el siguiente más barato?  (Primera de 5 opciones.)
 10 [btn] Leer la página
 11 [btn] Resumir la página
 12 [btn] Volver a la página anterior
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 15 [btn] Enviar
```
