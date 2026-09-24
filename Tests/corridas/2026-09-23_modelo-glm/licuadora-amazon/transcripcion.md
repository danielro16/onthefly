# licuadora-amazon

**Quién:** Vive en México, con baja visión. Quiere comprar una licuadora en Amazon.

**Qué quiere:** Que JEF entre a Amazon México, busque licuadoras, abra una y diga el precio que está en la página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «entrá a Amazon México y buscame una licuadora»

- [+  6.6s] 💬 Persona: entrá a Amazon México y buscame una licuadora
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.0s] 💬 JEF: Buscando: Amazon México.
- [+  8.0s] 🔊 «Buscando: Amazon México.»
- [+ 13.6s] 📄 Cargó https://www.google.com/search?q=Amazon%20M%C3%A9xico&gl=us&hl=es — «Amazon México - Buscar con Google» (paginas/01.txt)
- [+ 14.0s] 💬 JEF: Estás en los resultados de «Amazon México». Los 3 más probables:
- [+ 14.0s] 🔊 «Estás en los resultados de «Amazon México». Los 3 más probables: 1. Amazon, .com.mx, amazon.com.mx. 2. México - Latinoamérica: Tienda Kindle, amazon.com. 3. Amazon.com. Spend less. Smile more., amazon.com»
- [+ 14.0s] 🔘 Botones: [Amazon, .com.mx — www.amazon.com.mx] · [México - Latinoamérica: Tienda Kindle — www.amazon.com] · [Amazon.com. Spend less. Smile more. — www.amazon.com] · [Ver más opciones (1)]
- [+ 14.0s] 💬 JEF: Cuando elijas, sigo con «búscame una licuadora».
- [+ 14.0s] 🔊 «Cuando elijas, sigo con «búscame una licuadora».»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 14.0s] 🔘 Botones: [Amazon, .com.mx — www.amazon.com.mx] · [México - Latinoamérica: Tienda Kindle — www.amazon.com] · [Amazon.com. Spend less. Smile more. — www.amazon.com] · [Ver más opciones (1)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «búscame una licuadora».
  7 [btn] Amazon, .com.mx — www.amazon.com.mx  (Primera de 5 opciones.)
  8 [btn] México - Latinoamérica: Tienda Kindle — www.amazon.com
  9 [btn] Amazon.com. Spend less. Smile more. — www.amazon.com
 10 [btn] Ver más opciones (1)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Amazon, .com.mx — www.amazon.com.mx»

- [+ 24.8s] 💬 Persona: Amazon, .com.mx — www.amazon.com.mx
- [+ 24.8s] 💬 JEF: Abriendo amazon.com.mx.
- [+ 24.8s] 🔊 «Abriendo amazon.com.mx.»
- [+ 29.8s] 📄 Cargó https://www.amazon.com.mx/ — «Amazon.com.mx: Precios bajos - Envío rápido» (paginas/02.txt)
- [+ 29.8s] 💬 JEF: Estás en www.amazon.com.mx.
- [+ 29.8s] 🔊 «Estás en www.amazon.com.mx.»
- [+ 32.1s] 💬 JEF: Esta página no ofrece nada que pueda abrir.
- [+ 32.1s] 🔊 «Esta página no ofrece nada que pueda abrir.»
- [+ 32.1s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «búscame una licuadora».
  7 [H] Vos: Amazon, .com.mx — www.amazon.com.mx
  8 [txt] Abriendo amazon.com.mx.
  9 [txt] Estás en www.amazon.com.mx.
 10 [txt] Esta página no ofrece nada que pueda abrir.
 11 [btn] Leer la página  (Primera de 4 opciones.)
 12 [btn] Resumir la página
 13 [btn] Volver a la portada
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — escribe «¿cuánto cuesta?»

- [+ 39.9s] 💬 Persona: ¿cuánto cuesta?
- [+ 44.5s] 💬 JEF: Esta página no ofrece nada que pueda abrir.
- [+ 44.5s] 🔊 «Esta página no ofrece nada que pueda abrir.»
- [+ 50.9s] 💬 JEF: Esta página no ofrece nada que pueda abrir.
- [+ 50.9s] 🔊 «Esta página no ofrece nada que pueda abrir.»
- [+ 50.9s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a la portada] · [Otra cosa]

Al terminar el paso (19 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a Amazon México y buscame una licuadora
  4 [txt] Buscando: Amazon México.
  5 [txt] Estás en los resultados de «Amazon México». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «búscame una licuadora».
  7 [H] Vos: Amazon, .com.mx — www.amazon.com.mx
  8 [txt] Abriendo amazon.com.mx.
  9 [txt] Estás en www.amazon.com.mx.
 10 [txt] Esta página no ofrece nada que pueda abrir.
 11 [H] Vos: ¿cuánto cuesta?
 12 [txt] Esta página no ofrece nada que pueda abrir.
 13 [txt] Esta página no ofrece nada que pueda abrir.
 14 [btn] Leer la página  (Primera de 4 opciones.)
 15 [btn] Resumir la página
 16 [btn] Volver a la portada
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```
