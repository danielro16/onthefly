# anti-robot-misma-pagina

**Quién:** 72 años, baja visión. La prueba la resuelve su nieta, que le avisa cuando está.

**Qué quiere:** Resolver la prueba anti-robot que aparece en la misma página (sin que cambie la dirección) y seguir con la tarea.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:54297/misma-pagina.html»

- [+  6.6s] 💬 Persona: http://localhost:54297/misma-pagina.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó http://localhost:54297/misma-pagina.html — «Auriculares bluetooth» (paginas/01.txt)
- [+  9.0s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  9.0s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~45%)
- [+  9.0s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:54297/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca «Ir a la prueba»

- [+ 15.2s] 💬 Persona: Ir a la prueba
- [+ 15.2s] 💬 JEF: La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
- [+ 15.2s] 🔊 «La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~42%)
- [+ 15.2s] 🔘 Botones: [Ya la resolví] · [Ir a la prueba] · [Otra cosa]
- [+ 19.9s] 📄 Cargó http://localhost:54297/misma-pagina.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 19.9s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 19.9s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 21.5s] 💬 JEF: Estás en la página de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados por precio: los In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
- [+ 21.5s] 🔊 «Estás en la página de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados por precio: los In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.»
- [+ 21.5s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:54297/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la página de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados por precio: los In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
 10 [btn] Leer la página  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 3 — no toca el asistente durante 12 s (resuelve algo en la página)


Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:54297/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la página de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados por precio: los In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
 10 [btn] Leer la página  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 4 — escribe «¿cuánto sale el más barato?»

- [+ 48.6s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 50.9s] 💬 JEF: El modelo más barato son los auriculares In Ear Bluetooth Básicos, que cuestan 12.499 pesos.
- [+ 50.9s] 🔊 «El modelo más barato son los auriculares In Ear Bluetooth Básicos, que cuestan 12.499 pesos.»
- [+ 50.9s] 🔘 Botones: [¿Cuánto salen los de vincha?] · [¿Cuáles son los más caros?] · [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:54297/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la página de auriculares bluetooth. Hay tres modelos disponibles con envío gratis, ordenados por precio: los In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
 10 [H] Vos: ¿cuánto sale el más barato?
 11 [txt] El modelo más barato son los auriculares In Ear Bluetooth Básicos, que cuestan 12.499 pesos.
 12 [btn] ¿Cuánto salen los de vincha?  (Primera de 5 opciones.)
 13 [btn] ¿Cuáles son los más caros?
 14 [btn] Leer la página
 15 [btn] Resumir la página
 16 [btn] Otra cosa
 17 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 18 [btn] Enviar
```
