# anti-robot-misma-pagina

**Quién:** 72 años, baja visión. La prueba la resuelve su nieta, que le avisa cuando está.

**Qué quiere:** Resolver la prueba anti-robot que aparece en la misma página (sin que cambie la dirección) y seguir con la tarea.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:61304/misma-pagina.html»

- [+  6.5s] 💬 Persona: http://localhost:61304/misma-pagina.html
- [+  6.5s] 💬 JEF: Abriendo localhost.
- [+  6.5s] 🔊 «Abriendo localhost.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~80%)
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 📄 Cargó http://localhost:61304/misma-pagina.html — «Auriculares bluetooth» (paginas/01.txt)
- [+  7.6s] 💬 JEF: El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
- [+  7.6s] 🔊 «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~68%)
- [+  7.6s] 🔘 Botones: [Ir a la prueba] · [Ya la resolví] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61304/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [btn] Ir a la prueba  (Primera de 3 opciones.)
  7 [btn] Ya la resolví
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca «Ir a la prueba»

- [+ 16.8s] 💬 Persona: Ir a la prueba
- [+ 16.8s] 💬 JEF: La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
- [+ 16.8s] 🔊 «La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~25%)
- [+ 16.8s] 🔘 Botones: [Ya la resolví] · [Ir a la prueba] · [Otra cosa]
- [+ 19.6s] 📄 Cargó http://localhost:61304/misma-pagina.html — «Auriculares bluetooth» (paginas/02.txt)
- [+ 19.6s] 💬 JEF: Listo, ya pasamos la verificación.
- [+ 19.6s] 🔊 «Listo, ya pasamos la verificación.»
- [+ 22.3s] 💬 JEF: Esta tienda muestra tres auriculares bluetooth disponibles, con envío gratis a todo el país y ordenados de menor a mayor precio. ¿Cuál de los tres auriculares necesitas?
- [+ 22.3s] 🔊 «Esta tienda muestra tres auriculares bluetooth disponibles, con envío gratis a todo el país y ordenados de menor a mayor precio. ¿Cuál de los tres auriculares necesitas?»
- [+ 22.3s] 🔘 Botones: [Auriculares In Ear Bluetooth Básicos] · [Auriculares Vincha Bluetooth con Micrófono] · [Auriculares con Cancelación de Ruido]
- [+ 22.3s] 🔘 Botones: [Auriculares In Ear Bluetooth Básicos] · [Auriculares Vincha Bluetooth con Micrófono] · [Auriculares con Cancelación de Ruido] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61304/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Esta tienda muestra tres auriculares bluetooth disponibles, con envío gratis a todo el país y ordenados de menor a mayor precio. ¿Cuál de los tres auriculares necesitas?
 10 [btn] Auriculares In Ear Bluetooth Básicos  (Primera de 4 opciones.)
 11 [btn] Auriculares Vincha Bluetooth con Micrófono
 12 [btn] Auriculares con Cancelación de Ruido
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — no toca el asistente durante 12 s (resuelve algo en la página)


Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61304/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Esta tienda muestra tres auriculares bluetooth disponibles, con envío gratis a todo el país y ordenados de menor a mayor precio. ¿Cuál de los tres auriculares necesitas?
 10 [btn] Auriculares In Ear Bluetooth Básicos  (Primera de 4 opciones.)
 11 [btn] Auriculares Vincha Bluetooth con Micrófono
 12 [btn] Auriculares con Cancelación de Ruido
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 4 — escribe «¿cuánto sale el más barato?»

- [+ 48.5s] 💬 Persona: ¿cuánto sale el más barato?
- [+ 52.7s] 💬 JEF: El más barato, los Auriculares In Ear Bluetooth Básicos, cuesta $12.499.
- [+ 52.7s] 🔊 «El más barato, los Auriculares In Ear Bluetooth Básicos, cuesta $12.499.»
- [+ 52.7s] 🔘 Botones: [Abrir «Auriculares In Ear Bluetooth Básicos»] · [Abrir «Auriculares Vincha Bluetooth con Micrófono»] · [Abrir «Auriculares con Cancelación de Ruido»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:61304/misma-pagina.html
  4 [txt] Abriendo localhost.
  5 [txt] El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.
  6 [H] Vos: Ir a la prueba
  7 [txt] La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».
  8 [txt] Listo, ya pasamos la verificación.
  9 [txt] Esta tienda muestra tres auriculares bluetooth disponibles, con envío gratis a todo el país y ordenados de menor a mayor precio. ¿Cuál de los tres auriculares necesitas?
 10 [H] Vos: ¿cuánto sale el más barato?
 11 [txt] El más barato, los Auriculares In Ear Bluetooth Básicos, cuesta $12.499.
 12 [btn] Abrir «Auriculares In Ear Bluetooth Básicos»  (Primera de 4 opciones.)
 13 [btn] Abrir «Auriculares Vincha Bluetooth con Micrófono»
 14 [btn] Abrir «Auriculares con Cancelación de Ruido»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
