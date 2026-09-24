# bloqueo-zapatillas

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «buscá zapatillas nike»

- [+  6.5s] 💬 Persona: buscá zapatillas nike
- [+  6.5s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  8.4s] 💬 JEF: Buscando: zapatillas nike.
- [+  8.4s] 🔊 «Buscando: zapatillas nike.»
- [+ 13.5s] 📄 Cargó https://www.google.com/search?q=zapatillas%20nike&gl=us&hl=es — «zapatillas nike - Buscar con Google» (paginas/01.txt)
- [+ 13.9s] 💬 JEF: Estás en los resultados de «zapatillas nike». Los 3 más probables:
- [+ 13.9s] 🔊 «Estás en los resultados de «zapatillas nike». Los 3 más probables: 1. Calzado. Nike US, nike.com. 2. Hombre Calzado. Nike US, nike.com. 3. Mujer Rebajas Calzado. Nike US, nike.com»
- [+ 13.9s] 🔘 Botones: [Calzado. Nike US — www.nike.com] · [Hombre Calzado. Nike US — www.nike.com] · [Mujer Rebajas Calzado. Nike US — www.nike.com] · [Ver más opciones (6)]
- [+ 13.9s] 🔘 Botones: [Calzado. Nike US — www.nike.com] · [Hombre Calzado. Nike US — www.nike.com] · [Mujer Rebajas Calzado. Nike US — www.nike.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: buscá zapatillas nike
  4 [txt] Buscando: zapatillas nike.
  5 [txt] Estás en los resultados de «zapatillas nike». Los 3 más probables:
  6 [btn] Calzado. Nike US — www.nike.com  (Primera de 5 opciones.)
  7 [btn] Hombre Calzado. Nike US — www.nike.com
  8 [btn] Mujer Rebajas Calzado. Nike US — www.nike.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
