# campos-que-reaccionan

**Quién:** Cualquiera: completa un formulario cuyos campos reaccionan a lo que se escribe.

**Qué quiere:** Que JEF diga «Listo» sólo si el valor quedó: el DNI con puntos sí; letras en el código postal, que las borra, no. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/campos.html»

- [+  6.4s] 💬 Persona: http://localhost:8765/campos.html
- [+  6.4s] 💬 JEF: Abriendo localhost.
- [+  6.4s] 🔊 «Abriendo localhost.»
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.0s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en la página de datos del socio de la institución. El formulario pide el DNI y el código postal.
- [+ 10.5s] 🔊 «Estás en la página de datos del socio de la institución. El formulario pide el DNI y el código postal.»
- [+ 10.5s] 🔘 Botones: [Completar los datos del socio] · [Resumir la página]
- [+ 10.5s] 🔘 Botones: [Completar los datos del socio] · [Resumir la página] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución. El formulario pide el DNI y el código postal.
  6 [btn] Completar los datos del socio  (Primera de 3 opciones.)
  7 [btn] Resumir la página
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — escribe «poné 30123456 en el DNI»

- [+ 21.3s] 💬 Persona: poné 30123456 en el DNI
- [+ 24.4s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/02.txt)
- [+ 24.4s] 💬 JEF: Listo, escrito en DNI.
- [+ 24.4s] 🔊 «Listo, escrito en DNI.»
- [+ 24.4s] 🔘 Botones: [Completar los datos del socio] · [Resumir la página] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución. El formulario pide el DNI y el código postal.
  6 [H] Vos: poné 30123456 en el DNI
  7 [txt] Listo, escrito en DNI.
  8 [btn] Completar los datos del socio  (Primera de 3 opciones.)
  9 [btn] Resumir la página
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 3 — escribe «poné Palermo en el código postal»

- [+ 35.7s] 💬 Persona: poné Palermo en el código postal
- [+ 40.0s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/03.txt)
- [+ 40.0s] 💬 JEF: No quedó escrito en «Código postal»: la página no lo aceptó.
- [+ 40.0s] 🔊 «No quedó escrito en «Código postal»: la página no lo aceptó.»
- [+ 40.0s] 🔘 Botones: [Completar los datos del socio] · [Resumir la página] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución. El formulario pide el DNI y el código postal.
  6 [H] Vos: poné 30123456 en el DNI
  7 [txt] Listo, escrito en DNI.
  8 [H] Vos: poné Palermo en el código postal
  9 [txt] No quedó escrito en «Código postal»: la página no lo aceptó.
 10 [btn] Completar los datos del socio  (Primera de 3 opciones.)
 11 [btn] Resumir la página
 12 [btn] Otra cosa
 13 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 14 [btn] Enviar
```
