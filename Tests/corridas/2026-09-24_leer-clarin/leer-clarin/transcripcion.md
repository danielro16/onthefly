# leer-clarin

**Quién:** Vive en Argentina, ciego. Quiere que JEF le lea las noticias de Clarín.

**Qué quiere:** Que llegando con la tarea pendiente, JEF sepa que es una portada y lea los titulares, no el pie de página.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «entrá a clarín y leeme las noticias»

- [+  9.8s] 💬 Persona: entrá a clarín y leeme las noticias
- [+  9.8s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.7s] 💬 JEF: Buscando: clarín.
- [+ 11.7s] 🔊 «Buscando: clarín.»
- [+ 15.6s] 📄 Cargó https://www.google.com/search?q=clar%C3%ADn&gl=us&hl=es — «clarín - Buscar con Google» (paginas/01.txt)
- [+ 15.9s] 💬 JEF: Estás en los resultados de «clarín». Los 3 más probables:
- [+ 16.0s] 🔊 «Estás en los resultados de «clarín». Los 3 más probables: 1. Clarin.com, clarin.com. 2. Clarín (periódico) - Wikipedia, la enciclopedia libre, es.wikipedia.org. 3. Clarín (Argentine newspaper), en.wikipedia.org»
- [+ 16.0s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Clarín (Argentine newspaper) — en.wikipedia.org]
- [+ 16.0s] 💬 JEF: Cuando elijas, sigo con «leeme las noticias».
- [+ 16.0s] 🔊 «Cuando elijas, sigo con «leeme las noticias».»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 16.0s] 🔘 Botones: [Clarin.com — www.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Clarín (Argentine newspaper) — en.wikipedia.org] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a clarín y leeme las noticias
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «leeme las noticias».
  7 [btn] Clarin.com — www.clarin.com  (Primera de 4 opciones.)
  8 [btn] Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org
  9 [btn] Clarín (Argentine newspaper) — en.wikipedia.org
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```

## Paso 2 — toca «Clarin.com — www.clarin.com»

- [+ 26.3s] 💬 Persona: Clarin.com — www.clarin.com
- [+ 26.3s] 💬 JEF: Abriendo clarin.com.
- [+ 26.3s] 🔊 «Abriendo clarin.com.»
- [+ 30.9s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/02.txt)
- [+ 30.9s] 💬 JEF: Estás en Clarin.com.
- [+ 30.9s] 🔊 «Estás en Clarin.com.»
- [+ 34.0s] 💬 JEF: Titulares 1 a 3:
- [+ 34.0s] 🔊 «Titulares 1 a 3:»
- [+ 34.0s] 💬 JEF: 1. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA
- [+ 34.0s] 🔊 «1. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA»
- [+ 34.0s] 💬 JEF: 2. Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”
- [+ 34.0s] 🔊 «2. Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»  ⟶ en cola: empieza a sonar a los +43.3s
- [+ 34.0s] 💬 JEF: 3. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia
- [+ 34.0s] 🔊 «3. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»  ⟶ en cola: empieza a sonar a los +50.4s
- [+ 34.0s] 🔘 Botones: [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Seguir con los titulares] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (18 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: entrá a clarín y leeme las noticias
  4 [txt] Buscando: clarín.
  5 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  6 [txt] Cuando elijas, sigo con «leeme las noticias».
  7 [H] Vos: Clarin.com — www.clarin.com
  8 [txt] Abriendo clarin.com.
  9 [txt] Estás en Clarin.com.
 10 [txt] Titulares 1 a 3:
 11 [txt] 1. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA
 12 [txt] 2. Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”
 13 [txt] 3. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia
 14 [btn] Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»  (Primera de 6 opciones.)
 15 [btn] Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»
 16 [btn] Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»
 17 [btn] Seguir con los titulares
 18 [btn] Volver a los resultados
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```
