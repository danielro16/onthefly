# clima-manana

**Quién:** Ciega, vive en Miami.

**Qué quiere:** Saber cómo va a estar el tiempo mañana donde está.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — toca «¿Cómo va a estar el tiempo mañana?»

- [+  4.7s] 💬 Persona: ¿Cómo va a estar el tiempo mañana?
- [+  4.7s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  5.8s] 💬 JEF: Buscando: tiempo mañana en Miami.
- [+  5.8s] 🔊 «Buscando: tiempo mañana en Miami.»
- [+ 10.2s] 📄 Cargó https://www.google.com/search?q=tiempo%20ma%C3%B1ana%20en%20Miami&gl=us&hl=es — «tiempo mañana en Miami - Buscar con Google» (paginas/01.txt)
- [+ 11.6s] 💬 JEF: Para mañana miércoles en Miami se esperan tormentas eléctricas fuertes. La temperatura máxima será de 82 grados y la mínima de 78 grados.
- [+ 11.6s] 🔊 «Para mañana miércoles en Miami se esperan tormentas eléctricas fuertes. La temperatura máxima será de 82 grados y la mínima de 78 grados.»
- [+ 11.6s] 🔘 Botones: [Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com] · [Tiempo para la mañana en Miami, FL — www.accuweather.com] · [Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com] · [Ver más opciones (6)]
- [+ 11.6s] 🔘 Botones: [Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com] · [Tiempo para la mañana en Miami, FL — www.accuweather.com] · [Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: ¿Cómo va a estar el tiempo mañana?
  4 [txt] Buscando: tiempo mañana en Miami.
  5 [txt] Para mañana miércoles en Miami se esperan tormentas eléctricas fuertes. La temperatura máxima será de 82 grados y la mínima de 78 grados.
  6 [btn] Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com  (Primera de 5 opciones.)
  7 [btn] Tiempo para la mañana en Miami, FL — www.accuweather.com
  8 [btn] Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
