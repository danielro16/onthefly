# solo-botones-clarin

**Quién:** 72 años, perdió la vista hace tres. Escribir le cuesta: prefiere tocar lo que le ofrecen.

**Qué quiere:** Leer alguna noticia de Clarín escribiendo sólo el nombre del sitio y después tocando siempre la primera opción.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarín»

- [+  6.3s] 💬 Persona: clarín
- [+  6.3s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  6.9s] 💬 JEF: Buscando: clarín.
- [+  6.9s] 🔊 «Buscando: clarín.»
- [+ 10.0s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=clar%C3%ADn&kl=ar-es — «clarín at DuckDuckGo» (paginas/01.txt)
- [+ 10.0s] 💬 JEF: Estás en los resultados de «clarín». Los 2 más probables:
- [+ 10.0s] 🔊 «Estás en los resultados de «clarín». Los 2 más probables: 1. Noticias. Últimas noticias de Argentina y el Mundo | Clarín, clarin.com. 2. Clarín - septiembre 21, 2026, kiosco.clarin.com»
- [+ 10.0s] 🔘 Botones: [Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com] · [Clarín - septiembre 21, 2026 — www.kiosco.clarin.com]
- [+ 10.0s] 🔘 Botones: [Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com] · [Clarín - septiembre 21, 2026 — www.kiosco.clarin.com] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  5 [btn] Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com  (Primera de 3 opciones.)
  6 [btn] Clarín - septiembre 21, 2026 — www.kiosco.clarin.com
  7 [btn] Otra cosa
  8 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
  9 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com»

- [+ 15.8s] 💬 Persona: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
- [+ 15.8s] 💬 JEF: Abriendo clarin.com.
- [+ 15.8s] 🔊 «Abriendo clarin.com.»
- [+ 20.2s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/02.txt)
- [+ 21.3s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/03.txt)
- [+ 24.3s] 💬 JEF: Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
- [+ 24.3s] 🔊 «Estás en la portada de Clarín. Los titulares principales: 1. Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que los guardaba en la casa. 2. La explicación de Adorni sobre su patrimonio que a la Justicia le costará creer. 3. La agenda del Papa: estiman que se movilizarán 7 millones de personas por su visita y evalúan dar asueto. 4. Renunció el secretario de Discapacidad en medio de la interna por los recortes.»
- [+ 24.3s] 🔘 Botones: [Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»] · [Abrir «La explicación de Adorni sobre su patrimonio que a la Justicia le costará creer»] · [Abrir «La agenda del Papa: estiman que se movilizarán 7 millones de personas por su visita y evalúan dar…»] · [Abrir «Renunció el secretario de Discapacidad en medio de la interna por los recortes»]
- [+ 24.3s] 🔘 Botones: [Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»] · [Abrir «La explicación de Adorni sobre su patrimonio que a la Justicia le costará creer»] · [Abrir «La agenda del Papa: estiman que se movilizarán 7 millones de personas por su visita y evalúan dar…»] · [Abrir «Renunció el secretario de Discapacidad en medio de la interna por los recortes»] · [Volver a los resultados] · [Otra cosa]

Al terminar el paso (15 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  8 [btn] Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»  (Primera de 6 opciones.)
  9 [btn] Abrir «La explicación de Adorni sobre su patrimonio que a la Justicia le costará creer»
 10 [btn] Abrir «La agenda del Papa: estiman que se movilizarán 7 millones de personas por su visita y evalúan dar…»
 11 [btn] Abrir «Renunció el secretario de Discapacidad en medio de la interna por los recortes»
 12 [btn] Volver a los resultados
 13 [btn] Otra cosa
 14 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 15 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»»

- [+ 30.9s] 💬 Persona: Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»
- [+ 30.9s] 💬 JEF: Abriendo.
- [+ 30.9s] 🔊 «Abriendo.»
- [+ 33.8s] 📄 Cargó https://www.clarin.com/suscripciones/landing-apw-scoring.html?apw-origin=https%3A%2F%2Fwww.clarin.com%2Fpolitica%2Fmanuel-adorni-presento-justificacion-crecimiento-patrimonial-dice-enriquecimiento-sustento-razonable-verificable_0_tTsGUUzliW.html&wb=PW_SC_AN_ZONDA — «Landing suscripciones» (paginas/04.txt)
- [+ 33.8s] 💬 JEF: Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.
- [+ 33.8s] 🔊 «Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.»
- [+ 33.8s] 🔘 Botones: [Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»]
- [+ 33.8s] 🔘 Botones: [Completar «Nombre*»] · [Completar «Apellido*»] · [Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»] · [Otra cosa]
- [+ 37.4s] 📄 Cargó https://www.clarin.com/suscripciones/landing-apw-scoring.html?apw-origin=https%3A%2F%2Fwww.clarin.com%2Fpolitica%2Fmanuel-adorni-presento-justificacion-crecimiento-patrimonial-dice-enriquecimiento-sustento-razonable-verificable_0_tTsGUUzliW.html&wb=PW_SC_AN_ZONDA — «Landing suscripciones» (paginas/05.txt)
- [+ 37.4s] 💬 JEF: La página cambió: ahora estás en la nota «Landing suscripciones», de www.clarin.com.
- [+ 37.4s] 🔊 «La página cambió: ahora estás en la nota «Landing suscripciones», de www.clarin.com.»
- [+ 37.4s] 🔘 Botones: [Completar «Nombre*»] · [Completar «Apellido*»] · [Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»] · [Otra cosa]

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  8 [H] Vos: Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»
  9 [txt] Abriendo.
 10 [txt] Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.
 11 [txt] La página cambió: ahora estás en la nota «Landing suscripciones», de www.clarin.com.
 12 [btn] Completar «Nombre*»  (Primera de 4 opciones.)
 13 [btn] Completar «Apellido*»
 14 [btn] Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»
 15 [btn] Otra cosa
 16 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 17 [btn] Enviar
```

## Paso 4 — toca el botón 1: «Completar «Nombre*»»

- [+ 44.2s] 💬 Persona: Completar «Nombre*»
- [+ 44.8s] 💬 JEF: ¿Qué pongo en Nombre*? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.
- [+ 44.8s] 🔊 «¿Qué pongo en Nombre*? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.»
- [+ 44.8s] 🔘 Botones: [Completar «Apellido*»] · [Completar «E-mail*»] · [Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  8 [H] Vos: Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»
  9 [txt] Abriendo.
 10 [txt] Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.
 11 [txt] La página cambió: ahora estás en la nota «Landing suscripciones», de www.clarin.com.
 12 [H] Vos: Completar «Nombre*»
 13 [txt] ¿Qué pongo en Nombre*? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.
 14 [btn] Completar «Apellido*»  (Primera de 4 opciones.)
 15 [btn] Completar «E-mail*»
 16 [btn] Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»
 17 [btn] Otra cosa
 18 [campo] Pedido  = Escribir: Nombre*  (Va directo al campo «Nombre*» de la página.)
 19 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Completar «Apellido*»»

- [+ 52.2s] 💬 Persona: Nombre* terminado en do*
- [+ 53.0s] 💬 JEF: Listo: quedó escrito en «Nombre*», terminado en do*.
- [+ 53.0s] 🔊 «Listo: quedó escrito en «Nombre*», terminado en do*.»
- [+ 53.0s] 🔘 Botones: [Completar «Apellido*»] · [Completar «E-mail*»] · [Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 2 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarín. Los titulares principales son las primeras opciones.
  8 [H] Vos: Abrir «Adorni trató de justificar su patrimonio: dijo que ganó casi US$ 600 mil con criptomonedas y que…»
  9 [txt] Abriendo.
 10 [txt] Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.
 11 [txt] La página cambió: ahora estás en la nota «Landing suscripciones», de www.clarin.com.
 12 [H] Vos: Completar «Nombre*»
 13 [txt] ¿Qué pongo en Nombre*? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.
 14 [H] Vos: Nombre* terminado en do*
 15 [txt] Listo: quedó escrito en «Nombre*», terminado en do*.
 16 [btn] Completar «Apellido*»  (Primera de 4 opciones.)
 17 [btn] Completar «E-mail*»
 18 [btn] Volver a «Noticias. Últimas noticias de Argentina y el Mundo | Clarín»
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```
