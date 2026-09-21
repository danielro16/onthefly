# dolar-desde-cero

**Quién:** Ciega, usa VoiceOver en el trabajo. Quiere datos rápido y sin vueltas.

**Qué quiere:** Saber a cuánto está hoy el dólar blue, y después el oficial.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio nuevo corta al que se está diciendo; la duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «¿a cuánto está el dólar blue hoy?»

- [+  0.0s] 💬 Persona: ¿a cuánto está el dólar blue hoy?
- [+  1.1s] 💬 JEF: Buscando: dólar blue hoy.
- [+  1.1s] 🔊 «Buscando: dólar blue hoy.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~0%)
- [+  1.1s] 🔊 «Cargando página»
- [+  4.2s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=d%C3%B3lar%20blue%20hoy&kl=ar-es — «dólar blue hoy at DuckDuckGo» (paginas/01.txt)
- [+  4.2s] 💬 JEF: No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.
- [+  4.2s] 🔊 «No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~62%)
- [+  4.2s] 🔘 Botones: [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.
  5 [btn] Otra cosa  (Va a esta opción)
  6 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  7 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Otra cosa»

- [+  8.7s] 💬 Persona: Otra cosa
- [+  8.7s] 💬 JEF: ¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.
- [+  8.7s] 🔊 «¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.»

Al terminar el paso (7 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.
  5 [txt] Vos: Otra cosa
  6 [txt] ¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.
  7 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  8 [btn] Enviar
```

## Paso 3 — escribe «¿y el oficial?»

- [+ 18.3s] 💬 Persona: ¿y el oficial?
- [+ 20.0s] 💬 JEF: La página muestra una tabla con 33 filas, pero no especifica qué tipo de cambio se detalla ni menciona el "dólar oficial".
- [+ 20.0s] 🔊 «La página muestra una tabla con 33 filas, pero no especifica qué tipo de cambio se detalla ni menciona el "dólar oficial".»
- [+ 20.0s] 🔘 Botones: [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: ¿a cuánto está el dólar blue hoy?
  3 [txt] Buscando: dólar blue hoy.
  4 [txt] No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.
  5 [txt] Vos: Otra cosa
  6 [txt] ¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.
  7 [txt] Vos: ¿y el oficial?
  8 [txt] La página muestra una tabla con 33 filas, pero no especifica qué tipo de cambio se detalla ni menciona el "dólar oficial".
  9 [btn] Otra cosa  (Va a esta opción)
 10 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 11 [btn] Enviar
```
