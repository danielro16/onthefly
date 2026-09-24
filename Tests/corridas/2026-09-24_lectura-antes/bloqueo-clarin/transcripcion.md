# bloqueo-clarin

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarin.com»

- [+  6.6s] 💬 Persona: clarin.com
- [+  6.6s] 💬 JEF: Abriendo clarin.com.
- [+  6.6s] 🔊 «Abriendo clarin.com.»
- [+  6.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.8s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/01.txt)
- [+ 13.9s] 💬 JEF: Estás en la portada de noticias de Clarín. La nota principal informa que la pobreza subió al 32,3% en el primer semestre del año y alcanza a 15 millones de personas; la indigencia también aumentó, del 6,3% al 7,5%. También está disponible la sección Índice de pobreza.
- [+ 13.9s] 🔊 «Estás en la portada de noticias de Clarín. La nota principal informa que la pobreza subió al 32,3% en el primer semestre del año y alcanza a 15 millones de personas; la indigencia también aumentó, del 6,3% al 7,5%. También está disponible la sección Índice de pobreza.»
- [+ 13.9s] 🔘 Botones: [Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»] · [Abrir «El Senado aprobó el cambio de Zonas Frías que recorta subsidios al gas y avanzó en la reforma del…»] · [Abrir «Netanyahu le agradeció a Milei el apoyo incondicional y dijo que es “uno de los grandes líderes de…»] · [Abrir «La actividad económica cayó 2,9% en julio, el mayor retroceso mensual en seis años»] · [Leer los titulares]
- [+ 13.9s] 🔘 Botones: [Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»] · [Abrir «El Senado aprobó el cambio de Zonas Frías que recorta subsidios al gas y avanzó en la reforma del…»] · [Abrir «Netanyahu le agradeció a Milei el apoyo incondicional y dijo que es “uno de los grandes líderes de…»] · [Abrir «La actividad económica cayó 2,9% en julio, el mayor retroceso mensual en seis años»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarin.com
  4 [txt] Abriendo clarin.com.
  5 [txt] Estás en la portada de noticias de Clarín. La nota principal informa que la pobreza subió al 32,3% en el primer semestre del año y alcanza a 15 millones de personas; la indigencia también aumentó, del 6,3% al 7,5%. También está disponible la sección Índice de pobreza.
  6 [btn] Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»  (Primera de 6 opciones.)
  7 [btn] Abrir «El Senado aprobó el cambio de Zonas Frías que recorta subsidios al gas y avanzó en la reforma del…»
  8 [btn] Abrir «Netanyahu le agradeció a Milei el apoyo incondicional y dijo que es “uno de los grandes líderes de…»
  9 [btn] Abrir «La actividad económica cayó 2,9% en julio, el mayor retroceso mensual en seis años»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
