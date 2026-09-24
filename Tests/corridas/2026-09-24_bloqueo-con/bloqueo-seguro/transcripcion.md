# bloqueo-seguro

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «buscá seguro de auto»

- [+  6.6s] 💬 Persona: buscá seguro de auto
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 10.9s] 💬 JEF: Buscando: seguro de auto San Francisco CA.
- [+ 10.9s] 🔊 «Buscando: seguro de auto San Francisco CA.»
- [+ 16.0s] 📄 Cargó https://www.google.com/search?q=seguro%20de%20auto%20San%20Francisco%20CA&gl=us&hl=es — «seguro de auto San Francisco CA» (paginas/01.txt)
- [+ 16.3s] 💬 JEF: Estás en los resultados de «seguro de auto San Francisco CA». Hay un anuncio: lo salteo. Los 3 más probables:
- [+ 16.3s] 🔊 «Estás en los resultados de «seguro de auto San Francisco CA». Hay un anuncio: lo salteo. Los 3 más probables: 1. Seguro de auto barato en San Francisco, CA, freeway.com. 2. Seguro de auto en California | Requisitos y opciones, allstate.com. 3. San Francisco, California Agentes de seguros, es.statefarm.com»
- [+ 16.3s] 🔘 Botones: [Seguro de auto barato en San Francisco, CA — www.freeway.com] · [Seguro de auto en California | Requisitos y opciones — www.allstate.com] · [San Francisco, California Agentes de seguros — es.statefarm.com] · [Ver más opciones (6)]
- [+ 16.3s] 🔘 Botones: [Seguro de auto barato en San Francisco, CA — www.freeway.com] · [Seguro de auto en California | Requisitos y opciones — www.allstate.com] · [San Francisco, California Agentes de seguros — es.statefarm.com] · [Ver más opciones (6)] · [Otra cosa]

Al terminar el paso (17 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: buscá seguro de auto
  4 [txt] Buscando: seguro de auto San Francisco CA.
  5 [txt] Estás en los resultados de «seguro de auto San Francisco CA». Hay un anuncio: lo salteo. Los 3 más probables:
  6 [btn] Seguro de auto barato en San Francisco, CA — www.freeway.com  (Primera de 5 opciones.)
  7 [btn] Seguro de auto en California | Requisitos y opciones — www.allstate.com
  8 [btn] San Francisco, California Agentes de seguros — es.statefarm.com
  9 [btn] Ver más opciones (6)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
