# bloqueo-clarin

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarin.com»

- [+  6.4s] 💬 Persona: clarin.com
- [+  6.4s] 💬 JEF: Abriendo clarin.com.
- [+  6.4s] 🔊 «Abriendo clarin.com.»
- [+  6.4s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 12.5s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/01.txt)
- [+ 15.6s] 💬 JEF: Estás en la portada de Clarín, el diario argentino, con las principales noticias de Argentina y el mundo. Los titulares principales son las primeras opciones.
- [+ 15.6s] 🔊 «Estás en la portada de Clarín, el diario argentino, con las principales noticias de Argentina y el mundo. Los titulares principales: 1. El mensaje de Milei ante ejecutivos en Estados Unidos: “Si somos reelectos, el 2028 será el mejor año de la historia”. 2. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA. 3. Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”. 4. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia.»
- [+ 15.6s] 🔘 Botones: [Abrir «El mensaje de Milei ante ejecutivos en Estados Unidos: “Si somos reelectos, el 2028 será el mejor…»] · [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»]
- [+ 15.6s] 🔘 Botones: [Abrir «El mensaje de Milei ante ejecutivos en Estados Unidos: “Si somos reelectos, el 2028 será el mejor…»] · [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarin.com
  4 [txt] Abriendo clarin.com.
  5 [txt] Estás en la portada de Clarín, el diario argentino, con las principales noticias de Argentina y el mundo. Los titulares principales son las primeras opciones.
  6 [btn] Abrir «El mensaje de Milei ante ejecutivos en Estados Unidos: “Si somos reelectos, el 2028 será el mejor…»  (Primera de 5 opciones.)
  7 [btn] Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»
  8 [btn] Abrir «Trump recibe con honores militares a Xi Jinping en la Casa Blanca: “Trataremos temas apremiantes”»
  9 [btn] Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
