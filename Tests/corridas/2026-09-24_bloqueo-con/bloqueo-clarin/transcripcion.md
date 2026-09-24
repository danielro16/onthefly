# bloqueo-clarin

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarin.com»

- [+  6.6s] 💬 Persona: clarin.com
- [+  6.6s] 💬 JEF: Abriendo clarin.com.
- [+  6.6s] 🔊 «Abriendo clarin.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 32.8s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/01.txt)
- [+ 36.3s] 💬 JEF: Estás en la portada de Clarín, con noticias de Argentina y del mundo de hoy. Los titulares principales son las primeras opciones.
- [+ 36.3s] 🔊 «Estás en la portada de Clarín, con noticias de Argentina y del mundo de hoy. Los titulares principales: 1. El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la reforma del BCRA. 2. Ajuste en la obra social de los militares: denuncian el despido de 600 empleados y el cierre de 13 hoteles. 3. Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia. 4. Milei en Nueva York: “Si somos reelectos, el 2028 será el mejor año de la historia”.»
- [+ 36.3s] 🔘 Botones: [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Ajuste en la obra social de los militares: denuncian el despido de 600 empleados y el cierre de 13…»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Abrir «Milei en Nueva York: “Si somos reelectos, el 2028 será el mejor año de la historia”»]
- [+ 36.3s] 🔘 Botones: [Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»] · [Abrir «Ajuste en la obra social de los militares: denuncian el despido de 600 empleados y el cierre de 13…»] · [Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»] · [Abrir «Milei en Nueva York: “Si somos reelectos, el 2028 será el mejor año de la historia”»] · [Otra cosa]

Al terminar el paso (38 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarin.com
  4 [txt] Abriendo clarin.com.
  5 [txt] Estás en la portada de Clarín, con noticias de Argentina y del mundo de hoy. Los titulares principales son las primeras opciones.
  6 [btn] Abrir «El oficialismo consiguió el quórum y busca aprobar en el Senado el régimen de Zonas Frías y la…»  (Primera de 5 opciones.)
  7 [btn] Abrir «Ajuste en la obra social de los militares: denuncian el despido de 600 empleados y el cierre de 13…»
  8 [btn] Abrir «Advierten que Rusia podría atacar con drones las playas más famosas de Italia, España y Francia»
  9 [btn] Abrir «Milei en Nueva York: “Si somos reelectos, el 2028 será el mejor año de la historia”»
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
