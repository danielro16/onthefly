# licuadora-amazon

**Quién:** Vive en México, con baja visión. Quiere comprar una licuadora en Amazon.

**Qué quiere:** Que JEF entre a Amazon México, busque licuadoras, abra una y diga el precio que está en la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «entrá a Amazon México y buscame una licuadora»

- [+  6.6s] 💬 Persona: entrá a Amazon México y buscame una licuadora
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.2s] 💬 JEF: Buscando: Amazon México.
- [+  9.2s] 🔊 «Buscando: Amazon México.»
- [+ 13.7s] 📄 Cargó https://www.google.com/search?q=Amazon%20M%C3%A9xico&gl=us&hl=es — «Amazon México - Buscar con Google» (paginas/01.txt)
- [+ 14.1s] 💬 JEF: Estás en los resultados de «Amazon México». Los 3 más probables:
- [+ 14.1s] 🔊 «Estás en los resultados de «Amazon México». Los 3 más probables: 1. Amazon, .com.mx, amazon.com.mx. 2. México - Latinoamérica: Tienda Kindle, amazon.com. 3. Amazon.com. Spend less. Smile more., amazon.com»
- [+ 14.1s] 🔘 Botones: [Amazon, .com.mx — www.amazon.com.mx] · [México - Latinoamérica: Tienda Kindle — www.amazon.com] · [Amazon.com. Spend less. Smile more. — www.amazon.com] · [Ver más opciones (1)]
- [+ 14.1s] 💬 JEF: Cuando elijas, sigo con «buscame una licuadora».
- [+ 14.1s] 🔊 «Cuando elijas, sigo con «buscame una licuadora».»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 14.1s] 🔘 Botones: [Amazon, .com.mx — www.amazon.com.mx] · [México - Latinoamérica: Tienda Kindle — www.amazon.com] · [Amazon.com. Spend less. Smile more. — www.amazon.com] · [Ver más opciones (1)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «buscame una licuadora».
  7 [btn] Amazon, .com.mx — www.amazon.com.mx  (Primera de 5 opciones.)
  8 [btn] México - Latinoamérica: Tienda Kindle — www.amazon.com
  9 [btn] Amazon.com. Spend less. Smile more. — www.amazon.com
 10 [btn] Ver más opciones (1)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Amazon, .com.mx — www.amazon.com.mx»

- [+ 24.9s] 💬 Persona: Amazon, .com.mx — www.amazon.com.mx
- [+ 24.9s] 💬 JEF: Abriendo amazon.com.mx.
- [+ 24.9s] 🔊 «Abriendo amazon.com.mx.»
- [+ 28.7s] 📄 Cargó https://www.amazon.com.mx/ — «Amazon.com.mx: Precios bajos - Envío rápido» (paginas/02.txt)
- [+ 28.7s] 💬 JEF: Estás en www.amazon.com.mx.
- [+ 28.7s] 🔊 «Estás en www.amazon.com.mx.»
- [+ 35.7s] 💬 JEF: Estás en Amazon México, pero una ventana de inicio de sesión cubre la página; ciérrala para poder buscar.
- [+ 35.7s] 🔊 «Estás en Amazon México, pero una ventana de inicio de sesión cubre la página; ciérrala para poder buscar.»
- [+ 35.7s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «buscame una licuadora».
  7 [H] Vos: Amazon, .com.mx — www.amazon.com.mx
  8 [txt] Abriendo amazon.com.mx.
  9 [txt] Estás en www.amazon.com.mx.
 10 [txt] Estás en Amazon México, pero una ventana de inicio de sesión cubre la página; ciérrala para poder buscar.
 11 [btn] Leer la página  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a la portada
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto cuesta?»

- [+ 43.1s] 💬 Persona: ¿cuánto cuesta?
- [+ 47.2s] 💬 JEF: Eso no aparece en esta página.
- [+ 47.2s] 🔊 «Eso no aparece en esta página.»
- [+ 47.2s] 🔘 Botones: [Buscarlo en internet] · [Leer la página] · [Resumir la página] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «buscame una licuadora».
  7 [H] Vos: Amazon, .com.mx — www.amazon.com.mx
  8 [txt] Abriendo amazon.com.mx.
  9 [txt] Estás en www.amazon.com.mx.
 10 [txt] Estás en Amazon México, pero una ventana de inicio de sesión cubre la página; ciérrala para poder buscar.
 11 [H] Vos: ¿cuánto cuesta?
 12 [txt] Eso no aparece en esta página.
 13 [btn] Buscarlo en internet  (Primera de 5 opciones.)
 14 [btn] Leer la página
 15 [btn] Resumir la página
 16 [btn] Volver a la portada
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```
