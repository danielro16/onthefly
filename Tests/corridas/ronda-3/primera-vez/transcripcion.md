# primera-vez

**Quién:** 72 años, es la primera vez que abre la app. No sabe qué se puede hacer.

**Qué quiere:** Entender qué hace la app y llegar a algo útil.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «hola, ¿qué podés hacer?»

- [+  6.6s] 💬 Persona: hola, ¿qué podés hacer?
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 💬 JEF: Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
- [+  7.7s] 🔊 «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»  ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~56%)
- [+  7.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [btn] Llevame a La Nación  (Primera de 4 opciones.)
  5 [btn] ¿A cuánto está el dólar hoy?
  6 [btn] ¿Cómo va a estar el tiempo mañana?
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
  9 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Llevame a La Nación»

- [+ 13.6s] 💬 Persona: Llevame a La Nación
- [+ 13.6s] 💬 JEF: Abriendo lanacion.com.ar.
- [+ 13.6s] 🔊 «Abriendo lanacion.com.ar.»
- [+ 18.7s] 📄 Cargó https://www.lanacion.com.ar/ — «Últimas noticias de Argentina y el mundo» (paginas/01.txt)
- [+ 21.0s] 💬 JEF: Estás en la portada de LA NACION. Los titulares principales son: El secretario de Discapacidad presentó su renuncia. Las grandes cadenas de TV reaccionan al veto de Trump. Un gas contaminado en un interruptor sería la causa de un apagón que dejó a oscuras a más de 2 millones de personas. El Vaticano difundió el cronograma oficial del papa León XIV en la Argentina. Procesaron a siete iraníes y un libanés como presuntos responsables del atentado a la AMIA.
- [+ 21.0s] 🔊 «Estás en la portada de LA NACION. Los titulares principales son: El secretario de Discapacidad presentó su renuncia. Las grandes cadenas de TV reaccionan al veto de Trump. Un gas contaminado en un interruptor sería la causa de un apagón que dejó a oscuras a más de 2 millones de personas. El Vaticano difundió el cronograma oficial del papa León XIV en la Argentina. Procesaron a siete iraníes y un libanés como presuntos responsables del atentado a la AMIA.»
- [+ 21.0s] 🔘 Botones: [Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»] · [Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»] · [Abrir «Interruptor L46. Un gas contaminado en un interruptor sería la causa…»] · [Abrir «Los detalles. El Vaticano difundió el cronograma oficial del papa…»]
- [+ 21.0s] 🔘 Botones: [Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»] · [Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»] · [Abrir «Interruptor L46. Un gas contaminado en un interruptor sería la causa…»] · [Abrir «Los detalles. El Vaticano difundió el cronograma oficial del papa…»] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [txt] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION. Los titulares principales son: El secretario de Discapacidad presentó su renuncia. Las grandes cadenas de TV reaccionan al veto de Trump. Un gas contaminado en un interruptor sería la causa de un apagón que dejó a oscuras a más de 2 millones de personas. El Vaticano difundió el cronograma oficial del papa León XIV en la Argentina. Procesaron a siete iraníes y un libanés como presuntos responsables del atentado a la AMIA.
  7 [btn] Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»  (Primera de 5 opciones.)
  8 [btn] Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»
  9 [btn] Abrir «Interruptor L46. Un gas contaminado en un interruptor sería la causa…»
 10 [btn] Abrir «Los detalles. El Vaticano difundió el cronograma oficial del papa…»
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 13 [btn] Enviar
```

## Paso 3 — escribe «no entiendo, ¿dónde estoy?»

- [+ 28.4s] 💬 Persona: no entiendo, ¿dónde estoy?
- [+ 32.2s] 💬 JEF: En Últimas noticias de Argentina y el mundo — LA NACION.
- [+ 32.2s] 🔊 «En Últimas noticias de Argentina y el mundo — LA NACION.»
- [+ 32.2s] 💬 JEF: Hay 140 notas. Las tres primeras:
- [+ 32.2s] 🔊 «Hay 140 notas. Las tres primeras:»  ⟶ en cola: empieza a sonar a los +36.2s
- [+ 32.2s] 💬 JEF: Por carta. El secretario de Discapacidad presentó su renuncia en medio de la puja por el rumbo del área
- [+ 32.2s] 🔊 «Por carta. El secretario de Discapacidad presentó su renuncia en medio de la puja por el rumbo del área»  ⟶ en cola: empieza a sonar a los +38.5s
- [+ 32.2s] 💬 JEF: Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele
- [+ 32.2s] 🔊 «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele»  ⟶ en cola: empieza a sonar a los +45.9s
- [+ 32.2s] 💬 JEF: Interruptor L46. Un gas contaminado en un interruptor sería la causa del apagón que dejó a oscuras a más de 2 millones d
- [+ 32.2s] 🔊 «Interruptor L46. Un gas contaminado en un interruptor sería la causa del apagón que dejó a oscuras a más de 2 millones d»  ⟶ en cola: empieza a sonar a los +52.5s
- [+ 32.2s] 🔘 Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [txt] Vos: hola, ¿qué podés hacer?
  3 [txt] Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.
  4 [txt] Vos: Llevame a La Nación
  5 [txt] Abriendo lanacion.com.ar.
  6 [txt] Estás en la portada de LA NACION. Los titulares principales son: El secretario de Discapacidad presentó su renuncia. Las grandes cadenas de TV reaccionan al veto de Trump. Un gas contaminado en un interruptor sería la causa de un apagón que dejó a oscuras a más de 2 millones de personas. El Vaticano difundió el cronograma oficial del papa León XIV en la Argentina. Procesaron a siete iraníes y un libanés como presuntos responsables del atentado a la AMIA.
  7 [txt] Vos: no entiendo, ¿dónde estoy?
  8 [txt] En Últimas noticias de Argentina y el mundo — LA NACION.
  9 [txt] Hay 140 notas. Las tres primeras:
 10 [txt] Por carta. El secretario de Discapacidad presentó su renuncia en medio de la puja por el rumbo del área
 11 [txt] Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y golpean donde más le duele
 12 [txt] Interruptor L46. Un gas contaminado en un interruptor sería la causa del apagón que dejó a oscuras a más de 2 millones d
 13 [btn] Leer los titulares  (Primera de 3 opciones.)
 14 [btn] Resumir la portada
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)
 17 [btn] Enviar
```
