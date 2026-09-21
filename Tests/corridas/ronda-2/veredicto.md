# Veredicto — ronda-2

Ronda 2: 10 escenarios, 4 jueces y 2 verificadores. Promedio general: 2,65 sobre 5 (529 puntos sobre 200 puntajes). Tres escenarios se lograron: wikipedia-mar-del-plata y otra-cosa los lograron los cuatro jueces, y noticias-la-nacion tres de cuatro (Ana, a medias). Cuatro no los logró nadie: solo-botones-clarin, turno-anses, mercadolibre-auriculares y banco-nacion (Marta lo dio a medias). Los otros tres quedaron a medias (dolar-desde-cero, clima-cordoba, primera-vez). Lo más alto fue Wikipedia (3,35) y lo más bajo ANSES (2,1). En Clarín, ANSES y Banco Nación los cuatro jueces pusieron control 1.

Las fallas que impiden llegar tienen cinco causas en el código:
1) Todo botón de la página que no es un enlace falla siempre, y el fallo produce el «Abriendo Abrir», el «ya no está» dicho sólo en voz y el círculo en el banco. La causa: en `arrived()`, la sugerencia se reconstruye con id `sug-<id>` y etiqueta «Abrir «…»». Después, `HeadlessWebView.activate` busca `data-jef-id="sugXXX"`, que no existe, y además compararía la etiqueta con «Abrir» delante.
2) No existe la idea de «muro». La suscripción de Clarín, el login y el captcha se describen como destino, y el captcha sólo ofrece Volver.
3) La pregunta de dato se pierde. El router la convierte en búsqueda y `arrived()` orienta sin conocerla. En el dólar y el clima, además, `orient()` devolvió nil y se cayó a `describe()`.
4) Los botones que propone el modelo reemplazan a los fijos (Volver, Leer, Resumir): `closeTurn` sólo agrega «Otra cosa».
5) Todos los anuncios van en cola (`Voz.decir` con `accessibilitySpeechQueueAnnouncement`) y nada los corta, por eso hay respuestas que suenan hasta dos minutos tarde.

Estas cinco explican la mayoría de los puntajes bajos de control y ritmo.

Aparte, no hacen fracasar el objetivo pero hacen perder tiempo o confianza:
- Todo pasa por el buscador, hasta el ejemplo propio «Llevame a La Nación».
- Los botones salen de la basura de la página: lo legal, cookies, epígrafes, «Crear cuenta».
- Los resúmenes cambian el sentido: «Hace 34 min» contado como noticia, horas pegadas a los hechos, precios de promoción sin la condición.
- La lectura de Wikipedia arranca con avisos y termina en un «Fin de la nota» falso.
- Para Ana (baja visión), los botones quedan fuera de la pantalla.

En el árbol de trabajo hay cambios sin commitear en /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift que no estaban en esta corrida y todavía no se probaron:
- Los sitios oficiales van primero.
- Se filtran los dominios sandbox/staging.
- Se sacan las frases «Puedo abrir uno / leer una».
- La lista hablada es más corta.

Esos cambios no alcanzan para ANSES: `named()` sigue poniendo primero a turnosanses.net, porque la consulta «turnos anses» pegada coincide exacta con ese dominio.

Lo único que puede ser del script es el silencio del paso 4 de ANSES: el toque no llegó ni a `heard()`, quizá porque el panel se estaba desplazando. Igual quedó adentro, porque de haber llegado habría fallado por la causa 1, y porque `accept()` descarta toques sin avisar cuando está `working`.

Archivos que miré: /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/UI/ReaderView.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/Engine/Registro.swift, /Users/daniel/Developer/JEF- BROWSER/Sources/Engine/HeadlessWebView.swift y /Users/daniel/Developer/JEF- BROWSER/Sources/Extraction/extract.js. No modifiqué nada.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana a medias | 2.9 |
| solo-botones-clarin | Marta no, Roberto no, Lucía no, Ana no | 2.2 |
| dolar-desde-cero | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.8 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.4 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 2.1 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.6 |
| banco-nacion | Marta a medias, Roberto no, Lucía no, Ana no | 2.4 |
| primera-vez | Marta a medias, Roberto no, Lucía a medias, Ana a medias | 2.9 |
| clima-cordoba | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.2 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.0 |

**Promedio general: 2.65**

## Problemas

### P01 · Los botones de la página que no son un enlace fallan siempre: «Abriendo Abrir», «ya no está», recarga y el mismo botón otra vez

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, banco-nacion, turno-anses

Evidencia:
- Clarín paso 5: 💬 «Abriendo Abrir «Correo electrónico».» y sólo en voz 🔊 «Esa opción ya no está en la página. La vuelvo a cargar.». paginas/06.txt es idéntica a 05.txt: el campo «Correo electrónico» seguía en la página. Después de recargar, el botón del correo desapareció.
- Banco paso 3: «Abriendo Abrir «Recuperar usuario y contraseña».», recarga de loginStep1 y otra vez [Abrir «Recuperar usuario y contraseña»] · [Otra cosa]. Roberto: «Quedé dando vueltas en el mismo lugar».
- ANSES paso 4: tocó [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad…»] y no hubo línea «Vos:», ni voz, ni botones. registro.jsonl termina en el paso 3.
- Ana: «veo 'Abriendo Abrir «...»' y la misma pantalla de antes, sin saber qué pasó». El aviso de recarga no está en arbol-05.txt.

Causa probable: En Assistant.arrived(), cada sugerencia «abrir» se reconstruye como una Action nueva con id `sug-<id del control>`, etiqueta «Abrir «…»» y `fields: nil`. Si tiene href, va por reader.go() y funciona (los titulares). Si es un botón, un campo o un enlace JavaScript, cae al final de accept(): `say("Abriendo \(action.label).")` produce «Abriendo Abrir», y después viene reader.activate(action). HeadlessWebView.activate filtra el id (queda «sugXXX») y __jefActivate busca [data-jef-id="sugXXX"], que no existe: devuelve «gone», es decir .stale. ReaderModel dice el aviso con Voz.decir directo, sin pasar por Assistant.say, y por eso no queda escrito. Aunque el id fuera el correcto, stillTheSame() compararía «abrir «recuperar…»» con «recuperar…» y daría «changed». Después de recargar, accept() llama a landed(), y orient() vuelve a proponer el mismo control. En ANSES, el toque ni siquiera llegó a heard(). O no se registró (puede ser del script), o lo descartó `guard let chosen = offer, !working else { return }`, que vuelve sin decir nada.

Propuesta: En arrived(), conservar el id y la etiqueta reales del control (por ejemplo, un mapa id de sugerencia → Action original, o un campo aparte para la etiqueta visible) y activar con esos. Para campos, pasar target.fields: llenarlos, o llevar el foco. El eco debe ser «Abriendo «Recuperar usuario y contraseña»», sin el «Abrir». Que ReaderModel.activate devuelva el resultado (.stale, sin cambios, error) y que lo diga Assistant.say, así queda escrito y hablado. Tras recargar, reintentar una vez buscando el control por su etiqueta. Si vuelve a fallar: «No pude abrir «…»», no volver a ofrecerlo y dar [Volver] y otra salida. Si un toque llega mientras `working`, decir «Espero a terminar lo anterior» en vez de callar.

Escéptico: Pasa en Clarín paso 5 («Abriendo Abrir «Correo electrónico».», el aviso «Esa opción ya no está…» sólo en 🔊, y paginas/05.txt y 06.txt son idénticas) y en Banco paso 3 (recarga de loginStep1 y otra vez [Abrir «Recuperar usuario y contraseña»]). En el código de HEAD, accept() hace say("Abriendo \(action.label)") y activa con id «sug-…», que no existe en la página. Lo de ANSES paso 4 no prueba nada: en paso-03.jpg el botón estaba debajo del borde y el script tuvo que arrastrar el panel antes de tocarlo (el propio script avisa que así el toque «sólo frena» el scroll). Además accept() siempre escribe «Vos:» cuando pasa el guard, y `working` estaba en false, así que ese caso es del arnés.

### P02 · Los muros (nota para suscriptores, inicio de sesión, captcha) se describen como si fueran el destino y no tienen salida útil

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, mercadolibre-auriculares, banco-nacion

Evidencia:
- Clarín paso 3: tocó una nota y cayó en clarin.com/suscripciones/landing-apw-scoring.html?apw-origin=…ganadores-perdedores… JEF: «Está en la página de suscripciones de Clarín. Ofrece distintas opciones: el plan Digital por $930 al mes…». Nunca dijo que la nota era para suscriptores.
- Clarín paso 3, botones: [Abrir «Ya tenés tu tarjeta 365?, Ingresá los datos de tu tarjeta 365 o 365…»] · [Abrir «¿Querés recibir Clarín en papel en tu casa?, Saber más»] · [Abrir «¿Necesitás una suscripción corporativa?, Ver planes»] · [Otra cosa].
- Clarín paso 4: «La página indica que para continuar debe iniciar sesión.» con [Abrir «Correo electrónico»] · [Abrir «Continuar con Facebook»] · [Abrir «Continuar con Google»] · [Abrir «Continuar con Apple»]. Roberto: «Me dio miedo tocar algo que no debía».
- ML paso 2: «Suele tener una opción de audio, pero está dentro del recuadro de la verificación y no la puedo tocar: hay que hacerlo en la pantalla.» Botones: [Volver a la página anterior] · [Otra cosa].
- Marta: «¿cómo, si no veo? No hay botón que me lleve el cursor de VoiceOver al recuadro». Ana: «Yo podría tocar la casilla… no había forma de decirle 'ya está, seguí'».

Causa probable: El extractor reconoce un muro de pago sólo cuando es un aviso encima de la página (detectOverlay → «paywall»). La redirección de Clarín a otra página de venta llega como una página común, y orient() la resume como cualquier otra. Nada compara la URL a la que se llegó con el href de la nota que se pidió. En un login al que no se pidió ir, orient() lo cuenta y propone sus controles. Para el captcha, describe() usa un texto fijo y followUps() devuelve sólo [Volver] cuando overlay.kind == .captcha. No hay ninguna acción que lleve el foco de VoiceOver al WebView, ni una para reintentar la tarea pendiente.

Propuesta: Después de abrir una nota, si la URL final no es el href pedido y contiene suscrip/apw/login/registr (o el extractor marca paywall), decir: «Esa nota es sólo para suscriptores de Clarín». Los primeros botones serían [Volver a la portada] · [Otra nota de la portada] · [Buscar esta noticia en otro diario]; los planes, últimos o nunca. En un login al que no se pidió ir: «Esto pide iniciar sesión; para leer noticias no hace falta», con Volver primero y sin «Continuar con Facebook/Google» entre las opciones. Para el captcha, ofrecer [Ir a la verificación], que ponga el foco de VoiceOver en el WebView con el recuadro a la vista (UIAccessibility.post(.layoutChanged, argument:)) y diga en una frase dónde está el botón de audio. También [Ya lo resolví, seguí], que reintenta la tarea pendiente, [Buscar en otra tienda] y Volver.

Escéptico: En Clarín paso 3 cargó clarin.com/suscripciones/landing-apw-scoring…?apw-origin=…ganadores-perdedores…, JEF dijo «Está en la página de suscripciones de Clarín… plan Digital por $930» sin avisar que la nota era paga, y ofreció [tarjeta 365] · [papel] · [corporativa]. En el paso 4 dio [Correo electrónico] · [Facebook] · [Google] · [Apple], y en ML, frente al captcha, sólo [Volver a la página anterior] · [Otra cosa]. Que el script tocara el primer titular no cambia nada: el muro lo pone el sitio y cómo se describe es cosa de la app.

### P03 · En la página de ingreso del banco no dice qué campos hay ni lleva a ellos, y no dice qué pasa con los datos

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: banco-nacion

Evidencia:
- Paso 2: «Está en la página de inicio del Home Banking del Banco Nación. La página permite recordar el DNI o recuperar usuario y contraseña.» Botones: [Abrir «Recuperar usuario y contraseña»] · [Abrir «Términos y Condiciones»] · [Otra cosa].
- paso-02.jpg muestra los campos DNI y Usuario y el botón Continuar, pero paginas/02.txt sólo trae «Recordá tu DNI / Recuperar usuario y contraseña / Términos y Condiciones».
- Paso 3: «La página pide recordar el DNI», que contradice lo que dijo en el paso 2 («permite»).
- Lucía: «Antes de escribir la clave del banco quiero saber si JEF la lee, la manda a algún lado o la guarda.»

Causa probable: Assistant.saying() descarta toda acción de tipo formulario (`action.kind != .form`), así que el texto que recibe orient() no nombra DNI, Usuario ni Continuar. Como orient() contestó, la rama de formulario de describe() («Hay un formulario de N campos…») nunca corre. Además, las sugerencias sólo pueden ser abrir, leer o resumir: no existe «ir a un campo». candidates() deja afuera las etiquetas de menos de 12 letras. Si los campos del banco no están dentro de un form, puede que el extractor tampoco los agrupe (a confirmar).

Propuesta: Incluir en saying() una línea por formulario con sus campos y su botón (por ejemplo «FORMULARIO: DNI, Usuario, [Continuar]»). En páginas de ingreso, anteponer por plantilla: «Para entrar te pide DNI y usuario; la clave la escribís vos en la página, yo no la leo ni la guardo». Agregar una sugerencia de tipo «campo» que lleve el foco de VoiceOver al campo real del WebView sin escribir nada, y que [Ir al campo DNI] sea el primer botón. [Recuperar usuario y contraseña] va después; Términos, nunca.

Escéptico: paso-02.jpg muestra DNI, Usuario y Continuar, pero paginas/02.txt sólo trae «Recordá tu DNI / Recuperar usuario y contraseña / … Términos y Condiciones». JEF dijo «permite recordar el DNI» en el paso 2 y «pide recordar el DNI» en el paso 3, sin nombrar los campos ni decir nada sobre los datos. saying() descarta `action.kind != .form`.

### P04 · La pregunta de dato se pierde al llegar a la página (el blue, el pronóstico)

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: dolar-desde-cero, clima-cordoba, mercadolibre-auriculares

Evidencia:
- Dólar: preguntó «¿a cuánto está el dólar blue hoy?» y al abrir el sitio JEF dijo sólo «Aviso de cookies encima de la página.» «Opciones: Aceptar, Rechazar.». paginas/02.txt tenía «Compra hoy $1.530,00 / Venta hoy $1.550,00 / Última actualización 21/9 12:00 hs / Dólar Blue».
- Clima: «En Clima mañana en Córdoba, Cordoba — eltiempoen.com.» «Hay 11 resultados. Los tres primeros:» «Buenos Aires» «Córdoba» «Rosario». La página decía «Mañana en Córdoba se esperan unas condiciones de nubes… máxima de 63º y mínima de 40º» y «Probabilidad 0%».
- Contraejemplo: en ML la segunda parte del pedido sí sobrevivió: «Cuando elijas, sigo con: buscame auriculares bluetooth.»

Causa probable: El router convierte la pregunta en `buscar` («dólar blue hoy», «tiempo mañana córdoba») y la pregunta no se guarda en ningún lado. `waiting` sólo guarda `decision.rest`, la segunda parte de un pedido doble: por eso ML funcionó. arrived() llama a orient() sin la pregunta. En estos dos casos orient() además devolvió nil (pasaron unos 4 s entre la carga y la respuesta) y se cayó a describe(). Lo más probable es que la verificación de «cifras» rechazara un número que el modelo no copió igual: «63°» contra «63º» de la página, o un valor convertido. describe() es una plantilla: antepone el aviso de cookies y trata el bloque «Hoy en otras ciudades» como si fueran resultados.

Propuesta: Si el pedido es una pregunta, guardarla (por ejemplo `pendingQuestion`) y, al llegar, llamar primero a reply(pregunta): «El blue está a $1.550 la venta y $1.530 la compra, según dolarinfohoy, actualizado a las 12». Después, a lo sumo, una frase de dónde está. Si la verificación rechaza la respuesta, reintentar reply antes de caer a describe(). En Answerer.appears(), tratar º y ° como iguales y tolerar los separadores de miles. Un menú de navegación nunca se cuenta como «resultados».

Escéptico: En Dólar, al abrir dolarinfohoy JEF dijo sólo «Aviso de cookies encima de la página.» / «Opciones: Aceptar, Rechazar.», con «Compra hoy $1.530,00 / Venta hoy $1.550,00 … Dólar Blue» en paginas/02.txt. En Clima dijo «Hay 11 resultados… Buenos Aires, Córdoba, Rosario», que es el bloque «Hoy en otras ciudades», cuando la página decía «máxima de 63º y mínima de 40º» y «Probabilidad 0%». Las dos son la plantilla describe(), no una respuesta a la pregunta.

### P05 · Faltan Volver, Leer y Resumir cuando los botones los arma el modelo, y «Otra cosa» deja sin ninguno

*grave* · confirmado · jueces: Roberto, Lucía, Ana, Verificador 1 · escenarios: solo-botones-clarin, noticias-la-nacion, banco-nacion, turno-anses, otra-cosa

Evidencia:
- Clarín pasos 3 a 5: ningún botón de Volver. Verificador: «No hay «Volver» a la portada ni otra noticia».
- La Nación paso 4, con la nota abierta: sólo [Abrir «La Justicia Federal ordenó investigar al ministro Lugones y al jefe…»] … · [Otra cosa]. Lucía: «no hay «Leer la nota», «Resumir la nota» ni «Volver». Tuve que escribirlo yo.»
- Banco paso 3: [Abrir «Recuperar usuario y contraseña»] · [Otra cosa]. ANSES pasos 2 y 3, sin Volver.
- Otra cosa: Roberto: «Al tocar «Otra cosa» desaparecieron todos los botones… si me arrepiento no tengo cómo volver a las opciones».

Causa probable: closeTurn() sólo le suma «Otra cosa» a la oferta que ya existe. followUps(), que es donde viven Leer, Resumir y Volver, corre únicamente cuando arrived() no dejó oferta. Cuando orient() trae sugerencias, estas reemplazan a las fijas. El reordenamiento de arrived() para notas sólo funciona si el propio modelo propuso leer o resumir, y en la nota de Milei propuso sólo abrir otras notas. accept(Otra cosa) deja la oferta vacía a propósito.

Propuesta: En closeTurn(), completar siempre la oferta. En una nota, [Leer la nota] y [Resumir] primero si faltan. [Volver a …] siempre que canGoBack, y como primera opción si la página es un muro o algo falló. Después, las sugerencias del modelo, hasta 4, y Otra cosa. Después de Otra cosa, dejar [Volver a las opciones].

Escéptico: Con botones del modelo no hay Volver ni Leer/Resumir: en La Nación paso 4 (nota abierta) sólo hay cuatro [Abrir «…»] + [Otra cosa], y lo mismo pasa en Clarín 3-5, Banco 3 y ANSES 2-3. En otra-cosa paso 3 el árbol queda con sólo [campo] Pedido y Enviar. En cambio, cuando se cae a describe() aparecen [Leer la página] · [Resumir] · [Volver], lo que confirma que closeTurn() sólo agrega followUps si no hay oferta.

### P06 · Botones con basura de la página, y la primera opción lleva a donde no se pidió

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: wikipedia-mar-del-plata, turno-anses, banco-nacion, mercadolibre-auriculares, solo-botones-clarin, noticias-la-nacion

Evidencia:
- Wikipedia: [Abrir «Desde arriba hacia abajo, y de izquierda a derecha: Vista de la Playa…»] · [Abrir «Mostrar en pantalla completa»] · [Abrir «Reproducir audio»].
- ANSES paso 2: [Abrir «Política de Privacidad»] · [Abrir «Política de Cookies»]. Paso 3, el primero: [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad…»]. Roberto: «yo soy jubilado».
- ML: [Abrir «Abrir app de Mercado Libre»] · [Abrir «Crear cuenta»] · [Abrir «Suscribirme desde $ 5.490»] · [Abrir «Configurar cookies»]. Banco: [Abrir «Términos y Condiciones»].
- Clarín: primero [Abrir «Ya tenés tu tarjeta 365?, Ingresá los datos de tu tarjeta 365 o 365…»], después [Abrir «Continuar con Facebook»]. Lucía: «La primera opción que me ofrece es cargar los datos de una tarjeta.»

Causa probable: Assistant.candidates(of:) le pasa al modelo los titulares y, detrás, cualquier acción de 12 letras o más, sin filtrar legales, cookies, cuenta, app, redes, multimedia ni epígrafes de imágenes. orient() elige de esa lista y el código sólo comprueba que el número exista. En ANSES los botones copian el orden de la página y nadie pregunta qué trámite hace falta.

Propuesta: Filtrar por código antes de armar los candidatos. Quedan afuera: privacidad, cookies, términos, legales; crear cuenta, iniciar sesión, «continuar con Facebook/Google/Apple»; abrir la app; suscribirme, planes, tarjeta; pantalla completa, reproducir, compartir; epígrafes (figcaption). En Wikipedia, ofrecer las secciones del artículo. Ante una lista larga de trámites, preguntar «¿Para qué trámite es el turno?», con los más comunes como botones, [Ver todos] y el buscador «Buscar turno» de la página. Nunca poner primero un formulario de pago o de datos personales.

Escéptico: Los botones con basura están en las transcripciones: Wikipedia [«Desde arriba hacia abajo…Vista de la Playa…»] · [«Mostrar en pantalla completa»] · [«Reproducir audio»]; ANSES [«Política de Privacidad»] · [«Política de Cookies»]; ML [«Abrir app…»] · [«Crear cuenta»] · [«Suscribirme desde $ 5.490»] · [«Configurar cookies»]; Banco [«Términos y Condiciones»]; y en Clarín el primero es [«Ya tenés tu tarjeta 365?, Ingresá los datos…»]. Se juzga si la primera opción era buena, no el toque del script, y no lo era. candidates() no filtra nada salvo por largo (≥12).

### P07 · «¿Dónde estoy?» repite la lista, y al abrir la app no se presenta

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: primera-vez

Evidencia:
- Paso 3: «no entiendo, ¿dónde estoy?» contestado con «Resultados para «La Nación». Los 3 más probables:», los mismos botones y la misma lista hablada dos veces seguidas. Roberto lo marcó bloqueante.
- Roberto: «Al abrir la app no escuché ningún saludo ni una explicación de qué es. Tuve que preguntar yo.»
- «Para empezar, un sitio o algo para buscar; o una de estas opciones.»: la frase no tiene verbo.

Causa probable: El router interpreta la pregunta como `orientar`, y carry(.orientar) llama a arrived(page). En la página del buscador, arrived() vuelve a llamar a present() con la misma lista. El texto de bienvenida del panel («Escribir a dónde ir o qué buscar…») se muestra pero nunca se anuncia. La frase de .orientar sin página quedó escrita sin verbo.

Propuesta: `orientar` tiene que explicar el estado, no repetir la última salida. En el buscador: «Estás en una búsqueda: buscaste La Nación y encontré tres sitios. El primero es el diario. ¿Lo abro?», con [Abrir La Nación] y [Empezar de nuevo]. Anunciar una bienvenida corta la primera vez: qué es JEF, arriba la página y abajo la conversación. Y la frase: «Para empezar, decime un sitio o qué buscar, o tocá una de estas opciones.»

Escéptico: En primera-vez paso 3, «no entiendo, ¿dónde estoy?» se contesta con el mismo «Resultados para «La Nación». Los 3 más probables:» y la misma lista hablada (en cola a +35.1s, justo después de la del paso 2). En el código, .orientar llama a arrived(page), que en el buscador vuelve a llamar a present(). En registro.jsonl no hay ninguna «voz» antes del primer pedido: el texto de bienvenida de AssistantPanel.swift:58 sólo se ve. La frase «Para empezar, un sitio o algo para buscar; o una de estas opciones.» (Assistant.swift:377) no tiene verbo.

### P08 · Los anuncios se encolan y nunca se cortan: lo que pedí suena hasta dos minutos tarde

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, primera-vez, clima-cordoba, otra-cosa

Evidencia:
- La Nación paso 6: «Volviendo.» se escribe a los +60.6s y empieza a sonar a los +165.1s.
- La Nación paso 2: tocó a los +15.1s y «Abriendo lanacion.com.ar.» suena a los +29.7s.
- Wikipedia: «Fin de la nota.» se escribe a los +47.9s y suena a los +186.7s. Otra cosa: «¿Qué otra cosa hacemos?…» se escribe a los +27.5s y suena a los +50.8s.
- ML: «Está en la portada…» suena a los +34.0s, cuando la página ya era el captcha (+25.2s). El aviso del captcha suena a los +60.1s.
- Marta: «al final escuchaba con casi dos minutos de atraso… Nunca sé a qué responde lo que escucho».

Causa probable: Voz.decir() (Engine/Registro.swift) publica todo con .accessibilitySpeechQueueAnnouncement = true, y nadie vacía la cola: ni ask(), ni accept(), ni goBack() cortan lo que venía sonando. Encima se encolan respuestas de 300 a 750 caracteres, la lista hablada de resultados (`aloud`) y una línea por cada renglón de describe() y readAloud().

Propuesta: Tener una cola propia en Voz que diga un anuncio por vez y avance con announcementDidFinishNotification. Cada acción de la persona (enviar, tocar, Otra cosa, escape) vacía esa cola y dice su confirmación sin encolar, para que interrumpa. Sólo se encadena la lectura continua que se pidió (Leer, Seguir leyendo). Lo que quedó de un turno anterior sin sonar se descarta.

Escéptico: El mecanismo es cierto: Voz.decir() siempre publica con .accessibilitySpeechQueueAnnouncement=true y nada descarta lo viejo. Sin ninguna acción de la persona pasa en ML: el captcha carga a +25.2s y su aviso queda detrás de «Está en la portada…», que describe una página que ya no está. Los atrasos entre turnos (+60.6→+165.1s, +47.9→+186.7s, «dos minutos») los infla el arnés: el script actúa sin VoiceOver cada 7 a 10 s. Con VoiceOver, mover el cursor corta la cola (lo dice el commit 031b3a2), así que esa cifra no se sostiene tal cual.

### P09 · Todo pasa por una lista de resultados, aunque el sitio sea obvio, y hasta con el ejemplo propio «Llevame a La Nación»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, primera-vez, clima-cordoba, otra-cosa

Evidencia:
- «llevame a la nación» → «Buscando: la nación.» «Resultados para «la nación». Los 3 más probables:»
- Primera vez: el botón [Llevame a La Nación] devuelve una lista con «2. Banco de la Nación Argentina — www.bna.com.ar». Verificador: «no llevó a ningún lado: armó una búsqueda y pidió elegir».
- «entrá a mercado libre…» → «Resultados para «mercado libre». Los 3 más probables:». Marta: «me hizo elegir entre tres Mercado Libre».
- Roberto: la lista se lee con títulos largos y «www», unos 20 s, por ejemplo «En Vivo | Los Detalles Y El Cronograma Oficial Del Papa León Xiv a La ... — www.youtube.com».

Causa probable: Es una decisión explícita en Assistant.arrive(): «Un buscador nunca navega solo: muestra la lista.» named() ya reconoce el sitio exacto (lanacion, mercadolibre, clarin, bna), pero sólo se usa para ordenar. Los ejemplos del inicio (starters) son pedidos sin href que vuelven a pasar por el router y el buscador.

Propuesta: Abrir directo cuando se cumplan tres cosas: el dominio coincide exacto con lo pedido (labels), es del país (closer == 2) o está en una lista corta de sitios conocidos, y es la portada (depth 0). Decir «Abriendo La Nación, lanacion.com.ar.» y ofrecer [No era ese], que muestra la lista. Darles a los ejemplos del inicio un href fijo. La lista queda para cuando hay duda de verdad, dicha con nombres cortos y sin «www». El cambio sin commitear acorta la lista hablada, pero no las etiquetas de los botones.

Escéptico: En los 10 escenarios el primer paso es «Buscando:…» y después «Resultados para «…». Los 3 más probables:», también para «llevame a la nación», «clarín» y «mercado libre», y para el botón de ejemplo [Llevame a La Nación], cuya lista trae «2. Banco de la Nación Argentina — www.bna.com.ar». El código lo confirma: arrive() dice «Un buscador nunca navega solo: muestra la lista», y los starters tienen href: "". La lista de La Nación incluye «En Vivo | Los Detalles Y El Cronograma… — www.youtube.com».

### P10 · Sitios no oficiales o ajenos entre «los más probables», sin aviso

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: turno-anses, solo-botones-clarin, primera-vez, noticias-la-nacion, otra-cosa

Evidencia:
- ANSES: «1. Turnos ANSES - ️ Sacar turno en ANSES — turnosanses.net. 2. Solicitar turnos en ANSES - Argentina.gob.ar». En paginas/01.txt el oficial era el 1.° y turnosanses.net el 4.°.
- Al entrar: «Está en la página de Turnos ANSES…», aunque el pie de la página dice «Este portal no es un sitio oficial perteneciente al Gobierno de Argentina.»
- Clarín: «3. Último Momento - Clarín.com — web-clarinsandbox.lilax.io».
- La Nación: [Banco de la Nación Argentina — www.bna.com.ar], YouTube e ingresar.lanacion.com.ar como opciones. Lucía: «En trámites y bancos eso me preocupa por mis datos.»

Causa probable: Con `naming: true`, ranked() pone primero lo que devuelve named(). named() toma como «el sitio nombrado» cualquier dominio cuyo nombre sea la consulta pegada: «turnos anses» → «turnosanses», que coincide exacto con turnosanses.net. El cambio sin commitear (isOfficial primero, filtro sandbox|staging) resuelve lo de Clarín pero no esto, porque named() se sigue anteponiendo. orient() no lee si la página dice que no es oficial.

Propuesta: Si la consulta nombra un organismo, que un .gob.ar/.gov.ar le gane a named(). Que named() exija closer == 2, o que el dominio no agregue palabras a lo pedido: «turnosanses» no es «anses». En trámites, marcar «(no oficial)» los resultados fuera de .gob.ar, y avisar al llegar si la página se declara no oficial. Cuando se pidió ir a un sitio, sacar de la lista las páginas de ingreso (ingresar.*) y YouTube.

Escéptico: En paginas/01.txt de ANSES el oficial (argentina.gob.ar) es el 1.° y turnosanses.net el 4.°, pero JEF lo pone primero («1. Turnos ANSES - ️ Sacar turno en ANSES — turnosanses.net»). Pasa porque flatten("turnos anses")="turnosanses" coincide exacto con labels(). Al llegar dice «Está en la página de Turnos ANSES…», y paginas/02.txt:106 dice «Este portal no es un sitio oficial…». Clarín lista «web-clarinsandbox.lilax.io» y La Nación, bna/youtube/ingresar. El tap mecánico no es la causa: la primera opción era mala.

### P11 · Lo que se dice no coincide con los botones: titulares sin botón y opciones prometidas que no existen

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, dolar-desde-cero, clima-cordoba, otra-cosa

Evidencia:
- Clarín paso 2: el resumen nombra «7 millones… León XIV», «Adorni… criptomonedas» y «Carlos Alonso», pero el primer botón es [Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»], y las dos primeras notas no tienen botón.
- Dólar: «Opciones: Aceptar, Rechazar.» con botones [Leer la página] · [Resumir la página] · [Volver a la página anterior].
- Clima: «Puedo abrir uno, leer más, o buscar otra cosa.», sin ningún botón para abrir. Deportes: «Puedo leer una, resumir la página, o buscar otra cosa.» con [Leer los titulares] · [Resumir la portada].
- Clarín paso 5: «o registrarse con un correo electrónico», y el botón del correo ya no estaba.

Causa probable: orient() devuelve el texto y las sugerencias por separado, y nada comprueba que los «abrir» sean los titulares que nombró. describe() nombra 3 notas o ítems pero no guarda lastChunk/lastDone, así que followUps() no ofrece abrirlas. Además agregaba «Puedo abrir uno…»; el cambio sin commitear lo saca, falta probarlo. Las opciones del aviso (overlay.choices) se dicen pero nunca se convierten en botones.

Propuesta: Pedirle al modelo los números de los titulares que nombra y armar los botones con esos mismos números, en el mismo orden; si no coinciden, rehacer el texto. Cuando describe() nombra 3 notas, guardar lastChunk con esas 3 para que salgan sus [Abrir «…»]. Convertir overlay.choices en botones: [Rechazar cookies] primero, [Aceptar cookies] después. La regla del extractor es no decidir por la persona, no esconderle la opción.

Escéptico: En Clarín paso 2 el texto nombra «7 millones… León XIV», «Adorni… criptomonedas» y «Carlos Alonso», pero los botones son [Ganadores y perdedores…], [Carlos Alonso] y [Rafecas…]: las dos primeras notas nombradas no tienen botón. En Dólar dice «Opciones: Aceptar, Rechazar.» con [Leer la página]·[Resumir la página]·[Volver…]. En Clima dice «Puedo abrir uno…» sin ningún botón para abrir. En Clarín paso 5 menciona «registrarse con un correo electrónico» y el botón de correo ya no está.

### P12 · Los resúmenes cambian el sentido de lo que dice la página

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, mercadolibre-auriculares, banco-nacion, clima-cordoba

Evidencia:
- «…calificó como "matices de opinión" las internas en el Ejecutivo el 21 de septiembre de 2026 a las 00:00»: es la hora de publicación de la entrada, y la página dice «este domingo». También «…por el atentado a la AMIA a las 12:30» y «hace 3 minutos».
- «se preparan 70 horas de frenesí para evitar que la visita del Papa se politice» (la volanta pegada al título). «el operativo de seguridad más grande de la historia», sin las comillas que tiene en la página.
- Clarín: «el plan Digital por $930 al mes». La página dice «Durante 6 meses… Luego $18.780 /mes».
- ML: «envíos gratis desde 15000 pesos», que es un beneficio de la suscripción paga. ML paso 3: «solo pide un paso de seguridad para iniciar sesión», cuando era el captcha.
- Banco: «La página pide recordar el DNI». Clima: «La probabilidad de lluvia en Córdoba es del 0%.», sin decir que es para mañana.

Causa probable: Los prompts de summarize() y orient() piden «los hechos concretos: qué pasó, quién, cuándo, las cifras» y, en una cobertura en vivo, «lo último que informa». Pero reciben saying(page), que mezcla la nota con titulares relacionados, horas de publicación y volantas. La verificación de «cifras» sólo comprueba que el número exista en la página, no su condición (promoción de 6 meses, beneficio para suscriptores). Frente al captcha, reply() le pregunta al modelo en vez de usar lo que ya se sabe (overlay .captcha).

Propuesta: Para una nota, pasarle al modelo sólo el cuerpo de Readability, con las horas del vivo marcadas como «[publicado 12:30]» y la instrucción de no usarlas como hora del hecho. Mantener las comillas de las declaraciones. Con precios, copiar la condición («durante 6 meses; después $18.780»). Comprobar que cada cifra aparezca junto a su condición, en la misma línea de la página. Con overlay .captcha, contestar por plantilla con la misma frase del paso anterior. Si la pregunta nombra un día, repetirlo en la respuesta («mañana»).

Escéptico: Todo se comprueba en paginas/: «00:00, 21 de Septiembre de 2026» es la hora de la entrada y el texto dice «este domingo»; «12:30» y «Hace 3 min» también son horas de entradas. La página dice «70 horas de frenesí. Tres misas y… para tratar de evitar que…se politice» y «“más grande la historia”», con comillas. Clarín dice «$930 /mes Durante 6 meses Luego $18.780 /mes» y el resumen omite la condición. En Banco, «Recordá tu DNI» es una opción y el resumen dice «pide». Son más débiles lo de ML («envíos gratis desde 15000», que está en el bloque de Meli+) y Clima (la página dice «mañana» y la respuesta lo omite).

### P13 · Titulares y listas con ruido de la página: «Hace 34 min», secciones contadas como notas, títulos cortados a mitad de palabra

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, otra-cosa, turno-anses, clima-cordoba

Evidencia:
- «se cumplen 34 minutos de las Medidas de Milei, el dólar hoy está actualizado hace 28 minutos».
- «1. Medidas de Milei, Hace 34 min / 2. Dólar hoy, Hace 28 min» y «Titular 3 de 154.». Botón [Abrir «Medidas de Milei, Hace 34 min»].
- Deportes: «…el camino a los playoffs y las copas, y el des», y «Además, cómo está la tabla anual…» contada como otra nota cuando es la bajada de la primera.
- ANSES: [Abrir «Solicitud de Jubilación, , ver sub-trámites»] y «Turnos ANSES - ️ Sacar turno…», con el hueco de un emoji.
- «En Clima mañana en Córdoba, Cordoba — eltiempoen.com.» y «En Noticias de Deportes — LA NACION.»

Causa probable: headlines(of:) toma cualquier enlace que sea encabezado, incluida la cinta «VIVO» con su «Hace N min», y los cuenta todos (154). describe() corta con String(title.prefix(120)) en vez de usar Self.short(), que corta en una palabra. En extract.js, los rótulos se arman uniendo segmentos con «, » sin descartar los vacíos (dedupeSegments no los filtra), y no se limpia el selector de variante de emoji. describe() lee el título crudo de la página, con «—» y el dominio.

Propuesta: En headlines(): quitar las marcas de tiempo relativas (,? Hace N min/h), descartar los rótulos de sección cortos y los de la cinta en vivo, juntar título y bajada cuando hablan de lo mismo, y contar sólo notas reales. En describe(): usar short() y una frase («Estás en Deportes de La Nación»). En extract.js: filtrar los segmentos vacíos al unir y sacar los U+FE0F sueltos.

Escéptico: Todo aparece en las transcripciones. En noticias-la-nacion, la portada se describe como «se cumplen 34 minutos de las Medidas de Milei», se lee «1. Medidas de Milei, Hace 34 min» y «Titular 3 de 154.». En otra-cosa, el titular sale cortado en «…y las copas, y el des» (justo 120 caracteres, el String(title.prefix(120)) de Assistant.swift:1801/1826), y «Además, cómo está la tabla anual…» se cuenta como otra nota aunque en paginas/03.txt aparece justo debajo de ese título, como su bajada. En ANSES están el botón «Solicitud de Jubilación, , ver sub-trámites» y el U+FE0F suelto (bytes ef b8 8f) en «Turnos ANSES - ️ Sacar turno», y en clima se dice «En Clima mañana en Córdoba, Cordoba — eltiempoen.com.».

### P14 · Wikipedia: la lectura empieza con avisos, lee las referencias y dice «Fin de la nota» después de la introducción

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata

Evidencia:
- Paso 4: «ciudad de la provincia de Buenos Aires, Argentina» / ««Marplatense»  redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).» / … / «Párrafo 3 de 6.»
- Paso 5: «…«Puerto de la Laguna de los Padres». [2 ]» … «[4 ] [5 ]».
- Paso 5: «Fin de la nota.», pero paginas/02.txt sigue con Historia, Demografía, Geografía… (plegadas en la versión móvil).
- Lucía: «Seguir leyendo me tiró tres párrafos de una vez, casi un minuto y medio sin poder frenar.»

Causa probable: readablePieces() acepta cualquier párrafo de 40 letras o más, así que entran la descripción corta y la nota de redirección, y cuentan en el total. No se sacan los <sup> de las referencias. Las secciones de la versión móvil llegan plegadas: sólo sus títulos, no su texto. readAloud() dice «Fin de la nota» cuando se termina lo extraído, y lee de a 3 pedazos de hasta 600 caracteres.

Propuesta: En extract.js, saltar .hatnote, .shortdescription y las notas de desambiguación, y quitar sup.reference. Desplegar las secciones antes de extraer; si quedan plegadas, decir «Fin de la introducción. Siguen: Historia, Geografía, Economía…», con esas secciones como botones. «Seguir leyendo» de a un párrafo, o de a unos 40 s. Decir «artículo» en Wikipedia.

Escéptico: En el paso 4, «leeme la nota» empieza con «ciudad de la provincia de Buenos Aires, Argentina» y con la nota «Marplatense redirige aquí…», que cuentan en «Párrafo 3 de 6.». En el paso 5 se leen las llamadas «[2 ]» y «[4 ] [5 ]» y después «Fin de la nota.», aunque paginas/02.txt sigue con Historia, Demografía, Geografía… (sólo los títulos, sin su texto). «Seguir leyendo» mandó tres párrafos de una vez: unos 1.150 caracteres, alrededor de 84 s a 14 caracteres por segundo.

### P15 · Respuestas largas al llegar a una página, aun con una tarea pendiente

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, mercadolibre-auriculares, solo-botones-clarin, otra-cosa

Evidencia:
- Nota de Milei: unos 750 caracteres con seis titulares de otras notas («Los titulares principales son: La Justicia Federal ordenó…»). Roberto: «Fueron casi 50 segundos… y todavía no sé de qué trata la nota que abrí».
- ML: «Se muestran ofertas con hasta 45% de descuento y hasta 18 cuotas sin interés en electrobeauty, accesorios y moda…», cuando la búsqueda de auriculares ya estaba pedida.
- Clarín: los tres planes con sus precios. Portada de La Nación: «El dólar oficial está a $1535,00, el dólar blue a $1550,00…».
- Ana: «Me escribió un bloque larguísimo… Ocupa toda la conversación y los botones quedan fuera de la pantalla.»

Causa probable: orient() recibe saying(page), que en una nota en vivo trae muchos titulares como si fueran contenido, y su prompt permite «la lista de titulares» sin tope. En accept(), landed() (con orient() completo) corre antes de continueWith(waiting), aunque haya una tarea esperando.

Propuesta: Al llegar, una frase de dónde está y otra de qué hay, con tope de unos 200 caracteres. En una nota, sólo el título y el tipo («Nota en vivo: Milei y sus medidas»), sin titulares de otras notas. Si `waiting` tiene algo, no orientar: «Entré a Mercado Libre. Busco auriculares bluetooth.» y seguir. Las cotizaciones de la portada, como botón [Ver cotizaciones]. Los montos, sin «,00».

Escéptico: Al abrir la nota de Milei, JEF escribió 758 caracteres, y la mayor parte eran titulares de otras notas («Los titulares principales son: La Justicia Federal ordenó…»). En Mercado Libre, a los +20.9s describió las ofertas de la portada («hasta 45% de descuento…») antes de «Sigo con: buscame auriculares bluetooth.», aunque esa tarea ya estaba esperando. En otra-cosa, la portada de La Nación terminó con las cotizaciones («$1535,00…»). En paso-04.jpg de La Nación el bloque ocupa todo el panel y no se ve ningún botón. En Clarín el texto es más corto (295 caracteres), pero igual enumera los planes con sus precios.

### P16 · «Otra cosa» tarda en responder y no lleva el cursor de VoiceOver al campo

*grave* · del script de prueba · jueces: Marta, Roberto, Lucía, Verificador 2 · escenarios: otra-cosa

Evidencia:
- «¿Qué otra cosa hacemos? Se puede escribir o dictar.» se escribe a los +27.5s y suena a los +50.8s. La persona escribió a los +37.0s sin haberla oído.
- Marta: «el cursor queda en esa frase en vez de ir al campo». También: «me explica que puedo escribir o dictar, cosa que ya sé».
- Roberto: «Tampoco me dijo dónde está el campo para escribir».

Causa probable: La frase queda en cola detrás del resumen anterior (P08). AssistantPanel.placeFocus() mueve el foco de VoiceOver al campo sólo cuando `settled` (Habla.pendientes == 0), o sea recién cuando se vació la cola. `writing = true` abre el teclado pero no mueve el cursor de VoiceOver.

Propuesta: Al tocar «Otra cosa», cortar la cola, poner `focused = "campo"` enseguida, sin esperar `settled`, y decir sólo «¿Qué hacemos?». Dejar el botón [Volver a las opciones] (P05).

Escéptico: La demora sale de que el script tocó «Otra cosa» a los +27.5s, apenas 0.4 s después de que empezara a sonar un resumen de 23 s (+27.1s). Para llegar a ese botón, alguien con VoiceOver tiene que mover el cursor, y eso corta lo que se está diciendo: el propio comentario de Habla lo dice («moverlo hace que VoiceOver lea el elemento nuevo, y eso corta lo que quedaba en la cola»). Así que el «suena a los +50.8s» no se sostiene. Lo del cursor tampoco está probado: el registro no anota a dónde fue el foco, y AssistantPanel.placeFocus() pone focused = "campo" cuando llega un inputRequest. Que el cursor vaya a la última línea es la regla general que describe el arnés, no lo que hace el código en «Otra cosa».

### P17 · Con baja visión, los botones y a veces la respuesta quedan fuera de la pantalla

*grave* · confirmado · jueces: Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, clima-cordoba, otra-cosa, primera-vez

Evidencia:
- Ana: «de los botones sólo se ve una rayita azul abajo de todo» (La Nación, pasos 2 a 5).
- ML: «Sigo con: buscame auriculares bluetooth.» es lo último que se ve, y la explicación del captcha quedó abajo (paso-02.jpg).
- Wikipedia: «El párrafo largo queda cortado abajo y 'Seguir leyendo' no se ve».
- paso-03.jpg de primera-vez: «Otra cosa» fuera de la vista. paso-04.jpg de ANSES: «Otra cosa» cortado.

Causa probable: AssistantPanel hace scrollTo(responseStart, anchor: .top), que ancla el comienzo de la respuesta: si es larga, los botones quedan debajo. Cuando la respuesta se arma en varios pasos (en ML, portada y después captcha), el ancla queda en la primera línea. El panel ocupa el 55 % de la pantalla y no hay nada que avise que hay más abajo.

Propuesta: Sacar los botones del ScrollView y fijarlos encima del campo, siempre visibles, o plegar la página cuando llega una respuesta larga. Si el último mensaje es un problema (captcha, error), anclar ahí. Mostrar un indicador de «más abajo». Con Texto Grande, darle prioridad a la conversación.

Escéptico: Las capturas lo confirman. En La Nación, paso-02.jpg muestra sólo el borde azul de un botón abajo de todo y en paso-04.jpg no se ve ningún botón. En Mercado Libre, paso-02.jpg termina en «Sigo con: buscame auriculares bluetooth.» y los mensajes del captcha quedan fuera de la vista. En Wikipedia, paso-04.jpg corta el párrafo y no se ve «Seguir leyendo». En primera-vez, paso-03.jpg deja «Otra cosa» fuera de la vista, y en ANSES paso-04.jpg lo corta. Pasa por el scrollTo(responseStart, anchor: .top) que está en AssistantPanel.

### P18 · La página de arriba no muestra aquello de lo que habla JEF

*grave* · confirmado · jueces: Ana, Verificador 1, Verificador 2 · escenarios: clima-cordoba, dolar-desde-cero, solo-botones-clarin, mercadolibre-auriculares

Evidencia:
- Clima: «Arriba la página estaba bajada hasta el pie, con el logo»: se veía «eltiempoen.com © 2026 Contacto Política de privacidad».
- Dólar: «Este sitio utiliza cookies» tapó la mitad de la página toda la sesión.
- Clarín: el cartel «Acceder a Clarin.com con Google — Continuar» y la ventana «¡Aprovechá esta Súper promo!», que JEF no menciona.
- Clima: la página vino en °F («63º 40º»). Ana: «si la leo yo, me asusto».

Causa probable: extract.js baja hasta el final para despertar el contenido que carga al desplazar. ReaderModel.go() llama a scrollToTop() después, pero pageChangedOnItsOwn() no; en eltiempoen.com hubo una segunda extracción a los +19.5s. Nadie desplaza la página al bloque del que se está hablando. JEF no cierra avisos, por diseño, y tampoco los ofrece como botón.

Propuesta: Llamar a scrollToTop() también después de cada extracción espontánea. Desplazar (scrollIntoView) al bloque que se está leyendo o citando. Ofrecer [Cerrar el aviso] o [Rechazar cookies] como botón (P11). Dar las temperaturas en °C, o decir la unidad.

Escéptico: En clima, paso-02.jpg y paso-03.jpg muestran la página bajada hasta el pie («eltiempoen.com © 2026 Contacto…», con el logo). En dólar, paso-02.jpg y paso-03.jpg muestran el aviso «Este sitio utiliza cookies» tapando la mitad de la página. En Clarín, paso-02.jpg tiene el cartel «Acceder a Clarin.com con Google — Continuar» y paso-03.jpg la ventana «¡Aprovechá esta Súper promo!», que el resumen no menciona. extract.js hace window.scrollTo(0, height) y sólo go() llama a scrollToTop(). Un matiz: la página vino en °F (hay «63º 40º», mph, in), pero el simulador está en es_AR, así que probablemente lo decidió el sitio según la red desde donde corrió la prueba. Además, JEF nunca dijo una temperatura.

### P19 · Etiquetas de botones cortadas con «…» y con ruido, también para VoiceOver

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 1 · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, otra-cosa

Evidencia:
- [Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»] y el eco «Abriendo «Quiénes son los ganadores y los perdedores tras la definición de la…»».
- [Abrir «Enriquecimiento. Adorni dijo ante la Justicia que su evolución…»]. Marta: «Con el rotor no sé de qué es la nota».
- Resultados con el título crudo y «www»: [Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar].

Causa probable: arrived() y followUps() arman la etiqueta con Self.short(label), que corta a 70 caracteres. El panel usa esa misma etiqueta como texto visible y como accessibilityLabel, y el eco de accept() la repite cortada. Los resultados usan título y dominio sin limpiar.

Propuesta: Guardar el título completo y limpio en la acción y usarlo como accessibilityLabel; cortar sólo lo que se ve (lineLimit). En los resultados, «La Nación (lanacion.com.ar)», sin «www» y sin el eslogan. Eco: «Abriendo la nota: <título completo>».

Escéptico: Pasa tal cual y llega a VoiceOver. El árbol de accesibilidad (solo-botones-clarin/arbol-02.txt, línea 8) tiene «[btn] Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»», el eco repite «Abriendo «Quiénes son … de la…»» y en noticias-la-nacion/arbol-01.txt figura «Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar». No es un corte del arnés: en el mismo árbol los textos largos del asistente aparecen enteros; el «…» ya viene en la etiqueta que arma la app (Self.short, 70 caracteres).

### P20 · Trato de usted en las respuestas del modelo y de vos en la interfaz

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion

Evidencia:
- «Está en la página de LA NACION…» contra «Estás en La Nación, la portada de noticias.»
- «La página indica que para continuar debe iniciar sesión.»
- «Está en la portada de Mercado Libre Argentina.»

Causa probable: Los dos prompts de Answerer (instructions y orient) dicen «No tutees ni voseés… usá la primera persona o formas que valen igual para todos». El modelo lo resuelve con usted o tercera persona, mientras la interfaz y las plantillas usan vos.

Propuesta: Si el idioma del teléfono es español de Argentina, pedir voseo rioplatense explícito en los dos prompts («Estás en…», «tenés que iniciar sesión»).

Escéptico: El modelo usa usted o tercera persona en casi todos los escenarios, y hasta es inconsistente consigo mismo. En La Nación, el paso 2 dice «Estás en La Nación, la portada…» y el paso 4 «Está en la página de LA NACION…». En Clarín: «para continuar debe iniciar sesión»; en Mercado Libre: «Está en la portada de Mercado Libre Argentina». Los prompts de Answerer.swift (líneas 78 y 218) piden «No tutees ni voseés».

### P21 · Botones con un nombre que no corresponde a la página

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: wikipedia-mar-del-plata, otra-cosa, noticias-la-nacion, solo-botones-clarin

Evidencia:
- Wikipedia: [Leer el artículo completo], puesto por el modelo, y después [Leer la nota], el fijo.
- Deportes: [Resumir la portada].
- Ya en la portada: [Volver a la página anterior]. Ana: «No sé si me lleva a la nota o al buscador».
- [Ver más opciones (1)]. Ana: «No entiendo qué es ese '(1)'».

Causa probable: followUps() usa etiquetas fijas según la forma de la página: isArticle da «nota» y readsHeadlines da «portada». El botón Volver no nombra el destino, aunque HeadlessWebView.backURL lo tiene. present() usa «(n)».

Propuesta: Nombrar según el sitio y el tipo: artículo (Wikipedia), nota (diario), sección (Deportes), página. «Volver a <título anterior>». «Ver 1 opción más» o «Ver 3 opciones más».

Escéptico: Está todo en las transcripciones. En Wikipedia aparece primero [Leer el artículo completo], después [Leer la nota] y al final «Fin de la nota.». En Deportes (otra-cosa, paso 4) el botón dice [Resumir la portada]. Clarín y otra-cosa muestran [Ver más opciones (1)]. De vuelta en la portada (La Nación, paso 6) queda [Volver a la página anterior] sin nombrar el destino: no es un error, pero es ambiguo.

### P22 · Después de un dato: sin fuente y con botones genéricos

*menor* · confirmado · jueces: Roberto, Lucía, Ana · escenarios: dolar-desde-cero, clima-cordoba

Evidencia:
- «El dólar oficial, al 21 de septiembre a las 11:03 horas…» sin decir de dónde sale. Lucía: «¿es el del Banco Nación, un promedio…?».
- Tras el dato, los botones son [Leer la página] · [Resumir la página] · [Volver a la página anterior]. Roberto: «Ofrecer «¿Y el blue?» y «Otros dólares (MEP, tarjeta)»».

Causa probable: reply() devuelve sólo el texto del modelo, y closeTurn() arma los botones con followUps() según la forma de la página, sin relación con la pregunta.

Propuesta: Cerrar con la fuente («según dolarinfohoy») y ofrecer las preguntas vecinas como botones de pedido (askPrefix): «¿Y el blue?», «¿Y el MEP?», «¿Y pasado mañana?».

Escéptico: La respuesta «El dólar oficial, al 21 de septiembre a las 11:03 horas, tiene un precio de compra de $1.482,52…» y la de «La probabilidad de lluvia en Córdoba es del 0%.» no nombran la fuente. En los dos casos cierran con [Leer la página] · [Resumir la página] · [Volver a la página anterior]. Matiz: el sitio sí figura tres líneas más arriba («Abriendo dolarinfohoy.com.ar.»), pero no en la respuesta.

### P23 · Las opciones que se reemplazan no quedan escritas

*menor* · confirmado · jueces: Roberto · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, banco-nacion, clima-cordoba, otra-cosa

Evidencia:
- Al repasar con el dedo queda «Resultados para «la nación». Los 3 más probables:» y después nada. Roberto: «No sé qué había ni qué elegí».

Causa probable: present() escribe sólo el encabezado, para no repetir lo que ya son botones; la lista va sólo en voz (`aloud`). Cuando la oferta se reemplaza, la lista se pierde.

Propuesta: Al reemplazar una oferta, dejar escrita una línea corta con lo que había y lo elegido: «Había: el diario La Nación, su canal de YouTube, la página de ingreso. Elegiste el diario.»

Escéptico: En todos los árboles, después de «Resultados para «…». Los 3 más probables:» la lista desaparece: la lista sólo va en 🔊 y los botones se reemplazan. En cambio «qué elegí» sí queda escrito: la línea que sigue es «Vos: Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar». Lo que se pierde son las opciones que había, no la elegida.

### P24 · El campo de escribir y el botón Enviar casi no se ven

*menor* · confirmado · jueces: Ana · escenarios: primera-vez, otra-cosa, noticias-la-nacion

Evidencia:
- Ana: «el campo de abajo dice '¿Qué querés hacer?' en gris clarito sobre gris, y a mí me cuesta muchísimo verlo». También: «el botón de enviar también es gris».

Causa probable: En AssistantPanel, el texto guía del TextField va con .foregroundStyle(.secondary) sobre Color(.tertiarySystemFill), y el botón Enviar se muestra deshabilitado (gris) mientras el campo está vacío.

Propuesta: Poner el texto guía en .primary con opacidad alta, o fondo systemBackground con borde marcado. Enviar, con el color de acento siempre visible. Respetar Texto Grande también en el campo.

Escéptico: La captura primera-vez/paso-01.jpg muestra «¿Qué querés hacer?» en gris muy claro sobre la cápsula gris clara y el botón Enviar como un círculo gris (deshabilitado con el campo vacío). En AssistantPanel.swift: prompt con .foregroundStyle(.secondary), fondo Color(.tertiarySystemFill) y .disabled(text…isEmpty).

## Lo que funciona

- «dame los titulares» respondido en medio segundo con una lista numerada, más el botón «Seguir con los titulares» y el «Titular N de M» (Marta, Lucía, Roberto).
- Volver es corto y ubica: «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.» (goBack). Lo valoraron los cuatro.
- Después de un resumen, los botones [Leer la nota] · [Volver a la página anterior] · [Otra cosa] eran justo los necesarios (followUps).
- Los datos puntuales, precisos y rápidos. Por ejemplo, «El dólar oficial, al 21 de septiembre a las 11:03 horas, tiene un precio de compra de $1.482,52 y un precio de venta de $1.534,23.» llegó en 1,5 s y coincide exacto con la página. También «Mar del Plata fue fundada el 10 de febrero de 1874 por Patricio Peralta Ramos.» y «El número de teléfono para solicitar turno es el 130.»
- Entiende los seguimientos en contexto: «¿y el oficial?», sin repetir la pregunta (previousRequest).
- «llevame a deportes» estando en La Nación fue directo a la sección, sin buscador. Marta: el mejor momento de todas las pruebas.
- Guardar la segunda parte del pedido y seguirla solo: «Cuando elijas, sigo con: buscame auriculares bluetooth.», y después buscar dentro del formulario del sitio (waiting + continueWith).
- Honestidad ante lo que no puede: «El sitio me puso una verificación de «no soy un robot». Eso no lo puedo resolver yo.» El detector reconoció el reCAPTCHA y la opción de audio.
- La presentación corta y sin condescendencia: «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen.», con tres ejemplos concretos como botones. La primera pantalla es limpia y tiene los 4 botones a la vista.
- En cada llegada dice qué clase de página es: «Estás en La Nación, la portada», «Home Banking del Banco Nación», «página de suscripciones», «inicio de sesión».
- En el buscador se saltean los anuncios pagos (fxterminal, ceifx, resortsguides, finditandmore, Amazon Appstore, newspapers.com). El primer resultado fue el correcto en La Nación, Clarín, Wikipedia, Mercado Libre y Banco Nación, y se descartó la Córdoba de España (Meteored).
- En una nota, «Leer el artículo completo» o «Seguir leyendo» quedan primeros, y el texto leído es literal y en orden.
- Todo en castellano, sin nombres internos, y con «Otra cosa» en cada paso. Otra cosa abre el teclado con el cursor en el campo (Ana lo vio bien).
- «Hay 35 notas. Las tres primeras:» dice cuánto hay y dónde se está.
- Los botones con texto oscuro y borde de color se leen bien cuando están a la vista (Ana).
- La ayuda del campo: «Con el dictado del teclado también se puede hablar.» (Roberto).
