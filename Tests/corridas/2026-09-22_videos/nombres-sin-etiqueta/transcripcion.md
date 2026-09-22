# nombres-sin-etiqueta

**Quién:** Ciega. Entra a una página con botones que son sólo dibujos: una lupa, tres rayas, una ×, un carrito.

**Qué quiere:** Que esos botones tengan nombre en su idioma, y que JEF se los diga. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/roto.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/roto.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.8s] 📄 Cargó http://localhost:8765/roto.html — «Página rota a propósito» (paginas/01.txt)
- [+  9.3s] 📄 Cargó http://localhost:8765/roto.html — «Página rota a propósito» (paginas/02.txt)
- [+ 10.3s] 💬 JEF: Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.
- [+ 10.3s] 🔊 «Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.»
- [+ 10.3s] 🔘 Botones: [Abrir «Deportes»] · [Resumir contenido]
- [+ 10.3s] 🔘 Botones: [Abrir «Deportes»] · [Resumir contenido] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.
  6 [btn] Abrir «Deportes»  (Primera de 3 opciones.)
  7 [btn] Resumir contenido
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
  5 [txt] Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.
  6 [btn] Abrir «Deportes»  (Primera de 3 opciones.)
  7 [btn] Resumir contenido
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 3 — escribe «¿hay un botón para buscar?»

- [+ 28.7s] 💬 Persona: ¿hay un botón para buscar?
- [+ 31.4s] 💬 JEF: Sí, el diario de prueba cuenta con un botón para buscar.
- [+ 31.4s] 🔊 «Sí, el diario de prueba cuenta con un botón para buscar.»
- [+ 31.4s] 🔘 Botones: [¿Qué secciones tiene el diario?] · [¿Qué dice sobre el clima en Buenos Aires?] · [Leer la página] · [Resumir la página] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.
  6 [H] Vos: ¿hay un botón para buscar?
  7 [txt] Sí, el diario de prueba cuenta con un botón para buscar.
  8 [btn] ¿Qué secciones tiene el diario?  (Primera de 5 opciones.)
  9 [btn] ¿Qué dice sobre el clima en Buenos Aires?
 10 [btn] Leer la página
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```

## Paso 4 — escribe «abrí el carrito»

- [+ 38.8s] 💬 Persona: abrí el carrito
- [+ 39.8s] 💬 JEF: Abriendo «Carrito».
- [+ 39.8s] 🔊 «Abriendo «Carrito».»
- [+ 40.9s] 🔊 «Carrito no cambió la página.»
- [+ 42.3s] 💬 JEF: Te encuentras en la página de inicio de Diario de prueba. El acceso al carrito que buscas se encuentra en la opción número 4.
- [+ 42.3s] 🔊 «Te encuentras en la página de inicio de Diario de prueba. El acceso al carrito que buscas se encuentra en la opción número 4.»
- [+ 42.3s] 🔘 Botones: [Abrir «Carrito»] · [Resumir página]
- [+ 42.3s] 🔘 Botones: [Abrir «Carrito»] · [Resumir página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/roto.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en el Diario de prueba, donde se informa que Buenos Aires amaneció nublada y con probabilidad de lluvia que no se tomó en serio hasta el mediodía.
  6 [H] Vos: ¿hay un botón para buscar?
  7 [txt] Sí, el diario de prueba cuenta con un botón para buscar.
  8 [H] Vos: abrí el carrito
  9 [txt] Abriendo «Carrito».
 10 [txt] Te encuentras en la página de inicio de Diario de prueba. El acceso al carrito que buscas se encuentra en la opción número 4.
 11 [btn] Abrir «Carrito»  (Primera de 3 opciones.)
 12 [btn] Resumir página
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```
