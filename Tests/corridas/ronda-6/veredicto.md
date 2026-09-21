# Veredicto — ronda-6

Cuatro jueces en 12 escenarios dan 48 juicios de logro: 27 «sí», 13 «a medias» y 8 «no». El promedio general es 3,5 sobre 5. Nadie sacó el turno de ANSES (2,55) ni supo el precio en Mercado Libre (2,6). En los dos casos el camino se cortó en una prueba anti-robot: en ANSES la prueba no existía (era el distintivo del reCAPTCHA invisible) y en Mercado Libre el aviso quedó en cola detrás de la descripción de la portada. El mejor escenario fue banco-nacion (4,55), seguido de anti-robot-avanza-sola (4,2) y primera-vez (3,95). Hay tres causas de fondo que se repiten. Primero, botones y palabras salen de lugares distintos: el casillero «para lo que viniste» de arrived() va primero sin verificar nada, el modelo parafrasea los titulares, y closeTurn/followUps cortan a 4 o 3 opciones, así que «Volver» es lo primero que se cae. Segundo, cualquier página con encabezados-enlace se trata como portada de diario (headlines/readsHeadlines): así salen «titulares» que son categorías, trámites cortados a cuatro y «Leer los titulares» en una cotización. Tercero, todo se dice en cola: lo que bloquea (una prueba, un error, la memoria de la tarea) espera detrás de descripciones largas. A eso se suman dos errores puntuales: el «Sin conexión» falso, que sale del catch genérico de run(), y el pronóstico en Fahrenheit, que probablemente se explica porque el WebView se presenta en inglés (el proyecto sólo declara la región en). Descarté lo que es sólo del script: el corte al 67 % del primer anuncio de primera-vez (lo cortó el toque del script) y el «localhost» de los escenarios anti-robot (es el servidor de prueba). También descarté el corte puntual de titulares y párrafos cuando el script tocó mientras sonaban, pero dejé el problema de fondo: «Seguir leyendo» avanza sobre lo que no se oyó. Archivos clave: /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/Extraction/extract.js, /Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift y /Users/daniel/Developer/JEF- BROWSER/Sources/UI/ReaderView.swift.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.1 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| dolar-desde-cero | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.4 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.6 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 2.5 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.6 |
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.5 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 4.0 |
| clima-cordoba | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.2 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.2 |
| anti-robot-ya-la-resolvi | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |

**Promedio general: 3.52**

## Problemas

### P01-prueba-inalcanzable · La prueba anti-robot se señala con palabras («arriba; con VoiceOver, antes de esta conversación») y no hay forma de llegar a ella

*bloqueante* · del script de prueba · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: mercadolibre-auriculares, turno-anses, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- Pasa en los cuatro escenarios con prueba: «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.»
- Botones de mercadolibre, pasos 2 y 3: [Ya la resolví] · [Volver a la página anterior] · [Otra cosa]. Ninguno lleva a la prueba.
- Roberto: «No sé llegar “arriba, antes de esta conversación”. Yo sólo deslizo… Me quedé trabado.» También: «Las opciones son «Ya la resolví», que para mí sería mentir, «Volver» y «Otra cosa».»
- Ana, que no usa VoiceOver: «Lo de VoiceOver no es para mí y me hace dudar de si tengo que prender algo. Tampoco dice qué hay que hacer en la prueba.»
- Lucía y el verificador 2: «me pide» da a entender que la prueba es para JEF. Nunca dice claro que la resuelve la persona.

Causa probable: askToSolve() (Assistant.swift) sólo dice un texto fijo, y nombra VoiceOver sin mirar UIAccessibility.isVoiceOverRunning. Para una prueba, followUps() ofrece únicamente «Ya la resolví» y «Volver». No existe ninguna acción que desplace la página hasta el recuadro ni que mueva el cursor de VoiceOver al WebView: en el código no hay un UIAccessibility.post(.layoutChanged/.screenChanged) apuntando a la página ni un scrollIntoView del iframe de la prueba. Además la conversación ocupa fijo el 55 % de la pantalla (ReaderView: max(380, alto × 0,55)), así que la página queda en una franja chica.

Propuesta: 1) Poner primero un botón «Ir a la prueba». Del lado de la página, que haga scrollIntoView({block: center}) del iframe que encontró detectChallenge; del lado de la app, UIAccessibility.post(notification: .layoutChanged, argument: webView), para que VoiceOver quede en la página a la altura de la prueba. 2) Mientras haya una prueba pendiente, achicar la conversación a cerca de un tercio para que el recuadro se vea entero. 3) Reescribir el aviso: «Esta página pide demostrar que no sos un robot, y eso lo hacés vos. Tocá «Ir a la prueba»: tiene opción de audio.» Mencionar VoiceOver sólo si está prendido; sin VoiceOver, decir «tocá el cuadrito No soy un robot, arriba». 4) Agregar «Buscarlo en otro sitio» como alternativa y dejar «Ya la resolví» después.

Escéptico: Que sea «inalcanzable» no se sostiene. WebPageView es el WKWebView tal cual, sin accessibilityHidden, y va antes del panel en el mismo VStack (ReaderView). En paso-02.jpg de mercadolibre y en paso-01.jpg de los dos fixtures el recuadro «No soy un robot» se ve entero arriba. Los jueces se sintieron «trabados» porque el arnés sólo lista los elementos de la conversación. Lo que sí es cierto, aunque no bloquea: la prueba se señala sólo con palabras, el texto nombra VoiceOver siempre (askToSolve) y followUps no ofrece más que «Ya la resolví» y «Volver».

### P02-prueba-falsa-anses · En ANSES avisó una prueba anti-robot que no existía (el distintivo del reCAPTCHA invisible) y no dijo dónde había quedado la persona

*bloqueante* · confirmado · jueces: Verificador 1, Roberto, Ana, Lucía, Marta · escenarios: turno-anses

Evidencia:
- Paso 4, después de «Abriendo «CONSULTAR TURNO»»: «El sitio web me pide resolver una prueba anti-robot… Cuando esté resuelta, continuamos.» y «Tiene una opción de audio, dentro del recuadro de la prueba.» Botones: [Ya la resolví] · [Volver a la página anterior] · [Otra cosa].
- Verificador 1: en paso-04.jpg no hay ninguna casilla «No soy un robot», sólo el logo de reCAPTCHA asomando en el borde. paginas/05.txt es un formulario común: «FORMULARIO que pide: CUIL, Número de solicitud — botón «Continuar»».
- Ana: «Miré arriba y no hay ningún recuadro… No tengo cómo resolverla.» Roberto: «Me quedé trabado.»
- Ana: «No me avisó que esta página es para consultar un turno ya pedido, ni que pide CUIL y número de solicitud, que yo no tengo.»

Causa probable: detectChallenge() (extract.js) toma como muro cualquier iframe de reCAPTCHA visible en una página que tenga 12 controles o menos. El distintivo del reCAPTCHA invisible, un iframe con size=invisible fijo en una esquina, pasa ese filtro en un formulario chico. Con overlay.kind == .captcha, arrived() corta enseguida por describe() → askToSolve(), y nunca dice qué página es ni qué pide.

Propuesta: En detectChallenge, descartar el iframe si su src trae size=invisible, si está dentro de .grecaptcha-badge o si tiene la forma del distintivo (unos 256×60, fijo abajo a la derecha). Tratar la página como muro sólo si hay texto de prueba («no soy un robot», «completá este paso») o un iframe anchor visible dentro del contenido. Y en arrived(), aun con prueba, decir primero dónde está: «Estás en Consulta de turnos solicitados: pide CUIL y número de solicitud. Sirve para un turno ya pedido.», con «Volver a pedir turno».

Escéptico: En turno-anses/paso-04.jpg no hay ninguna casilla, sólo el logo de reCAPTCHA en el borde derecho. paginas/05.txt es un formulario común («FORMULARIO que pide: CUIL, Número de solicitud»). Ese formulario tiene menos de 12 controles, y detectChallenge (extract.js 2360-2365) en ese caso toma el distintivo visible como muro. Por eso JEF dijo «me pide resolver una prueba anti-robot» y no dijo qué página era.

### P03-primer-boton-casillero-objetivo · El primer botón lo pone un casillero «para lo que viniste» que no respeta ni el objetivo ni lo dicho: una nota no nombrada en Clarín, «CONSULTAR TURNO» para quien quiere sacar uno

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: solo-botones-clarin, turno-anses

Evidencia:
- Clarín, paso 2: dijo «Los titulares principales son: Alejandro Vilches renunció… Adorni dijo… Se analizan quiénes ganan… El Gobierno espera…» y el primer botón fue [Abrir «Cinco grandes cadenas de TV de EE.UU. suspenden la cobertura de la…»]. Tocándolo, se abrió esa nota.
- ANSES, paso 3: el primer botón fue [Abrir «CONSULTAR TURNO»], aunque el mismo mensaje dice «También te ofrece opciones para consultar o reprogramar turnos ya sacados». Llevó a «Consulta de turnos solicitados».
- Lucía: «Como toco siempre la primera opción, abrí algo que nunca escuché mencionar.» Roberto: «Quiero SACAR un turno y lo primero que me ofrece es consultar uno que no tengo.»

Causa probable: En arrived() (Assistant.swift), cuando la página tiene «titulares», los botones se arman como forGoal + named + el resto. forGoal es la primera sugerencia «abrir» del modelo que no esté entre los cuatro titulares nombrados, y va adelante siempre. Pasa aunque la persona haya venido sólo al sitio («clarín» se le pasa al modelo como LA PERSONA VINO A), y sin verificar que la sugerencia sirva al objetivo ni que se haya dicho en voz alta. En ANSES el modelo propuso «CONSULTAR TURNO» y el código lo puso primero, por delante de los trámites.

Propuesta: 1) Llenar forGoal sólo si hay una tarea de verdad: un rest/waiting, o un pedido que no sea sólo el nombre del sitio. 2) Llenarlo sólo con algo que la orientación haya nombrado en el texto. Sin eso, los botones son exactamente los titulares dichos, en su orden. 3) Cuando hay tarea, descartar sugerencias que contradicen el verbo: consultar, reprogramar o cancelar cuando se pidió sacar o pedir. 4) En una página de trámites, preguntar «¿Para qué trámite es el turno?» con los trámites como botones, y dejar «Consultar un turno que ya tengo» al final.

Escéptico: En Clarín, paso 2, la voz nombró cuatro titulares y el primer botón fue «Cinco grandes cadenas de TV…», que nunca se dijo. En ANSES, paso 3, el primer botón fue «Abrir «CONSULTAR TURNO»» para quien quería sacar un turno. Viene de Assistant.swift 2201-2202: forGoal (la primera sugerencia «sug-» que no es un titular) va siempre adelante. El toque fue mecánico, pero lo que falla es el orden de las opciones, y eso es de la app.

### P04-repregunta-a-otra-lista · «¿Y el oficial?» no se contesta: termina en otra lista del buscador

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: dolar-desde-cero

Evidencia:
- Paso 3: «Buscando: Dólar oficial Dolarhoy.com.» y después «Estás en los resultados de «Dólar oficial Dolarhoy.com». Los 3 más probables: 1. Dólar Oficial, Cotización del dólar oficial | Dolarhoy.com, dolarhoy.com…»
- Botones del paso 2: [¿A cuánto está el dólar mayorista?] · [¿A cuánto está el dólar MEP?] · [Leer los titulares] · [Resumir la portada]. No está «¿Y el oficial?».
- Verificador 1: el resultado 11 de paginas/03.txt ya traía «Dólar BNA… Venta $1.535,00 Compra $1.485,00». La pregunta quedó sin responder.
- Lucía: «Terminé sin saber cuánto está el oficial.»

Causa probable: La página del blue (paginas/02.txt) no tiene el oficial, así que answerer.answer devuelve nil. Entonces carry(.buscar) cae en arrive(), que por diseño nunca abre un resultado: sólo presenta la lista. pendingQuestion queda guardada y contestaría al elegir, pero no se dice. Y el primer resultado era del mismo sitio en el que la persona ya estaba. La consulta se lee tal cual la armó el ruteador («Dólar oficial Dolarhoy.com»). Además, Answerer limita las preguntas siguientes a lo que «ESTA página contesta», por eso nunca podía ofrecer el oficial.

Propuesta: 1) Antes de salir de la página, buscar entre sus enlaces uno del mismo sitio cuyo texto nombre lo pedido («oficial»), abrirlo y contestar. 2) Si hay que ir al buscador y el primer resultado es del mismo host que la página actual, abrirlo directo y contestar con pendingQuestion («En Dolarhoy, el oficial está a…»), con «Ver otras fuentes» como botón. 3) Decir la búsqueda en castellano: «Busco el dólar oficial en Dolarhoy». 4) Permitir que entre las preguntas sugeridas esté la hermana obvia («¿Y el oficial?»), aunque para contestarla haya que ir a buscar.

Escéptico: En el paso 3, a «¿y el oficial?» respondió «Buscando: Dólar oficial Dolarhoy.com.» y terminó en «Estás en los resultados…», sin cifra y sin avisar que contestaría al elegir. Es cierto que paginas/02.txt no trae el oficial y que el resultado 11 de paginas/03.txt sí trae «Dólar BNA… Venta $1.535,00». El escenario termina ahí, pero en ese paso la app no contestó.

### P05-unidades-y-formatos · El pronóstico salió en Fahrenheit y millas sin avisar («40º y 63º», «13 mph»), y las horas en formato inglés («21/09/26 a las 05:28 PM»)

*grave* · del script de prueba · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: clima-cordoba, dolar-desde-cero

Evidencia:
- «Mañana en Córdoba, la temperatura mínima será de 40º y la máxima de 63º… el viento soplará desde el NE a una velocidad media de 13 mph.»
- paginas/02.txt de clima: «Viento NE 13 mph», «Lluvias 0 in», «Visibilidad, 6 mi», «12:00 AM». La página está en unidades imperiales.
- Dólar: «Esta cotización se actualizó por última vez el 21/09/26 a las 05:28 PM.»
- Roberto: «Cuarenta grados de mínima en Córdoba me suena a disparate.» Lucía: «Suena inventado.» Ana: «me asustó».
- Comprensión 2 o 3 y confianza 2 en los cuatro jueces del clima.

Causa probable: El sitio sirvió la página en unidades imperiales y con reloj de 12 horas. Lo más probable es que el WebView se presente en inglés: el proyecto sólo declara la región en (knownRegions = Base, en, sin localización es), y WebKit arma el Accept-Language con los idiomas de la app. Es el mismo motivo por el que Answerer tuvo que leer aparte el idioma del teléfono. La página escribe «63º» sin «F», así que la regla de Answerer («decí la unidad tal como está en la página») no alcanza. En el código no hay conversión de unidades, y forEar sólo quita los «,00».

Propuesta: 1) Declarar la localización castellana en el proyecto (es, es-AR en knownRegions y CFBundleLocalizations) y verificar el Accept-Language que manda el WebView. 2) En código, como red: si el texto de la página trae mph, in, mi o °F, convertir a °C y km/h antes de pasárselo al modelo, o marcarlo («63º Fahrenheit, unos 17 °C»). 3) Decir horas y fechas en forma hablada desde forEar: «actualizado hoy a las 17:28».

Escéptico: Los °F y las mph salieron de verdad: la caché del simulador guarda el HTML con «var units = "f"». Pero la causa es la IP de la Mac de pruebas (Miami, EE.UU.), no el idioma de la app. Con Accept-Language es-AR y navegador, el sitio devuelve «f» desde esta IP y «c» con X-Forwarded-For de Argentina. Una persona en Argentina habría recibido °C. Lo único propio de la app es repetir «21/09/26 a las 05:28 PM» tal cual lo escribe dolarhoy, y eso es menor.

### P06-sin-conexion-falso · «Sin conexión. No puedo navegar a ningún lado.» con la página cargada y la red andando, cuando se pidió «dame los titulares»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion

Evidencia:
- Paso 3: a «dame los titulares» contestó «Sin conexión. No puedo navegar a ningún lado.», con [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] al lado.
- Paso 4: [Leer los titulares] anduvo al instante («Titulares 1 a 3 de 142:»). En el paso 6 navegó sin problema.
- Roberto: «me asusto y pienso que rompí algo». Lucía: «Después de esto dudo de todo lo que me dice.» Los cuatro jueces le pusieron confianza 2.

Causa probable: En run() (Assistant.swift), cualquier error de analyzer.nextStep se dice «Sin conexión. No puedo navegar a ningún lado.»: HTTP, decodificación o red, da igual. El pedido llegó a run() porque el ruteador no lo mandó a leer: lo mandó a abrir, o no devolvió decisión. Y la llamada a Jev sobre la portada falló; el registro no guarda el motivo. reply() ya distingue transporte de otros errores; run() no.

Propuesta: 1) En run(), decir «Sin conexión» sólo ante JevError.transport. Para cualquier otro error, «No pude decidir a dónde ir», con failedTurn = true para que aparezca «Intentar de nuevo». 2) En las instrucciones del ruteador, sumar que «dame / decime / leeme los titulares» es leer. 3) En carry(.abrir), si la referencia es genérica («los titulares») y la página es una portada, leer en vez de caminar.

Escéptico: En el paso 3, a «dame los titulares» contestó «Sin conexión. No puedo navegar a ningún lado.». Un momento antes el ruteador acababa de contestar, y en el paso 6 navegó sin problema. En run() (Assistant.swift 1546-1549) cualquier error de analyzer.nextStep se dice «Sin conexión», y además el pedido no se mandó a leer.

### P07-hablar-de-mas-en-cola · Lo importante llega tarde o no llega: descripciones largas con una tarea en curso, y mensajes encadenados que esperan detrás

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: mercadolibre-auriculares, turno-anses, solo-botones-clarin, noticias-la-nacion

Evidencia:
- Mercado Libre, paso 2: «Estás en Mercado Libre Argentina, en la portada. Para encontrar auriculares bluetooth, tenés el campo de búsqueda… Hay un aviso sobre cookies.» Son unos 24 s. Detrás quedaron en cola «Sigo con: buscame auriculares bluetooth.», «Buscando auriculares bluetooth en mercadolibre.com.ar.», el aviso de la prueba anti-robot y «Tiene una opción de audio…». Todos terminaron DESCARTADOS.
- Mercado Libre, paso 3: la persona pregunta el precio sin saber que había una prueba. Lucía: «pregunté el precio sin saber que la página estaba bloqueada».
- ANSES, paso 1: «Cuando elijas, sigo con: sacar un turno.», dicho después de la lista, quedó DESCARTADO. Paso 2: «No es claro cuál. ¿Turnos? También encuentro Turnos.» también quedó DESCARTADO.
- Clarín, paso 2: más de 30 s de titulares antes de poder hacer algo (Roberto). Ana: «Fueron cinco burbujas seguidas en un solo paso.»
- Nota: cuál anuncio se descartó depende de cuándo tocó el script. Pero aun esperando, el aviso de la prueba en Mercado Libre habría empezado unos 20 s después de que la prueba apareció.

Causa probable: say() pone todo en la cola de VoiceOver. Sólo lo primero después de un pedido interrumpe (heard() → interruptNext); askToSolve() no lo hace, así que el aviso que bloquea espera a que termine la descripción de una portada que ya no está. Con una tarea pendiente (waiting/rest), accept() llama a landed() → arrived(), que es la orientación completa del modelo, antes de continueWith(). Y el modelo, que no sabe que JEF va a seguir solo, explica cómo hacerlo a mano. En ask(), «Cuando elijas, sigo con…» se dice después de la lista, y continueWith() suma «Sigo con:» como mensaje aparte.

Propuesta: 1) Con una tarea pendiente, no orientar: una línea («En Mercado Libre. Busco auriculares bluetooth.») y seguir. 2) Los avisos que cambian la situación (prueba, error, página nueva inesperada) con interruptNext = true. 3) La memoria de la tarea va delante: «Para sacar el turno, primero elegí el sitio de ANSES: 1…». 4) Juntar «Sigo con / Buscando / Abriendo» en un solo anuncio y una sola burbuja que se va reemplazando. 5) Poner tope a la orientación de una portada: tres titulares cortos.

Escéptico: En registro.jsonl de Mercado Libre, la orientación de la portada (351 caracteres, unos 25 s) sale a los 20,5 s con cola=true. Detrás esperan «Sigo con…», «Buscando…» y el aviso de la prueba, que también sale con cola=true a los 24,9 s: askToSolve() nunca pone interruptNext. Aunque el script hubiera esperado, el aviso habría empezado hacia los 52 s, unos 27 s después de aparecer la prueba (el juez dijo 20). Algunos DESCARTADO sí dependen de cuándo tocó el script: «No es claro cuál» en ANSES habría sonado 0,3 s después del toque. La cita de las «cinco burbujas» no corresponde a Clarín, que tuvo 2 en ese paso; sí a Mercado Libre, paso 2.

### P08-turnos-duplicados · Dos botones idénticos, «Turnos» · «Turnos», que además reemplazaron las opciones que acababa de ofrecer

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: turno-anses

Evidencia:
- Paso 2: «Estás en la portada de ANSES. Para sacar un turno, tenés la opción de 'Turnos'.», con [Abrir «Turnos»] · [Abrir «Clave de la Seguridad Social»] · … Un segundo después: «Sigo con: sacar un turno.» y «No es claro cuál. ¿Turnos? También encuentro Turnos.», con [Turnos] · [Turnos] · [Volver a la página anterior] · [Otra cosa].
- Verificador 1: en paginas/02.txt uno es el «Turnos» del contenido y el otro el del menú.
- Lucía: «Primero me dijo muy seguro «tenés la opción de 'Turnos'» y después que no sabe cuál.»

Causa probable: Después de orientar, accept() sigue con continueWith(rest) aunque la orientación ya haya puesto el botón que servía. El ruteador manda «sacar un turno» a abrir → run(), y Jev reparte la confianza entre dos enlaces con el mismo texto (menú y contenido), por debajo de 0,7. La rama .ask de run() ofrece los dos candidatos sin mirar si se llaman igual o van al mismo lugar, y pisa la oferta anterior.

Propuesta: 1) En la rama .ask de run(), juntar los candidatos con el mismo href o el mismo texto. Si van al mismo lugar, tocar ése sin preguntar; si no, distinguirlos por región o destino («Turnos, del menú» / «Turnos, en la página»). 2) Si la orientación ya ofreció una opción que coincide con la tarea pendiente, tocarla (o dejarla primera) en vez de volver a rutear.

Escéptico: En el registro, a los 20,5 s se ofrece [Abrir «Turnos»]…; al segundo, a los 21,5 s, la oferta se reemplaza por ['Turnos', 'Turnos'] junto con «No es claro cuál. ¿Turnos? También encuentro Turnos.». En paginas/02.txt hay dos «Turnos»: la línea 17, en el contenido, y la 35, en el bloque de menú. La rama .ask de run() arma los botones con los dos candidatos sin compararlos.

### P09-prueba-misma-pagina · Si la prueba se resuelve sin cambiar de dirección, JEF no se entera y se queda callado después de prometer «continuamos»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: anti-robot-ya-la-resolvi

Evidencia:
- Paso 1: «Cuando esté resuelta, continuamos.» Paso 2: 15 s sin ningún mensaje, con los mismos [Ya la resolví] · [Otra cosa], mientras paso-02.jpg ya muestra los auriculares con precios.
- Recién con [Ya la resolví], en el paso 3, dijo «Listo, ya pasamos la verificación.» En anti-robot-avanza-sola, donde la dirección cambia, siguió solo.
- Lucía: «La frase me hace esperar que siga sola… sin mi nieta al lado me habría quedado esperando.»

Causa probable: El aviso depende de pageChanged(), que sólo llega si el extractor vuelve a leer la página. Sin navegación, lo único que mira es el observador tardío de extract.js, que exige un cambio de 20 nodos o más (LATE_THRESHOLD) y se apaga a los 90 s (LATE_WINDOW_MS). Cambiar la prueba por tres productos no llegó a ese umbral, así que la página nunca se volvió a leer.

Propuesta: 1) Mientras challenge != nil, releer la página cada 2 o 3 s (reader.reread()) hasta que hasChallenge dé falso, con un tope de algunos minutos. Otra opción: que extract.js vigile específicamente el iframe o el texto de la prueba y avise cuando desaparece. 2) Si no se puede vigilar, que el texto no prometa: «Cuando la resuelvas, tocá «Ya la resolví»».

Escéptico: Después de «Cuando esté resuelta, continuamos.», el paso 2 no tiene ningún mensaje, y paso-02.jpg ya muestra los tres auriculares con precios. Recién con [Ya la resolví] dijo «Listo, ya pasamos la verificación.». El fixture cambia el contenido sin navegar; ese cambio pesa unos 16 nodos, menos que LATE_THRESHOLD = 20, así que extract.js no volvió a leer la página. El umbral y la ventana de 90 s son de la app, no del script. En anti-robot-avanza-sola, donde cambia la dirección, siguió solo.

### P10-buscador-antes-de-ir · Nombrar un sitio conocido o preguntar un dato siempre pasa por una lista del buscador, mientras que el botón «Llevame a La Nación» va directo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, mercadolibre-auriculares, turno-anses, banco-nacion, dolar-desde-cero, clima-cordoba

Evidencia:
- «llevame a la nación» dio «Buscando: la nación.» y después «Los 3 más probables: 1. … lanacion.com.ar. 2. LN+ EN VIVO…, youtube.com. 3. La Nacion, ingresar.lanacion.com.ar». En primera-vez, el botón [Llevame a La Nación] abrió directo.
- «entrá a mercado libre…» ofreció mercadolibre.com.ar, mercadolibre.com y listado.mercadolibre.com.ar. «clarín» ofreció clarin.com, kiosco y Wikipedia.
- A «¿a cuánto está el dólar blue hoy?» le presentó una lista cuyo resultado 2 ya decía «Dólar Blue Hoy $1550».
- Marta: «con las mismas palabras, escribiendo me toca un paso de más». Lucía: «es inconsistente».

Causa probable: Es una decisión explícita de arrive(): «Un buscador nunca navega solo: muestra la lista». Se tomó después de tres errores reales (anses.fr, La Nación de Costa Rica, una página interna de ANSES con captcha). El botón de inicio no pasa por ahí porque tiene el href escrito en starters. Para las preguntas, pendingQuestion ya contesta sola apenas se elige un resultado, pero igual hay que elegir.

Propuesta: Abrir directo sólo cuando la prueba es fuerte; en cualquier otro caso, seguir listando. La prueba fuerte es que se cumplan las cuatro condiciones: (a) el nombre registrado del dominio coincide exacto con lo nombrado (labels(of:) contiene flatten(pedido): lanacion, clarin, mercadolibre); (b) el sitio es del país de la persona (closer == 2); (c) es la portada (depth == 0); (d) no hay otro resultado exacto de otro dominio. Así se habrían abierto La Nación, Clarín y Mercado Libre, y ANSES y el banco habrían quedado en lista; los casos que salieron mal antes no pasan (b) ni (c). Para una pregunta de un dato (pendingQuestion), abrir el primer resultado del país y contestar, con «Ver otras fuentes» como botón. Decir «Abriendo La Nación», igual que el botón de inicio.

Escéptico: «llevame a la nación» dio «Buscando: la nación.» y una lista con lanacion.com.ar, youtube.com e ingresar.lanacion.com.ar. En primera-vez, [Llevame a La Nación] fue directo: «Abriendo lanacion.com.ar.». Mercado Libre, Clarín, el dólar (con «Dólar Blue Hoy $1550» como resultado 2), el clima y el banco también pasaron por una lista. Es una decisión explícita del código, en arrive(): «Un buscador nunca navega solo: muestra la lista».

### P11-dicho-distinto-de-botones · Lo que se dice no es lo que se ofrece: titulares parafraseados, un botón que empieza con una cita rota y volantas leídas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, primera-vez, otra-cosa, solo-botones-clarin

Evidencia:
- En noticias, primera-vez y otra-cosa, el botón es [Abrir «A partir de este momento”. Renunció el secretario de Discapacidad en…»], con una comilla de cierre suelta, mientras lo dicho fue «renunció el secretario de Discapacidad…».
- «Leer los titulares»: «2. Escalada. Las grandes cadenas de TV…» y «3. Interruptor L46. Un gas contaminado…».
- otra-cosa: dijo «Renunció el secretario de Discapacidad por recortes en el gobierno… Y habrá tres misas…»; el título real es «…en medio de la interna del Gobierno por los recortes» (Verificador 2).
- Clarín: dijo «Alejandro Vilches renunció como secretario de Discapacidad…» y el botón es «Renunció el secretario de Discapacidad en medio de la interna por los…».

Causa probable: dekick() sólo quita volantas de hasta 4 palabras. «“A partir de este momento”.» tiene 5 y va entre comillas, así que queda. readablePieces(), que lee los titulares, no pasa por dekick(). Y lo que se dice al llegar lo redacta el modelo en orient(), que parafrasea aunque se le pida «nombrá estos y en este orden». Eso contradice la regla del propio archivo: «ni una palabra de lo que el asistente dice la escribe un modelo».

Propuesta: 1) Que el código arme la lista hablada de titulares con los mismos textos de los botones (dekick + short). El modelo aporta sólo la frase de lugar («Estás en la portada de La Nación.»). 2) Ampliar dekick() para una volanta entre comillas o de hasta unas 6 palabras, y limpiar comillas desparejas. 3) Usar dekick() también en readablePieces() y en describe().

Escéptico: El botón es 'Abrir «A partir de este momento". Renunció el secretario…»', con una comilla recta suelta (no ” como dice la evidencia): dekick() no quita esa volanta porque tiene 5 palabras. «Leer los titulares» dice «2. Escalada. …» y «3. Interruptor L46. …». En otra-cosa se dijo «Renunció el secretario de Discapacidad por recortes en el gobierno». En Clarín se dijo «Alejandro Vilches renunció…», y además el primer botón, «Cinco grandes cadenas…», no se nombró.

### P12-todo-es-portada · Toda página con encabezados-enlace se trata como portada de diario: «titulares» que son categorías y avisos legales, trámites cortados a cuatro, «Leer los titulares» en una cotización

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: mercadolibre-auriculares, turno-anses, dolar-desde-cero, otra-cosa, wikipedia-mar-del-plata

Evidencia:
- Mercado Libre: «También veo estos titulares principales: Accesorios para Vehículos, Electrodomésticos y Aires Ac., Cómo cuidamos tu privacidad, e Información al usuario financiero.» Encima, el campo de búsqueda se ofreció como [Abrir «Ingresá lo que quieras encontrar»].
- ANSES, paso 3: «…te aparecen como opciones: Plan de Pago de Deuda Previsional…, Solicitud de Jubilación, Solicitud de Pensión y Pensión no Contributiva por Invalidez Laboral.» Según el verificador 1, la página tiene 18 trámites, y faltan «Trámites Jubilados y Pensionados» y «Pensión Universal para Adultos Mayores».
- Dolarhoy: [Leer los titulares] · [Resumir la portada]. Deportes: [Resumir la portada]. Wikipedia: [Leer la nota] · [Resumir la nota].
- Ana: «Eso no son titulares: son categorías y avisos legales. Suena a que no entendió la página.»

Causa probable: headlines(of:) cuenta como titular cualquier enlace-encabezado de 20 letras o más y cualquier ítem de listado de 25 o más. readsHeadlines() es simplemente «no es nota y tiene algún titular». Con eso, arrived() le pasa al modelo «TITULARES PRINCIPALES, EN ORDEN (nombrá estos y en este orden, nada más de la portada)» con los cuatro primeros en el orden de la página: categorías y pie en Mercado Libre, los primeros cuatro trámites en ANSES. followUps() y la rama de notas usan etiquetas fijas («Leer los titulares», «Resumir la portada», «Leer la nota») sin mirar qué clase de página es.

Propuesta: 1) Reservar el modo portada para sitios de noticias: muchos titulares con bajada o fecha, o og:type / NewsArticle. Excluir los enlaces de nav y footer. 2) En otras páginas, no forzar «nombrá estos cuatro»: que la orientación nombre lo que sirve al objetivo y diga cuántos hay («hay 18 trámites; los más pedidos son…», con «Ver todos»). 3) Etiquetas según el tipo de página (portada, sección, nota, artículo, cotización, tienda): «Resumir la sección», «Leer el artículo». 4) Un campo de búsqueda se ofrece como «Buscar», no como «Abrir».

Escéptico: En Mercado Libre dijo «titulares principales: Accesorios para Vehículos, … Cómo cuidamos tu privacidad, e Información al usuario financiero» y ofreció el campo como [Abrir «Ingresá lo que quieras encontrar»]. En ANSES nombró 4 trámites, y paginas/04.txt lista 18: faltan «Trámites Jubilados y Pensionados» y «Pensión Universal para Adultos Mayores». En dolarhoy.com/cotizaciondolarblue ofreció [Leer los titulares] · [Resumir la portada]; en Deportes, [Resumir la portada]; en Wikipedia, [Leer la nota] · [Resumir la nota].

### P13-volver-y-abrir-faltan · «Volver» aparece y desaparece, y faltan los botones para abrir lo que se acaba de nombrar

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: noticias-la-nacion, dolar-desde-cero, wikipedia-mar-del-plata, clima-cordoba, otra-cosa, primera-vez, anti-robot-ya-la-resolvi, anti-robot-avanza-sola

Evidencia:
- Noticias, pasos 4 y 5: [Abrir …] · [Seguir con los titulares] · [Otra cosa]. Falta «Volver», que en el paso 2 estaba.
- Dólar, paso 2: [¿A cuánto está el dólar mayorista?] · [¿A cuánto está el dólar MEP?] · [Leer los titulares] · [Resumir la portada] · [Otra cosa]. En Wikipedia (paso 3) y en clima tampoco aparece «Volver».
- otra-cosa, paso 4: leyó tres notas de Deportes y ofreció [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa]. Ningún «Abrir».
- primera-vez, paso 3: [Leer los titulares] · [Resumir la portada] · [Otra cosa]. Desaparecieron los «Abrir…».
- anti-robot-ya-la-resolvi, paso 3: [Leer la página] · [Resumir la página] · [Otra cosa]. No se puede abrir ninguno de los tres productos, que son enlaces.

Causa probable: closeTurn() corta a 4 opciones y pone primero las preguntas del modelo. followUps() corta a 3 con «Volver» al final, así que «Volver» es lo primero que se cae; y en la rama de titulares recién leídos, followUps() hace return antes de agregarlo. Los «Abrir…» sólo se ofrecen si lo último fue readAloud (lastDone == readID y lastChunk). La llegada a Deportes salió por describe(), la plantilla que se usa cuando la orientación del modelo no vuelve o no pasa la verificación; ni describe() ni la respuesta a orientar dejan lastChunk. Tampoco la orientación de una lista de productos genera «abrir».

Propuesta: 1) Reservar siempre el anteúltimo lugar para «Volver» cuando canGoBack, fuera del tope de opciones. 2) Toda vez que se nombran notas o productos (orientación, describe(), respuesta), dejar lastChunk y ofrecer sus «Abrir…». 3) Si ya se dijeron titulares, ofrecer «Seguir con los titulares» en vez de «Leer los titulares».

Escéptico: Se ve en las transcripciones: en Noticias los pasos 4 y 5 ofrecen «[Abrir…] · [Seguir con los titulares] · [Otra cosa]» sin «Volver», que en el paso 2 estaba. En Dólar (paso 2), Wikipedia (paso 3), clima y anti-robot-avanza-sola (paso 3) tampoco aparece. En otra-cosa (paso 4) se nombran tres notas y los botones son «[Leer los titulares] · [Resumir la portada] · [Volver…] · [Otra cosa]». El código lo explica: followUps() hace `return out` en la rama de titulares antes de agregar Volver y después corta con `prefix(3)`, y describe() no deja lastChunk. Una salvedad: en anti-robot-ya-la-resolvi los productos del fixture apuntan a `#a`/`#b`/`#c` dentro de la misma página, así que ese ejemplo en particular es débil.

### P14-lectura-repite-y-salta · La lectura repite lo ya dicho, cuenta de más y avanza sobre lo que no llegó a sonar

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa

Evidencia:
- Noticias, paso 4: «Titulares 1 a 3 de 142:» y los mismos titulares que se habían dicho al llegar.
- Clarín, pasos 4 y 5: el párrafo 2 («Las cadenas que participan… son: ABC, CBS, CNN, Fox News y NBC.») quedó DESCARTADO, y «Seguir leyendo» respondió «Párrafos 3 a 4 de 20: Fox News es un aliado de la administración Trump.»
- otra-cosa: «Hay 35 notas. Las tres primeras:», y la segunda es «Además, cómo está la tabla anual…», que es la bajada de la primera.
- Nota: el párrafo se descartó porque el script tocó mientras sonaba. Una persona que toca «Seguir leyendo» antes de tiempo pierde lo mismo, y Roberto lo describe así.

Causa probable: accept(readID) pone readingFrom = 0 aunque la llegada ya haya dicho los cuatro primeros titulares. El total es headlines(of:).count, que cuenta cada enlace-encabezado de la portada. readAloud() manda cada pedazo como un anuncio aparte en cola y suma readingFrom += chunk.count por lo escrito, no por lo oído; un pedido nuevo interrumpe y descarta lo que esperaba. Y headlines(of:) toma como nota cada ítem de listado de 25 letras o más, bajadas incluidas.

Propuesta: 1) Después de la llegada, que «Leer los titulares» siga desde el quinto («los cuatro que te dije, y sigo con…»). 2) No decir totales grandes: «te los leo de a tres». 3) Mandar cada tramo como un solo anuncio. Si el pedido siguiente lo interrumpe, retroceder readingFrom hasta la primera pieza que no terminó de sonar; Habla ya escucha announcementDidFinishNotification. 4) Unir título y bajada: el ítem que empieza con «Además,» o que comparte href con el anterior.

Escéptico: Lo de repetir y contar de más es de la app. En Noticias, paso 4, dice «Titulares 1 a 3 de 142:» y repite los titulares de la llegada, porque accept pone `readingFrom = 0`. En otra-cosa, «Hay 35 notas. Las tres primeras:» cuenta como segunda nota «Además, cómo está la tabla anual…», que en paginas/03.txt es la bajada de la primera. El salto de Clarín, en cambio, lo provocó el script: tocó «Seguir leyendo» 9,6 s después, cuando el párrafo 1 (unos 21 s) seguía sonando y el 2 quedó «DESCARTADO». El mecanismo existe (`readingFrom += chunk.count`, por lo escrito y no por lo oído), pero en esta corrida lo disparó ese tiempo.

### P15-wikipedia-metadatos · En Wikipedia, «el comienzo del artículo» son metadatos: la descripción corta y el aviso de redirección; después vienen «[2 ]» y espacios dobles

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata

Evidencia:
- Paso 4: «Párrafos 1 a 2 de 6:», luego «ciudad de la provincia de Buenos Aires, Argentina» y luego ««Marplatense»  redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).»
- Paso 5: «…aumentar en alrededor de un 301  %…», «siglo  XVIII», ««Puerto de la Laguna de los Padres». [2 ]».
- Verificador 1: el artículo tiene secciones (Historia, Demografía, Geografía…) plegadas en la versión móvil, así que «de 6» da a entender que termina ahí.
- Roberto: «Pensé que había entrado a otra página.»

Causa probable: readablePieces() toma todo bloque párrafo de 40 letras o más que deje Readability. La descripción corta de Wikipedia (49 letras) y la nota de redirección (hatnote) pasan ese filtro. No se limpian las llamadas a notas (sup.reference) ni los espacios duros, que se leen como espacio doble. La versión móvil deja las secciones plegadas, así que sólo se extrae la introducción, y su total se dice como si fuera el del artículo.

Propuesta: 1) En extract.js, descartar .hatnote, .shortdescription, .dablink, .infobox, sup.reference y .mw-editsection, y normalizar los espacios. 2) Decir qué se está contando: «La introducción tiene 4 párrafos; después vienen Historia, Geografía…». 3) Desplegar las secciones de la versión móvil y ofrecerlas como botones.

Escéptico: En el paso 4, «Párrafos 1 a 2 de 6:» lee «ciudad de la provincia de Buenos Aires, Argentina» y después ««Marplatense»  redirige aquí…». En el paso 5 se escuchan «301  %», «siglo  XVIII» y «[2 ]». En paginas/02.txt las secciones (Historia, Demografía…) sólo aparecen como encabezados plegados. Los 6 son la descripción corta, la nota de redirección y los 4 párrafos de la introducción. readablePieces() acepta cualquier párrafo de 40 letras o más.

### P16-baja-vision-botones-fuera · Con letra grande, los botones quedan fuera de la pantalla y la vista se queda en el primer mensaje de la respuesta

*grave* · confirmado · jueces: Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, primera-vez, mercadolibre-auriculares, otra-cosa, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- Noticias, paso-02.jpg: el resumen queda cortado en «…para evitar que la» y no se ve ninguno de los 6 botones. En paso-04.jpg tampoco se ve «Seguir con los titulares».
- Clarín, paso-05.jpg: no se ve «Seguir leyendo».
- Mercado Libre, paso-02.jpg: arriba se ve la prueba, pero la conversación sigue mostrando «Estás en Mercado Libre Argentina, en la portada.», con «Ya la resolví» fuera de la vista.
- Ana: «Tuve que adivinar que había que deslizar para abajo para encontrar las notas que se pueden abrir.»

Causa probable: El panel tiene alto fijo: max(380, alto × 0,55) en ReaderView. Cuando llegan líneas nuevas, AssistantPanel hace scrollTo(responseStart, anchor: .top), o sea, muestra el comienzo de la respuesta, que en una portada ya llena el panel. Con varios mensajes en un turno, ese comienzo es el primero («Estás en Mercado Libre…»), no el que importa. Además las respuestas de llegada son largas (ver P07).

Propuesta: 1) Cuando la respuesta no entra, llevar la vista al último mensaje con el primer botón visible abajo, o fijar un «Opciones ↓» encima del campo de escribir. 2) Que la conversación crezca con las respuestas largas, o que el divisor con la página se pueda arrastrar. 3) Acortar la orientación de llegada.

Escéptico: Las capturas lo confirman. En Noticias, paso-02.jpg termina en «…para evitar que la» sin ningún botón a la vista, y en paso-04.jpg no se ve «Seguir con los titulares». En Clarín, paso-05.jpg no muestra «Seguir leyendo». En Mercado Libre, paso-02.jpg sigue en «Estás en Mercado Libre Argentina…» con la prueba arriba. Eso sale de `scrollTo(start, anchor: .top)` en AssistantPanel y del panel de `max(380, alto*0.55)`. Un matiz: no hace falta letra grande, porque las capturas están con el tamaño de letra por defecto (.callout).

### P17-oficial-y-seguridad · No distingue lo oficial de lo que no lo es, ni avisa cuando el sitio no coincide con lo pedido antes de cargar datos

*grave* · confirmado · jueces: Lucía, Roberto, Verificador 1, Verificador 2 · escenarios: turno-anses, banco-nacion

Evidencia:
- ANSES, paso 1: «3. ANSES - Mi Anses, mianses.org», ofrecido junto a los .gob.ar sin aclarar que no es oficial. «2. ANSES, servicioswww.anses.gob.ar» es una «Consulta para completar o iniciar estudios».
- El resultado que resolvía el pedido, «Solicitar turnos en ANSES - Argentina.gob.ar» (n.º 3 en paginas/01.txt), no se ofreció.
- Banco, paso 1: el primer resultado se describe a sí mismo como «Accedé a BNA Digital Empresas…», y JEF dijo «Estás en el Home Banking del Banco Nación». El resultado 9 avisa: «el Home Banking dejará de funcionar y todas las operaciones pasarán a realizarse desde BNA+».
- Lucía: «Para un trámite con mis datos personales, eso lo tengo que saber.»

Causa probable: results(of:) se queda con un solo resultado por host (seen.insert(host)). Por eso «Solicitar turnos en ANSES» se cayó: también era de argentina.gob.ar. isOfficial() sólo sirve para ordenar y nunca se dice en voz alta. Los resultados se presentan sólo con título y dominio, sin el resumen del buscador, que es justo donde estaban «Empresas» y «Web dedicada a brindar ayuda…».

Propuesta: 1) Deduplicar por URL o por título, no por host; o permitir dos resultados del mismo host oficial cuando el título coincide con la tarea. 2) Decir «sitio oficial» para los .gob.ar y los dominios conocidos de bancos, y advertir «no es del gobierno» ante imitadores como mianses.org. 3) Usar el resumen del buscador para elegir el resultado que sirve a la tarea (el de «Solicitar turnos» para «sacar un turno») y para avisar cuando contradice el pedido (empresas en vez de personas).

Escéptico: En ANSES, paso 1, se ofrece «ANSES - Mi Anses — mianses.org» junto a los .gob.ar sin aviso. «ANSES, servicioswww.anses.gob.ar» es «Consulta para completar o iniciar estudios». «Solicitar turnos en ANSES» (n.º 3 en paginas/01.txt) se perdió por `seen.insert(host)`: también es de argentina.gob.ar. En el banco, el resultado elegido dice «Accedé a BNA Digital Empresas…» y JEF afirmó «Estás en el Home Banking del Banco Nación» sin advertirlo. Que ese sitio sea de verdad sólo para empresas no está probado: lo cierto es que el resumen del buscador no se usa ni se menciona.

### P18-primera-vez-arriba-abajo · La bienvenida y la respuesta a «¿dónde estoy?» hablan de «arriba» y «abajo» y no dicen qué hacer

*grave* · confirmado · jueces: Roberto, Lucía, Ana, Marta, Verificador 2 · escenarios: primera-vez, banco-nacion

Evidencia:
- Paso 1: «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.» La frase no tiene verbo y no dice cómo pedir. El corte del anuncio al 67 % lo provocó el script y quedó descartado.
- Paso 3: «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- Roberto: «“Arriba” y “abajo” no me ubican. «Últimas noticias de Argentina y el mundo» me suena a titular, no a un lugar.» Banco: «“Acá abajo” no me sirve porque no veo.»
- Ana: cuando apareció la página por primera vez, «los botones se fueron de la vista».

Causa probable: Son frases fijas en carry(.orientar) y en complete(). Usan page.sectionTitle, que es el título de la pestaña, como si fuera un lugar, y no cambian la indicación de ubicación según esté prendido VoiceOver o no. No hay ninguna opción de ayuda ni de volver al inicio.

Propuesta: 1) Bienvenida: «Decime un sitio o qué querés buscar, por ejemplo «el diario La Nación», o tocá una de las opciones que siguen.» 2) «¿Dónde estoy?»: «Estás en la página principal del diario La Nación. Después de este mensaje hay opciones para leer los titulares o abrir uno.» 3) Con VoiceOver, decir «después de este mensaje» en lugar de «abajo»; sin VoiceOver, arriba/abajo está bien. 4) Mantener los «Abrir…» y sumar «¿Qué puedo hacer?».

Escéptico: Las frases son textuales. En el paso 1, «Para empezar, un sitio o algo para buscar; o una de estas opciones.» no tiene verbo. En el paso 3 dice «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación…», una frase fija de la línea 481 de Assistant.swift que usa page.sectionTitle. En el banco, paso 3, dice «Se puede escribir o dictar acá abajo». El corte al 67 % del paso 1 sí lo provocó el script, pero el problema ya lo descartaba. En primera-vez, paso-02.jpg confirma que los botones quedan fuera de la vista al llegar.

### P19-campo-que-espera-un-dato · Mientras espera un dato, el campo sigue diciendo «¿Qué querés hacer?» y se vuelve a ofrecer el mismo campo

*grave* · confirmado · jueces: Roberto, Ana, Marta, Lucía, Verificador 2 · escenarios: banco-nacion

Evidencia:
- Paso 3: «¿Qué pongo en DNI? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.», mientras el campo se anuncia como «Pedido = ¿Qué querés hacer? (Escribí a dónde querés ir…)» (arbol-03, línea 14).
- Botones durante la espera: [Completar «DNI»] · [Completar «Usuario»] · [Volver a la página anterior] · [Otra cosa].
- Paso 4: lo último que se puede recorrer es «Toolbar», en inglés (arbol-04). En paso-04.jpg se ve la barra de formulario web con ↑ ↓ ✓.
- Roberto: «dudo si estoy escribiendo el DNI o un pedido».

Causa probable: En AssistantPanel, el TextField tiene etiqueta, pista y texto de ayuda fijos y no mira awaitingField. formOptions() excluye los campos ya llenos (filledFields), pero no el que se está esperando. __jefFill (extract.js) hace el.focus() en el campo de la página y lo deja enfocado, y por eso iOS muestra su barra de formulario.

Propuesta: 1) Exponer awaitingField y, mientras exista, cambiar la etiqueta y el texto de ayuda a «DNI: escribí sólo los números». 2) Ofrecer «Cancelar» en lugar de repetir «Completar «DNI»». 3) Después de llenar, hacer el.blur(), salvo en los autocompletados. 4) Cambiar «acá abajo» por «en el campo de escribir, que ya tiene el cursor».

Escéptico: Pasa como se describe. En arbol-03 (línea 14), mientras el asistente pregunta «¿Qué pongo en DNI?», el campo sigue diciendo «Pedido = ¿Qué querés hacer? (Escribí a dónde querés ir…)» y el botón 1 vuelve a ser [Completar «DNI»]. En el código, formOptions sólo excluye los campos ya llenos (`!filled.contains($0.id)`) y no el que está esperando, y paso-04.jpg muestra la barra de formulario web ↑ ↓ ✓ (arbol-04, línea 17: «[grp] Toolbar»). Que diga «Toolbar» en inglés probablemente depende del idioma del simulador; que la barra aparezca es de la app.

### P20-carteles-y-pagina-que-no-acompana · Carteles de la página que el asistente no menciona o no deja decidir (inicio de sesión con Google, cookies), y una página que no acompaña lo que se lee

*menor* · confirmado · jueces: Ana, Lucía · escenarios: solo-botones-clarin, mercadolibre-auriculares, wikipedia-mar-del-plata, dolar-desde-cero

Evidencia:
- Clarín, paso-02.jpg: sobre la portada aparece «Acceder a Clarin.com con Google», con un botón azul «Continuar», y el asistente no lo mencionó. Ana: «Con mi vista, un botón azul que dice “Continuar” es justo lo que tocaría.»
- Mercado Libre: «Hay un aviso sobre cookies.», sin ninguna opción para aceptarlo o rechazarlo. Lucía: «Es una decisión de privacidad que quiero tomar yo.»
- Clarín, paso 3: arriba se ven los íconos de redes y «Leé el diario de hoy», no el título de la nota.

Causa probable: El detector de avisos (overlay) no reconoce el cartel de inicio de sesión de Google, que es un iframe de accounts.google.com. El aviso de cookies sólo aparece dentro del texto de la orientación; no se convierte en opción. Y no hay código que desplace la página al bloque que se está leyendo: sólo existe scrollToTop() al cargar.

Propuesta: 1) Detectar el iframe de Google y cerrarlo, o avisar «es para iniciar sesión; no hace falta». 2) Convertir el aviso de cookies en botones: «Rechazar las opcionales» y «Aceptar». 3) Al abrir una nota o leer, hacer scrollIntoView del título o del párrafo que se está leyendo.

Escéptico: En paso-02.jpg de Clarín se ve «Acceder a Clarin.com con Google» con el botón azul «Continuar». No figura en paginas/02.txt y la orientación no lo menciona. En Mercado Libre la orientación dice «Hay un aviso sobre cookies.», pero ningún botón lo ofrece, aunque la página tiene «Aceptar cookies / Configurar cookies» (paso-02.jpg, paginas/02.txt:128). En Clarín paso-03.jpg arriba se ven «Leé el diario de hoy» y los íconos de redes, no el título. Wikipedia paso-05.jpg sigue arriba de todo mientras se leen los párrafos 3 y 4.

### P21-preguntas-ya-contestadas · Las preguntas sugeridas repiten lo que se acaba de contestar

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: wikipedia-mar-del-plata, clima-cordoba

Evidencia:
- «Mar del Plata se fundó el 10 de febrero de 1874 por Patricio Peralta Ramos.», con [¿Quién la fundó?] como primer botón.
- Clima, paso 3: después de «No va a llover…», [¿Qué clima hará mañana?] · [¿Cuál es la humedad?]. La humedad ya se había dicho: «La humedad relativa será del 31%».

Causa probable: Answerer.answer pide «hasta dos preguntas… que ESTA página contesta», sin excluir lo que la respuesta ya dijo ni lo que ya se preguntó. closeTurn() las pone primeras sin filtrar.

Propuesta: 1) En la instrucción, pedir preguntas «que esta respuesta y las anteriores NO contestaron». 2) En código, descartar una pregunta si sus palabras clave (fundó, humedad, clima mañana) ya aparecen en la respuesta o en un pedido anterior.

Escéptico: En Wikipedia la respuesta es «Mar del Plata se fundó el 10 de febrero de 1874 por Patricio Peralta Ramos.» y el primer botón es [¿Quién la fundó?]. En Clima, el paso 2 ya había dicho el pronóstico de mañana y «La humedad relativa será del 31%», y en el paso 3 se ofrecen [¿Qué clima hará mañana?] · [¿Cuál es la humedad?]. Son preguntas que genera la app, no elecciones del script.

### P22-opciones-fuera-de-lugar · Opciones que no corresponden: campos de la página que nadie pidió, controles de audio, releer lo que se acaba de decir, volver a la prueba

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: clima-cordoba, wikipedia-mar-del-plata, solo-botones-clarin, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- Clima: [Completar «Selecionar localidad»], con la falta de ortografía del sitio.
- Wikipedia: [Abrir «Reproducir audio»], que es el reproductor de un audio de 28 segundos y no una página.
- Clarín, paso 3: [Abrir «Donald Trump, sobre Irán…»] antes de «Volver».
- Escenarios anti-robot: [Leer la página] como primera opción, justo después de decir la página entera. Y en avanza-sola, «Volver a la página anterior» lleva otra vez a captcha.html.

Causa probable: formOptions() ofrece los dos primeros campos de cualquier formulario que no sea de búsqueda, y closeTurn() los pone primero. En una nota, arrived() conserva una sugerencia «abrir» del modelo sin filtrar controles de medios. followUps() ofrece «Leer» aunque la orientación ya haya dicho todo. El historial incluye la página de la prueba.

Propuesta: 1) Ofrecer campos sólo en páginas que son formularios (ingreso, turnos), y nombrarlos por lo que hacen («Ver el tiempo de otra ciudad»). 2) Filtrar botones de audio y video. 3) Después de una orientación completa, ofrecer preguntas o abrir ítems, no «Leer». 4) Al volver desde una página ya resuelta, saltear la de la prueba.

Escéptico: Confirmado en lo principal: en Clima aparece [Completar «Selecionar localidad»], con la falta de ortografía, y en Wikipedia [Abrir «Reproducir audio»], que en paginas/02.txt:40-41 es «Reproducir audio / Duración: 28 segundos.». Hay partes flojas. Lo de Clarín es un enlace «Mirá también» de la nota, ofrecido después de Leer y Resumir, y se puede defender. [Leer la página] sale primero después de una orientación que dijo todo, pero eso pasa porque la página de prueba de localhost es mínima. Que «Volver» lleve a captcha.html no se probó en ningún paso: es una inferencia.

### P23-textos-tecnicos · Se leen textos técnicos o sucios: dominios, consultas armadas, mayúsculas, abreviaturas

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: clima-cordoba, turno-anses, dolar-desde-cero, mercadolibre-auriculares, anti-robot-ya-la-resolvi

Evidencia:
- «3. Tiempo Mañana en Córdoba — … xn--tiempomaana-8db.net», en el anuncio y en el botón.
- «2. ANSES, servicioswww.anses.gob.ar».
- «Buscando: Dólar oficial Dolarhoy.com.»
- [Abrir «CONSULTAR TURNO»] y [Abrir «Solicitud de Jubilación, ver sub-trámites»].
- «Electrodomésticos y Aires Ac.»
- «Encontraste tres opciones con envío gratis…» y «están $89.900».

Causa probable: present() dice bare(host), y URL.host() devuelve el dominio en punycode. La consulta del ruteador se lee cruda. short() no normaliza las mayúsculas ni saca los sufijos de listado. La orientación del modelo cambia de persona («encontraste»).

Propuesta: 1) Decodificar el punycode, o usar el dominio que muestra el buscador («tiempomañana.net»). 2) Nombrar el sitio por su nombre y no por el host. 3) Decir la búsqueda en castellano: «Busco el dólar oficial en Dolarhoy». 4) Pasar las MAYÚSCULAS a tipo oración y sacar «, ver sub-trámites». 5) Indicarle a orient() que diga «hay» y no «encontraste».

Escéptico: Aparece todo en las transcripciones. En clima-cordoba, el anuncio dice «…, xn--tiempomaana-8db.net» y el botón «www.xn--tiempomaana-8db.net». En turno-anses se escucha «2. ANSES, servicioswww.anses.gob.ar» (es el host real, leído crudo) y hay botones [Abrir «CONSULTAR TURNO»] y [Abrir «Solicitud de Jubilación, ver sub-trámites»]. Además: «Buscando: Dólar oficial Dolarhoy.com.», «Electrodomésticos y Aires Ac.», y en anti-robot-ya-la-resolvi «Encontraste tres opciones…» y «están $89.900».

### P24-dato-en-voz-alta · El dato que se escribe en un formulario se repite entero en voz alta y queda en la conversación

*menor* · confirmado · jueces: Roberto, Lucía · escenarios: banco-nacion

Evidencia:
- «Escrito «30123456» en DNI.», y en la conversación queda «Vos: 30123456».
- Roberto: «en la calle me da cosa». Lucía: «No me dice si lo que escribo pasa por algún servidor o se guarda.»

Causa probable: Cuando hay awaitingField, ask() confirma con say(Escrito «valor» en campo), y heard() guarda lo escrito como turno de la persona.

Propuesta: 1) Confirmar sin repetir el dato completo: «DNI cargado, termina en 456». 2) Decir una sola vez que el dato va únicamente al campo de la página y no se guarda. 3) Para documentos y tarjetas, no leerlos completos nunca, igual que ya se hace con las contraseñas.

Escéptico: En banco-nacion, paso 4, se anuncia «Escrito «30123456» en DNI.» y en arbol-04 (línea 10) queda «[H] Vos: 30123456». El código lo confirma: `say("Escrito «\(goal)» en …")`. Si es un defecto o una confirmación útil es una decisión de producto, pero el comportamiento es de la app y es tal como se describe.

### P25-explicaciones-repetidas · Explica el dictado cada vez, y «Otra cosa» deja la pantalla sin ninguna opción

*menor* · confirmado · jueces: Marta, Roberto, Ana · escenarios: otra-cosa, banco-nacion

Evidencia:
- «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» y «Se puede escribir o dictar acá abajo…».
- Roberto: «desaparecen todos los botones: si me arrepiento, no tengo cómo volver a las opciones de antes».
- Ana: el campo, con su letra gris clara, cuesta verlo.

Causa probable: Son frases fijas en accept(otherID) y en complete(). «Otra cosa» vacía la oferta a propósito.

Propuesta: 1) Explicar el dictado sólo la primera vez. 2) Después alcanza con «¿Qué otra cosa?» y el cursor en el campo. 3) Dejar un botón «Volver a las opciones». 4) Resaltar el campo cuando se activa.

Escéptico: Lo de «Otra cosa» está probado: en otra-cosa/arbol-03 la conversación termina en «9 [txt] ¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado. / 10 [campo] Pedido / 11 [btn] Enviar». No queda ningún botón, ni siquiera para volver a las opciones de antes, y el código lo hace a propósito (Assistant.swift:1403-1407: «sin más botones»). Lo de «cada vez» está exagerado: en las transcripciones cada frase aparece una sola vez y en escenarios distintos (otra-cosa paso 3, banco-nacion paso 3), así que nunca se ve repetida en una misma sesión. Aun así son frases fijas sin condición (Assistant.swift:587 y :1405), así que se repetirían, y la ayuda del campo vuelve a decir «Con el dictado del teclado también se puede hablar.» cada vez que se enfoca. Lo de Ana se ve en paso-03.jpg: el texto de ejemplo «¿Qué querés hacer?» es gris claro y el campo activo se ve igual que en paso-02.jpg, salvo el cursor. No es culpa del script: tocar «Otra cosa» era justamente lo que buscaba el escenario.

## Lo que funciona

- El ingreso al banco es el modelo a seguir. La llegada dice «Estás en el Home Banking del Banco Nación. Te pide tu DNI y tu usuario.», el primer botón es «Completar «DNI»», awaitingField manda el valor directo al campo, confirma con «Escrito… en DNI» y ofrece «Completar «Usuario»» como paso siguiente (complete(), formOptions(), awaitingField).
- El botón de inicio «Llevame a La Nación» abre directo, y «llevame a deportes» dentro de un diario va a la sección sin pasar por el buscador (regla del ruteador: abrir dentro del sitio).
- Las preguntas de un dato se contestan al llegar, sin describir la página: «El dólar blue hoy está a $1.530 para la compra y $1.550 para la venta», «Mar del Plata se fundó el 10 de febrero de 1874 por Patricio Peralta Ramos», «No va a llover, la probabilidad de lluvia es del 0%», «El más barato… $12.499» (pendingQuestion y reply()).
- No inventa. Dice «La página no muestra precios porque te pide que completes un paso de seguridad» y «Todavía no hay una nota abierta: estás en la portada de LA NACION. ¿Cuál abro?», con los titulares como botones. La verificación de cifras de Answerer funciona.
- Volver avisa dónde quedó sin releer todo: «Volviendo.» y «De vuelta en los resultados de «la nación».» (goBack(), present con speak: false).
- Se acuerda de la tarea entre páginas: en ANSES siguió solo hasta «Pedir turno», y en Mercado Libre buscó los auriculares dentro del sitio (waiting/rest y continueWith()).
- Detecta la prueba anti-robot y retoma solo cuando la página cambia: «Listo, ya pasamos la verificación.», seguido de los precios. «Ya la resolví» funciona al instante, y avisar que hay opción de audio sirve.
- En la portada de La Nación, los titulares dichos y los botones coinciden en orden, porque los elige el código (lead en arrived()). Hay que mantenerlo y extenderlo (ver P03 y P11).
- Al abrir una nota dice de qué trata en una frase, pone «Leer la nota» y «Resumir la nota» primero, y lee con la posición adelante («Párrafos 1 a 2 de 20:»), con «Seguir leyendo» siempre primero.
- «Otra cosa» deja el cursor en el campo con el teclado abierto.
- El buscador saltea los enlaces patrocinados, deja afuera los resultados de otro país (la Córdoba de España), muestra el dominio y ofrece «Ver más opciones (n)».
- «Primera de N opciones» en el primer botón. Todo en castellano y sin nombres internos.
- Cuando la página tiene lo que sigue, las repreguntas sugeridas son útiles: «¿Y el de vincha?», «¿Cuánto sale el más caro?», «¿A cuánto está el dólar MEP?».
