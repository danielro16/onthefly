# clima-manana

**Quién:** Ciega, vive en Miami.

**Qué quiere:** Saber cómo va a estar el tiempo mañana donde está.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — toca «¿Cómo va a estar el tiempo mañana?»

- [+  4.5s] 💬 Persona: ¿Cómo va a estar el tiempo mañana?
- [+  4.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  5.8s] ❌ Error de carga: {'tipo': 'error', 'donde': 'decidir', 'detalle': 'unusable', 't': 1790095255.0759501}
- [+  5.8s] 💬 JEF: Buscando: ¿Cómo va a estar el tiempo mañana?.
- [+  5.8s] 🔊 «Buscando: ¿Cómo va a estar el tiempo mañana?.»
- [+ 10.5s] 📄 Cargó https://www.google.com/search?q=%C2%BFC%C3%B3mo%20va%20a%20estar%20el%20tiempo%20ma%C3%B1ana%3F&gl=us&hl=es — «¿Cómo va a estar el tiempo mañana?» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en los resultados de «¿Cómo va a estar el tiempo mañana?». Los 3 más probables:
- [+ 10.5s] 🔊 «Estás en los resultados de «¿Cómo va a estar el tiempo mañana?». Los 3 más probables: 1. Tiempo para la mañana en Miami, FL, accuweather.com. 2. Pronóstico del Tiempo en Miami, Florida ..., telemundo51.com. 3. Tiempo para mañana en Miami (Local): Hora por hora, tiempo3.com»
- [+ 10.5s] 🔘 Botones: [Tiempo para la mañana en Miami, FL — www.accuweather.com] · [Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com] · [Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com] · [Ver más opciones (7)]
- [+ 10.5s] 🔘 Botones: [Tiempo para la mañana en Miami, FL — www.accuweather.com] · [Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com] · [Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com] · [Ver más opciones (7)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, el botón Asistente.)
  3 [H] Vos: ¿Cómo va a estar el tiempo mañana?
  4 [txt] Buscando: ¿Cómo va a estar el tiempo mañana?.
  5 [txt] Estás en los resultados de «¿Cómo va a estar el tiempo mañana?». Los 3 más probables:
  6 [btn] Tiempo para la mañana en Miami, FL — www.accuweather.com  (Primera de 5 opciones.)
  7 [btn] Pronóstico del Tiempo en Miami, Florida ... — www.telemundo51.com
  8 [btn] Tiempo para mañana en Miami (Local): Hora por hora — www.tiempo3.com
  9 [btn] Ver más opciones (7)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
