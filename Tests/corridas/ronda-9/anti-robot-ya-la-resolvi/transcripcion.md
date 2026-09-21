# anti-robot-ya-la-resolvi

**Quién:** 72 años, baja visión. La prueba la resuelve su nieta, que le avisa cuando está.

**Qué quiere:** Resolver la prueba anti-robot que aparece en la misma página y seguir con la tarea.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:61344/misma-pagina.html»

- [+  6.5s] 💬 Persona: http://localhost:61344/misma-pagina.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó http://localhost:61344/misma-pagina.html — «Auriculares bluetooth» (paginas/01.txt)
- [+  9.0s] 💬 JEF: El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.
- [+  9.0s] 🔊 «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~50%)
- [+  9.0s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:61344/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.
  5 [btn] Ir a la prueba  (Primera de 3 opciones.)
  6 [btn] Ya la resolví
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  9 [btn] Enviar
```

## Paso 2 — toca «Ir a la prueba»

- [+ 14.3s] 💬 Persona: Ir a la prueba
- [+ 14.3s] 💬 JEF: Listo: la prueba está en la página. Cuando esté resuelta, continuamos.
- [+ 14.3s] 🔊 «Listo: la prueba está en la página. Cuando esté resuelta, continuamos.»
- [+ 14.3s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:61344/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.
  5 [H] Vos: Ir a la prueba
  6 [txt] Listo: la prueba está en la página. Cuando esté resuelta, continuamos.
  7 [btn] Ir a la prueba  (Primera de 3 opciones.)
  8 [btn] Ya la resolví
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 3 — no toca el asistente durante 12 s (resuelve algo en la página)


Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:61344/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.
  5 [H] Vos: Ir a la prueba
  6 [txt] Listo: la prueba está en la página. Cuando esté resuelta, continuamos.
  7 [btn] Ir a la prueba  (Primera de 3 opciones.)
  8 [btn] Ya la resolví
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```

## Paso 4 — toca «Ya la resolví»

- [+ 40.8s] 💬 Persona: Ya la resolví
- [+ 41.4s] 📄 Cargó http://localhost:61344/misma-pagina.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 41.4s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 41.4s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 43.5s] 💬 JEF: Estás en localhost, en una página de auriculares bluetooth. Encontraste tres modelos disponibles con envío gratis, ordenados por precio: Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.
- [+ 43.5s] 🔊 «Estás en localhost, en una página de auriculares bluetooth. Encontraste tres modelos disponibles con envío gratis, ordenados por precio: Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.»
- [+ 43.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:61344/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.
  5 [H] Vos: Ir a la prueba
  6 [txt] Listo: la prueba está en la página. Cuando esté resuelta, continuamos.
  7 [H] Vos: Ya la resolví
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en localhost, en una página de auriculares bluetooth. Encontraste tres modelos disponibles con envío gratis, ordenados por precio: Auriculares In Ear Bluetooth Básicos a $12.499, Auriculares Vincha Bluetooth con Micrófono a $24.990, y Auriculares con Cancelación de Ruido a $89.900.
 10 [btn] Leer la página  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 14 [btn] Enviar
```
