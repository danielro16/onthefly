# campos-que-reaccionan

**Quién:** Cualquiera: completa un formulario cuyos campos reaccionan a lo que se escribe.

**Qué quiere:** Que JEF diga «Listo» sólo si el valor quedó: el DNI con puntos sí; letras en el código postal, que las borra, no. Necesita la página de prueba servida: python3 -m http.server 8765 --directory Tests

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «http://localhost:8765/campos.html»

- [+  6.6s] 💬 Persona: http://localhost:8765/campos.html
- [+  6.6s] 💬 JEF: Abriendo localhost.
- [+  6.6s] 🔊 «Abriendo localhost.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.8s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/01.txt)
- [+  9.4s] 💬 JEF: Estás en la página de datos del socio de la institución, un formulario que pide el DNI y el código postal, con un botón de Guardar al final. Si me das esos dos datos, los completo y lo guardamos.
- [+  9.4s] 🔊 «Estás en la página de datos del socio de la institución, un formulario que pide el DNI y el código postal, con un botón de Guardar al final. Si me das esos dos datos, los completo y lo guardamos.»
- [+  9.4s] 🔘 Botones: [Completar datos del socio]
- [+  9.4s] 🔘 Botones: [Completar datos del socio] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución, un formulario que pide el DNI y el código postal, con un botón de Guardar al final. Si me das esos dos datos, los completo y lo guardamos.
  6 [btn] Completar datos del socio  (Primera de 2 opciones.)
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — escribe «poné 30123456 en el DNI»

- [+ 16.9s] 💬 Persona: poné 30123456 en el DNI
- [+ 20.5s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/02.txt)
- [+ 20.5s] 💬 JEF: Listo, escrito en DNI.
- [+ 20.5s] 🔊 «Listo, escrito en DNI.»
- [+ 20.5s] 🔘 Botones: [Completar datos del socio] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución, un formulario que pide el DNI y el código postal, con un botón de Guardar al final. Si me das esos dos datos, los completo y lo guardamos.
  6 [H] Vos: poné 30123456 en el DNI
  7 [txt] Listo, escrito en DNI.
  8 [btn] Completar datos del socio  (Primera de 2 opciones.)
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 3 — escribe «poné Palermo en el código postal»

- [+ 28.8s] 💬 Persona: poné Palermo en el código postal
- [+ 31.8s] 📄 Cargó http://localhost:8765/campos.html — «Datos del socio» (paginas/03.txt)
- [+ 31.8s] 💬 JEF: No quedó escrito en «Código postal»: la página no lo aceptó.
- [+ 31.8s] 🔊 «No quedó escrito en «Código postal»: la página no lo aceptó.»
- [+ 31.8s] 🔘 Botones: [Completar datos del socio] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: http://localhost:8765/campos.html
  4 [txt] Abriendo localhost.
  5 [txt] Estás en la página de datos del socio de la institución, un formulario que pide el DNI y el código postal, con un botón de Guardar al final. Si me das esos dos datos, los completo y lo guardamos.
  6 [H] Vos: poné 30123456 en el DNI
  7 [txt] Listo, escrito en DNI.
  8 [H] Vos: poné Palermo en el código postal
  9 [txt] No quedó escrito en «Código postal»: la página no lo aceptó.
 10 [btn] Completar datos del socio  (Primera de 2 opciones.)
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
