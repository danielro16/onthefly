# Veredicto — ronda-1

Diez escenarios, cuatro jueces: 7 de 10 terminaron en «no» para los cuatro (dólar, Wikipedia, ANSES, Mercado Libre, Banco Nación, primera vez, otra cosa). Sólo La Nación (Roberto y Ana: sí) y Clarín (Lucía: sí) se lograron para alguien; clima quedó «a medias» para tres, y Ana dijo «no» porque el pronóstico era de Córdoba, España. Promedio general de puntajes: 2,26 sobre 5. Wikipedia sacó lo peor (1,5) y La Nación lo mejor (3,0).

Cinco causas explican casi todo:
1. Búsqueda: DuckDuckGo lite no se lee cuando arriba hay anuncios o un recuadro informativo. Al asistente le llega «Tabla de 33 filas» y extrae cero resultados.
2. Voz: Assistant.say() hace un anuncio por línea y cada uno corta al anterior. Después el panel lleva el cursor a la última línea, que es el contador o el cierre («Titular 3 de 154», «Párrafo 3 de 15», «Fin de la nota»).
3. Botones: al llegar a una página los elige el modelo de orientación, sin un orden fijo en el código. Además no se renuevan cuando la página cambia dentro del mismo turno.
4. Memoria: el Router y el Answerer reciben sólo la frase y la página, no la conversación. Por eso contesta sobre DuckDuckGo o sobre «una tabla de 33 filas».
5. Sitios conocidos: nunca va directo, siempre muestra una lista del buscador. Esa lista se deduplica por host completo, así que aparecen cdnedge, clarinsandbox.lilax.io y mianses.org, y se pierde «Solicitar turnos».

Cambios sin commitear que esta corrida NO midió (terminó 13:16):
- extract.js y PageModel.swift (13:23 a 13:25): tablas de enlaces y tablas con sus datos.
- Otros que otra sesión hizo mientras yo revisaba (13:34): voz en cola con accessibilitySpeechQueueAnnouncement, named() por nombre registrado del sitio, isArticle con dos párrafos largos y una regla nueva del Router para completar el tema.

Esos cambios apuntan a P01, P02, P06 y P10, pero hay que volver a correr para saber si alcanzan. La cola de anuncios sola no evita que el foco vaya a la última línea. El cambio de scroll de AssistantPanel (13:09) sí estaba en la corrida, y no resuelve que los botones queden escondidos. Las causas se refieren al código que corrió. Las rutas son relativas a /Users/daniel/Developer/JEF- BROWSER/.

Descartado por ser del script: el porcentaje exacto al que se corta una descripción larga, que depende de que el script actuó unos 9 s después (por ejemplo, «No pude leer…» cortado al 62 % por el toque del script); y que el script esperara un «Seguir». El hecho de producto detrás sí quedó: sólo había «Otra cosa».

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta a medias, Roberto sí, Lucía a medias, Ana sí | 3.0 |
| solo-botones-clarin | Marta a medias, Roberto a medias, Lucía sí, Ana a medias | 2.8 |
| dolar-desde-cero | Marta no, Roberto no, Lucía no, Ana no | 1.8 |
| wikipedia-mar-del-plata | Marta no, Roberto no, Lucía no, Ana no | 1.5 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 2.2 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.0 |
| banco-nacion | Marta no, Roberto no, Lucía no, Ana no | 2.2 |
| primera-vez | Marta no, Roberto no, Lucía no, Ana no | 2.1 |
| clima-cordoba | Marta a medias, Roberto a medias, Lucía a medias, Ana no | 2.4 |
| otra-cosa | Marta no, Roberto no, Lucía no, Ana no | 2.5 |

**Promedio general: 2.25**

## Problemas

### P01 · La búsqueda web no lee los resultados y el pedido muere ahí

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: dolar-desde-cero, wikipedia-mar-del-plata, banco-nacion, otra-cosa

Evidencia:
- «No pude leer los resultados de esa búsqueda. Probar con otras palabras, o con el nombre de un sitio.» (paso 1 de dólar, Wikipedia y banco; paso 4 de otra-cosa)
- Texto que recibió el asistente (dolar-desde-cero/paginas/01.txt): «DuckDuckGo / Next Page > / Tabla de 33 filas / Next Page > / Search», sin ningún resultado.
- Verificador: la captura paso-01 muestra «1. FxPro» (patrocinado) y «2. Dólar Blue, Cotización del dólar Blue | Dolar…»; en Wikipedia, «Sheraton Mar del Plata» patrocinado; en banco, «Top 5 Online Banks (2026)» patrocinado; en deportes, el recuadro «Zero-click info: Deporte» («Tabla de 2 filas / Tabla de 36 filas»).
- Ana: «Arriba veo clarito ‘2. Dólar Blue, Cotización del dólar Blue’, y el asistente me dice que no pudo leer los resultados.»
- Contraste: con «la nación» (sin anuncio arriba), 01.txt sí trae los resultados numerados después de «Tabla de 30 filas».

Causa probable: DuckDuckGo lite arma los resultados con tablas de maquetación. Cuando arriba hay enlaces patrocinados o un recuadro informativo, Sources/Extraction/extract.js conservaba esa tabla como tabla de datos y Sources/Engine/PageModel.swift (Block.plainText) la reducía a «Tabla de N filas». Assistant.results(of:) sólo mira las entradas link/listing del recorrido, encuentra cero, y arrive() dice la frase de error y termina. No hay reintento, ni motor de respaldo (Engine está fijo en .duckduckgo), ni atajo para sitios conocidos. Los cambios sin commitear de extract.js y PageModel.swift (posteriores a la corrida) atacan justo esto, pero nadie los midió.

Propuesta: 1) Volver a correr estos cuatro escenarios con los cambios de extract.js y PageModel.swift, y dejar como prueba fija las cuatro páginas de DuckDuckGo guardadas (con anuncio arriba y con recuadro Zero-click). 2) Si results(of:) da vacío, reintentar una vez con otro motor (la enum Engine ya lo permite) antes de rendirse. 3) Para sitios y datos frecuentes, no depender del buscador (ver P10). 4) Si igual falla, decir dónde quedó la persona y ofrecer botones concretos: «Buscar de nuevo», «Volver a <sitio anterior>», «Abrir <fuente conocida>».

Escéptico: Pasa en los cuatro escenarios. dolar-desde-cero/paginas/01.txt trae sólo «DuckDuckGo / Next Page > / Tabla de 33 filas / Next Page > / Search», y la respuesta es «No pude leer los resultados de esa búsqueda…». La captura paso-01 muestra «2. Dólar Blue, Cotización del dólar Blue» debajo del anuncio de FxPro. Wikipedia y banco (Tabla de 36 filas, con anuncios de Sheraton y de «Top 5 Online Banks») y deportes (recuadro Zero-click, «Tabla de 2 filas / Tabla de 36 filas») fallan igual. En cambio, otra-cosa/paginas/01.txt («la nación») sí trae los resultados numerados. En el código de HEAD, arrive() termina con esa frase cuando results(of:) da vacío.

### P02 · En las respuestas de varias líneas sólo se oye la última: «Titular 3 de 154», «Párrafo 3 de 15», «Fin de la nota»

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, mercadolibre-auriculares, clima-cordoba

Evidencia:
- La Nación, paso 3: los tres titulares y «Titular 3 de 154.» se anuncian en el mismo instante (+24.7s); cada titular queda «CORTADO (~0%)» y sólo se oye «Titular 3 de 154.».
- Clarín, paso 5: tres párrafos y «Párrafo 3 de 15.» a +53.7s. Roberto: «La noticia nunca sonó.»
- ANSES, paso 4: «Ingrese el código que se muestra en la imagen» CORTADO ~0% por «Fin de la nota.».
- Mercado Libre, paso 2: «El sitio me puso una verificación de «no soy un robot». Eso no lo puedo resolver yo.» y la línea del audio, CORTADAS ~0%. Sólo se oye «Si preferís, te llevo a otro lado o volvemos a la página anterior.». En el paso 1, la lista de opciones la corta «Cuando elijas, sigo con: buscame auriculares bluetooth.».
- Clima, paso 2: «Aviso de cookies encima de la página.» CORTADO ~0%; sólo se oye «Opciones: Política de Cookies, Configuración de cookies, nuestros socios.»

Causa probable: Assistant.say() dispara un anuncio de VoiceOver por cada línea (Voz.decir en Sources/Engine/Registro.swift). readAloud(), describe() y el aviso del captcha llaman a say() en un bucle o varias veces seguidas, así que cada anuncio corta al anterior. Al terminar, Sources/UI/AssistantPanel.swift (onChange de turns.count, focused = last.id) pone el cursor de VoiceOver en la última línea, que es justamente el contador o el cierre. La cola de anuncios agregada después de la corrida (Registro.swift, sin commitear) no cambia a qué línea va el foco.

Propuesta: Un turno, un anuncio: juntar en un solo texto lo que dice el turno, con el contador adelante («Titulares 1 a 3 de 40: …», «Párrafos 1 a 3 de 15: …»). Al terminar, llevar el cursor a la PRIMERA línea nueva del turno, no a la última. El contador puede ir en el botón: «Seguir leyendo (quedan 12)». Aplicarlo en readAloud(), describe() y el aviso del captcha, y medirlo con el registro.

Escéptico: El registro muestra los anuncios disparados en el mismo milisegundo, así que el corte no sale de la estimación de 14 caracteres por segundo. En La Nación, los tres titulares y «Titular 3 de 154.» van entre 24.717 y 24.719 s. En Clarín, los tres párrafos y «Párrafo 3 de 15.» van a +53.7 s. En ANSES, «Ingrese el código…» sale junto con «Fin de la nota.». En Mercado Libre, las líneas del captcha salen junto con «Si preferís…». En Clima, «Aviso de cookies…» sale junto con «Opciones: …». En HEAD, readAloud() llama a say() en un bucle con working=false, y el panel pone el foco en turns.last. Los párrafos quedan escritos y se pueden recorrer con gestos, pero ninguno se anuncia solo.

### P03 · Callejones sin salida: respuestas sin botones o con «Otra cosa» como único botón

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: dolar-desde-cero, wikipedia-mar-del-plata, banco-nacion, otra-cosa, primera-vez

Evidencia:
- Dólar (pasos 1 y 3), Wikipedia (pasos 1, 3 y 4), banco (paso 1), otra-cosa (paso 4): «Botones: [Otra cosa]».
- Wikipedia, paso 5: «no hay opción 'Seguir'; hay: ['Otra cosa']».
- Banco, paso 3, después de tocar «Otra cosa»: «no hay opción 1; hay: []». Primera vez: «no hay opción 1; hay: []».
- Roberto: «Me dejan frente al campo para escribir, que es lo que más me cuesta.»
- Ana: «Toqué ‘Otra cosa’ y quedé sin ningún botón, sólo el campo vacío.»

Causa probable: En Assistant.closeTurn(), sin página no se ofrece nada («el campo de escribir ya es la única opción»). En la página del buscador, followUps() sólo ofrece resultados y retorna, así que con cero resultados queda sólo «Otra cosa». accept() retorna antes de closeTurn a propósito cuando se toca «Otra cosa» («sin más botones»). Ningún camino de error agrega una acción concreta.

Propuesta: Una regla que closeTurn() verifique: toda respuesta termina con al menos una acción concreta además de «Otra cosa». Si falla la búsqueda: «Buscar de nuevo», «Volver a <sitio anterior>» (si canGoBack) y «Abrir <sitio conocido>» si el pedido lo nombra. Sin página abierta: 3 o 4 ejemplos que funcionen («Leer las noticias de hoy», «¿A cuánto está el dólar?», «El clima de mañana»). Si antes de tocar «Otra cosa» hubo un error, mantener los botones de salida.

Escéptico: El único botón es [Otra cosa] en dólar (pasos 1 y 3), en Wikipedia (pasos 1, 3 y 4), en banco (paso 1) y en otra-cosa (paso 4). En este último pasa aunque había una página anterior a la cual volver: followUps() retorna después de los resultados, que eran cero. Los ⚠️ son del producto: en Wikipedia, «no hay opción 'Seguir'; hay: ['Otra cosa']»; en banco (después de «Otra cosa») y en primera-vez, «hay: []». accept() deja sin botones a propósito después de «Otra cosa», pero eso contradice la regla de que toda respuesta termina con botones.

### P04 · La primera vez, «¿qué podés hacer?» no tiene respuesta

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: primera-vez

Evidencia:
- «Todavía no hay ninguna página abierta. Decir un sitio o qué buscar.»
- Roberto: «¿Qué página? Recién abro la app. ‘Decir un sitio’, ¿cuál? No me dio ni un ejemplo.»
- Ana: «La pantalla es un blanco enorme con dos burbujas arriba.»
- Verificador: arbol-01.txt sólo tiene el texto, el campo y «Enviar»; no hay ningún botón.

Causa probable: El Router toma «hola, ¿qué podés hacer?» como orientar. En Assistant.carry(.orientar), sin página, la única salida es esa frase fija. El texto de bienvenida con ejemplos existe sólo como indicación del panel mientras no hay mensajes (Sources/UI/AssistantPanel.swift, «Escribir a dónde ir o qué buscar…»): nunca se anuncia y desaparece con el primer mensaje.

Propuesta: En orientar sin página, contestar qué hace JEF en dos frases, de vos, con 3 o 4 botones de ejemplo. Y la primera vez que se abre la app, que JEF hable primero con esa bienvenida y esos botones.

Escéptico: En primera-vez, la única respuesta es «Todavía no hay ninguna página abierta. Decir un sitio o qué buscar.», sin botones. arbol-01.txt sólo tiene el texto, el campo y «Enviar», y la captura muestra la pantalla vacía con dos burbujas. Esa frase aparece una sola vez en el código de HEAD: carry(.orientar) sin página. Los ejemplos de bienvenida del panel sólo se muestran cuando turns.isEmpty.

### P05 · Clima: da el pronóstico de Córdoba, España, como si fuera el de Argentina

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: clima-cordoba

Evidencia:
- Primera opción: «El tiempo en Córdoba mañana - Meteored España — www.tiempo.com». Los resultados 2 y 3 eran de Córdoba, Argentina.
- paginas/02.txt: «Meteored España / Inicio / Andalucía / Provincia de Córdoba / Córdoba».
- Respuesta: «…con temperaturas que oscilarán entre los 17°C y 36°C.», sin decir de qué lugar ni de qué fuente.
- Ana: «Me dio el pronóstico de Córdoba de España como si fuera el mío, sin avisar. Le habría creído.»

Causa probable: arrive() presenta los resultados en el orden del buscador, salvo que alguno coincida por dominio con lo pedido (ranked/named). La preferencia por el país (closer()) sólo desempata entre coincidencias exactas, así que con «tiempo mañana córdoba» no hace nada. El «Meteored España» del botón suena al nombre del sitio y no a otro país. Ni orient() ni answer() piden decir el lugar y la fuente del dato.

Propuesta: Para el clima, ir a una fuente argentina fija (una tabla en el código: SMN o meteored.com.ar). Si se busca, subir los resultados .ar o con «Argentina» en el título y bajar los de otro país. Si el lugar es ambiguo, preguntar con botones: «Córdoba, Argentina» o «Córdoba, España». Que toda respuesta con un dato diga lugar y fuente: «Según Meteored, en Córdoba, Argentina, …».

Escéptico: El script tocó el botón 1 mecánicamente, pero lo que falla es la opción que la app puso primera. Con kl=ar-es, la primera fue «El tiempo en Córdoba mañana - Meteored España — www.tiempo.com», y los resultados 2 y 3 eran de Córdoba, Argentina (eltiempoen.com/argentina y meteored.com.ar). En 02.txt aparece «Meteored España / Inicio / Andalucía / Provincia de Córdoba». La respuesta, «…entre los 17°C y 36°C», no dice ni el lugar ni la fuente.

### P06 · No usa el hilo de la conversación ni el sitio abierto

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: wikipedia-mar-del-plata, dolar-desde-cero, otra-cosa, turno-anses

Evidencia:
- «La página no menciona cuándo se fundó DuckDuckGo.»
- «La página muestra una tabla con 33 filas, pero no especifica qué tipo de cambio se detalla ni menciona el ‘dólar oficial’.»
- En la portada de La Nación, «llevame a deportes» → «Buscando: deportes.», aunque la portada tenía la sección Deportes (02.txt) y «Secciones» se veía en pantalla.
- «quiero sacar un turno en anses» → «Buscando: anses.», sin «Cuando elijas, sigo con: …» (en Mercado Libre sí lo hizo).
- «buscá mar del plata en wikipedia» → «Buscando: mar del plata en wikipedia.»
- ANSES, paso 2: describe una página de estudios sin avisar que no sirve para turnos.

Causa probable: Router.decide() recibe sólo la frase y el estado que arma Router.state(), sin los turnos anteriores ni el tema. Además, su prompt dice que si hay una página abierta y la pregunta podría contestarse con ella, «es responder», y el estado no avisa que la página es una búsqueda fallida. Answerer.answer() también recibe sólo la pregunta y el texto de la página. carry(.ir) y arrive() salen siempre al buscador web: nunca buscan antes un enlace o sección del sitio abierto (.buscar sólo mira si el sitio tiene formulario de búsqueda). El «rest» que devuelve el ruteador (flash-lite) es irregular: en ANSES no volvió «sacar un turno». No hay búsqueda dentro de un sitio nombrado. orient() no recibe el objetivo, así que no puede decir «esta página no es la de turnos».

Propuesta: 1) Pasarles al Router y al Answerer los últimos turnos y el objetivo vigente (el que ya se guarda en «waiting»). 2) Marcar en Router.state cuando la página es de resultados o una búsqueda fallida. 3) Nunca responder sobre la página del buscador: reformular con el tema y buscar («fundación de Mar del Plata», «dólar oficial hoy»). 4) Antes de salir a la web con «ir X», buscar X entre los enlaces del sitio abierto y decir «Abriendo Deportes de La Nación». 5) Si el pedido nombra un sitio con buscador propio conocido (Wikipedia), buscar ahí. 6) Guardar el objetivo en el código aunque el ruteador no devuelva rest, y pasárselo a orient() para que diga si la página acerca o no.

Escéptico: Todas las citas están en las transcripciones. En Wikipedia: «La página no menciona cuándo se fundó DuckDuckGo.». En dólar: «…una tabla con 33 filas… ni menciona el "dólar oficial"». Parado en la portada de La Nación, que tiene el encabezado «Deportes» (02.txt, línea 41) y la pestaña «Secciones» a la vista en paso-03.jpg, pidió «llevame a deportes» y la respuesta fue «Buscando: deportes.». En ANSES, «Buscando: anses.» salió sin «Cuando elijas, sigo con», y en el paso 2 describió la página de estudios sin avisar que no sirve para turnos. Nada de esto lo causa el script: los pedidos fueron escritos y el único botón disponible era «Otra cosa».

### P07 · «No soy un robot» y código en imagen: sin salida real, y explicado a medias o contradicho

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: mercadolibre-auriculares, turno-anses

Evidencia:
- «Suele tener una opción de audio, pero está dentro del recuadro del proveedor y no la alcanzo: hay que tocarla en la pantalla.»
- Paso 3: «Es una página de seguridad que pide que vayas al login.», mientras paso-03.jpg muestra la casilla reCAPTCHA «No soy un robot».
- ANSES: «La página te pide que ingreses un código que se muestra en una imagen para continuar.», sin ninguna alternativa.
- Ana: «No me dice dónde tocar, y yo el cuadrado lo veo.»

Causa probable: Para el captcha, Assistant.describe() dice tres frases fijas y no deja botones propios (quedan los del turno anterior, ver P08). Nada lleva el foco de VoiceOver a la página. reply() arma el texto con saying(page), que no incluye page.overlay, y el texto de la página es «Por seguridad, completá este paso / Ir al login»: de ahí sale el «login». En ANSES, el código en imagen sólo se reconoce en complete() (isChallenge), no al llegar, y sin el objetivo no hay a qué otro camino proponer.

Propuesta: Un solo mensaje («Mercado Libre me pide demostrar que no soy un robot; eso no lo puedo hacer yo») con botones: «Ir a la verificación» (mueve el foco de VoiceOver a la casilla, que está viva en WebPageView), «Ya la pasé, seguí» (retoma la tarea pendiente), «Volver» y «Buscar en otra tienda». Incluir el estado del aviso en el texto que recibe answer(), para que la página se describa siempre igual. Para quien ve poco: «Tocá la casilla ‘No soy un robot’, arriba». En ANSES, reconocer el código en imagen al llegar y ofrecer otro camino hacia el objetivo (la página oficial de turnos u otra vía de contacto).

Escéptico: Todo está en la transcripción. En Mercado Libre, paso 2, JEF dice «Suele tener una opción de audio… no la alcanzo: hay que tocarla en la pantalla», no dice dónde está ni deja un botón para ir a la casilla (quedan «[Suscribirme a Meli+] · [Configurar cookies]»). En el paso 3 contradice lo anterior con «Es una página de seguridad que pide que vayas al login», mientras paso-03.jpg muestra la casilla «No soy un robot» (03.txt sólo tiene «Por seguridad, completá este paso / Ir al login»). En ANSES dice «te pide que ingreses un código que se muestra en una imagen» y ofrece «[Ver mis trámites en Mi ANSES] · [Resumir esta página]», nada que lleve a un turno. Que el captcha aparezca puede ser cosa del entorno; cómo lo maneja la app, no.

### P08 · Los botones no siguen a la página ni al pedido: una suscripción primero, otra nota antes que «Leer», «Leer la nota» en un pronóstico

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: mercadolibre-auriculares, solo-botones-clarin, noticias-la-nacion, clima-cordoba, turno-anses, otra-cosa

Evidencia:
- Mercado Libre, paso 2, después del captcha: «[Suscribirme a Meli+] · [Configurar cookies] · [Otra cosa]». Son los botones de la portada (03.txt no tiene Meli+), y el texto ofrecía «volvemos a la página anterior» pero no había botón para eso.
- Clarín, paso 3: «[Abrir Marcha del Orgullo Gay] · [Abrir La Primavera…] · [Leer la nota completa] · [Resumir esta nota]». En el paso 4, en cambio, «Leer la nota completa» salió primera.
- La Nación, paso 4, dentro de la nota: sólo «[Abrir noticia sobre Formosa] · … · [Abrir noticia sobre Milei en la ONU]», sin Leer, Resumir ni Volver.
- Clima: «[Leer la nota] · [Resumir la nota]» en un pronóstico. Las cookies se nombran («Opciones: …») pero no hay botón para aceptarlas o rechazarlas.
- La portada no tiene «Secciones» ni «Más titulares», y ofrece «Resumir esta nota» justo después del resumen.

Causa probable: Al llegar, Assistant.arrived() deja que el modelo de Answerer.orient() elija entre 2 y 4 sugerencias. Si ya hay offer, closeTurn() sólo le suma «Otra cosa»: no hay orden fijo ni garantía de Leer, Resumir o Volver. El offer no se limpia cuando la página cambia dentro del mismo turno: accept() → arrived(portada) fija Meli+ y cookies → continueWith() → captcha → describe(), que no toca el offer. followUps() sólo distingue portada, nota y página, e isArticle() da «nota» para un pronóstico. overlay.choices se dicen pero nunca se vuelven botones. El prompt de orient() no excluye acciones pagas.

Propuesta: Armar los botones en el código, con orden fijo: 1) seguir con lo que se está haciendo según el tipo de página (Leer, Seguir o Resumir la nota; Pronóstico; en un formulario o una verificación, la salida); 2) Volver; 3) hasta dos relacionadas (las de orient); 4) Otra cosa. Limpiar el offer en cada cambio de página. Filtrar las sugerencias que suscriben, pagan o compran. Si un aviso tapa la página, sus botones reales (Aceptar, Rechazar, Cerrar) van primero. En portadas de diario, sumar «Secciones» y «Más titulares». No ofrecer «Resumir» si lo último fue un resumen o la orientación de esa misma página.

Escéptico: Todo confirmado. Después del captcha de Mercado Libre quedan «[Suscribirme a Meli+] · [Configurar cookies] · [Otra cosa]» (03.txt no tiene Meli+) y no hay botón de «volvemos a la página anterior». En Clarín, paso 3, «Leer la nota completa» sale tercera y en el paso 4 sale primera. En La Nación, paso 4, sólo hay cuatro «Abrir noticia sobre…» más Otra cosa, sin Leer, Resumir ni Volver. En Clima aparece «[Leer la nota] · [Resumir la nota]» en un pronóstico, y las cookies se nombran («Opciones: Política de Cookies, Configuración…») sin botones, aunque paso-02.jpg muestra «ACEPTAR Y CONTINUAR». Se juzga qué se ofrece y en qué orden, no lo que eligió el script.

### P09 · El botón de un titular abre otra nota, y «Abriendo <dominio>» no deja notarlo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: solo-botones-clarin, noticias-la-nacion

Evidencia:
- Clarín: JEF nombró «el gobierno calcula que 7 millones de personas se movilizarán por la visita de León XIV y evalúa declarar asueto». El botón «[Abrir noticia de la visita de León XIV]» abrió «Quiénes son los ganadores y los perdedores tras la definición de la agenda del papa León…».
- «Abriendo www.clarin.com.» / «Abriendo www.lanacion.com.ar.» al abrir una nota.
- Marta: «así que no supe que era otra cosa hasta que me leyó el resumen».

Causa probable: En Answerer.orient(), el modelo escribe la etiqueta del botón y elige un número de la lista de candidatos, y nada verifica que la etiqueta y el candidato hablen de lo mismo (en Clarín hay dos notas del Papa seguidas; 02.txt, líneas 305 y 306). Además, Assistant.accept() dice «Abriendo» y el host para todo id que empiece con «res-» o «sug-».

Propuesta: Que la etiqueta salga del título real del candidato (acortada en un límite de palabra), o verificar que comparta palabras con ese título antes de ofrecerla. Anunciar «Abriendo: <título de la nota>». Al cargar, comparar el título de la página con el esperado y avisar si no coincide.

Escéptico: En Clarín, JEF nombra la nota de «7 millones… asueto» (02.txt, línea 305), pero «[Abrir noticia de la visita de León XIV]» carga «Quiénes son los ganadores y los perdedores tras la definición de la agenda del papa León…» (línea 306), y sólo anuncia «Abriendo www.clarin.com.». En La Nación el botón abrió la nota correcta; ahí el problema es sólo el «Abriendo www.lanacion.com.ar.», que no nombra la nota. La etiqueta que no coincide con el destino la genera la app, no el script.

### P10 · Para sitios conocidos hace elegir en una lista con espejos, sitios de prueba, duplicados y sitios no oficiales

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, mercadolibre-auriculares, turno-anses, otra-cosa, banco-nacion, clima-cordoba

Evidencia:
- «[Últimas noticias de Argentina y el mundo - LA NACION — cdnedge.lanacion.com.ar]», con el mismo título que el primero.
- «[Noticias. Últimas noticias de Argentina y el Mundo | Clarín — web-clarinsandbox.lilax.io]».
- ANSES: «[ANSES — servicioswww.anses.gob.ar]» primero (una página de estudios) y «[ANSES - Mi Anses — mianses.org]» (no oficial). «Solicitar turnos en ANSES - Argentina.gob.ar» (resultado 3) no se ofrece.
- Tres Mercado Libre casi iguales (.com.ar, .com, listado) y un video de YouTube cortado con «...».
- «Encontré 5 resultados para «la nación».», cuando 01.txt tiene 8.
- Lucía, banco: «Para entrar a mi banco no quiero pasar por resultados de un buscador: es donde aparecen sitios falsos.»

Causa probable: Es una decisión de diseño de arrive(): «Un buscador nunca navega solo: muestra la lista». Assistant.results(of:) deduplica por host completo, así que cdnedge.lanacion.com.ar y www.lanacion.com.ar cuentan como dos sitios, y el resultado de turnos se descarta por compartir host (www.argentina.gob.ar) con otro resultado de ANSES. Sólo se filtran anuncios y buscadores, no dominios cuyo título imita una marca. named() da coincidencia exacta a servicioswww.anses.gob.ar (etiqueta «anses»). «Encontré N» cuenta hosts, no resultados. Las etiquetas son «título — host».

Propuesta: Una tabla en el código de sitios frecuentes con su dirección oficial (escrita a mano, no adivinada por un modelo, como pide la regla del archivo): La Nación, Clarín, Mercado Libre Argentina, ANSES y su página de turnos, Banco Nación y su home banking, Wikipedia en español, cotizaciones del dólar, SMN. Si el pedido nombra uno, ir directo y decir «Te llevo a la página oficial de …; si no era, decime». Para el resto: deduplicar por dominio registrable y no por host; descartar los resultados cuyo título nombra una marca que no es la de su dominio; marcar «sitio oficial» (gob.ar o el dominio de la marca); preferir el país; etiquetas cortas («La Nación, lanacion.com.ar»); contar bien, o no dar el número.

Escéptico: En la lista aparecen espejos y un sitio de prueba: «LA NACION — cdnedge.lanacion.com.ar» con el mismo título que el primero y «Clarín — web-clarinsandbox.lilax.io». En ANSES, servicioswww.anses.gob.ar (la página de estudios con código en imagen) sale primero y mianses.org, que no es oficial, tercero; «Solicitar turnos en ANSES» (resultado 3 de 01.txt) no sale entre los tres primeros ni cabe en «Ver más» (6 resultados, uno por host, y comparte host con el resultado 1). Clima pone primero la Córdoba de España (tiempo.com), y «Encontré 5» cuando la página de La Nación tiene 8. Salvedad: en banco-nacion no se mostró ninguna lista porque la búsqueda falló («No pude leer los resultados»), así que la frase de Lucía es opinión, no un hecho de esa corrida.

### P11 · Fallas silenciosas: un botón que no anduvo termina presentado como una página nueva

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: turno-anses

Evidencia:
- «Abriendo Ver mis trámites en Mi ANSES.» → «Ese control ya no está. Recargando.», CORTADO ~0% por «Cargando página» → se recarga la misma URL (03.txt es igual a 02.txt) → «Hola, estás en la página de la Administración Nacional de la Seguridad Social, que es la ANSES…».
- Roberto: «Pensé que había entrado a Mi ANSES, pero no: el botón no funcionó y no me enteré.»
- Ana: «Sólo me di cuenta porque cambió el número del código.»

Causa probable: ReaderModel.activate() (Sources/UI/ReaderView.swift) resuelve el caso .stale con un anuncio de voz y una recarga, sin avisarle al Assistant (no devuelve nada). accept() sigue con arrived(), y orient() describe la misma página como si recién se llegara. La falla nunca queda escrita en la conversación.

Propuesta: Que activate() devuelva qué pasó (cambió, no cambió, ya no estaba) y que el Assistant lo diga como un mensaje: «No pude abrir Mi ANSES. Seguís en la misma página», con otra salida. Si la página es la misma (isEquivalent ya existe), no volver a orientar.

Escéptico: El registro de ANSES muestra «Activando Ver mis trámites en Mi ANSES» y «Ese control ya no está. Recargando.», y 0,3 ms después «Cargando página»: el corte no es una estimación dudosa, los dos anuncios salen casi a la vez. Después se carga la misma URL (03.txt es idéntico a 02.txt) y JEF escribe «Hola, estás en la página de la Administración Nacional…» como si fuera una página nueva. En la conversación sólo queda «Abriendo Ver mis trámites en Mi ANSES.» seguido de la orientación: la falla nunca se escribe.

### P12 · Titulares y resúmenes sin hechos

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa

Evidencia:
- «Segundo, el precio actual del dólar.», sin número, aunque 02.txt dice «Dólar oficial $1535,00 / Dólar blue $1550,00».
- Como titulares: «1. Medidas de Milei, Hace 14 min» y «2. Dólar hoy, Hace 15 min»; y «Titular 3 de 154.».
- Resumen: «Informa sobre las decisiones del Presidente, las reacciones de la oposición y las declaraciones de los funcionarios» (es la bajada de la página).
- «un informe judicial sobre el enriquecimiento de Adorni» (era un descargo de Adorni); «a todos les fue mal o muy mal, ganando Bullrich»; «las medidas de Milei de hace 20 minutos».

Causa probable: summarize() pide «Resumí de qué trata esta página en dos o tres frases», lo que invita a describir el tipo de página. orient() pide cada titular «en una frase corta y clara», y el modelo lo parafrasea como un tema. Assistant.headlines(of:) toma todo enlace con nivel de encabezado (los rótulos de la franja VIVO, con su «Hace N min») y todo ítem de listado de 25 caracteres o más: por eso 154.

Propuesta: Prompt de resumen: «Contá 2 o 3 hechos concretos (quién, qué, cuándo, cifras), el más importante primero; si es una cobertura en vivo, las últimas 3 entradas; no describas la página». En orient(), titulares casi textuales, y el dato cuando la portada lo muestra (la cotización). En headlines(of:), descartar rótulos cortos y los que terminan en «Hace N min». No dar un total poco confiable: «te leo 5, ¿seguimos?».

Escéptico: Confirmado. «Segundo, el precio actual del dólar.» sin cifra, aunque 02.txt (líneas 191-192) trae «Dólar oficial $1535,00 / Dólar blue $1550,00». Los titulares salen como «1. Medidas de Milei, Hace 14 min» y hay «Titular 3 de 154.». El resumen repite la bajada («El minuto a minuto de las decisiones del Presidente, las reacciones de la oposición…»). Aparecen «un informe judicial sobre el enriquecimiento de Adorni» (era su descargo) y «las medidas de Milei de hace 20 minutos». Un ejemplo no se sostiene: «a todos les fue mal o muy mal, ganando Bullrich» es fiel al titular real («a todos les fue entre mal y muy mal (y ganó Bullrich)»).

### P13 · Descripciones largas y con relleno, que se repiten enteras al volver

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, mercadolibre-auriculares, otra-cosa

Evidencia:
- «Antes de seguir, hay un aviso de suscripción a la vista. ¿Qué te gustaría hacer? También puedes pedirme otra cosa.»
- «Hola, estás en la página de la Administración Nacional de la Seguridad Social, que es la ANSES.»
- «También hay un aviso para suscribirte a Clarín por 930 pesos por seis meses.»
- Después de «volvé»: «Estás en la portada de LA NACION, un diario de noticias. Hay un aviso sobre una promo exclusiva para suscribirse por $1.500. Los titulares principales son: …». Son unos 40 segundos, con otros titulares, aunque 02.txt y 04.txt son idénticos.
- Mercado Libre, con la búsqueda de auriculares pendiente: «Hay varias ofertas destacadas: 1. Ofertas Glam Days en pantalones…».

Causa probable: El prompt de Answerer.orient() pide: «natural, cálido», «Nombrá el sitio y qué clase de página es», mencionar todo aviso («suscripción, cookies, newsletter») y «Terminá preguntando qué le gustaría hacer, y aclarando que también puede pedirte otra cosa». arrived() antepone «HAY UN AVISO ENCIMA DE LA PÁGINA» ante cualquier aviso, aunque no tape. orient() no recibe la historia: no sabe que ya saludó, que es una vuelta, ni qué titulares ya dijo, y no es determinista. goBack() llama a arrived() completo. accept() orienta la portada antes de seguir con la tarea pendiente (continueWith).

Propuesta: Reescribir el prompt: sin saludo, sin explicar qué es el sitio, sin pregunta final (para eso están los botones), dos o tres frases con lo esencial primero, y avisos sólo si tapan. Al volver: «Volviste a la portada de La Nación» y los mismos botones (guardar la orientación por URL; si la página cambió, «hay N titulares nuevos»). Si hay una tarea pendiente, no orientar: «Estoy en Mercado Libre, busco auriculares bluetooth».

Escéptico: Todas las citas están en las transcripciones. La Nación paso 2 cierra con «Antes de seguir, hay un aviso de suscripción a la vista. ¿Qué te gustaría hacer? También puedes pedirme otra cosa.», y en paso-02.jpg el «aviso» es sólo el botón amarillo «SUSCRIBITE POR $1.500» del encabezado, que no tapa nada. Después de «volvé», paso 6 dice otra orientación entera y con otros titulares (600 caracteres, unos 43 s), aunque paginas/02.txt y 04.txt tienen el mismo md5. En Mercado Libre, con «sigo con: buscame auriculares bluetooth» pendiente, igual dice «Hay varias ofertas destacadas: 1. Ofertas Glam Days en pantalones…». Que el script tocara el botón 1 no influye: lo que falla es el texto que arma la app.

### P14 · Con un aviso de cookies, al llegar sólo habla del aviso: ni el contenido ni un botón para cerrarlo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: clima-cordoba

Evidencia:
- «Aviso de cookies encima de la página.» (CORTADO) + «Opciones: Política de Cookies, Configuración de cookies, nuestros socios.»
- La página ya decía «Martes, 22 de septiembre Nubes y claros La mayor parte del día 36° 17°» (02.txt).
- En pantalla el cartel ofrece «ACEPTAR Y CONTINUAR» y «CONFIGURACIÓN»; en paso-03.jpg sigue tapando la página.
- Roberto: «Y esas ‘opciones’ no son botones que yo pueda tocar.»

Causa probable: Se descartó la orientación del modelo: el turno tardó unos 5 s y cayó en la plantilla describe(). Probablemente una «cifra» no coincidió letra por letra, porque la verificación de orient() descarta todo, o la respuesta vino vacía. describe(), ante cualquier aviso, dice el aviso y sus opciones y termina sin contar el contenido. Esas opciones son enlaces del texto del aviso, no sus botones, y nunca se ofrecen como botones.

Propuesta: En describe(), mencionar al final un aviso que no bloquea y seguir con el contenido. Si bloquea, sus botones reales (Aceptar, Rechazar) van primero como botones de JEF, o se cierra solo rechazando. Registrar por qué se descartó la orientación y, si fue una cifra, no tirar la respuesta entera.

Escéptico: clima-cordoba paso 2 dice sólo «Aviso de cookies encima de la página.» y «Opciones: Política de Cookies, Configuración de cookies, nuestros socios.». Los botones son [Leer la nota] [Resumir la nota] [Volver a la página anterior] [Otra cosa], ninguno cierra el aviso. Mientras tanto 02.txt ya tenía «Martes, 22 de septiembre Nubes y claros … 36° 17°». En paso-02.jpg y paso-03.jpg el cartel sigue encima y muestra «ACEPTAR Y CONTINUAR» y «CONFIGURACIÓN», que no son las opciones que se nombraron.

### P15 · Anuncios que se pisan entre sí y respuestas que se oyen dos veces

*grave* · confirmado · jueces: Marta, Roberto, Lucía · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, mercadolibre-auriculares, clima-cordoba, otra-cosa, dolar-desde-cero, wikipedia-mar-del-plata, banco-nacion

Evidencia:
- En los nueve escenarios, «Buscando: …» o «Abriendo …» CORTADO ~0% por «Cargando página».
- Anuncios técnicos: «Activando Ver mis trámites en Mi ANSES», «Enviando formulario», «Formulario enviado.», y «Volviendo.» seguido de «Volviendo».
- Marta: «el anuncio se cortó al 28 % y el foco lo volvió a leer desde el principio, así que escuché dos veces el arranque».

Causa probable: say() anuncia, y enseguida ReaderModel.go() anuncia «Cargando página» (Sources/UI/ReaderView.swift). activate(), submit() y back() tienen sus propios anuncios técnicos. Al terminar el turno, AssistantPanel mueve el foco a la última línea y VoiceOver la vuelve a leer, aunque ya se estaba anunciando. El porcentaje exacto del corte de una descripción larga depende de cuándo actuó el script; la doble lectura y los cortes simultáneos no.

Propuesta: Un solo canal por turno: o anuncio o foco, nunca los dos sobre el mismo texto. Sacar «Cargando página», «Activando», «Enviando formulario», «Formulario enviado» y el segundo «Volviendo» cuando el asistente ya dijo qué está haciendo. Si la carga tarda más de 3 s, decir «Sigo cargando».

Escéptico: En los nueve registros «Buscando…»/«Abriendo…» y «Cargando página» se anuncian en el mismo milisegundo. También aparecen «Activando Ver mis trámites en Mi ANSES» → «Ese control ya no está. Recargando.» (ANSES), «Enviando formulario»/«Formulario enviado.» (Mercado Libre) y «Volviendo.» seguido de «Volviendo» (La Nación paso 6). La doble lectura sale de que say() anuncia y el foco pasa a esa misma línea. Una salvedad: el corte al 28 % que cita Marta lo causa el paso siguiente del script (a los 24,7 s), así que ese porcentaje sí depende del arnés; lo demás no.

### P16 · Con poca vista: la conversación es una franja chica y los botones quedan escondidos

*grave* · confirmado · jueces: Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, mercadolibre-auriculares, otra-cosa, clima-cordoba

Evidencia:
- Ana: «En la pantalla la respuesta queda cortada a la mitad, en una franja chica abajo, y los botones no se ven.»
- Verificador: en las capturas paso-02, paso-04 y paso-06 no se ve ningún botón.
- Mercado Libre, paso-02.jpg: la conversación quedó en «Abriendo www.mercadolibre.com.ar.» y en la portada cortada en «3. Ofertas en accesorios con hasta un», mientras arriba ya se veía el «No soy un robot».

Causa probable: ReaderView fija la conversación en 380 puntos de alto cuando hay página (.frame(height: 380)), y los botones están dentro del ScrollView, debajo del texto. El cambio sin commitear de AssistantPanel (13:09, anterior a la corrida) desplaza la vista al comienzo de todo el turno (responseStart, la primera línea de JEF después del último pedido). En turnos de varios mensajes quedan a la vista «Abriendo…» y lo más viejo, no lo último.

Propuesta: Botones fijos justo arriba del campo de escribir, fuera del ScrollView. Más alto para la conversación que para la página, o que se pueda agrandar. Desplazar la vista al comienzo del último mensaje. Probar con el tamaño de texto más grande.

Escéptico: En paso-02, paso-04 y paso-06 de La Nación, paso-02 de otra-cosa y paso-02 a 05 de Clarín, la conversación ocupa una franja de unos 380 puntos y queda anclada en «Abriendo …». La respuesta aparece cortada a la mitad y no se ve ningún botón. En Mercado Libre paso-02.jpg el texto se corta en «3. Ofertas en accesorios con hasta un» mientras arriba está el «No soy un robot». En clima-cordoba sí se ven botones, pero eso no cambia el problema.

### P17 · Lo que se ve arriba no coincide con lo que se dice abajo

*grave* · confirmado · jueces: Ana, Verificadores · escenarios: solo-botones-clarin, turno-anses

Evidencia:
- Clarín, pasos 2 a 5: arriba se ven «Leé el diario de hoy», los íconos de redes y «Términos y Condiciones», mientras JEF dice «Hola, estás en Clarin.com, la portada de noticias de Argentina».
- Ana, ANSES: «El botón 1 no es el resultado 1 que veo arriba… Me confunde tener dos listas en distinto orden.»

Causa probable: Probable: wakeLazyContent() en Sources/Extraction/extract.js baja hasta el pie hasta cuatro veces, para despertar lo que carga al desplazar, y después hace window.scrollTo(0, 0). En Clarín la vista quedó en el pie: esa vuelta no quedó aplicada (por contenido que sigue creciendo o por un scroll que restaura el sitio). Los botones de resultados además se reordenan (ranked) y no siguen el orden visible.

Propuesta: Después de extraer, forzar la vuelta arriba desde el lado nativo (el contentOffset del scrollView del web view en cero) y verificarla, o llevar la página a la sección que se está describiendo. Marcar en la página el resultado que JEF recomienda.

Escéptico: En las capturas paso-02 a paso-05 de Clarín la página está en el pie («Leé el diario de hoy», íconos de redes y, en 2 y 3, «Términos y Condiciones») mientras JEF dice «Hola, estás en Clarin.com, la portada…». En ANSES paso-01.jpg, DuckDuckGo muestra «1. ANSES - Argentina.gob.ar» y «2. ANSES», pero el botón 1 es «ANSES — servicioswww.anses.gob.ar»: el orden de los botones no es el de la página.

### P18 · Jerga técnica y direcciones web en lo que se dice

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, mercadolibre-auriculares, wikipedia-mar-del-plata, dolar-desde-cero, otra-cosa, clima-cordoba

Evidencia:
- «Esta página no tiene texto corrido para leer.»
- «Ese control ya no está. Recargando.»; «Enviando formulario»; «pide que vayas al login»; «recuadro del proveedor».
- «una tabla con 33 filas»; «DuckDuckGo»; «Fin de la nota.» en un formulario.
- Botones con «servicioswww.anses.gob.ar», «cdnedge.lanacion.com.ar», «web-clarinsandbox.lilax.io».

Causa probable: Hay textos fijos en Sources/Intelligence/Assistant.swift (readAloud: «texto corrido», y «Fin de la nota.» para todo lo que no es portada; el aviso del captcha) y en Sources/UI/ReaderView.swift (anuncios de activate y submit). Las etiquetas de los resultados llevan el host. El texto que recibe el modelo trae «Tabla de N filas» y el nombre del buscador.

Propuesta: Una lista de palabras prohibidas con su reemplazo (login → iniciar sesión; control → botón; formulario → lo que hace; «texto corrido» → «no hay nada para leer»). Nombrar los sitios por su nombre. Decir «Fin de la página» fuera de las notas. No nombrar nunca el buscador interno.

Escéptico: Todas las frases están textuales: «Esta página no tiene texto corrido para leer.» (wikipedia paso 4), «La página no menciona cuándo se fundó DuckDuckGo.» (wikipedia paso 3), «una tabla con 33 filas» (dólar paso 3), «Fin de la nota.» después del código de imagen de ANSES, «pide que vayas al login» y «recuadro del proveedor» (Mercado Libre), y botones con «servicioswww.anses.gob.ar», «cdnedge.lanacion.com.ar» y «web-clarinsandbox.lilax.io». Es cierto que el script siguió preguntando sobre la página de DuckDuckGo después de una búsqueda fallida, pero las palabras las eligió la app.

### P19 · Contraste bajo en el campo de escribir y en los botones

*grave* · confirmado · jueces: Ana · escenarios: primera-vez, dolar-desde-cero, banco-nacion

Evidencia:
- «El campo para escribir tiene la letra en gris clarito, que casi no leo, y la flecha de enviar es gris y chiquita, parece apagada.»
- «Los botones son letras celestes sobre fondo celeste.»

Causa probable: En Sources/UI/AssistantPanel.swift, el TextField usa estilo plain sobre tertiarySystemFill, con el gris del sistema. Enviar es un símbolo arrow.up.circle.fill que queda desactivado mientras el campo está vacío. Los botones usan .foregroundStyle(.tint) sobre .tint.opacity(0.12).

Propuesta: Botones con texto oscuro o fondo lleno; campo con borde y texto de ayuda de más contraste; botón «Enviar» grande, con la palabra. Verificar contraste de 4,5:1 o más, también con «Aumentar contraste».

Escéptico: Las capturas lo muestran: en banco-nacion/paso-01.jpg y dolar-desde-cero/paso-03.jpg «Otra cosa» es texto celeste sobre fondo celeste, y el texto de ayuda «¿Qué querés hacer?» y la flecha están en gris claro. Medido sobre los píxeles de la captura, da unos 3,5:1 en el botón, 1,8:1 en el texto de ayuda y 2,1:1 en la flecha, todo por debajo de 4,5:1. El código que se probó (HEAD) usaba .foregroundStyle(.tint) sobre .tint.opacity(0.12), y el botón de enviar queda desactivado con el campo vacío.

### P20 · «Otra cosa» es un toque de más: agrega un mensaje, dice «abajo» y no lleva el cursor de VoiceOver al campo

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: dolar-desde-cero, banco-nacion, otra-cosa, wikipedia-mar-del-plata

Evidencia:
- «¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.»
- Roberto: «Tampoco sé dónde queda ‘abajo’: tuve que buscar el campo deslizando.» Tampoco le dijo que seguían en La Nación.
- Verificador: la pista «Va a esta opción» en un botón que no va a ningún lado.

Causa probable: accept() agrega ese mensaje y sube inputRequests. El panel da el foco de teclado al campo (writing = true), pero el onChange de turns.count lleva el cursor de VoiceOver a la línea nueva, no al campo.

Propuesta: Sin mensaje, o uno solo: «Escribí o dictá tu pedido. Seguimos en La Nación.». Foco de VoiceOver y teclado en el campo, y nada de «abajo».

Escéptico: En dolar-desde-cero, banco-nacion y otra-cosa, tocar «Otra cosa» agrega «Vos: Otra cosa» y «¿Qué otra cosa hacemos? Se puede escribir o dictar abajo.». En otra-cosa no dice que se sigue en La Nación, y el botón tiene la pista «(Va a esta opción)». En el código probado, onChange(turns.count) pone focused = last.id, así que el cursor de VoiceOver cae en esa línea y no en el campo; writing = true sólo pone ahí el foco del teclado. Que el script tocara el botón no es la causa: pasa igual cuando la persona lo elige, como en otra-cosa.

### P21 · Trato desparejo: tú, vos, infinitivo y «Hola» en cada página

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, banco-nacion, primera-vez, otra-cosa, turno-anses

Evidencia:
- «También puedes pedirme otra cosa.», al lado de «¿Qué querés hacer?».
- «Probar con otras palabras»; «Decir un sitio o qué buscar.»
- «Hola, estás en La Nación…» al abrir una nota, en medio de la charla.

Causa probable: Los prompts de Answerer (orient y answer) dicen «Hablá en: español» sin fijar el voseo, y piden un tono «cálido». Hay frases fijas en infinitivo en Assistant.swift («Probar con otras palabras», «Decir un sitio o qué buscar», «Indicar qué poner y lo completo», «Probar de nuevo») y en el texto inicial del panel («Escribir a dónde ir o qué buscar»).

Propuesta: Voseo e imperativo en todo texto fijo («Probá», «Decime»). En los prompts: «español rioplatense, de vos, sin saludar». Saludar sólo la primera vez.

Escéptico: Aparece textual en las transcripciones. En otra-cosa y en solo-botones-clarin dice «¿Qué te gustaría hacer? También puedes pedirme otra cosa.», mientras el campo dice «¿Qué querés hacer?» y ANSES usa «podés/tenés». Hay infinitivos: «Probar con otras palabras…» (dolar, banco, wikipedia, otra-cosa) y «Decir un sitio o qué buscar.» (primera-vez). Saluda con «Hola, estás en La Nación…» al abrir una nota a los 41 s (noticias-la-nacion) y con «Hola, estás en Clarín, en una nota…» (solo-botones-clarin).

### P22 · Botones con etiquetas largas, cortadas o que prometen de más, y sin decir cuántos hay

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, mercadolibre-auriculares, clima-cordoba, otra-cosa

Evidencia:
- «Abrir «Enriquecimiento. Adorni dijo ante la Justicia que su evolución patrimo»»; «Abrir «Medidas de Milei, Hace 14 min»».
- «(Va a esta opción)» en todos los botones, también en «Otra cosa» y «Leer la nota».
- «[Leer la nota completa]» lee 3 párrafos de 15.
- «En Vivo | Los Detalles Y El Cronograma Oficial Del Papa León Xiv a La ... — www.youtube.com».
- Marta: los titulares aparecen dos veces, como texto y como botón. Roberto: «Nunca me dice que hay opciones debajo ni cuántas son.»

Causa probable: followUps() corta en 70 caracteres (prefix(70)); present() arma «título — host»; AssistantPanel pone siempre .accessibilityHint(«Va a esta opción»); la etiqueta «Leer la nota completa» la escribe el modelo.

Propuesta: Cortar en un límite de palabra o usar una etiqueta corta por tema. Sacar la pista o hacerla específica. «Leer la nota» en vez de «completa». Decir «Tenés 4 opciones» dentro del mismo anuncio del turno. Que cada titular leído sea directamente su botón.

Escéptico: En noticias-la-nacion, paso 3, están los botones «Abrir «Enriquecimiento. Adorni dijo ante la Justicia que su evolución patrimo»» (cortado a 70 caracteres, a mitad de palabra) y «Abrir «Medidas de Milei, Hace 14 min»». Esos titulares figuran también como texto en las líneas 9 a 11 del árbol. Todos los botones tienen la pista «(Va a esta opción)», también «Otra cosa». Hay etiquetas largas con host, como «En Vivo | Los Detalles… — www.youtube.com» y «Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com». En solo-botones-clarin, «Leer la nota completa» termina en «Párrafo 3 de 15.». Ninguna respuesta sobre una página dice cuántas opciones hay. Son hechos de la app, no de que el script tocara el primer botón.

## Lo que funciona

- Ubicar al llegar: «Estás en la portada de LA NACION» dice dónde se está enseguida (Marta, Roberto; también en otra-cosa).
- «volvé» anduvo rápido en todos los casos y dejó en la portada (Marta, Roberto, Lucía, Ana): goBack().
- Recordar la segunda mitad del pedido: «Cuando elijas, sigo con: buscame auriculares bluetooth.», y seguir solo después de elegir (waiting más continueWith). Lo destacaron los cuatro jueces; es el patrón que piden para todo.
- No inventar: cuando no tenía el dato lo dijo («No pude leer…», «La página no menciona si va a llover…», «La página actual no muestra información sobre precios…»). Todo dato que dio estaba en la página, según los verificadores; la verificación de cifras del Answerer sirve.
- Botones de portada con un nombre corto por tema («Abrir noticia de Adorni», «Abrir noticia de Carlos Alonso»): fáciles de recorrer.
- Los botones después de leer o resumir: «Seguir con los titulares», «Seguir leyendo», «Resumir la nota», «Volver a la página anterior» (followUps).
- Lectura textual y en orden de la nota, con contador exacto (15 párrafos en 04.txt). Es útil cuando no se pisa y cuando se ve (Ana).
- Resúmenes concretos cuando la página es una nota de verdad: la Marcha del Orgullo, y la portada de Clarín con cuatro titulares con datos.
- Honestidad ante los límites: «Eso no lo puedo resolver yo» ante el captcha, y el código en imagen de ANSES bien descripto.
- Los resultados de búsqueda son reales y sin anuncios, y el primero fue el correcto en La Nación, Clarín y Mercado Libre. La región ar-es en la búsqueda ayuda.
- Velocidad: 3 o 4 segundos por paso. Las respuestas cortas se oyen y se leen enteras (clima paso 3, primera vez).
- «Otra cosa» deja el cursor de escritura en el campo con el teclado abierto (Ana) y permite cambiar de idea (Lucía, Roberto).
- Visual: burbujas nítidas, el pedido a la derecha y la respuesta a la izquierda; sin página, la conversación ocupa toda la pantalla (Ana).
- Con una página cargada, toda respuesta terminó con botones y «Otra cosa» (verificadores): la regla anda donde hay página.
