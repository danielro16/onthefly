# anti-robot-misma-pagina

**Quién:** 72 años, baja visión. La prueba la resuelve su nieta, que le avisa cuando está.

**Qué quiere:** Resolver la prueba anti-robot que aparece en la misma página (sin que cambie la dirección) y seguir con la tarea.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:56797/misma-pagina.html»

- [+  6.7s] 💬 Persona: http://localhost:56797/misma-pagina.html
- [+  6.7s] 💬 JEF: Abriendo localhost.
- [+  6.7s] 🔊 «Abriendo localhost.»
- [+  6.8s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.7s] 📄 Cargó http://localhost:56797/misma-pagina.html — «Auriculares bluetooth» (paginas/01.txt)
- [+  9.7s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  9.7s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~45%)
- [+  9.7s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56797/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca «Ir a la prueba»

- [+ 15.8s] 💬 Persona: Ir a la prueba
- [+ 15.8s] 💬 JEF: La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
- [+ 15.8s] 🔊 «La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~42%)
- [+ 15.8s] 🔘 Botones: [Ya la resolví] · [Ir a la prueba] · [Otra cosa]
- [+ 20.5s] 📄 Cargó http://localhost:56797/misma-pagina.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 20.5s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 20.5s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 22.8s] 💬 JEF: Estás en la sección de auriculares bluetooth, donde hay tres opciones disponibles con envío gratis, ordenadas de menor a mayor precio: los auriculares In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
- [+ 22.8s] 🔊 «Estás en la sección de auriculares bluetooth, donde hay tres opciones disponibles con envío gratis, ordenadas de menor a mayor precio: los auriculares In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.»
- [+ 22.8s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56797/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la sección de auriculares bluetooth, donde hay tres opciones disponibles con envío gratis, ordenadas de menor a mayor precio: los auriculares In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
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
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56797/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la sección de auriculares bluetooth, donde hay tres opciones disponibles con envío gratis, ordenadas de menor a mayor precio: los auriculares In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
 10 [btn] Leer la página  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 4 — escribe «¿cuánto sale el más barato?»

- [+ 49.7s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 52.6s] 💬 JEF: El modelo más barato es el de los auriculares In Ear Bluetooth Básicos, que cuesta 12.499 pesos.
- [+ 52.6s] 🔊 «El modelo más barato es el de los auriculares In Ear Bluetooth Básicos, que cuesta 12.499 pesos.»
- [+ 52.6s] 🔘 Botones: [¿Qué opciones de gama media hay?] · [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: http://localhost:56797/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Estás en la sección de auriculares bluetooth, donde hay tres opciones disponibles con envío gratis, ordenadas de menor a mayor precio: los auriculares In Ear Básicos a $12.499, los de Vincha con micrófono a $24.990 y los de Cancelación de Ruido a $89.900.
 10 [H] Vos: ¿cuánto sale el más barato?
 11 [txt] El modelo más barato es el de los auriculares In Ear Bluetooth Básicos, que cuesta 12.499 pesos.
 12 [btn] ¿Qué opciones de gama media hay?  (Primera de 4 opciones.)
 13 [btn] Leer la página
 14 [btn] Resumir la página
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
