# tienda-liverpool

**Quién:** Vive en México, con baja visión. Entra a una tienda.

**Qué quiere:** Que JEF sepa qué tipo de sitio y de página es, y que los pasos que ofrece sean los probables para ese tipo.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «liverpool.com.mx»

- [+  6.6s] 💬 Persona: liverpool.com.mx
- [+  6.6s] 💬 JEF: Abriendo liverpool.com.mx.
- [+  6.6s] 🔊 «Abriendo liverpool.com.mx.»
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+ 12.9s] 📄 Cargó https://www.liverpool.com.mx/tienda/home — «Liverpool | Hasta 50% de descuento + 9 MSI | Envío gratis» (paginas/01.txt)
- [+ 18.1s] 💬 JEF: Estás en la página principal de Liverpool, la tienda por departamentos, con ofertas de hasta 50% de descuento y hasta 9 meses sin intereses, secciones de productos en tendencia y más vendidos, y búsqueda por producto o categoría. Primero tienes que cerrar un aviso que tapa la pantalla invitando a descargar la app.
- [+ 18.1s] 🔊 «Estás en la página principal de Liverpool, la tienda por departamentos, con ofertas de hasta 50% de descuento y hasta 9 meses sin intereses, secciones de productos en tendencia y más vendidos, y búsqueda por producto o categoría. Primero tienes que cerrar un aviso que tapa la pantalla invitando a descargar la app.»
- [+ 18.1s] 🔘 Botones: [Buscar productos en Liverpool] · [Categorías chevron_right] · [Iniciar sesión]
- [+ 18.1s] 🔘 Botones: [Buscar productos en Liverpool] · [Categorías chevron_right] · [Iniciar sesión] · [Otra cosa]
- [+ 19.7s] 📄 Cargó https://www.liverpool.com.mx/tienda/home — «Liverpool | Hasta 50% de descuento + 9 MSI | Envío gratis» (paginas/02.txt)

Al terminar el paso (21 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [btn] Cerrar el asistente  (Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.)
  3 [H] Vos: liverpool.com.mx
  4 [txt] Abriendo liverpool.com.mx.
  5 [txt] Estás en la página principal de Liverpool, la tienda por departamentos, con ofertas de hasta 50% de descuento y hasta 9 meses sin intereses, secciones de productos en tendencia y más vendidos, y búsqueda por producto o categoría. Primero tienes que cerrar un aviso que tapa la pantalla invitando a descargar la app.
  6 [btn] Buscar productos en Liverpool  (Primera de 4 opciones.)
  7 [btn] Categorías chevron_right
  8 [btn] Iniciar sesión
  9 [btn] Otra cosa
 10 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 11 [btn] Enviar
```
