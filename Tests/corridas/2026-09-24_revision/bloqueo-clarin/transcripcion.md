# bloqueo-clarin

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarin.com»

- [+  6.6s] 💬 Persona: clarin.com
- [+  6.6s] 💬 JEF: Abriendo clarin.com.
- [+  6.6s] 🔊 «Abriendo clarin.com.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 11.5s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/01.txt)
- [+ 15.3s] 💬 JEF: Estás en la portada de Clarín, el diario de noticias de Argentina. La nota principal informa que la pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas, cuatro puntos más que la medición anterior, cuando era del 28,2%, y la indigencia saltó del 6,3% al 7,5%.
- [+ 15.3s] 🔊 «Estás en la portada de Clarín, el diario de noticias de Argentina. La nota principal informa que la pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas, cuatro puntos más que la medición anterior, cuando era del 28,2%, y la indigencia saltó del 6,3% al 7,5%.»
- [+ 15.3s] 🔘 Botones: [Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»] · [Abrir «La actividad económica cayó 2,9% en julio y tuvo un retroceso interanual del 1,4%»] · [Abrir «El Senado aprobó con cambios la reforma del Banco Central y vuelve a Diputados: ahora trata el…»] · [Abrir «Mar del Plata: dieron a conocer los precios de referencia de los alquileres para el verano»] · [Leer los titulares]
- [+ 15.3s] 🔘 Botones: [Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»] · [Abrir «La actividad económica cayó 2,9% en julio y tuvo un retroceso interanual del 1,4%»] · [Abrir «El Senado aprobó con cambios la reforma del Banco Central y vuelve a Diputados: ahora trata el…»] · [Abrir «Mar del Plata: dieron a conocer los precios de referencia de los alquileres para el verano»] · [Leer los titulares] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: clarin.com
  4 [txt] Abriendo clarin.com.
  5 [txt] Estás en la portada de Clarín, el diario de noticias de Argentina. La nota principal informa que la pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas, cuatro puntos más que la medición anterior, cuando era del 28,2%, y la indigencia saltó del 6,3% al 7,5%.
  6 [btn] Abrir «La pobreza subió a 32,3% en el primer semestre del año y alcanza a 15 millones de personas»  (Primera de 6 opciones.)
  7 [btn] Abrir «La actividad económica cayó 2,9% en julio y tuvo un retroceso interanual del 1,4%»
  8 [btn] Abrir «El Senado aprobó con cambios la reforma del Banco Central y vuelve a Diputados: ahora trata el…»
  9 [btn] Abrir «Mar del Plata: dieron a conocer los precios de referencia de los alquileres para el verano»
 10 [btn] Leer los titulares
 11 [btn] Otra cosa
 12 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 13 [btn] Enviar
```
