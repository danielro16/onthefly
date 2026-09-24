# bloqueo-fravega

**Quién:** Medición: la misma página con y sin las listas de bloqueo.

**Qué quiere:** Comparar tiempo de carga, texto que ve el modelo y anuncios, con y sin EasyList/EasyPrivacy.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «fravega.com»

- [+  6.8s] 💬 Persona: fravega.com
- [+  6.8s] 💬 JEF: Abriendo fravega.com.
- [+  6.8s] 🔊 «Abriendo fravega.com.»
- [+  6.9s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  9.1s] 📄 Cargó https://www.fravega.com/ — «Frávega: Electrodomésticos, Tecnología y Artículos para el Hogar» (paginas/01.txt)
- [+ 13.1s] 💬 JEF: Estás en la página principal de Frávega, una tienda de electrodomésticos, tecnología y artículos para el hogar, donde puedes explorar categorías y productos.
- [+ 13.1s] 🔊 «Estás en la página principal de Frávega, una tienda de electrodomésticos, tecnología y artículos para el hogar, donde puedes explorar categorías y productos.»
- [+ 13.1s] 🔘 Botones: [Abrir «Más Vendidos»] · [Abrir «Ofertas»]
- [+ 13.1s] 🔘 Botones: [Abrir «Más Vendidos»] · [Abrir «Ofertas»] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [txt] www.fravega.com quiere utilizar tu ubicación actual
  2 [txt] Este sitio web utilizará tu ubicación exacta porque actualmente JEF tiene acceso a este dato.
  3 [btn] No permitir
  4 [btn] Permitir
```
