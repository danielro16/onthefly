# anti-robot-ya-la-resolvi

**Quién:** 72 años, baja visión. La prueba la resuelve su nieta, que le avisa cuando está.

**Qué quiere:** Resolver la prueba anti-robot que aparece en la misma página y seguir con la tarea.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:62511/misma-pagina.html»

- [+  6.5s] 💬 Persona: http://localhost:62511/misma-pagina.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó http://localhost:62511/misma-pagina.html — «Auriculares bluetooth» (paginas/01.txt)
- [+  9.0s] 💬 JEF: El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
- [+  9.0s] 🔊 «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.»
- [+  9.0s] 🔘 Botones: [Ya la resolví] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:62511/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [btn] Ya la resolví  (Primera de 2 opciones.)
  6 [btn] Otra cosa
  7 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  8 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 15 s (resuelve algo en la página)


Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:62511/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [btn] Ya la resolví  (Primera de 2 opciones.)
  6 [btn] Otra cosa
  7 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  8 [btn] Enviar
```

## Paso 3 — toca «Ya la resolví»

- [+ 35.8s] 💬 Persona: Ya la resolví
- [+ 36.5s] 📄 Cargó http://localhost:62511/misma-pagina.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 36.5s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 36.5s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 38.5s] 💬 JEF: Estás en la página de auriculares bluetooth. Encontraste tres opciones con envío gratis, ordenadas por precio de menor a mayor. Los Auriculares In Ear Bluetooth Básicos cuestan $12.499, los Auriculares Vincha Bluetooth con Micrófono valen $24.990, y los Auriculares con Cancelación de Ruido están $89.900.
- [+ 38.5s] 🔊 «Estás en la página de auriculares bluetooth. Encontraste tres opciones con envío gratis, ordenadas por precio de menor a mayor. Los Auriculares In Ear Bluetooth Básicos cuestan $12.499, los Auriculares Vincha Bluetooth con Micrófono valen $24.990, y los Auriculares con Cancelación de Ruido están $89.900.»
- [+ 38.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: http://localhost:62511/misma-pagina.html
  3 [txt] Abriendo localhost.
  4 [txt] El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.
  5 [H] Vos: Ya la resolví
  6 [txt] Listo, ya pasamos la verificación.
  7 [txt] Estás en la página de auriculares bluetooth. Encontraste tres opciones con envío gratis, ordenadas por precio de menor a mayor. Los Auriculares In Ear Bluetooth Básicos cuestan $12.499, los Auriculares Vincha Bluetooth con Micrófono valen $24.990, y los Auriculares con Cancelación de Ruido están $89.900.
  8 [btn] Leer la página  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 12 [btn] Enviar
```
