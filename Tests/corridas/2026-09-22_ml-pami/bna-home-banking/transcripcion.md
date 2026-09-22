# bna-home-banking

**Quién:** Ciega, cliente del Banco Nación.

**Qué quiere:** Entrar al home banking desde la página del banco.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «banco nación»

- [+  6.6s] 💬 Persona: banco nación
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 💬 JEF: Buscando: banco nación.
- [+  7.8s] 🔊 «Buscando: banco nación.»
- [+ 11.3s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=banco%20naci%C3%B3n&kl=ar-es — «banco nación at DuckDuckGo» (paginas/01.txt)
- [+ 11.3s] 💬 JEF: Estás en los resultados de «banco nación». Los 3 más probables:
- [+ 11.3s] 🔊 «Estás en los resultados de «banco nación». Los 3 más probables: 1. Banco de la Nación Argentina, bna.com.ar. 2. Banco de la Nación Argentina - Home banking, digital.bna.com.ar. 3. Home banking - Banco de la Nación Argentina, digital.bna.com.ar»
- [+ 11.3s] 🔘 Botones: [Banco de la Nación Argentina — www.bna.com.ar] · [Banco de la Nación Argentina - Home banking — digital.bna.com.ar] · [Home banking - Banco de la Nación Argentina — digital.bna.com.ar] · [Ver más opciones (5)]
- [+ 11.3s] 🔘 Botones: [Banco de la Nación Argentina — www.bna.com.ar] · [Banco de la Nación Argentina - Home banking — digital.bna.com.ar] · [Home banking - Banco de la Nación Argentina — digital.bna.com.ar] · [Ver más opciones (5)] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: banco nación
  4 [txt] Buscando: banco nación.
  5 [txt] Estás en los resultados de «banco nación». Los 3 más probables:
  6 [btn] Banco de la Nación Argentina — www.bna.com.ar  (Primera de 5 opciones.)
  7 [btn] Banco de la Nación Argentina - Home banking — digital.bna.com.ar
  8 [btn] Home banking - Banco de la Nación Argentina — digital.bna.com.ar
  9 [btn] Ver más opciones (5)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca «Banco de la Nación Argentina — www.bna.com.ar»

- [+ 17.3s] 💬 Persona: Banco de la Nación Argentina — www.bna.com.ar
- [+ 17.3s] 💬 JEF: Abriendo bna.com.ar.
- [+ 17.3s] 🔊 «Abriendo bna.com.ar.»
- [+ 23.6s] 📄 Cargó https://www.bna.com.ar/Personas — «Banco de la Nación Argentina» (paginas/02.txt)
- [+ 25.5s] 💬 JEF: Estás en la página principal del Banco de la Nación Argentina, donde podés gestionar cuentas, solicitar préstamos, realizar inversiones y acceder a la tienda online BNA+. El dólar cotiza a 1485,00 para la compra y 1535,00 para la venta, el euro a 1680,00 para la compra y 1780,00 para la venta, y el real a 28200,00 para la compra y 30400,00 para la venta.
- [+ 25.5s] 🔊 «Estás en la página principal del Banco de la Nación Argentina, donde podés gestionar cuentas, solicitar préstamos, realizar inversiones y acceder a la tienda online BNA+. El dólar cotiza a 1485 para la compra y 1535 para la venta, el euro a 1680 para la compra y 1780 para la venta, y el real a 28200 para la compra y 30400 para la venta.»
- [+ 25.5s] 🔘 Botones: [Abrir «Centro de ayuda»] · [Abrir «Tutoriales»] · [Abrir «Contáctenos»]
- [+ 25.5s] 🔘 Botones: [Abrir «Centro de ayuda»] · [Abrir «Tutoriales»] · [Abrir «Contáctenos»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: banco nación
  4 [txt] Buscando: banco nación.
  5 [txt] Estás en los resultados de «banco nación». Los 3 más probables:
  6 [H] Vos: Banco de la Nación Argentina — www.bna.com.ar
  7 [txt] Abriendo bna.com.ar.
  8 [txt] Estás en la página principal del Banco de la Nación Argentina, donde podés gestionar cuentas, solicitar préstamos, realizar inversiones y acceder a la tienda online BNA+. El dólar cotiza a 1485,00 para la compra y 1535,00 para la venta, el euro a 1680,00 para la compra y 1780,00 para la venta, y el real a 28200,00 para la compra y 30400,00 para la venta.
  9 [btn] Abrir «Centro de ayuda»  (Primera de 5 opciones.)
 10 [btn] Abrir «Tutoriales»
 11 [btn] Abrir «Contáctenos»
 12 [btn] Volver a los resultados
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — escribe «Quiero ir a mi home banking»

- [+ 32.7s] 💬 Persona: Quiero ir a mi home banking
- [+ 35.8s] 💬 JEF: Abriendo Canales Electrónicos.
- [+ 35.8s] 🔊 «Abriendo Canales Electrónicos.»
- [+ 37.1s] 📄 Cargó https://www.bna.com.ar/Personas# — «Banco de la Nación Argentina» (paginas/03.txt)
- [+ 38.2s] 💬 JEF: Sin avance: doy vueltas sobre lo mismo. Probar con otras palabras.
- [+ 38.2s] 🔊 «Sin avance: doy vueltas sobre lo mismo. Probar con otras palabras.»
- [+ 38.2s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Volver a «Banco de la Nación Argentina»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: banco nación
  4 [txt] Buscando: banco nación.
  5 [txt] Estás en los resultados de «banco nación». Los 3 más probables:
  6 [H] Vos: Banco de la Nación Argentina — www.bna.com.ar
  7 [txt] Abriendo bna.com.ar.
  8 [txt] Estás en la página principal del Banco de la Nación Argentina, donde podés gestionar cuentas, solicitar préstamos, realizar inversiones y acceder a la tienda online BNA+. El dólar cotiza a 1485,00 para la compra y 1535,00 para la venta, el euro a 1680,00 para la compra y 1780,00 para la venta, y el real a 28200,00 para la compra y 30400,00 para la venta.
  9 [H] Vos: Quiero ir a mi home banking
 10 [txt] Abriendo Canales Electrónicos.
 11 [txt] Sin avance: doy vueltas sobre lo mismo. Probar con otras palabras.
 12 [btn] Leer la página  (Primera de 4 opciones.)
 13 [btn] Resumir la página
 14 [btn] Volver a «Banco de la Nación Argentina»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
