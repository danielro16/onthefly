# banco-sin-dato

**Quién:** Ciega, vive en Miami.

**Qué quiere:** Llegar al sitio de su banco.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «bank of america»

- [+  6.3s] 💬 Persona: bank of america
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.2s] 💬 JEF: Buscando: bank of america.
- [+  7.3s] 🔊 «Buscando: bank of america.»
- [+ 11.6s] 📄 Cargó https://www.google.com/search?q=bank%20of%20america&gl=us&hl=es — «bank of america - Buscar con Google» (paginas/01.txt)
- [+ 11.6s] 💬 JEF: Estás en los resultados de «bank of america». Los 3 más probables:
- [+ 11.6s] 🔊 «Estás en los resultados de «bank of america». Los 3 más probables: 1. Bank of America, bankofamerica.com. 2. Bank of America, en.wikipedia.org. 3. Bank of America & BofA Securities - Global Insights…, business.bofa.com»
- [+ 11.6s] 🔘 Botones: [Bank of America — www.bankofamerica.com] · [Bank of America — en.wikipedia.org] · [Bank of America & BofA Securities - Global Insights & Solutions — business.bofa.com] · [Ver más opciones (1)]
- [+ 11.6s] 🔘 Botones: [Bank of America — www.bankofamerica.com] · [Bank of America — en.wikipedia.org] · [Bank of America & BofA Securities - Global Insights & Solutions — business.bofa.com] · [Ver más opciones (1)] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: bank of america
  4 [txt] Buscando: bank of america.
  5 [txt] Estás en los resultados de «bank of america». Los 3 más probables:
  6 [btn] Bank of America — www.bankofamerica.com  (Primera de 5 opciones.)
  7 [btn] Bank of America — en.wikipedia.org
  8 [btn] Bank of America & BofA Securities - Global Insights & Solutions — business.bofa.com
  9 [btn] Ver más opciones (1)
 10 [btn] Otra cosa
 11 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 12 [btn] Enviar
```
