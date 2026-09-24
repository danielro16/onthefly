# leer-clarin

**Quién:** Vive en Argentina, ciego. Quiere que JEF le lea las noticias de Clarín.

**Qué quiere:** Que llegando con la tarea pendiente, JEF sepa que es una portada y lea los titulares, no el pie de página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «entrá a clarín y leeme las noticias»

- [+  6.5s] 💬 Persona: entrá a clarín y leeme las noticias
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.9s] 💬 JEF: Buscando: clarín.
- [+  8.9s] 🔊 «Buscando: clarín.»
- [+ 11.4s] 📄 Cargó https://www.google.com/search?q=clar%C3%ADn&gl=us&hl=es — «clarín - Buscar con Google» (paginas/01.txt)
- [+ 11.7s] 💬 JEF: Estás en los resultados de «clarín». Los 3 más probables:
- [+ 11.7s] 🔊 «Estás en los resultados de «clarín». Los 3 más probables: 1. Clarin.com, clarin.com. 2. Clarín (periódico) - Wikipedia, la enciclopedia libre, es.wikipedia.org. 3. Clarín 80, clarin80.com»
- [+ 11.7s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Clarín 80 — www.clarin80.com]
- [+ 11.7s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Clarín 80 — www.clarin80.com] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a clarín y leeme las noticias
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  6 [btn] Clarin.com — www.clarin.com  (Primera de 4 opciones.)
  7 [btn] Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org
  8 [btn] Clarín 80 — www.clarin80.com
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```

## Paso 2 — toca «Clarin.com — www.clarin.com»

- [+ 18.5s] 💬 Persona: Clarin.com — www.clarin.com
- [+ 18.5s] 💬 JEF: Abriendo clarin.com.
- [+ 18.5s] 🔊 «Abriendo clarin.com.»
- [+ 23.2s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/02.txt)
- [+ 26.7s] 💬 JEF: Estás en Clarín, la portada del diario con las noticias de Argentina y del mundo. Los titulares principales son las primeras opciones.
- [+ 26.7s] 🔊 «Estás en Clarín, la portada del diario con las noticias de Argentina y del mundo. Los titulares principales: 1. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA. 2. Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”. 3. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia. 4. Ajuste en la obra social de militares: denuncian 600 despidos y el cierre de 13 hoteles.»
- [+ 26.7s] 🔘 Botones: [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Abrir «Ajuste en la obra social de militares: denuncian 600 despidos y el cierre de 13 hoteles»] · [Leer la página]
- [+ 26.7s] 🔘 Botones: [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Abrir «Ajuste en la obra social de militares: denuncian 600 despidos y el cierre de 13 hoteles»] · [Leer la página] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a clarín y leeme las noticias
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  6 [H] Vos: Clarin.com — www.clarin.com
  7 [txt] Abriendo clarin.com.
  8 [txt] Estás en Clarín, la portada del diario con las noticias de Argentina y del mundo. Los titulares principales son las primeras opciones.
  9 [btn] Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»  (Primera de 7 opciones.)
 10 [btn] Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»
 11 [btn] Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»
 12 [btn] Abrir «Ajuste en la obra social de militares: denuncian 600 despidos y el cierre de 13 hoteles»
 13 [btn] Leer la página
 14 [btn] Volver a los resultados
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```
