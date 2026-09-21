# Veredicto — ronda-4

Ronda 4: promedio general 3,0 sobre 5 (la ronda 3 dio 2,85). Por dimensión: control 2,4, confianza 2,83, ritmo 3,0, orientación 3,15, comprensión 3,65. Clima es el mejor escenario (4,15) y ANSES el peor (2,45). Nadie de los cuatro jueces logró su objetivo en ANSES ni en Mercado Libre. En el banco, Roberto no lo logró y los otros tres a medias; los cuatro le pusieron control 1.

Hay tres bloqueos.
1) Toques que no hacen nada. Pasó en La Nación, Clarín y ANSES, y las tres veces el toque venía justo después de que el script desplazara la conversación: los botones habían quedado escondidos debajo del campo de escribir. Lo más probable es que el toque cayera con el desplazamiento todavía frenando, un problema del arnés que ya estaba anotado el 20/9. Aun así hay dos fallas del producto: los botones quedan fuera de la vista, y `accept()` descarta los toques sin avisar nada.
2) En los trámites no se ofrece el paso que acerca al objetivo: «Pedir turno» en ANSES, «Completar DNI» en el banco. En su lugar aparece relleno como «Saltar al contenido principal» o «Certificación Negativa».
3) Ante un captcha o campos que sólo la persona puede completar, no se le dice cómo llegar a ellos con VoiceOver ni se le da otra salida. En Mercado Libre, además, la explicación cambió de captcha a login.

Después vienen los problemas que confunden:
- Un sitio nombrado termina en la lista de DuckDuckGo, mientras el botón «Llevame a La Nación» abre directo.
- Afirmaciones falsas: «No encontré Wikipedia» y el resumen de la portada presentado como si fuera la nota.
- «¿y el oficial?» se convirtió en la búsqueda «dólar blue oficial hoy».
- Los titulares que se nombran no coinciden con los botones, y en Wikipedia hay un botón duplicado y otro al que no se llega (ids repetidos).
- En la sección Deportes la lista sale de una plantilla: sin botones para abrir las notas y con una bajada contada como nota.
- «¿Dónde estoy?» se contesta repitiendo la portada.
- «Seguir leyendo» retoma desde lo escrito, no desde lo escuchado.

Ojo: /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift tiene cambios sin commitear. El archivo se modificó a las 15:27 y la corrida terminó a las 15:25, así que no se probaron. Ya apuntan a cuatro causas:
- Wikipedia primera, con `siteNamed`.
- «Completar» primero en los formularios, con `formOptions` en `closeTurn`.
- «Pedir turno» (piso de 5 letras) y los enlaces dentro de párrafos.
- No ofrecer preguntas siguientes frente a un captcha.

Hay que confirmarlos en la ronda 5.

Descartado por ser del script: lo que se oyó CORTADO o DESCARTADO en parte depende del ritmo del script, que actúa a los 6–8 s sin esperar a que termine la voz. Se dejó sólo donde revela una falla del producto (la lectura que no retoma bien). La queja de Marta de que el foco queda en la línea después de «Otra cosa» no se sostiene: el código y la captura muestran el foco en el campo.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta a medias, Roberto a medias, Lucía no, Ana a medias | 2.5 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.3 |
| dolar-desde-cero | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.1 |
| wikipedia-mar-del-plata | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.8 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 2.5 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.6 |
| banco-nacion | Marta a medias, Roberto no, Lucía a medias, Ana a medias | 2.8 |
| primera-vez | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.8 |
| clima-cordoba | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.2 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |

**Promedio general: 3.00**

## Problemas

### P01 · Toques que no hacen nada: tras una respuesta larga los botones quedan escondidos y el toque que sigue al desplazamiento se pierde sin ningún aviso

*bloqueante* · del script de prueba · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses

Evidencia:
- noticias-la-nacion p4: toca «Abrir «Por carta. El secretario de Discapacidad presentó su renuncia en…»» y no hay ningún evento entre +31.1s y +48.9s; arbol-04 es idéntico a arbol-03 y paso-04.jpg sólo muestra la conversación desplazada
- solo-botones-clarin p3: mismo toque sin respuesta; en p4 el toque idéntico, ya con el botón a la vista, abre al instante: «Abriendo «Renunció el secretario de Discapacidad…»»
- turno-anses p4: «Seguir leyendo» sin respuesta; arbol-04 = arbol-03
- paso-02/03.jpg de Clarín, paso-03 de La Nación y paso-03 de ANSES: la respuesta ocupa el panel y ninguno de los botones se ve
- wikipedia p5: también hubo que desplazar antes de tocar «Seguir leyendo» y esa vez funcionó. La falla no es determinista.
- Ronda 3: la misma falla en noticias-la-nacion p4

Causa probable: Dos causas juntas. (a) El arnés: `Panel.tocar()` de /Users/daniel/Developer/JEF- BROWSER/Scripts/probar-escenarios.py arrastra, espera 0,8 s y toca. Si la conversación todavía se está frenando, iOS usa el toque para detener el desplazamiento y no aprieta el botón. `accept()` ni siquiera llegó a ejecutarse (no hay registro), y el log de sesión del 2026-09-20 ya anotaba "toque durante desaceleración" como falla del arnés. (b) El producto: `AssistantPanel` (/Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift) lleva cada respuesta al tope (`scrollTo(start, anchor: .top)`), así que con respuestas largas los botones quedan debajo del campo y hay que desplazar. Una persona con baja visión que desplaza con el dedo y toca enseguida cae en lo mismo. Y en Assistant.swift, `accept()`, `ask()` y `goBack()` hacen `guard …, !working else { return }` sin decir nada: si el toque llega mientras JEF trabaja, se pierde en silencio. Con VoiceOver (doble toque sobre el foco) este toque probablemente sí llegue, pero no se probó en un dispositivo.

Propuesta: 1) Confirmar primero: en el arnés, tocar sólo cuando el marco del botón se mantiene igual en dos lecturas separadas por 300 ms, y repetir los tres escenarios. Probar además a mano en un iPhone con VoiceOver y con el dedo. 2) En el panel, que los botones se vean al terminar: si la respuesta más los botones no entran, desplazar hasta que se vea el primer botón, o fijar una franja de opciones justo encima del campo. 3) En `accept()` y `ask()`, no descartar en silencio: si `working`, anunciar «Un momento, termino lo anterior» y ejecutar el toque al terminar. Si `offer` es nil, decirlo.

Escéptico: Los toques se perdieron de verdad: en registro.jsonl de La Nación no hay ningún evento entre +31.1s y +48.9s, en Clarín tampoco entre +22.8s y +35.9s, y arbol-04 es igual a arbol-03 en ANSES. Pero la culpa es del arnés: en los tres casos `Panel.tocar()` arrastró, esperó 0,8 s y tocó, y el mismo toque en Clarín p4, con el botón ya a la vista y sin arrastre, abrió enseguida («Abriendo «Renunció el secretario…»»). En Wikipedia p5 se arrastró y el toque sí funcionó, así que depende del tiempo; los session-logs del 20/9 ya anotaban «toque durante desaceleración» como falla del harness. `accept()` no llegó a correr: no quedó el turno «Persona» que escribe `heard()`, y `working` era falso porque el arnés espera a que todo esté quieto. Lo que sí es de la app es que los botones queden debajo del campo (paso-02 de Clarín, paso-03 de ANSES y de La Nación). Eso es secundario: con VoiceOver `placeFocus()` lleva el foco a la primera opción.

### P02 · En trámites falta el botón del paso que acerca al objetivo y sobran botones de relleno

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: turno-anses, banco-nacion, solo-botones-clarin

Evidencia:
- turno-anses p2: «[Leer más sobre cómo pedir el turno] · [Abrir «Obtener Certificación Negativa de ANSES»]». La página (paginas/02.txt) tiene «Pedir turno» y «Solicitud de turnos, Ingresá a Solicitud de turnos.»
- banco-nacion p2: «Para entrar, ingresá tu DNI y tu usuario.» y el único botón propio es [Abrir «Recuperar usuario y contraseña»] (Primera de 3 opciones)
- banco-nacion p3: «[Abrir «Saltar al contenido principal»]». En la página figura dos veces «Saltar al contenido principal»
- solo-botones-clarin p4: «Abrir «Últimas Noticias»», un enlace de menú ofrecido como si fuera una nota
- solo-botones-clarin p5: después de «Fin de la nota.» la primera opción es [Resumir la nota]

Causa probable: Los candidatos, en la versión que corrió (HEAD 54ef51e), pedían etiquetas de 12 letras o más en `candidates()` de /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift. «Pedir turno» tiene 11 y quedó afuera. Los enlaces dentro de párrafos («Solicitud de turnos») tampoco entraban. `closeTurn()` sólo agregaba «Completar «DNI»» cuando el modelo no había propuesto opciones; en el banco sí las propuso, y el botón no salió. El cambio sin commitear corrige esos tres puntos, pero todavía no se probó. El filtro de enlaces de salto de /Users/daniel/Developer/JEF- BROWSER/Sources/Extraction/extract.js, `/^(ir a|skip to|saltar a)\b/i`, no reconoce «Saltar al…», «Ir al…» ni «Pasar al contenido principal»: después de «saltar a» viene una «l» y `\b` no corta ahí. `orient()` elige libremente de la lista, que incluye «Trámites relacionados» y enlaces de sección. Y después de leer una nota completa, `followUps()` pone «Resumir» primero.

Propuesta: 1) Comprobar en la ronda 5 que el diff sin commitear muestre «Pedir turno» o «Solicitud de turnos» primero en ANSES y «Completar «DNI»» primero en el banco. 2) Cambiar el ruido de extract.js a `/^(ir|saltar|pasar|skip)\s+(a|al|to)\b/i` y filtrar lo mismo en `candidates()`. 3) Sacar de los candidatos las zonas «Trámites relacionados», «Compartir» y los menús de sección. 4) Después de «Fin de la nota», ofrecer primero «Volver a la portada de <sitio>» y «Otra noticia», y «Resumir» al final.

Escéptico: En ANSES p2 los botones fueron «[Leer más sobre cómo pedir el turno] · [Abrir «Obtener Certificación Negativa de ANSES»]», y paginas/02.txt tiene «Pedir turno» y «Solicitud de turnos, Ingresá a Solicitud de turnos.». En el banco p2, con «FORMULARIO que pide: DNI, Usuario», la única opción propia fue «Recuperar usuario y contraseña», y en p3 fue «Abrir «Saltar al contenido principal»». El arnés tocó la primera opción, pero lo que se juzga es qué se ofreció, y eso lo decidió la app.

### P03 · Ante un captcha o campos que sólo la persona puede completar, no se le dice cómo llegar ni se le da otra salida; la explicación del captcha cambia a «login» y la privacidad no queda clara

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: mercadolibre-auriculares, banco-nacion

Evidencia:
- mercadolibre p2: «Suele tener una opción de audio, pero está dentro del recuadro de la verificación y no la puedo tocar: hay que hacerlo en la pantalla.» Botones: sólo [Volver a la página anterior] · [Otra cosa]
- mercadolibre p2: «Si preferís, te llevo a otro lado o volvemos a la página anterior.» No hay ningún botón que lleve «a otro lado».
- mercadolibre p3: «La página actual no muestra auriculares. Para verlos, tenés que completar un paso de seguridad. Hay un botón que dice "Ir al login".» En paso-03.jpg no hay tal botón: se ve el reCAPTCHA
- mercadolibre p3: botones «[¿Qué tengo que hacer para ir al login?] · [¿Qué dice el Centro de Privacidad?]»
- banco-nacion p2: «Para entrar, ingresá tu DNI y tu usuario.» No dice dónde ni cómo, ni si JEF ve lo que se escribe
- banco-nacion p3: la página ofrece «Descárgalo en el app store» y «Disponible en google play» y pide escanear un QR; JEF no ofrece la descarga

Causa probable: La rama de captcha de `describe()` (Assistant.swift) tiene un texto fijo que no dice dónde está el recuadro ni cómo llegar con VoiceOver. `followUps()` frente a un captcha sólo devuelve «Volver». No existe ninguna acción que lleve el foco de VoiceOver a la página (el WKWebView) ni a un control de ella. «¿cuánto sale el más barato?» fue a `reply()`, que le pasa al modelo `saying(page)` con el texto oculto «Ir al login» y el aviso de cookies «Centro de Privacidad». De ahí salieron la contradicción y las preguntas de relleno (el diff sin commitear ya saca las preguntas cuando hay captcha). En el banco, «Completar «DNI»» pregunta el valor en el chat, y la respuesta vuelve a entrar por `ask()` → `Router.decide`: el DNI escrito sale hacia el modelo por el gateway. El filtro `paying` de `candidates()` ("descarg|app store|google play") saca la única salida real de la página de recuperación.

Propuesta: 1) Con captcha: responder por plantilla, sin modelo, y siempre con el mismo diagnóstico («No puedo ver precios hasta que se pase la verificación»). Nunca mandar esa página a `reply()`. 2) Agregar el botón «Ir a la verificación», que lleve el foco de VoiceOver al recuadro (foco por JS + `UIAccessibility.post(.layoutChanged, argument: webView)`), con una indicación concreta: «Arriba, en la página: casilla «No soy un robot»; avisame cuando esté y sigo». 3) Salidas como botones: el otro resultado («Más vendidos»), «Buscar en otra tienda» y «Reintentar». 4) En formularios sensibles, un botón «Ir al campo DNI» que lleve el foco al campo de la página, para que la persona escriba directo ahí. Si se completa desde el chat, capturar el valor como respuesta pendiente del campo, sin pasar por el Router ni por ningún modelo, y decirlo. 5) Dejar pasar los enlaces a la tienda cuando la página dice que el trámite sólo sigue en la app.

Escéptico: En Mercado Libre p2 JEF dice «te llevo a otro lado o volvemos a la página anterior», pero los únicos botones son «[Volver a la página anterior] · [Otra cosa]». En p3 dice «Hay un botón que dice "Ir al login"» y ofrece «¿Qué dice el Centro de Privacidad?», mientras paso-03.jpg muestra el reCAPTCHA «No soy un robot». En el banco p2 sólo dice «ingresá tu DNI y tu usuario», sin decir dónde, y en p3 no ofrece «Descárgalo en el app store» ni «Disponible en google play», aunque figuran en paginas/03.txt.

### P04 · Cuando se nombra un sitio, en vez de abrirlo se muestra la lista de DuckDuckGo, y a veces el sitio nombrado ni siquiera queda primero; lo escrito no hace lo mismo que el botón

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, wikipedia-mar-del-plata, mercadolibre-auriculares, banco-nacion

Evidencia:
- noticias-la-nacion p1: escribe «llevame a la nación» → «Buscando: la nación.» → «Estás en los resultados de «la nación». Los 3 más probables:»
- primera-vez p2: el botón «Llevame a La Nación» → «Abriendo lanacion.com.ar.» directo, sin lista
- solo-botones-clarin p1: «Buscando: clarin.»
- otra-cosa p1: «3. Últimas noticias de Costa Rica | La Nación, nacion.com»
- wikipedia p1: «1. Mar del Plata | Sitio Oficial del Municipio de General…, mardelplata.gob.ar. 2. Mar del Plata - Wikipedia, la enciclopedia libre, es.wikipedia.org.» DuckDuckGo la tenía primera
- mercadolibre p1: «entrá a mercado libre y buscame…» → «Buscando: auriculares bluetooth mercado libre.» (DuckDuckGo)
- noticias-la-nacion p6: «volvé» desde la portada → «De vuelta en los resultados de «la nación».»

Causa probable: `arrive()` no navega nunca por decisión propia ("Un buscador nunca navega solo: muestra la lista"), mientras el ejemplo de `starters` trae el href fijo. Por eso la misma frase escrita y tocada hacen cosas distintas. En la versión que corrió, `ranked()` ponía lo oficial (.gob.ar) antes que el sitio nombrado, así que el municipio le ganó a Wikipedia; el `siteNamed` del diff sin commitear lo corrige, sin probar. La regla del Router «Buscá X en Y → buscar "X Y"» manda Mercado Libre a DuckDuckGo. Y la búsqueda queda en el historial, así que «volvé» lleva a la lista.

Propuesta: Abrir directo cuando se cumplen a la vez: coincidencia exacta del nombre registrado del dominio (`named()` exacto), sitio del país y resultado en la raíz (depth 0). Ese criterio abre lanacion.com.ar y clarin.com y sigue dejando afuera anses.fr, nacion.com y la página de captcha de ANSES. Avisarlo («Abriendo lanacion.com.ar, el diario. Si no era, decime «volvé»») y dejar «Ver otros resultados» como botón. Si el pedido nombra un sitio, ese sitio va primero siempre; confirmarlo con el diff. Si se nombra una tienda con buscador propio, abrirla y usar su buscador (la rama `.buscar` ya sabe buscar dentro del sitio). Al volver desde un sitio abierto así, saltearse la página del buscador.

Escéptico: Escribir «llevame a la nación» da «Buscando: la nación.» y una lista de resultados; el botón «Llevame a La Nación» de primera-vez p2 da «Abriendo lanacion.com.ar.» directo. En Wikipedia, paginas/01.txt muestra que DuckDuckGo tenía «Mar del Plata - Wikipedia…, 1.» y al municipio 5.º, pero JEF puso primero a mardelplata.gob.ar. Mercado Libre fue a DuckDuckGo, y «volvé» terminó en «De vuelta en los resultados de «la nación».».

### P05 · Dice cosas que no corresponden a lo que pasó: «No encontré Wikipedia» con Wikipedia en la lista, y «resumime la nota» resume la portada sin avisar

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata, noticias-la-nacion

Evidencia:
- wikipedia p2: «No encontré Wikipedia. Estás en la página oficial de la Municipalidad de General Pueyrredon…», un paso después de leer «2. Mar del Plata - Wikipedia…». Ningún botón lleva a Wikipedia
- noticias-la-nacion p5: «resumime la nota» → «De «Últimas noticias de Argentina y el mundo»: La página de La Nación informa que el secretario de Discapacidad renunció…», con la portada cargada (paso-05.jpg)
- noticias-la-nacion p5: botones [Leer los titulares] · [Volver a la página anterior]. No hay ninguno para abrir la nota

Causa probable: `arrived()` le pasa a `Answerer.orient()` el pedido anterior («buscá mar del plata en wikipedia») como «LA PERSONA VINO A». El prompt le pide «empezá diciendo si esta página sirve para eso», y el modelo, que no sabe que Wikipedia estaba entre los resultados, lo dijo como «No encontré Wikipedia». En el resumen, el Router eligió `resumir` y `summarize()` resumió lo que había. El único aviso es el prefijo «De «sectionTitle»», y en La Nación ese título es «Últimas noticias de Argentina y el mundo», que no dice «portada».

Propuesta: Hacer estas verificaciones en código, antes del modelo. 1) Si el pedido nombró un sitio y el host abierto es otro: plantilla «Esto no es Wikipedia: es el sitio del Municipio (mardelplata.gob.ar)», con primer botón «Ir a Wikipedia» usando el href del resultado guardado en `pending` o en los resultados. 2) En `carry(.resumir)`: si el pedido dice «nota» y `!isArticle(page)`, contestar «Seguís en la portada de La Nación: no hay ninguna nota abierta. ¿Cuál abro?», con los titulares como botones. 3) En el prompt de orient, prohibir «no encontré».

Escéptico: En Wikipedia p2, JEF dice «No encontré Wikipedia. Estás en la página oficial…» aunque Wikipedia figuraba 2.ª en la lista que acababa de leer, y ningún botón lleva a Wikipedia. En La Nación p5, «resumime la nota» resume la portada («De «Últimas noticias de Argentina y el mundo»: La página de La Nación informa…») sin avisar que no hay ninguna nota abierta. A esa situación se llegó porque se perdió el toque de p4, que fue del arnés, pero no avisar es responsabilidad de la app.

### P06 · «¿y el oficial?» escrito arma una búsqueda que mezcla blue y oficial, en vez de contestar con la página abierta o hacer lo mismo que el botón «¿Y el dólar oficial?»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: dolar-desde-cero

Evidencia:
- dolar p2: botones [¿Y el dólar oficial?] · [¿Hay variación?] · …
- dolar p3: escribe «¿y el oficial?» → «Buscando: dólar blue oficial hoy.» → «Estás en los resultados de «dólar blue oficial hoy». Los 3 más probables:», sin ningún número
- La página abierta (paginas/02.txt) decía «Dólar Oficial», compra $1.482,52 y venta $1.534,23

Causa probable: El Router nunca ve el texto de la página ni los botones ofrecidos: su estado sólo dice «Está en … en dolarinfohoy». Su prompt (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Router.swift) trae como ejemplo justamente «¿y el oficial?» con la regla «completalo con el tema», y con el pedido anterior «dólar blue» armó «dólar blue oficial». `ask()` no compara lo escrito con las etiquetas de la oferta vigente. Las `nextQuestions` del Answerer sabían que la página contestaba eso, pero el Router no se entera.

Propuesta: 1) Antes de rutear, comparar lo escrito (sin tildes ni signos, con distancia chica) con las etiquetas de la oferta actual; si coincide, ejecutar `accept()` de ese botón. 2) Pasarle al Router, como parte del estado, las preguntas que la página ya sabe contestar («Esta página contesta: ¿Y el dólar oficial?»), con la regla de preferir `responder` cuando el turno anterior fue una respuesta sobre esta página. 3) Cambiar el ejemplo del prompt: en una repregunta, reemplazar el término («oficial» en lugar de «blue»), no sumarlo.

Escéptico: En p2 JEF ofreció «[¿Y el dólar oficial?]», y en p3 lo escrito «¿y el oficial?» dio «Buscando: dólar blue oficial hoy.» y una lista de resultados sin ningún número. paginas/02.txt tenía «Compra hoy $1.482,52 / Venta hoy $1.534,23 … Dólar Oficial … 1 USD = $1.534,23». El prompt de Router.swift (línea 158) trae «¿y el oficial?» con la regla «completalo con el tema». El pedido lo escribió el script, pero es un texto de persona normal.

### P07 · Las preguntas de dato (dólar, clima) se quedan en la lista de resultados: hay que elegir un sitio antes de tener la respuesta

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero, clima-cordoba

Evidencia:
- dolar p1: «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real…», con el número ya en el título
- clima p1: «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:»
- dolar p2 y clima p2: recién después de tocar llega la respuesta («El dólar blue hoy tiene un valor de compra de $1.530,00 y de venta de $1.550,00.»)

Causa probable: `carry(.buscar)` guarda la pregunta en `pendingQuestion` y `arrive()` muestra la lista. La pregunta se contesta recién cuando la persona elige un resultado (rama `pendingQuestion` de `accept()`). No hay ningún camino que abra solo el mejor resultado para una pregunta.

Propuesta: Si hay `pendingQuestion` y el primer resultado según `ranked()` es claramente del tema (títulos con los términos de la pregunta, un sitio del país, sin anuncios), abrirlo y contestar en el mismo turno: «Según dolarinfohoy.com.ar: …». Dejar «Ver otras fuentes» como botón con los demás resultados.

Escéptico: Pasa en los dos escenarios: dolar p1 termina en «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables:», con «$1550» ya en el título del primer resultado, y clima p1 termina en «Estás en los resultados de «tiempo mañana córdoba»». La respuesta recién llega en p2 («El dólar blue hoy tiene un valor de compra de $1.530,00…»), y dolar p3 («¿y el oficial?») vuelve a quedar en la lista. Que el script tocara el botón 1 no causa nada: la lista es lo que la app eligió mostrar en vez de contestar.

### P08 · Botón duplicado e inalcanzable con VoiceOver: «Leer sobre la historia» suena como «economía», y además leería desde el principio

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 1 · escenarios: wikipedia-mar-del-plata, turno-anses

Evidencia:
- wikipedia arbol-02 líneas 8 y 9: «Leer sobre la economía de Mar del Plata (Primera de 5 opciones.)» dos veces, mientras el registro dice [Leer sobre la economía…] · [Leer sobre la historia…]
- turno-anses p3: [Leer más sobre cómo pedir el turno] arrancó por «Inicio. Ministerio de Capital Humano. ANSES…», no por la sección de los pasos

Causa probable: En `arrived()` toda sugerencia de tipo `.leer` recibe el id `Self.readID`, y toda `.resumir` recibe `summaryID`. Dos «leer» comparten el id, y `ForEach(offer.options)` de /Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift se identifica por `Action.id`: con ids repetidos SwiftUI dibuja y expone el primero dos veces. Por eso los dos llevan la pista «Primera de 5», que se compara por id. Además `readID` siempre lee desde `readingFrom = 0`, así que «Leer sobre la historia» o «Leer más sobre cómo pedir el turno» nunca van a esa sección.

Propuesta: Dar un id propio a cada sugerencia (`jef-leer-<n>`) y guardarle una posición de inicio: buscar el encabezado de `page.blocks` que más se parezca a la etiqueta («Historia», «¿Cómo hago?») y leer desde ahí. Si no se encuentra, llamarlo «Leer la página». Como resguardo, que el `ForEach` del panel no dependa de que los ids sean únicos (por ejemplo, id = índice + id).

Escéptico: wikipedia arbol-02 muestra dos veces «8 [btn] Leer sobre la economía de Mar del Plata (Primera de 5 opciones.)» y «9 [btn] Leer sobre la economía…», mientras el registro ofrecía «[Leer sobre la economía…] · [Leer sobre la historia…]». En el código, las dos sugerencias `.leer` reciben `id: Self.readID`, la pista se compara con `option.id == offer.options.first?.id`, y `readID` pone `readingFrom = 0`. Por eso turno-anses p3 arranca en «Inicio. Ministerio de Capital Humano. ANSES…» y no en «¿Cómo hago?».

### P09 · Los titulares que se nombran no son los botones que se ofrecen, y cambian entre una respuesta y otra en la misma página

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, primera-vez, otra-cosa

Evidencia:
- solo-botones-clarin p2: nombra en segundo lugar «Adorni intentó justificar su patrimonio…», pero el segundo botón es [Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»]. Adorni, Messi y Carlos Alonso no tienen botón
- primera-vez p2 → p3: el cuarto titular pasa de «se necesitan tres misas y diplomacia…» a «el Vaticano difundió el cronograma oficial del papa León XIV» sin que la página cambie
- otra-cosa p2: da el Vaticano como uno de «los titulares principales», cuando está cerca del puesto 16 de la página
- primera-vez p2: «el secretario de Discapacidad renunció por la puja en el área», y el titular dice «en medio de la puja»

Causa probable: En `Answerer.orient()` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift) el modelo redacta el texto y elige los números por separado. El código sólo verifica que los números existan, no que cada titular nombrado tenga su botón en el mismo orden. Cada «¿dónde estoy?» (orientar → `arrived()`) vuelve a llamar al modelo, sin guardar nada por URL, y sale otra lista.

Propuesta: Que el modelo devuelva por cada titular un par {numero, frase} y que el texto hablado lo arme el código en el orden de los botones. Así lo dicho y lo tocable son lo mismo por construcción, y cada botón puede usar la misma frase simple. Guardar la orientación por URL durante la sesión y reusarla mientras la página no cambie.

Escéptico: Clarín p2 nombra cinco titulares (Discapacidad, Adorni, visita del Papa, Messi, Carlos Alonso), pero ofrece tres botones y el segundo es «Abrir «Quiénes son los ganadores y los perdedores…»». En primera-vez, entre p2 y p3 no se recargó la página (el registro no muestra ningún evento `pagina`), y aun así el cuarto titular pasó de «tres misas y diplomacia» a «el Vaticano difundió el cronograma», con su botón. La página dice «presentó su renuncia en medio de la puja», no «renunció por la puja». En otra-cosa, el Vaticano está en la línea ~14-16 del contenido (paginas/02.txt).

### P10 · Sección Deportes: una bajada contada como nota, un titular cortado, «36 notas» que no coincide y ningún botón para abrirlas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: otra-cosa

Evidencia:
- otra-cosa p4: «Hay 36 notas. Las tres primeras:» / «Las posiciones del Clausura. Faltan seis fechas…» / «Además, cómo está la tabla anual y el ingreso a las copas, los playoffs y el descenso» / «…"Los dinosaurios que se comieron a su padre soy…»
- otra-cosa p4: botones [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa]
- La página (paginas/03.txt) dice «…soy yo"». Hay 33 notas en el cuerpo

Causa probable: «llevame a deportes» pasa por `run()`. En el paso siguiente el analizador devuelve `.done`, y esa rama llama a `describe(page)`, la plantilla, no a `arrived()`, que es la orientación con titulares y botones. `headlines(of:)` toma cualquier enlace-encabezado de 20 letras o más, así que la bajada entra como titular aparte (probablemente comparte el href de la nota). `describe()` recorta con `short(title, 140)`. `followUps()` sólo ofrece «Abrir «…»» si `lastDone == readID`, y escribe «Resumir la portada» a mano aunque sea una sección.

Propuesta: En `run()`, que `.done` llame a `arrived(page)`, igual que al llegar por un resultado. En `headlines()`, sacar duplicados por href (título y bajada de la misma nota son una sola). No recortar lo que se dice en voz; recortar sólo las etiquetas de los botones. Después de nombrar notas, ofrecer siempre un «Abrir «…»» por cada una. Si la URL no es la raíz del sitio, decir «Resumir esta sección».

Escéptico: otra-cosa p4 dice «Hay 36 notas. Las tres primeras:» y cuenta como segunda «Además, cómo está la tabla anual…», que en paginas/03.txt es la bajada de la nota del Clausura. El tercero termina en «…su padre soy…», cuando la página dice «soy yo"» (`short(title, 140)`). Los botones son [Leer los titulares] · [Resumir la portada] · [Volver…] · [Otra cosa]: ninguno abre una nota, y dice «portada» en una sección. No pude confirmar la cifra exacta de 33, pero la bajada ya infla el conteo.

### P11 · «No entiendo, ¿dónde estoy?» repite la portada, más larga y con el dólar, en vez de explicar la app; la bienvenida no tiene verbo y no hay un botón fijo de ayuda o inicio

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: primera-vez, otra-cosa, banco-nacion, mercadolibre-auriculares

Evidencia:
- primera-vez p1: «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.» Se cortó al 59 %
- primera-vez p3: «no entiendo, ¿dónde estoy?» → «Estás en la portada de La Nación. Tenés titulares como: … El dólar oficial está a $1535,00, el blue a $1550,00, el tarjeta a $1995,50 y el MEP a $1533,09.»
- primera-vez p2/p3: sólo hay botones [Abrir «…»] y [Otra cosa]. No hay «Volver» (no hay historial) ni «Inicio» o «¿Qué puedo hacer?»

Causa probable: En `carry(.orientar)` de Assistant.swift, si hay página se llama a `arrived(page)`: se vuelve a orientar con el modelo, y la meta es «no entiendo, ¿dónde estoy?», así que describe la página en lugar de la app. Si no hay página, la frase fija no tiene verbo («Para empezar, un sitio o algo para buscar»). `closeTurn()` sólo agrega «Volver» si `canGoBack`, y no hay ninguna opción permanente de ayuda.

Propuesta: Separar «orientar en la app» de «describir la página». Ante «no entiendo» o «¿dónde estoy?», contestar con una plantilla de dos frases: «Estás en JEF. Arriba está la página de La Nación, un diario; abajo hablamos vos y yo. Tocá un titular y te lo leo, o pedime otra cosa.» Sin dólar y con los mismos botones de antes. Bienvenida: «Decime un sitio o qué querés buscar, escribiendo o dictando. Abajo tenés ejemplos.» Agregar una opción fija «¿Qué puedo hacer?» o «Volver al inicio», además de la acción de escape que ya existe.

Escéptico: primera-vez p3 contesta «no entiendo, ¿dónde estoy?» con otra orientación de la portada, más larga y con «El dólar oficial está a $1535,00, el blue a $1550,00…», porque `case .orientar` llama a `arrived(page)`. La bienvenida fija dice «Para empezar, un sitio o algo para buscar», sin verbo. En p2 y p3 los botones son sólo [Abrir «…»] ×4 y [Otra cosa], sin ayuda ni inicio. Lo del corte al 59 % es ritmo del script (tocó a los 6,3 s de una frase de ~10,5 s), pero no cambia el fondo del problema.

### P12 · «Seguir leyendo» retoma desde lo escrito, no desde lo escuchado: se pierden párrafos y el final de respuestas largas

*grave* · del script de prueba · jueces: Roberto, Lucía · escenarios: wikipedia-mar-del-plata, noticias-la-nacion, primera-vez, mercadolibre-auriculares

Evidencia:
- wikipedia p4: «Magníficas playas, amplias bahías, acantilados imponentes…» → DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- wikipedia p5: «Seguir leyendo» empieza en «La temperatura media en invierno…» (el párrafo 4). El 3 no se escuchó nunca
- noticias-la-nacion p5: el resumen quedó CORTADO (se habría escuchado ~42%); primera-vez p1: la bienvenida quedó CORTADA (~59%)

Causa probable: `readAloud()` pone en cola tres pedazos seguidos con `say()` y adelanta `readingFrom` apenas los escribe. Cualquier pedido nuevo interrumpe (`interruptNext`) y se descarta lo que faltaba sonar. `Habla` (/Users/daniel/Developer/JEF- BROWSER/Sources/Engine/Registro.swift) cuenta los anuncios, pero no guarda cuáles terminaron bien. Parte de los cortes se deben al ritmo del script, que actúa antes de que termine la voz; el párrafo perdido sí es del producto.

Propuesta: Escuchar `announcementDidFinishNotification` con `announcementWasSuccessfulUserInfoKey` y el texto anunciado, y hacer avanzar `readingFrom` sólo por los pedazos que sonaron completos. «Seguir leyendo» retoma desde el primero que no se escuchó. Opcional: leer de a un pedazo por anuncio y encadenar el siguiente al terminar, en vez de encolar tres.

Escéptico: El mecanismo existe: `readAloud()` hace `readingFrom += chunk.count` apenas escribe, y en wikipedia p5 «Seguir leyendo» arranca en «La temperatura media…» aunque «Magníficas playas…» figura «DESCARTADO». Pero eso pasó porque el script tocó a los 8 s (+50,2) de una lectura de ~30 s que había empezado a +42,2. La app no mueve el cursor hasta que `Habla.pendientes == 0`, así que quien escucha hasta el final oye los tres pedazos. Los otros cortes citados (noticias p5 ~42 %, primera-vez p1 ~59 %) también son del ritmo del script y no tienen que ver con «Seguir leyendo».

### P13 · Trámites y bancos: no distingue sitios oficiales de imitaciones y oculta un resultado oficial útil

*grave* · confirmado · jueces: Marta, Lucía, Ana, Verificador 1 · escenarios: turno-anses, banco-nacion

Evidencia:
- turno-anses p1: «2. ANSES, servicioswww.anses.gob.ar. 3. Turnos ANSES - ️ Sacar turno en ANSES, turnosanses.net», sin aviso de que el tercero no es oficial
- turno-anses p1: el segundo resultado es una consulta de estudios con captcha (paginas/01.txt), y «Sacá tu turno - Argentina.gob.ar» no aparece
- banco-nacion p1: «Buscando: home banking banco nacion.» No confirma que el dominio es el oficial

Causa probable: `present()` no marca lo oficial ni avisa cuando un sitio imita el nombre de un organismo. `results(of:)` saca duplicados por host (`seen.insert(host)`), así que el segundo resultado de argentina.gob.ar («Sacá tu turno») se descarta. `ranked()` sube todo lo .gob.ar, también páginas internas que no sirven.

Propuesta: En `present()`: decir «sitio oficial» para .gob.ar y bancos conocidos, y «no es un sitio oficial» cuando el nombre de un resultado contiene el de un organismo que tiene resultado oficial (turnosanses.net frente a anses). Permitir hasta dos resultados del mismo host oficial. Entre los oficiales, preferir los que tienen los términos del pedido en el título («turno»).

Escéptico: Pasa. En turno-anses p1 el 2.º botón es «ANSES — servicioswww.anses.gob.ar», que en paginas/01.txt es «Consulta para completar o iniciar estudios Ingrese el código que se muestra en la imagen». El 3.º es «Turnos ANSES - ️ Sacar turno en ANSES — turnosanses.net» y no lleva ningún aviso. «Sacá tu turno - Argentina.gob.ar» (resultado 8) y «ANSES - Argentina.gob.ar» (www.argentina.gob.ar/anses) quedan afuera porque `results(of:)` hace `guard seen.insert(host)`. En banco-nacion nada se presenta como oficial, y homebanking.bna.com.es (resultado 4 de la página) queda sin aviso detrás de «Ver más opciones (3)». Atenuante: la primera opción era la oficial correcta en los dos casos.

### P14 · Baja visión: avisos de la página que la tapan y nadie menciona, una página que no acompaña lo que se lee y un campo de escribir con poco contraste

*grave* · confirmado · jueces: Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, dolar-desde-cero, clima-cordoba, otra-cosa, wikipedia-mar-del-plata, primera-vez

Evidencia:
- solo-botones-clarin paso-02.jpg: «Acceder a Clarin.com con Google — Continuar» tapa la página
- dolar p2: «Este sitio utiliza cookies» tapa la cotización
- clima p2/p3: modal «Aviso de privacidad… ACEPTAR Y CONTINUAR / CONFIGURACIÓN» encima del pronóstico
- solo-botones-clarin p5: mientras lee la nota, arriba se ve el pie («Leé el diario de hoy», redes)
- otra-cosa p3: el campo «¿Qué querés hacer?» en gris claro y el cursor apenas visible

Causa probable: `orient()` menciona un aviso sólo si `page.overlay` viene cargado, y la detección de extract.js no reconoce el iframe de Google One Tap ni esos banners de cookies o privacidad. La lectura no mueve la vista web hasta el párrafo que se lee. El texto guía del campo usa `.secondary` en AssistantPanel.swift.

Propuesta: Detectar como aviso el iframe de accounts.google.com (One Tap) y los banners de consentimiento, y decirlo en media frase («Hay un aviso de cookies arriba; no hace falta tocarlo») o cerrarlo si tiene «Cerrar» o «Rechazar». Al leer, llevar la vista a cada bloque (scrollIntoView por id). Dar más contraste al texto guía y al botón Enviar, y probar el panel con el texto más grande de Accesibilidad.

Escéptico: Las capturas lo confirman. En solo-botones-clarin/paso-02.jpg, «Acceder a Clarin.com con Google — Continuar» tapa la página. En dolar/paso-02.jpg, «Este sitio utiliza cookies — Aceptar/Rechazar». En clima/paso-02 y paso-03, «Aviso de privacidad… ACEPTAR Y CONTINUAR / CONFIGURACIÓN». Ningún texto de JEF menciona un aviso («En DolarInfoHoy.», «En meteored.com.ar.»). En clarin/paso-05.jpg se ve el pie («Leé el diario de hoy», redes) mientras se lee el primer párrafo. En otra-cosa/paso-03.jpg el campo «¿Qué querés hacer?» está en gris muy claro.

### P15 · Ruido en la lectura: migas de pan y títulos contados como párrafos, tramos que terminan en un título, contadores como última línea, titulares repetidos y la bajada omitida

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: turno-anses, wikipedia-mar-del-plata, noticias-la-nacion, solo-botones-clarin

Evidencia:
- turno-anses p3: «Inicio. Ministerio de Capital Humano. ANSES. Solicitar turnos en ANSES» y después «Párrafo 3 de 17.»
- wikipedia p4: «— La Ciudad —» contado como párrafo; p5 termina en «— Economía —» / «Párrafo 6 de 17.»
- noticias-la-nacion p3: «dame los titulares» repite los tres ya dichos y termina en «Titular 3 de 137.» (DESCARTADO, pero queda como última línea)
- solo-botones-clarin p5: «Fin de la nota.» sin la bajada («Alejandro Vilches aseguró…») ni «Noticia en desarrollo»

Causa probable: `readablePieces()` convierte cada encabezado en un pedazo «— X —» y cada lista en otro (las migas de pan salen como una lista con los ítems unidos por punto), y los cuenta en el total. `readAloud()` corta de a tres pedazos sin importar si el tercero es un título, y siempre dice «Párrafo/Titular N de M». En una portada, «leer» arranca en 0 aunque la orientación ya haya nombrado los primeros. Los bloques de Readability no traen la bajada.

Propuesta: Saltear la lista de migas (ítems cortos que terminan en el título de la página) y los enlaces de salto. No contar encabezados: pegarlos al párrafo que sigue, anunciarlos como «Sección: Economía» y no cortar nunca un tramo en un título. Sacar el contador hablado o reemplazarlo por «Hay más» (el número puede ir en la pista del botón «Seguir leyendo»). En portadas, «dame los titulares» sigue después de los ya nombrados. Leer la bajada antes del cuerpo y avisar «Noticia en desarrollo» si la página lo dice.

Escéptico: Todo verificado en las transcripciones. En turno-anses p3 sale «Inicio. Ministerio de Capital Humano. ANSES. Solicitar turnos en ANSES» → «Párrafo 3 de 17.». En wikipedia p4, «— La Ciudad —» cuenta como uno de los 3 párrafos, y p5 termina en «— Economía —» / «Párrafo 6 de 17.». En noticias p3 se repiten los 3 titulares que la orientación ya había dicho, y el árbol termina en «12 [txt] Titular 3 de 137.». En clarin p5 falta la bajada «Alejandro Vilches aseguró…» y también «Noticia en desarrollo», aunque las dos están en paginas/04.txt. Que la voz haya quedado DESCARTADA es cosa del ritmo del script, pero lo que se reclama es el contenido.

### P16 · El resumen de una portada agrega las cotizaciones del dólar que nadie pidió

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: noticias-la-nacion, primera-vez

Evidencia:
- noticias-la-nacion p2: «…El dólar oficial está a $1535,00, el dólar blue a $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1533,80.»
- primera-vez p3: «…El dólar oficial está a $1535,00, el blue a $1550,00, el tarjeta a $1995,50 y el MEP a $1533,09.»

Causa probable: El prompt de `Answerer.orient()` dice «Si nombrás un dato que la página da con un número (una cotización…) decí el número», y `saying()` le pasa la barra del dólar como «DATOS AL PASO». El modelo entiende que tiene que incluirla.

Propuesta: En el prompt de orient: «En una portada, sólo titulares; nunca datos de MENÚ, AVISOS Y DATOS AL PASO salvo que el pedido los pida». Si hay cotizaciones, ofrecer el botón «¿A cuánto está el dólar?» en lugar de leerlas.

Escéptico: En noticias-la-nacion p2 la orientación de la portada termina en «El dólar oficial está a $1535,00, el dólar blue a $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1533,80.». En primera-vez p3, ante «no entiendo, ¿dónde estoy?», termina en «…el blue a $1550,00, el tarjeta a $1995,50 y el MEP a $1533,09.». En ninguno de los dos pedidos se preguntó por el dólar.

### P17 · Etiquetas de botones largas y con ruido: «— www.dominio», volantas, cortes con «…», «servicioswww» y el hueco de un emoji

*menor* · confirmado · jueces: Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, dolar-desde-cero, wikipedia-mar-del-plata, clima-cordoba, banco-nacion, otra-cosa

Evidencia:
- noticias-la-nacion p1: [Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar]
- solo-botones-clarin p1: [Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com]
- noticias-la-nacion p2: [Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»]
- turno-anses p1: «ANSES, servicioswww.anses.gob.ar» y [Turnos ANSES - ️ Sacar turno en ANSES — turnosanses.net]

Causa probable: En `present()` la etiqueta es `"\(result.title) — \(result.host)"`, con título y host tal cual. Los botones de titulares usan `short(label, 70)` sobre el texto con la volanta («Por carta.», «Interruptor L46.»). La limpieza de emojis deja el selector de variante U+FE0F. «servicioswww» es el host real, pero leído en voz suena roto.

Propuesta: Resultado = título sin el sufijo del sitio (« - LA NACION», «| Clarín») + nombre registrado corto («La Nación — lanacion.com.ar»), sin «www.». Los botones de titulares, sin la volanta, o con la misma frase que se dijo en la orientación (ver P09). Quitar U+FE0F y los signos sueltos. Decir el dominio registrado («anses.gob.ar») en lugar del subdominio completo.

Escéptico: Los botones son tal cual: «Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar», «Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com», «Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»» y «ANSES — servicioswww.anses.gob.ar». En turno-anses/registro.jsonl, «Turnos ANSES - ️ Sacar» trae en bytes EF B8 8F (U+FE0F), el selector de variante que quedó del emoji. `present()` arma la etiqueta como "\(result.title) — \(result.host)".

### P18 · Vocabulario inconsistente: «nota» para cualquier página, «portada» para una sección, «Puedes» en vez de «Podés», «Abrir» contestado con «Tocando» y búsquedas sin tilde

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: clima-cordoba, wikipedia-mar-del-plata, turno-anses, otra-cosa, banco-nacion, solo-botones-clarin

Evidencia:
- clima p2: [Leer la nota] · [Resumir la nota] en un pronóstico; wikipedia p3: [Leer la nota] en el sitio municipal
- otra-cosa p4: [Resumir la portada] estando en Deportes
- turno-anses p2: «Puedes pedir un turno por internet…»
- banco-nacion p3: botón «Abrir «Recuperar usuario y contraseña»» → «Tocando «Recuperar usuario y contraseña».»
- solo-botones-clarin p1: «Buscando: clarin.»

Causa probable: `isArticle()` sólo pide dos párrafos largos, y `followUps()` y `arrived()` le dicen «nota» a todo lo que pasa esa prueba. «Resumir la portada» está escrito a mano. Los prompts de orient y answer piden evitar las formas que cambian entre tú y vos en lugar de pedir voseo, y el modelo usó «Puedes». `accept()` dice «Tocando» cuando el destino no es un enlace. El Router devuelve el target sin tildes.

Propuesta: «Nota» sólo con señales de artículo periodístico (fecha y autor, og:type=article); si no, «la página» o el nombre de lo que es («el pronóstico»). «Resumir esta sección» fuera de la raíz del sitio. Pedir voseo rioplatense de forma explícita cuando el teléfono está en es-AR y corregir por código «puedes/quieres/tienes». Usar el mismo verbo que el botón («Abriendo…»). Mostrar lo que escribió la persona y normalizar sólo la consulta interna.

Escéptico: Todo está en las transcripciones. En clima p2/p3 aparecen [Leer la nota]/[Resumir la nota] en un pronóstico, y en wikipedia p3 [Leer la nota] en mardelplata.gob.ar. En otra-cosa p4 hay [Resumir la portada] en lanacion.com.ar/deportes. En turno-anses p2 dice «Puedes pedir un turno por internet…». En banco-nacion p3, el botón «Abrir «Recuperar usuario y contraseña»» se contesta con «Tocando «Recuperar usuario y contraseña».» (Assistant.swift:1435). En solo-botones-clarin p1 la persona escribe «clarín» y JEF dice «Buscando: clarin.».

### P19 · Clima: «No va a llover» dicho con certeza sin dato de la página; sugerencias que repiten lo ya contestado y un «En X.» de más

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: clima-cordoba, dolar-desde-cero

Evidencia:
- clima p3: «No va a llover.» La página no trae probabilidad ni milímetros (paginas/02.txt) y el encabezado dice «Nubes y claros»
- clima p2: primer botón [¿A qué hora sale el sol?]; p3: [¿Cuál es la temperatura máxima?] después de «entre 7°C y 19°C»
- clima p2: «Abriendo meteored.com.ar.» y después «En meteored.com.ar.»; dolar p2: «En DolarInfoHoy.»

Causa probable: El prompt de `Answerer.answer()` pide contestar directo y no pide decir cuándo se está deduciendo. Las «preguntas» se piden sin excluir lo que ya se contestó en la conversación ni darle prioridad a lo que se preguntó. La rama `pendingQuestion` de `accept()` dice `say("En \(page.displaySite).")` aunque se acaba de decir «Abriendo…».

Propuesta: En el prompt: «si la página no trae el dato, decí lo que sí dice ("no marca lluvia; cielo con nubes y claros"), nunca una certeza». Pasar las respuestas previas y descartar preguntas ya contestadas, priorizando las del tema del pedido («¿Y pasado mañana?», «¿Va a llover?»). Sacar el «En X.» cuando «Abriendo X» fue lo último que se dijo.

Escéptico: Las tres partes se confirman. En clima p3 dice «No va a llover.», pero paginas/02.txt sólo trae «Nubes y claros» y un rótulo «PRECIPITACIÓN» sin datos, así que es una deducción dicha como certeza. En p2 el primer botón es [¿A qué hora sale el sol?], y en p3 ofrece [¿Cuál es la temperatura máxima?] después de haber dicho «entre 7°C y 19°C». También sale «Abriendo meteored.com.ar.» seguido de «En meteored.com.ar.» (y en dólar, «En DolarInfoHoy.»), por el `say("En \(page.displaySite).")` de la rama `pendingQuestion` en Assistant.swift:1411. Las sugerencias las generó la app; el script sólo tocó botones antes.

### P20 · «Otra cosa» borra todas las opciones y no deja cómo volver sin escribir

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: otra-cosa

Evidencia:
- otra-cosa p3: «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» Después, sólo el campo y [Enviar]

Causa probable: `accept()` con `otherID` vuelve antes del `defer { closeTurn }`, a propósito («sin más botones»). El foco sí va al campo con el teclado abierto (`placeFocus` con `inputRequests`, visto en paso-03.jpg): eso ya funciona.

Propuesta: Mantener un botón «Volver a las opciones» que reponga la oferta anterior. Acortar la frase a «¿Qué hacemos?» y dejar lo del dictado para la primera vez.

Escéptico: En otra-cosa p3, después de «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» sólo quedan [campo] Pedido y [btn] Enviar. Desapareció incluso «Volver a la página anterior», que estaba en p2. Es intencional: Assistant.swift:1326-1330 hace `return` antes de `closeTurn` («sin más botones»). Aun así no cumple la regla de que toda respuesta termine con opciones. El script tocó «Otra cosa» a propósito, según el escenario.

### P21 · La lista de resultados desaparece del historial: queda «Los 3 más probables:» sin nada después

*menor* · confirmado · jueces: Verificador 2 · escenarios: mercadolibre-auriculares, banco-nacion, clima-cordoba, otra-cosa, noticias-la-nacion

Evidencia:
- banco-nacion arbol-02 línea 4: «Estás en los resultados de «home banking banco nacion». Los 3 más probables:», seguido directamente por «Vos: …»
- noticias-la-nacion arbol-02 línea 4: lo mismo

Causa probable: `present()` escribe en la conversación sólo «… Los 3 más probables:». La lista existe en voz (`aloud`) y como oferta, y cuando la oferta se reemplaza, el texto queda colgado.

Propuesta: Al reemplazar la oferta, reescribir esa línea con los nombres cortos («Los 3 más probables: La Nación, LN+ en YouTube, Kiosco»), o escribirlos desde el principio en forma breve.

Escéptico: En banco-nacion/arbol-02.txt y noticias-la-nacion/arbol-02.txt la línea 4 es «Estás en los resultados de «…». Los 3 más probables:» y lo que sigue ya es «Vos: …». Pasa lo mismo en clima, dólar y otra-cosa, y en mercadolibre con «Los 2 más probables:». `present()` escribe sólo `"\(found) \(intro)"` y deja la lista en `aloud` y en la oferta (Assistant.swift:672), así que al reemplazar la oferta la frase queda colgada en lo que VoiceOver puede recorrer.

## Lo que funciona

- El ejemplo «Llevame a La Nación» abre el sitio directo, sin lista (href fijo en `starters`).
- En trámites y bancos el primer resultado fue el oficial: argentina.gob.ar en ANSES, digital.bna.com.ar en el banco. Además descartó homebanking.bna.com.es, la Córdoba de España y los anuncios de DuckDuckGo.
- La orientación en una frase ubica bien: «Estás en la portada de La Nación. Los titulares principales son…», «Estás en Clarín, en una nota sobre…», «Estás en la página de Home Banking del Banco Nación».
- Cuando el toque llega, la confirmación es inmediata: «Abriendo «Renunció…»», «Abriendo lanacion.com.ar.».
- Dentro de una nota, «Leer la nota completa» es la primera opción. La lectura es textual, párrafo por párrafo, y cierra con «Fin de la nota.».
- Después de abrir un sitio, la respuesta al dato llega directa y corta: el blue con compra y venta, el pronóstico con fecha, mínima, máxima y viento, y «No va a llover» primero.
- `forEar()`: los montos se dicen sin «coma cero cero» ($1.550).
- Preguntas siguientes útiles como botones: «¿Y el dólar oficial?», «¿Quién fundó Mar del Plata?», «¿Cuál fue el primer nombre…?».
- «Volviendo.» + «De vuelta en los resultados de «…»», sin releer la lista.
- La pista «Primera de N opciones» sólo en el primer botón.
- Frente al captcha es honesto: «Eso no lo puedo resolver yo.» No inventa precios.
- «llevame a deportes» se queda dentro de La Nación (el Router elige `abrir` en el sitio).
- «Otra cosa» lleva el foco al campo con el teclado abierto.
- «Seguir leyendo» es la primera opción mientras se lee y continúa textual; el tramo de 3 más «Párrafo N de M» le sirve a Roberto y a Lucía.
- Wikipedia: la fecha de fundación llegó en menos de 2 s y es la correcta.
- Todas las respuestas terminan con botones y «Otra cosa».
- Los botones son grandes, con borde y texto oscuro, y se leen bien de cerca (Ana).
- Los resultados muestran el dominio, lo que sirve para elegir el sitio real (Lucía).
