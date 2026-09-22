# cerrar-asistente

**Quién:** Baja visión. A veces quiere mirar la página entera y tocarla ella misma.

**Qué quiere:** Cerrar el asistente para ver la página en pantalla completa, volver a abrirlo y seguir pidiendo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarín»

- [+  6.6s] 💬 Persona: clarín
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.6s] 💬 JEF: Buscando: clarín.
- [+  7.6s] 🔊 «Buscando: clarín.»
- [+ 11.2s] 📄 Cargó https://www.google.com/search?q=clar%C3%ADn&gl=ar&hl=es — «clarín - Buscar con Google» (paginas/01.txt)
- [+ 11.2s] 💬 JEF: Estás en los resultados de «clarín». Los 2 más probables:
- [+ 11.2s] 🔊 «Estás en los resultados de «clarín». Los 2 más probables: 1. Clarin.com, clarin.com. 2. Clarín (periódico) - Wikipedia, la enciclopedia libre, es.wikipedia.org»
- [+ 11.2s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org]
- [+ 11.2s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Otra cosa]

Al terminar el paso (12 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarín
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  6 [btn] Clarin.com — www.clarin.com  (Primera de 3 opciones.)
  7 [btn] Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Clarin.com — www.clarin.com»

- [+ 16.9s] 💬 Persona: Clarin.com — www.clarin.com
- [+ 16.9s] 💬 JEF: Abriendo google.com.
- [+ 16.9s] 🔊 «Abriendo google.com.»
- [+ 22.2s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/02.txt)
- [+ 23.2s] 💬 JEF: Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
- [+ 23.2s] 🔊 «Estás en la portada de Clarín. Los titulares principales: 1. Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre. 2. Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en público la reforma. 3. Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su agencia de viajes. 4. Primera reacción del Gobierno tras el intento de Adorni de justificar su enriquecimiento.»
- [+ 23.2s] 🔘 Botones: [Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»] · [Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»] · [Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»] · [Abrir «Primera reacción del Gobierno tras el intento de Adorni de justificar su enriquecimiento»]
- [+ 23.2s] 🔘 Botones: [Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»] · [Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»] · [Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»] · [Abrir «Primera reacción del Gobierno tras el intento de Adorni de justificar su enriquecimiento»] · [Volver a los resultados] · [Otra cosa]
- [+ 23.9s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/03.txt)

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarín
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  6 [H] Vos: Clarin.com — www.clarin.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»  (Primera de 6 opciones.)
 10 [btn] Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»
 11 [btn] Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»
 12 [btn] Abrir «Primera reacción del Gobierno tras el intento de Adorni de justificar su enriquecimiento»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 3 — toca «Cerrar el asistente»


Al terminar el paso (7 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [btn] Volver
  2 [btn] Abrir el asistente  = clarin.com
```

## Paso 4 — no toca el asistente durante 4 s (resuelve algo en la página)


Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [btn] Volver
  2 [btn] Abrir el asistente  = clarin.com
```

## Paso 5 — toca «Abrir el asistente»


Al terminar el paso (7 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarín
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  6 [H] Vos: Clarin.com — www.clarin.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»  (Primera de 6 opciones.)
 10 [btn] Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»
 11 [btn] Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»
 12 [btn] Abrir «Primera reacción del Gobierno tras el intento de Adorni de justificar su enriquecimiento»
 13 [btn] Volver a los resultados
 14 [btn] Otra cosa
 15 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 16 [btn] Enviar
```

## Paso 6 — escribe «dame los titulares»

- [+ 56.2s] 💬 Persona: dame los titulares
- [+ 57.3s] 💬 JEF: Titulares 1 a 3:
- [+ 57.3s] 🔊 «Titulares 1 a 3:»
- [+ 57.3s] 💬 JEF: 1. Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre
- [+ 57.3s] 🔊 «1. Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»
- [+ 57.3s] 💬 JEF: 2. Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en público la reforma
- [+ 57.3s] 🔊 «2. Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en público la reforma»  ⟶ en cola: empieza a sonar a los +64.2s
- [+ 57.3s] 💬 JEF: 3. Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su agencia de viajes
- [+ 57.3s] 🔊 «3. Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su agencia de viajes»  ⟶ en cola: empieza a sonar a los +72.6s
- [+ 57.3s] 🔘 Botones: [Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»] · [Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»] · [Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»] · [Seguir con los titulares] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (10 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-06.txt, captura en paso-06.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarín
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  6 [H] Vos: Clarin.com — www.clarin.com
  7 [txt] Abriendo google.com.
  8 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  9 [H] Vos: dame los titulares
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre
 12 [txt] 2. Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en público la reforma
 13 [txt] 3. Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su agencia de viajes
 14 [btn] Abrir «Trump afirmó que “Cuba caerá” y anunció un acuerdo con Irán luego de noviembre»  (Primera de 6 opciones.)
 15 [btn] Abrir «Quién es la jueza que a días de asumir benefició a un menor que atacó a un playero y critica en…»
 16 [btn] Abrir «Garbarino y su dueño, en quiebra: la Justicia avanza con el remate de los bienes de la cadena y su…»
 17 [btn] Seguir con los titulares
 18 [btn] Volver a los resultados
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```
