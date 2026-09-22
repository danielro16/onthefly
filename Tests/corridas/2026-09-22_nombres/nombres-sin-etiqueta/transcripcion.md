# nombres-sin-etiqueta

**Quién:** Ciega. Entra a una página con botones que son sólo dibujos: una lupa, tres rayas, una ×, un carrito.

**Qué quiere:** Que esos botones tengan nombre en su idioma, y que JEF se los diga. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/roto.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/roto.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.0s] 📄 Cargó http://localhost:8765/roto.html — «Página rota a propósito» (paginas/01.txt)
- [+  9.7s] 📄 Cargó http://localhost:8765/roto.html — «Página rota a propósito» (paginas/02.txt)
- [+ 10.2s] 💬 JEF: Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.
- [+ 10.2s] 🔊 «Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.»
- [+ 10.2s] 🔘 Botones: [Abrir «Deportes»] · [Resumir el texto]
- [+ 10.2s] 🔘 Botones: [Abrir «Deportes»] · [Resumir el texto] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.
  6 [btn] Abrir «Deportes»  (Primera de 3 opciones.)
  7 [btn] Resumir el texto
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — no toca el asistente durante 4 s (resuelve algo en la página)


Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.
  6 [btn] Abrir «Deportes»  (Primera de 3 opciones.)
  7 [btn] Resumir el texto
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 3 — escribe «¿hay un botón para buscar?»

- [+ 28.9s] 💬 Persona: ¿hay un botón para buscar?
- [+ 30.2s] 💬 JEF: Estás en «Página rota a propósito», localhost. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
- [+ 30.2s] 🔊 «Estás en «Página rota a propósito», localhost. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~84%)
- [+ 30.2s] 🔘 Botones: [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.
  6 [H] Vos: ¿hay un botón para buscar?
  7 [txt] Estás en «Página rota a propósito», localhost. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
  8 [btn] Leer la página  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 4 — escribe «abrí el carrito»

- [+ 38.9s] 💬 Persona: abrí el carrito
- [+ 40.4s] 💬 JEF: Abriendo «Carrito».
- [+ 40.5s] 🔊 «Abriendo «Carrito».»
- [+ 41.5s] 🔊 «Carrito no cambió la página.»
- [+ 42.7s] 💬 JEF: Estás en el sitio web del Diario de prueba. El acceso al carrito que buscas se encuentra en el número 4 de la lista de opciones disponibles.
- [+ 42.7s] 🔊 «Estás en el sitio web del Diario de prueba. El acceso al carrito que buscas se encuentra en el número 4 de la lista de opciones disponibles.»
- [+ 42.7s] 🔘 Botones: [Abrir «Carrito»] · [Resumir página]
- [+ 42.7s] 🔘 Botones: [Abrir «Carrito»] · [Resumir página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que el 12 de octubre Buenos Aires amaneció nublada y con una probabilidad de lluvia que nadie se tomó en serio hasta el mediodía. Esta página sirve para consultar secciones como deportes.
  6 [H] Vos: ¿hay un botón para buscar?
  7 [txt] Estás en «Página rota a propósito», localhost. Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.
  8 [H] Vos: abrí el carrito
  9 [txt] Abriendo «Carrito».
 10 [txt] Estás en el sitio web del Diario de prueba. El acceso al carrito que buscas se encuentra en el número 4 de la lista de opciones disponibles.
 11 [btn] Abrir «Carrito»  (Primera de 3 opciones.)
 12 [btn] Resumir página
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
