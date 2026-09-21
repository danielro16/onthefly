# Veredicto — ronda-3

Ronda 3: 10 escenarios, 4 jueces y 40 juicios. Hubo 11 «sí», 15 «a medias» y 14 «no». JEF funciona para preguntas de dato con respuesta en una página: dólar (4,05 de 5) y clima (3,6). También funciona para moverse dentro de un diario (otra-cosa, 3,5). Falla en toda tarea que exige avanzar hacia un objetivo dentro de un sitio: Wikipedia (1,75), Mercado Libre (1,95), ANSES (2,5) y el banco (3,15, pero sin entrar). El motivo es casi siempre el mismo. Los botones se eligen sin conocer lo que la persona pidió: Answerer.orient no recibe el pedido. Ante un muro (nota paga, captcha, «usá la app», dato ausente) la única salida es «Volver». Le siguen, por peso, cuatro cosas: cambios de página que pasan en silencio (el captcha de Mercado Libre), resúmenes de otra página sin decir cuál, titulares mal armados por el extractor (cortes ciegos a 120 y 160 caracteres) y que nombrar un sitio siempre pase por la lista del buscador. Esto último es una decisión explícita en arrive().

Lo que se descartó o se matizó por ser del script o del entorno:
(1) El toque «Abrir «Escalada…»» que no hizo nada (La Nación, paso 4). En registro.jsonl no hay ningún evento, ni siquiera el «botones: []» con que arranca accept(). El script acababa de arrastrar el panel, y su propio comentario admite que un toque después de arrastrar puede sólo frenar el desplazamiento. Lo más probable es que el toque no llegara a la app. Queda en el problema de cambios silenciosos como riesgo real: accept() y goBack() descartan toques mientras el asistente trabaja, sin decir nada.
(2) Los DESCARTADO/CORTADO de la voz los produjo el ritmo del script, que actúa sin esperar a que termine la voz. El problema real del producto es el orden y el largo de los anuncios.
(3) Fahrenheit, mph y el cartel de donación «for readers in the United States» salen en parte de que la máquina de prueba está en EE.UU. Igual el producto no convierte ni avisa.

Ya arreglado después de la corrida, sin verificar todavía: el commit 1698f3d saca el código JS de los botones, hace que se diga la unidad tal como viene (no la convierte) y agrega la regla «Buscá X en Y» al ruteador. El diff sin commitear de Mercado Libre, que busca en internet si el buscador del sitio no responde, tapa el síntoma pero compite con navegaciones que llegan tarde.

Código en /Users/daniel/Developer/JEF- BROWSER/Sources. Transcripciones en /Users/daniel/Developer/JEF- BROWSER/Tests/corridas/ronda-3.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.5 |
| solo-botones-clarin | Marta no, Roberto a medias, Lucía a medias, Ana a medias | 2.8 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |
| wikipedia-mar-del-plata | Marta no, Roberto no, Lucía no, Ana no | 1.8 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 2.5 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 1.9 |
| banco-nacion | Marta a medias, Roberto no, Lucía a medias, Ana a medias | 3.1 |
| primera-vez | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 2.8 |
| clima-cordoba | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.6 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |

**Promedio general: 2.85**

## Problemas

### P01-botones-no-sirven-al-objetivo · El primer botón no acerca a lo que la persona pidió, y la acción que necesita no aparece aunque esté en la página

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: turno-anses, banco-nacion, wikipedia-mar-del-plata, mercadolibre-auriculares

Evidencia:
- turno-anses p2: «Podés pedir un turno por internet para ser atendido en una oficina de ANSES.» → [Abrir «Consultar en línea»] · [Abrir «Obtener Certificación Negativa de ANSES»]. La página tenía «Solicitud de turnos, Ingresá a Solicitud de turnos.» (paginas/02.txt:27).
- turno-anses p3: «te da la opción de pedir un turno para otros trámites o atención presencial.» → [Abrir «Cambio de obra social para trabajadores»] · [Abrir «Cambio medio de cobro jubilaciones y pensiones»] · [Abrir «Elegir medio de cobro…»] · [Abrir «Solicitar la Pensión No Contributiva…»]. El enlace «Solicitar un turno» estaba en la página (paginas/03.txt:29). El botón 1 llevó a obra social (p4) y JEF no avisó que se alejaba del turno.
- banco-nacion p2: «Te pide tu DNI y Usuario para continuar.» → único botón [Abrir «Recuperar usuario y contraseña»].
- wikipedia p2: en el portal, [Leer la nota] · [Abrir «Search Wikipedia»]. No hubo ningún «Buscar Mar del Plata».
- mercadolibre p2: con «buscame auriculares bluetooth» pendiente, [Abrir «GLAM DAYS PANTALONES…»] · [Abrir «GLAM DAYS REMERAS…»] · [Abrir «ACC, VEHÍCULOS…»] · [Abrir «Suscribirme desde $ 5.490»].

Causa probable: Answerer.orient(page:candidates:) (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:198) recibe el texto de la página y la lista numerada, pero nunca el pedido de la persona: elige botones «útiles en general». En turno-anses el ruteador convirtió todo el pedido en la búsqueda «turnos anses» sin `rest`, así que al llegar no quedaba objetivo guardado. Assistant.waiting sólo existe cuando hay `rest`. candidates(of:) (Assistant.swift:1612) pone primero los «titulares», que acá son listas de trámites, y corta en 30: «Solicitar un turno» compite en desventaja. Las sugerencias sólo pueden ser abrir, leer o resumir. No hay «buscar en este sitio» ni «ir al campo», así que en Wikipedia y en el banco el botón necesario no puede existir. Tampoco se controla que una acción que el texto menciona («te da la opción de pedir un turno») tenga su botón.

Propuesta: Guardar el objetivo de la sesión (el pedido original, no sólo `rest`) y pasárselo a orient() con esta regla: «el primer botón es el que avanza hacia el objetivo; si la página no sirve para eso, decilo y ofrecé volver». Agregar dos tipos de sugerencia: `buscarAca`, que usa el formulario de búsqueda del sitio con el tema pendiente («Buscar «Mar del Plata» en Wikipedia»), y `completar`, que lleva el foco al campo. En candidates(), subir los enlaces cuyo texto coincide con el objetivo («Solicitar un turno»). Si el texto de orientación menciona una acción que coincide con el objetivo y no hay botón para ella, agregarlo desde código. En trámites, decir en una frase qué hay que tener a mano (CUIL y Clave de la Seguridad Social, según la página).

Escéptico: Real en turno-anses p3: la página tenía «Solicitar un turno» (paginas/03.txt:29) y JEF ofreció «Cambio de obra social…», «Cambio medio de cobro…» y otros trámites online. También en banco p2, donde el único botón fue «Recuperar usuario y contraseña» con el formulario DNI/Usuario en pantalla, y en wikipedia p2, donde ofreció «Leer la nota» y ningún «Buscar Mar del Plata». Además `orient(page:candidates:)` (Answerer.swift:198) no recibe el pedido. Hay dos matices. En turno-anses p2 el botón 1 «Consultar en línea» sí acercó: llevó a anses.gob.ar/turnos. Y la evidencia de mercadolibre p2 corresponde a P05, no a un objetivo perdido: JEF sí siguió con la búsqueda («Buscando auriculares bluetooth en www.mercadolibre.com.ar.») y la navegación llegó tarde.

### P02-callejones-sin-salida · Ante un muro (nota paga, captcha, dato que la página no tiene, «usá la app») la única salida es «Volver»

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, mercadolibre-auriculares, wikipedia-mar-del-plata, banco-nacion

Evidencia:
- solo-botones-clarin p3: «Esa nota no se puede leer sin suscribirse o iniciar sesión: el sitio me llevó a «Landing suscripciones».» → [Volver a la página anterior] · [Otra cosa].
- solo-botones-clarin p5: vuelve a ofrecer [Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»], la nota que acababa de rebotar.
- mercadolibre p3: «La página me pide que complete un paso de seguridad para poder verla, así que no puedo decirte el precio de los auriculares más baratos.» → [Volver a la página anterior] · [Otra cosa].
- Ana (mercadolibre): «Yo veo. Podría haber tocado la casilla «No soy un robot» si me lo decía».
- wikipedia p3: «La página no tiene la información que buscás. Es la portada de Wikipedia y solo muestra un formulario para buscar y un pedido de donación.» → [Leer la nota] · [Resumir la nota] · [Volver…] · [Otra cosa].
- banco-nacion p3: «…que uses la app BNA+ para recuperar tu usuario y contraseña.» → [Abrir «Disponible en google play»] · [Abrir «Descárgalo en el app store»].

Causa probable: La rama de muro de accept() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1281-1286) arma la oferta sólo con «Volver» y nombra la página con page.sectionTitle. followUps() con captcha devuelve sólo «Volver» (Assistant.swift:1683-1685). El buen aviso de describe() para captcha («El sitio me puso una verificación de «no soy un robot»…», con la opción de audio) no se dijo porque el captcha llegó sin turno (ver P05). Cuando reply() contesta «no está en la página», nada ofrece buscarlo, aunque el ruteador ya sabe completar la pregunta con el tema («cuándo se fundó Mar del Plata»). No se recuerdan las notas que rebotaron, ni se usa el «Solo suscriptores» que Clarín pone en el texto de algunas tarjetas (paginas/05.txt).

Propuesta: Nota paga: «Es una nota para suscriptores.» con [Abrir la próxima nota], que es el siguiente titular no marcado, [Buscar esta noticia en otro diario] y «Volver». Recordar las URL pagas y no volver a ofrecerlas. Marcar «(para suscriptores)» cuando la tarjeta lo dice. Captcha: decir qué es (casilla, imagen, audio), ofrecer [Intentar de nuevo] y [Buscar en otra tienda], y para quien ve: «Arriba hay una casilla «No soy un robot»: tocala y sigo yo». Dato ausente: el primer botón es [Buscar «<pregunta con su tema>»]. «Usá la app»: [Bajar BNA+ del App Store].

Escéptico: Real en Clarín p3 («Esa nota no se puede leer…» → [Volver a la página anterior] · [Otra cosa]) y en Mercado Libre p3 (captcha → [Volver…] · [Otra cosa]). En Clarín p5 volvió a ofrecer como botón 2 la nota que acababa de rebotar. El título exagera en dos casos. En banco p3 sí había salida: [Abrir «Descárgalo en el app store»], aunque segundo, detrás de Google Play. En wikipedia p3 no sólo estaba «Volver»: estaban «Leer/Resumir la nota», inútiles pero presentes.

### P03-pierde-el-tema · «buscá mar del plata en wikipedia» buscó sólo «wikipedia» y abrió el portal multilingüe

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata

Evidencia:
- wikipedia p1: «Buscando: wikipedia.» (la URL fue q=wikipedia).
- wikipedia p1: botón 1 [Wikipedia — www.wikipedia.org], antes que [Wikipedia, la enciclopedia libre — es.wikipedia.org].
- wikipedia p2: «Estás en la portada de Wikipedia… Un mensaje te informa que en Estados Unidos el promedio de donación es de 13 dólares…»

Causa probable: El ruteador devolvió ir/buscar con target «wikipedia» y descartó «mar del plata» sin `rest`. El commit 1698f3d agregó la regla «Buscá X en Y» (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Router.swift:150-153), pero es de las 14:57, después de esta corrida (14:50): está sin verificar. Además, Assistant.named()/ranked() empatan www.wikipedia.org y es.wikipedia.org: la misma cercanía, y la misma profundidad porque «es» está en `suffixes`. Gana el primero del buscador, que es el portal. Que el cartel hable de «readers in the United States» es ambiental: la máquina de prueba está en EE.UU.

Propuesta: Confirmar 1698f3d en la ronda 4 con este mismo pedido. Como red en código: si el target del ruteador pierde los sustantivos del pedido (todo menos muletillas y el nombre del sitio), buscar el pedido completo. En empates por nombre, preferir el subdominio del idioma del teléfono (es.) antes que el portal de idiomas.

Escéptico: El registro muestra «Buscando: wikipedia.» y q=wikipedia. El botón 1 fue [Wikipedia — www.wikipedia.org], antes de es.wikipedia.org, y p2 describió el portal y el cartel de donación. La corrida arrancó a las 14:49:14 y el commit 1698f3d, que agrega la regla «Buscá X en Y» (Router.swift:150), es de las 14:57:00. El fallo ocurrió en esta build y el arreglo sigue sin verificar.

### P04-login-sin-camino · En la pantalla de ingreso no hay forma de completar DNI y usuario, ni un aviso de qué pasa con esos datos

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: banco-nacion

Evidencia:
- banco-nacion p2: «Estás en el Home Banking del Banco Nación. Te pide tu DNI y Usuario para continuar. Si olvidaste tu usuario o contraseña, podés recuperarlos.» → [Abrir «Recuperar usuario y contraseña»] · [Volver a la página anterior] · [Otra cosa].
- paginas/02.txt: «FORMULARIO que pide: DNI, Usuario — botón «Continuar»».
- Marta: «Tampoco voy a dictar mi DNI en el chat sin saber adónde va.» Lucía: «no me aclara si JEF ve o guarda lo que escriba». Ana: «los campos de la página tienen letra gris clarita que me cuesta encontrar».

Causa probable: No hay ninguna acción que lleve el foco de VoiceOver (o la vista) al campo de la página. La única vía para llenarlo es la acción `completar` del ruteador: dictar el DNI en la conversación, y ese texto viaja tal cual al modelo en la nube (Router.decide manda «PIDIÓ: …») antes de escribirse. Además, arrived() manda todo el texto de la página del banco al modelo para orientar (Assistant.saying → Answerer.orient). Ni followUps() ni orient() tienen un tipo de sugerencia para formularios.

Propuesta: En páginas con formulario de ingreso, el primer botón es «Completar DNI y usuario (lo escribís vos en la página del banco)». Ese botón mueve el foco de accesibilidad al campo dentro del WebView y lo resalta para baja visión. Una frase fija y verdadera: «Los datos van directo al banco; yo no los leo ni los guardo». Hacerla verdad: en páginas de login no mandar a la nube pedidos que contengan números de documento, y verificar que el extractor no capture los valores escritos. «Recuperar usuario» va después.

Escéptico: En banco p2 JEF dijo «Te pide tu DNI y Usuario para continuar» y el único botón fue [Abrir «Recuperar usuario y contraseña»]. No indicó dónde están los campos ni qué pasa con esos datos. El «no hay forma» es exagerado: la página de arriba es el WKWebView real, que VoiceOver puede recorrer (WebPageView.swift lo reserva «para lo que sólo la persona puede hacer: una contraseña»), y el ruteador tiene la acción `completar`. Lo que falta es la guía y el aviso, no la vía.

### P05-cambios-en-silencio · Páginas que cambian sin aviso y botones que quedan de la página anterior

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: mercadolibre-auriculares, noticias-la-nacion

Evidencia:
- mercadolibre p2: a +24.5s dice «Estás en la portada de Mercado Libre Argentina. Tenés descuentos en Glam Days…» y a +25.0s «Cargó https://www.mercadolibre.com.ar/captcha/wall?go_url=…auriculares-bluetooth — «Seguridad — Mercado Libre»», sin ningún anuncio. Los botones siguen siendo [Abrir «GLAM DAYS PANTALONES…»] … [Abrir «Suscribirme desde $ 5.490»].
- Ana: «En la pantalla de arriba veía «Por seguridad, completá este paso» y el «No soy un robot», pero el asistente me describía dos veces seguidas las ofertas».
- noticias-la-nacion p4: el toque en [Abrir «Escalada. Las grandes cadenas de TV reaccionan al veto de Trump y…»] no dejó rastro: 17 s sin «Abriendo», sin página y sin voz.

Causa probable: ReaderModel.pageChangedOnItsOwn (/Users/daniel/Developer/JEF- BROWSER/Sources/UI/ReaderView.swift:70) actualiza la página en silencio: el Assistant no se entera, no anuncia nada y no rehace la oferta. carry(.buscar) mira la página apenas se envía el formulario, y la navegación del buscador de Mercado Libre llegó 2,4 s tarde: primero la misma portada, después el muro. El diff sin commitear en Assistant.swift compara reader.page?.url == before y cae a «Busco en internet». Cubriría el «no respondió», pero en este caso lanzaría la búsqueda en internet mientras llega el captcha: arregla el síntoma, no la causa. Sobre el toque de La Nación: el registro no tiene ningún evento (accept() anota «botones: []» apenas arranca) y el script acababa de arrastrar el panel. Lo más probable es que el toque no llegara a la app y sea un artefacto del script. Sí existe un silencio real: accept() y goBack() hacen `guard … !working else { return }` (Assistant.swift:1204 y 1752) y descartan el toque sin decir nada.

Propuesta: Que el Assistant reciba los cambios de página no pedidos. Si la nueva es un muro, captcha o redirección, anunciarlo en el momento («Mercado Libre me frenó con una verificación»), usar el mensaje de describe() para captcha y rehacer los botones con closeTurn(). Después de enviar una búsqueda del sitio, esperar unos segundos por una navegación antes de describir o de caer a internet. Si llega un toque o un «volver» mientras el asistente trabaja, decir «Esperá, estoy terminando lo anterior» en vez de ignorarlo. En la ronda 4, repetir el paso 4 de La Nación sin arrastrar antes de tocar, para descartar del todo al producto.

Escéptico: Real en Mercado Libre: a +25.0s llegó el muro captcha/wall sin ningún anuncio y quedaron los botones GLAM DAYS/«Suscribirme» de la portada. `pageChangedOnItsOwn` (ReaderView.swift:70) sólo actualiza `state`. La parte de La Nación p4 es casi seguro artefacto del script. El registro no tiene ningún evento entre +28.35 y +45.89, ni siquiera el «botones: []» que accept() anota apenas pasa el guard, y la oferta estaba vigente. paso-04.jpg muestra el botón intacto después de que tocar() arrastró el panel.

### P06-resume-otra-pagina · «Resumime/leeme la nota» sin nota abierta: resume o lee otra cosa sin decir qué

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion, wikipedia-mar-del-plata

Evidencia:
- noticias-la-nacion p5, con la nota sin abrir: «La ultraderecha alemana se posiciona como «el partido del pueblo» tras otro triunfo. En la Argentina, el Vaticano difundió el cronograma oficial del papa León XIV… Además, murió el pintor Carlos Alonso a los 97 años.» Era la portada, resumida con titulares secundarios (Verificador 1: líneas 47, 185 y 31 de paginas/02.txt).
- noticias-la-nacion p6: recién al volver y caer en el buscador se nota que la nota nunca se abrió.
- wikipedia p4: «leeme la nota» → «An important update for readers in the United States.» … «Párrafo 3 de 8.»
- wikipedia p2: botón [Leer la nota] en el portal.

Causa probable: carry(.leer) y carry(.resumir) (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:359-372) actúan sobre reader.page sin mirar si es una nota y sin nombrarla. El pedido de summarize() (Assistant.swift:1189) no pide decir qué se resume ni recibe lo que dijo la persona («la nota»), y para una portada no usa la lista de titulares. isArticle() (Assistant.swift:1093) da verdadero en el portal de Wikipedia porque el cartel de donación tiene dos o más párrafos de 160+ caracteres: de ahí «Leer la nota» y la lectura del cartel.

Propuesta: Toda lectura o resumen empieza nombrando la página: «Resumen de la portada de La Nación:», «Leo «<título>»:». Si la persona dice «la nota» y la página no es una nota: «No hay ninguna nota abierta: seguís en la portada de La Nación», con [Abrir «<última nota ofrecida>»]. Excluir los carteles de donación, suscripción y cookies de isArticle() y de la lectura. El resumen de una portada sale de headlines(), en su orden.

Escéptico: En La Nación p5, «resumime la nota» sobre la portada devolvió titulares secundarios (paginas/02.txt:47 ultraderecha, :23 Vaticano, :31 Carlos Alonso) sin decir que era la portada. Esa situación nació del toque fallido del script en p4, pero la respuesta es del producto. Wikipedia p4 no depende del script: en el portal, «leeme la nota» leyó «An important update for readers in the United States.…» («Párrafo 3 de 8»). isArticle() lo tomó como nota por los párrafos largos del cartel (paginas/02.txt:11-14).

### P07-dicho-no-coincide-con-botones · Lo que se dice no coincide con los botones, y lo que se nombra no siempre se puede abrir

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, noticias-la-nacion, primera-vez, otra-cosa

Evidencia:
- solo-botones-clarin p2: «Los titulares principales son: Adorni justificó su patrimonio… Murió a los 97 años Carlos Alonso… El juez Rafecas…», pero el botón 1 es [Abrir «Quiénes son los ganadores y los perdedores tras la definición de la…»]: una nota no nombrada, y además paga.
- noticias-la-nacion: en p2 el resumen dice que el tercer titular es el de Adorni; en p3, «dame los titulares» pone tercero «70 horas de frenesí…».
- solo-botones-clarin p4, al volver: sólo [Leer los titulares] · [Resumir la portada] · [Volver…] · [Otra cosa].
- otra-cosa p4, después de nombrar tres notas de Deportes: [Leer los titulares] · [Resumir la portada] · [Volver…] · [Otra cosa]. primera-vez p3: [Leer los titulares] · [Resumir la portada] · [Otra cosa].

Causa probable: Answerer.orient() devuelve por separado el texto redactado y las sugerencias por número. El código sólo verifica que el número exista (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:262-280), no que corresponda a lo nombrado ni que respete el orden. followUps() arma botones «Abrir» sólo si lo último fue leer titulares (lastDone == readID, Assistant.swift:1700). describe(), la plantilla que se usa en secciones y en «¿dónde estoy?», no deja botones de notas, y goBack() vacía la oferta.

Propuesta: Una sola lista para todo. El modelo elige índices de headlines(), y con esos índices el código arma la frase hablada, la lista de «Leer los titulares» y los botones «Abrir», en el mismo orden. Cada vez que se nombran notas (resumen de llegada, describe, volver, secciones), quedan sus botones «Abrir».

Escéptico: Está en las transcripciones. En solo-botones-clarin p2 se dice «Adorni… Carlos Alonso… Rafecas», pero el botón 1 es [Abrir «Quiénes son los ganadores y los perdedores…»] y lleva a «Landing suscripciones» (p3). En noticias-la-nacion el resumen de p2 pone tercero a Adorni y en p3 «3. 70 horas de frenesí». Al volver (clarín p4), en Deportes (otra-cosa p4) y en primera-vez p3 sólo quedan [Leer los titulares] · [Resumir la portada]; en primera-vez p2 se nombran cinco notas y hay cuatro «Abrir». El script tocó el botón 1 sin elegir, pero el problema es qué ofrece la app, no ese toque.

### P08-titulares-mal-armados · Titulares cortados a mitad de palabra, con bajada, autor o sección pegados, bajadas contadas como notas y totales que no son creíbles

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, primera-vez, otra-cosa, turno-anses

Evidencia:
- noticias-la-nacion p3 y primera-vez p3: «Interruptor L46. Un gas contaminado en un interruptor sería la causa del apagón que dejó a oscuras a más de 2 millones d».
- solo-botones-clarin p5: «1. Adorni intentó justificar su patrimonio: … con la venta de criptomonedas, Casi tres meses después de renunciar, el ex jefe de Gabin» · «…Tironeo entre Gobierno e Iglesia, Sergio Rubin, Qu» · «…“La Argentina lo espera”, Política, El Gobierno espe».
- otra-cosa p4: «Las posiciones del Clausura. Faltan seis fechas: … y las copas, y el des» seguido de «Además, cómo está la tabla anual y el ingreso a las copas, los playoffs y el descenso». Es la bajada contada como una nota, y queda afuera la de Podoroska.
- «Titular 3 de 140.» · «Titular 3 de 131.» · «Hay 140 notas.» · «Hay 36 notas.»
- turno-anses p4: «Te pide el Formulario “Declaración Jurada del Trabajador y su Grupo Familiar adheridos al S y que consultes…»
- noticias-la-nacion p3: «dame los titulares» repite los dos primeros que el resumen acababa de decir.

Causa probable: extract.js corta a ciegas: los títulos de listados con title.slice(0, 120) (/Users/daniel/Developer/JEF- BROWSER/Sources/Extraction/extract.js:1805) y las etiquetas de enlaces con label.slice(0, 160) (extract.js:2561). describe() vuelve a cortar con prefix(120) (Assistant.swift:1923). En Clarín la tarjeta entera es un <a>, y textOf une volanta, título, bajada, autor y sección con «, ». Assistant.headlines(of:) (Assistant.swift:2024) toma cualquier enlace con nivel, o cualquier ítem de 25+ caracteres, así que suma bajadas y enlaces repetidos: de ahí 140. readAloud() arranca desde 0 aunque el resumen ya dijo tres. El orientador repite dentro de sus frases etiquetas que ya vienen truncadas («adheridos al S»). Assistant.short() ya corta en palabra, pero no se usa en estos caminos.

Propuesta: En extract.js, cortar en fin de palabra con «…». En tarjetas que son un enlace, tomar como título el encabezado interno (h2/h3) y dejar la bajada aparte. Unir título y bajada que apuntan al mismo href. En headlines(), deduplicar por href y sacar autor y sección. No decir totales: «Hay más; tocá Seguir con los titulares». «Leer los titulares» sigue desde el último que nombró el resumen.

Escéptico: El texto ya llega cortado de la extracción. paginas/02.txt de La Nación dice «…a más de 2 millones d», y el de Clarín «…el ex jefe de Gabin» y «Política, El Gobierno espe». En Deportes se cuenta la bajada «Además, cómo está la tabla anual…» como nota y Podoroska queda afuera, aunque está en la página. «dame los titulares» (p3) repite Escalada e Interruptor que el resumen acababa de decir. Hay un matiz: «140» no es disparatado (el commit 1698f3d habla de 133 titulares en La Nación), pero está inflado por duplicados como «Escalada… veto de Tr».

### P09-todo-por-el-buscador · Nombrar un sitio o hacer una pregunta de dato siempre pasa por la lista del buscador

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, mercadolibre-auriculares, banco-nacion, dolar-desde-cero, clima-cordoba, turno-anses, wikipedia-mar-del-plata

Evidencia:
- noticias-la-nacion p1: «llevame a la nación» → «Buscando: la nación.» → «Estás en los resultados de «la nación». Los 3 más probables: 1. Últimas noticias… 2. En Vivo | Los Detalles Y El Cronograma Oficial Del Papa…, youtube.com. 3. La Nacion, ingresar.lanacion.com.ar». En cambio, el botón [Llevame a La Nación] (primera-vez p2) dijo «Abriendo lanacion.com.ar.» y abrió directo.
- solo-botones-clarin p1: «clarín» da una lista con Kiosco y Wikipedia. mercadolibre p1: «entrá a mercado libre…» da tres Mercado Libre.
- dolar p1: «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real…». El dato ya estaba en el título.
- clima p1: «1. Clima mañana en Córdoba | Hora a hora - eltiempoen.com, eltiempoen.com.» (dominio dos veces, y VoiceOver lee el «|»).

Causa probable: Es una decisión explícita en arrive() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:579-595): «Un buscador nunca navega solo: muestra la lista». Se tomó después de abrir por error anses.fr, nacion.com (Costa Rica) y una página con captcha. Desde entonces ranked() pone primero lo oficial y lo del país, pero la lista se muestra igual. El ejemplo inicial tiene un href fijo (Assistant.starters, Assistant.swift:129-132), por eso escrito y tocado dan resultados distintos. present() (Assistant.swift:635-642) repite la consulta entera y lee «título, dominio» aunque el título ya diga el dominio.

Propuesta: Abrir directo cuando el primer resultado de ranked() coincide exacto con el nombre, está en un dominio del país u oficial (closer == 2 o isOfficial) y es una portada (depth 0): decir «Abriendo lanacion.com.ar.» y dejar [Volver a los resultados]. Para preguntas de dato (pendingQuestion), abrir el primer resultado de ese tipo y contestar nombrando la fuente, con [Ver otras fuentes]. Mostrar la lista sólo si hay ambigüedad real, sin repetir la consulta y sin el dominio cuando el título ya lo tiene.

Escéptico: Todo pedido escrito pasó por la lista de DuckDuckGo: «llevame a la nación» → «Estás en los resultados de «la nación». Los 3 más probables…», y lo mismo con clarín, mercado libre, wikipedia, ANSES, banco, dólar y clima. En cambio, el botón [Llevame a La Nación] de primera-vez p2 dijo «Abriendo lanacion.com.ar.» y abrió directo. Es una decisión del código: el comentario en arrive() dice «Un buscador nunca navega solo: muestra la lista». También está el título con el dato en dólar p1 («Dólar Blue Hoy $1550») y el dominio dicho dos veces en clima p1.

### P10-anuncios-largos-pendiente-al-final · Lo importante se dice al final de colas de 30 a 80 s, y se resume lo que nadie pidió

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: mercadolibre-auriculares, solo-botones-clarin, wikipedia-mar-del-plata, primera-vez, otra-cosa, noticias-la-nacion

Evidencia:
- mercadolibre p1: «Cuando elijas, sigo con: buscame auriculares bluetooth.» llega después de la lista entera de resultados (DESCARTADO).
- mercadolibre p2: con el pedido pendiente, primero «Estás en la portada de Mercado Libre Argentina. Hay ofertas destacadas como GLAM DAYS…» (unos 23 s). Recién después «Sigo con…», «Buscando auriculares…» y un segundo resumen de la portada: los tres DESCARTADOS.
- solo-botones-clarin p5: tres titulares y «Titular 3 de 131.», en cola hasta +81.8 s. wikipedia p5: «Párrafo 6 de 8.» en cola hasta +84.6 s.
- primera-vez p2: cinco titulares de entrada, más de 30 s. primera-vez p1: la instrucción «Para empezar…» va al final de la bienvenida.

Causa probable: ask() dice el pendiente después de present() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:248-253), así que queda detrás de la lista ya encolada. accept() llama a landed(), que hace la orientación completa con el modelo, antes de continueWith(waiting) (Assistant.swift:1297-1303). readAloud() y describe() emiten cada titular y el contador como say() separados (Assistant.swift:1125, 1922-1923): cada uno es un anuncio en cola. El prompt de orient pide «de tres a cinco» titulares (Answerer.swift:208). Los DESCARTADO/CORTADO concretos los causó el script, que actúa sin esperar a que termine la voz. Con una persona real el costo es la espera y el orden.

Propuesta: El pendiente va primero y en la misma frase: «Elegí el sitio y después busco auriculares bluetooth. Los tres primeros: …». Si hay algo en `waiting`, no orientar: «Entré a Mercado Libre. Busco auriculares bluetooth.» y seguir. Un anuncio por respuesta, con lo esencial adelante. Titulares en un solo anuncio y tres como máximo; el detalle queda escrito para recorrerlo con gestos.

Escéptico: El orden sí es de la app. En mercadolibre p1, «Cuando elijas, sigo con…» va en cola detrás de la lista (~18 s). En p2 primero se resume la portada («GLAM DAYS…», ~25 s) y recién después vienen «Sigo con», «Buscando…» y un segundo resumen de la portada que nadie pidió; accept() llama a landed() antes de continueWith(waiting). Pero lo exagera: el «+81.8 s» y el «+84.6 s» son horas desde el inicio, y las colas reales son de unos 33 a 40 s (clarín p5, wikipedia p5, primera-vez p2 con 458 caracteres). Los DESCARTADO los causó el script al no esperar, y el contador del final («Titular 3 de 131») no es «lo importante».

### P11-botones-fuera-de-vista · Con baja visión, los botones quedan fuera de la pantalla después de una respuesta larga

*grave* · confirmado · jueces: Ana · escenarios: noticias-la-nacion, solo-botones-clarin, turno-anses, primera-vez, mercadolibre-auriculares, banco-nacion, clima-cordoba, wikipedia-mar-del-plata, otra-cosa, dolar-desde-cero

Evidencia:
- Ana (noticias-la-nacion p2): «se ve solo la mitad del primer botón, cortado por el campo de escribir. Los otros botones y «Otra cosa» no se ven, y nada me avisa que hay más abajo».
- Ana (primera-vez p2): «El resumen largo empujó los botones fuera de la pantalla y no vi ninguno».
- Ana (turno-anses p3): «en pantalla se veía un solo botón».

Causa probable: AssistantPanel lleva la vista al comienzo de la respuesta con anchor .top (/Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift:126-136). Es a propósito, para que no se esconda la respuesta, pero con respuestas largas los botones quedan abajo y no hay ningún indicador. El panel ocupa el 55% de la pantalla (ReaderView.swift:281), contando encabezado y campo.

Propuesta: Cuando la respuesta termina, si la respuesta y el primer botón no entran juntos, desplazar hasta que el primer botón se vea entero. Mostrar arriba del campo un aviso tocable «N opciones más abajo» y dejar «Otra cosa» fija. Permitir agrandar la conversación, o achicar la página, con un toque.

Escéptico: Se ve en las capturas. En noticias-la-nacion paso-02.jpg sólo asoma la mitad de «Abrir «Escalada…»», tapado por el campo. En primera-vez paso-02.jpg el resumen llega hasta el campo y no se ve ningún botón. En turno-anses paso-03.jpg se ve un solo botón de seis. No hay ningún aviso de que haya más abajo. Viene del scrollTo(start, anchor: .top) de AssistantPanel.swift y le pasaría igual a una persona real, peor aún con letra grande.

### P12-unidades-y-datos · Datos sin adaptar al país ni al oído: Fahrenheit, mph, AM/PM, «,00», compra/venta ambiguo, y sin decir qué cotización ni de qué hora

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: clima-cordoba, dolar-desde-cero

Evidencia:
- clima p2: «La temperatura máxima será de 63º y la mínima de 40º. El viento soplará desde el noreste a una velocidad media de 13 mph… El amanecer será a las 7:06 AM y el atardecer a las 7:12 PM.»
- dolar p2: «El dólar blue hoy se compra a $1.530,00 y se vende a $1.550,00.»
- dolar p3: «Según la página, el dólar oficial está a $1.534,23 para la venta hoy. Para la compra, está a $1.482,52.» El orden se invierte respecto del blue, y no dice qué oficial es ni de qué hora es el dato.
- clima p3: «No, no va a llover.» Lucía: es más categórico que un pronóstico.

Causa probable: La página sirvió unidades imperiales porque la máquina de prueba está en EE.UU. (lo dice el mensaje de 1698f3d), pero el producto no convierte. 1698f3d sólo agrega al prompt «decí la unidad tal como está» (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:82), así que ahora diría «63 °F». Convertir desde el prompt choca con la verificación: answer() descarta la respuesta si una cifra no aparece literal en la página (Answerer.swift:168), y «17 °C» no aparece. El prompt no dice nada de centavos en cero, orden de compra y venta, tipo de cotización ni hora del dato.

Propuesta: Convertir en código después de verificar. El modelo devuelve la cifra original con su unidad, que se puede verificar, y el código la pasa a °C, km/h y hora de 24 h antes de decirla («máxima de 17 grados, mínima de 4»). Formato fijo para cotizaciones: «Compra: $1.530. Venta: $1.550.», sin centavos en cero, con fuente, tipo («oficial promedio») y hora si la página la da. Los pronósticos, atribuidos: «Según eltiempoen.com…».

Escéptico: Las citas son literales: clima p2 «máxima será de 63º… 13 mph… 7:06 AM… 7:12 PM», dólar p2 «se compra a $1.530,00 y se vende a $1.550,00», y dólar p3 invierte el orden («$1.534,23 para la venta… Para la compra, está a $1.482,52»). La página daba «Última actualización 21/9 11:03 hs» y la respuesta no lo dice. Matiz: los °F, mph y AM/PM vienen de que la máquina de prueba está en EE.UU. (lo dice el commit 1698f3d); en Argentina la página probablemente daría °C. En cambio, los «,00», el orden de compra y venta y la falta de hora son de la app. Además, la página sólo dice «Dólar Oficial», así que pedirle que diga qué oficial es no tiene de dónde salir.

### P13-avisos-y-carteles · Carteles leídos como contenido (donación) y avisos que tapan la página que no se mencionan

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata, dolar-desde-cero, solo-botones-clarin, mercadolibre-auriculares

Evidencia:
- wikipedia p2: «Te pide que consideres donar para apoyar el sitio… Un mensaje te informa que en Estados Unidos el promedio de donación es de 13 dólares… Hay un formulario para donar.»
- Ana (wikipedia p2): «En la pantalla veo el logo, el buscador y la lista de idiomas, pero no veo ningún formulario de donación».
- Ana (dolar p2): «Este sitio utiliza cookies — Aceptar / Rechazar… tapa casi toda la página… El asistente no lo mencionó».
- Ana (solo-botones-clarin p2): «Acceder a Clarin.com con Google — Continuar… El asistente no dijo nada».

Causa probable: extract.js no reconoce los carteles de recaudación de Wikipedia como aviso: quedan en «CONTENIDO DE LA PÁGINA» (wikipedia paginas/02.txt:13-19) y el modelo los resume y los lee. Los avisos de cookies o de Google sólo le llegan al modelo si el detector los marcó como overlay, y el prompt de orient pide mencionarlos apenas «en media frase al final» (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:217-219).

Propuesta: Detectar como avisos los carteles de donación, suscripción e inicio de sesión, y sacarlos del contenido. Si un aviso tapa la página, nombrarlo primero en una frase y ofrecer [Cerrar el aviso], rechazando las cookies cuando se puede.

Escéptico: Pasa como se describe. En wikipedia paginas/02.txt:9-19 el cartel de donación está en «CONTENIDO DE LA PÁGINA», y el paso 2 lo resume («Hay un formulario para donar»), aunque paso-02.jpg sólo muestra logo, buscador e idiomas. En dolar paso-02.jpg se ve «Este sitio utiliza cookies — Aceptar / Rechazar», que no figura en paginas/02.txt ni en la respuesta. En clarin paso-02.jpg se ve «Acceder a Clarin.com con Google — Continuar» sin mención, y en mercadolibre el aviso de cookies queda como contenido (02.txt:128) y nadie lo nombra. Un matiz: el cartel en inglés («for readers in the United States») aparece porque la máquina de prueba está en EE. UU., pero tratar un cartel como contenido es falla de la app.

### P14-donde-estoy-y-bienvenida · «No entiendo, ¿dónde estoy?» se contesta con el título técnico y relectura, y la bienvenida no dice qué hacer

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: primera-vez, otra-cosa

Evidencia:
- primera-vez p3: «En Últimas noticias de Argentina y el mundo — LA NACION.» «Hay 140 notas. Las tres primeras:» y los tres titulares ya dichos. Botones: [Leer los titulares] · [Resumir la portada] · [Otra cosa].
- primera-vez p1: «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»
- otra-cosa p4: «En Noticias de Deportes — LA NACION.»

Causa probable: La respuesta del paso 3 es la plantilla describe() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1917-1923): «En \(sectionTitle) — \(displaySite).», un conteo y tres títulos cortados a 120 caracteres. «orientar» con página abierta llama a arrived(), que cae a describe() cuando la orientación del modelo no llega o no pasa la verificación de cifras. No hay ninguna respuesta pensada para la confusión: qué es JEF, qué es la parte de arriba. La bienvenida es una cadena fija sin verbo, con la instrucción al final (Assistant.swift:411). Las secciones que se abren con «abrir» terminan en run() → describe(), que usa el título de la página.

Propuesta: Una plantilla para «no entiendo» o «¿dónde estoy?»: «Estás en JEF. Arriba se ve la página del diario La Nación, que abriste con el botón. Abajo está esta conversación: puedo leerte una noticia o llevarte a otro lado.», con [Abrir …], [Qué puedo hacer acá] y [Empezar de nuevo]. Bienvenida con la instrucción primero: «Decime un sitio o qué querés saber, o tocá una de estas opciones.». En describe(), nombrar el lugar con palabras comunes («la sección Deportes de La Nación») y darle el mismo formato que a una portada.

Escéptico: Es real. A «no entiendo, ¿dónde estoy?» (primera-vez p3), la app contesta con la plantilla de describe(): «En Últimas noticias de Argentina y el mundo — LA NACION.» «Hay 140 notas. Las tres primeras:» y repite los titulares, cortados («2 millones d»). La cadena es Assistant.swift:409-415, donde .orientar lleva a arrived() y de ahí a describe() en la línea 1833. En otra-cosa p4 se oye «En Noticias de Deportes — LA NACION.» por run()→.done→describe(), y la bienvenida fija de la línea 411 termina en «Para empezar, un sitio o algo para buscar», sin verbo.

### P15-volver · «Volver» no dice de dónde a dónde, y en el buscador relee la lista entera

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion

Evidencia:
- noticias-la-nacion p6: «Volviendo.» → «Estás en los resultados de «la nación». Los 3 más probables: 1. … 2. … 3. …», el mismo texto largo del paso 1.
- Contraste: en solo-botones-clarin p4, «De vuelta en «Noticias de Argentina», Clarin.com.» funcionó bien.

Causa probable: goBack() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1751-1769) usa la frase corta sólo si no vuelve al buscador. Si vuelve a resultados, llama a landed() → present() y repite la presentación completa. Es una decisión documentada en el comentario.

Propuesta: «Saliste de La Nación. De vuelta en la búsqueda de «la nación».», sin releer. Los resultados quedan como botones, y el primero es [Volver a La Nación]. Todo «volver» dice de dónde sale y adónde llega.

Escéptico: Es real. En noticias-la-nacion p6, «volvé» da «Volviendo.» y enseguida «Estás en los resultados de «la nación». Los 3 más probables: 1. … 2. … 3. …», idéntico al paso 1, sin decir que salió de La Nación. goBack() (Assistant.swift:1763-1766) manda a landed() cuando la página es el buscador; en Clarín p4 usa la frase corta «De vuelta en «Noticias de Argentina», Clarin.com.».

### P16-resumenes-que-tuercen-detalles · Resúmenes que agregan o tuercen detalles

*grave* · confirmado · jueces: Verificador 1, Verificador 2, Lucía · escenarios: mercadolibre-auriculares, wikipedia-mar-del-plata, turno-anses, otra-cosa, noticias-la-nacion, clima-cordoba

Evidencia:
- mercadolibre p2: «en accesorios para vehículos, zapatillas y electrónica hay hasta 45% de descuento». La página no tiene ninguna oferta de electrónica, que es justo el rubro de los auriculares.
- wikipedia p2: «muchos donantes aportan 2.75 dólares», cuando la página dice «Many first-time donors give $2.75».
- turno-anses p4: «Te pide el Formulario…». La página dice que se adjunta al iniciar el trámite por Atención Virtual.
- otra-cosa p2: «renunció por la puja», cuando la página dice «presentó su renuncia en medio de la puja».
- noticias-la-nacion p2: completó «de personas» sobre un texto que termina en «2 millones d».

Causa probable: La única verificación es que cada cifra declarada aparezca en la página (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:168 y 262). «45%» existe, pegado a otra categoría, y pasa. Nada controla las relaciones: qué cifra va con qué rubro, causa o contexto.

Propuesta: Pedir las cifras como pares {cifra, a qué se refiere} y verificar que las dos cosas aparezcan en la misma línea de la página. En el prompt, exigir que se mantengan las relaciones tal como están («en medio de» no es «por») y que no se complete un texto cortado.

Escéptico: Es real. En mercadolibre paginas/02.txt:61-64 el 45% es sólo para «ACC, VEHÍCULOS» y «ZAPATILLAS», pero el resumen agrega «y electrónica». En otra-cosa la página dice «presentó su renuncia en medio de la puja» (02.txt:10) y el resumen, «renunció por la puja». En ANSES el formulario se pide «cuando inicies el trámite por Atención Virtual» (04.txt) y el resumen dice «Te pide el Formulario». En La Nación el texto termina en «2 millones d» y el modelo completó «de personas». En Wikipedia se perdió el «first-time» de «Many first-time donors give $2.75». El único control es el de cifras (Answerer.swift:168 y 262), y el 45% existe en la página.

### P17-idioma-codigo-jerga · Texto sin adaptar: inglés, código en botones, jerga de la página, «puedes» y mensajes que no se traducen a la situación

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: wikipedia-mar-del-plata, mercadolibre-auriculares, solo-botones-clarin, turno-anses, banco-nacion

Evidencia:
- wikipedia p4-p5: «An important update for readers in the United States.» … «Please select an amount ( $).» Botón [Abrir «Search Wikipedia»].
- mercadolibre p2: [Abrir «GLAM DAYS PANTALONES ¡HASTA 40% OFF! Ver ofertas, var trackMclicks =…»].
- solo-botones-clarin p3: «el sitio me llevó a «Landing suscripciones».»
- turno-anses p3: «Te informa qué trámites puedes hacer desde el celular o computadora», en la misma respuesta que «podés solicitar».
- banco-nacion p3: «Esta página te pide que continúes el proceso desde tu celular…», cuando ya está en el celular.

Causa probable: readAloud() lee el texto literal sin mirar el idioma. Los rótulos «Abrir «…»» usan la etiqueta de la página: «Search Wikipedia» es el nombre del campo. El código JS entraba porque textOf recorría los <script>; eso ya está corregido en 1698f3d, después de la corrida. El aviso de muro usa page.sectionTitle. El prompt pide evitar las formas que cambian entre tú y vos (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:78) en lugar de exigir voseo, y el modelo mezcla igual. Tampoco pide traducir lo que dice la página a la situación de la persona.

Propuesta: Detectar el idioma de cada bloque: si no es el del teléfono, avisar («Este texto está en inglés»), ofrecer [Contámelo en castellano] y marcar el idioma para VoiceOver (accessibilitySpeechLanguage). Traducir los rótulos de campos en otro idioma («Buscar en Wikipedia»). Nombrar los lugares con palabras comunes («la página para suscribirse»). Exigir voseo explícito y revisar en código «puedes», «quieres» y «tienes». Pedir al orientador que traduzca los mensajes a la situación: «El banco no deja hacerlo desde la web; hay que usar su app BNA+». Confirmar 1698f3d en la ronda 4.

Escéptico: Todo aparece en las transcripciones. Wikipedia p4-p5 lee «An important update for readers in the United States…» sin aviso, y hay un botón [Abrir «Search Wikipedia»]. Mercado Libre p2 muestra [Abrir «GLAM DAYS PANTALONES… var trackMclicks =…»]: la corrida es de las 14:51 y el arreglo 1698f3d de las 14:57. Clarín p3 dice «me llevó a «Landing suscripciones»». ANSES p3 pone «podés solicitar» y «qué trámites puedes hacer» en la misma respuesta, y Banco Nación p3 dice «te pide que continúes el proceso desde tu celular» a quien ya está en el celular. Answerer.swift:78 y 222 piden evitar las formas que cambian entre tú y vos, sin exigir voseo.

### P18-botones-que-cobran-o-no-aplican · Se sugieren botones para suscribirse pagando o que no sirven en un iPhone

*grave* · confirmado · jueces: Roberto, Lucía, Ana, Marta, Verificador 2 · escenarios: mercadolibre-auriculares, banco-nacion

Evidencia:
- mercadolibre p2: [Abrir «Suscribirme desde $ 5.490»]. Roberto: «Me da miedo tocarlo sin querer».
- banco-nacion p3: primer botón [Abrir «Disponible en google play»] y recién segundo [Abrir «Descárgalo en el app store»].

Causa probable: Las sugerencias de abrir del orientador salen de candidates(of:) sin ningún filtro: no se excluyen las acciones que suscriben, compran o pagan, ni los enlaces de otra plataforma. La expresión `committing` de isSearch() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1481) ya lista esos verbos, pero sólo se usa para formularios.

Propuesta: Sacar de candidates() los enlaces cuyo texto o destino suscribe, compra o paga, reusando `committing`, salvo que la persona lo haya pedido. En iOS, sacar Google Play. Rótulo claro: «Bajar BNA+ del App Store».

Escéptico: Es real. En Mercado Libre p2 (segunda orientación) se ofrece [Abrir «Suscribirme desde $ 5.490»], y en Banco Nación p3 el primer botón es [Abrir «Disponible en google play»] en un iPhone. candidates(of:) (Assistant.swift:1612-1620) sólo filtra por titulares, largo y región; `committing` (línea 1481) se usa únicamente en isSearch(). Un matiz: tocar «Suscribirme» abre una página de suscripción y no cobra en el acto, pero el botón no corresponde a lo pedido.

### P19-otra-cosa · «Otra cosa» borra todas las opciones y no explica cómo dictar

*menor* · confirmado · jueces: Roberto, Lucía, Marta · escenarios: otra-cosa

Evidencia:
- otra-cosa p3: «¿Qué otra cosa hacemos? Se puede escribir o dictar.» En el árbol sólo quedan [campo] Pedido y [btn] Enviar.
- Roberto: «No me dice cómo dictar ni dónde está el campo para escribir. Y desaparecieron todos los botones».

Causa probable: La rama otherID de accept() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1224-1228) vuelve antes del defer de closeTurn, con la oferta ya en nil, a propósito («sin más botones»). El foco sí va al campo: placeFocus() usa inputRequests → «campo», y Ana y el verificador lo ven en la captura. La queja de Marta sobre el cursor hay que confirmarla con VoiceOver en un dispositivo.

Propuesta: Dejar un único botón [Volver a las opciones] y decir «Escribí, o dictá con el micrófono del teclado».

Escéptico: Pasa, y a propósito. otra-cosa p3 termina en «¿Qué otra cosa hacemos? Se puede escribir o dictar.» y el árbol sólo tiene [campo] Pedido y [btn] Enviar. La rama otherID de accept() hace `return` antes del `defer { closeTurn }`, con el comentario «sin más botones». La parte de «no explica cómo dictar» es sólo a medias: el campo, que es adonde va el foco (inputRequests → focused = "campo"; en paso-03.jpg el cursor está en el campo), tiene la ayuda «Con el dictado del teclado también se puede hablar.» La queja de que «no dice dónde está el campo» tampoco se sostiene.

### P20-seguimiento-generico · Botones de seguimiento genéricos o que repiten lo que se acaba de hacer

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: dolar-desde-cero, clima-cordoba, otra-cosa, primera-vez, wikipedia-mar-del-plata

Evidencia:
- dolar p2-p3 y clima p2-p3: [Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa], después de dar un dato. Roberto tuvo que escribir «¿y el oficial?» y «¿va a llover?».
- primera-vez p3: [Leer los titulares] justo después de leerlos.
- otra-cosa p4: [Resumir la portada] estando en Deportes. wikipedia p2: [Leer la nota] en un portal sin notas.

Causa probable: followUps() (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1674-1723) elige según el tipo de página, con rótulos fijos («Resumir la portada» para toda página que lee titulares), sin mirar la pregunta anterior. describe() no marca lastDone = readID aunque haya leído titulares.

Propuesta: Después de reply(), ofrecer la pregunta siguiente según el tema («¿Y el oficial?», «¿Y el MEP?», «¿Va a llover?», «¿Y pasado mañana?») y [Ver en otra fuente]. Si ya se leyeron titulares: [Seguir con los titulares]. Rotular con el nombre de la sección («Resumir Deportes»).

Escéptico: Todo se comprueba en las transcripciones. En dolar p2-p3 y clima p2-p3 los botones son [Leer la página] · [Resumir la página] · [Volver…] · [Otra cosa] después de dar el dato. En otra-cosa p4 aparece [Resumir la portada] en /deportes/. En wikipedia p2 aparece [Leer la nota] en www.wikipedia.org. En primera-vez p3, describe() leyó «Las tres primeras» sin marcar lastDone = readID, y «Leer los titulares» arranca de nuevo en readingFrom = 0, así que repetiría esos tres. Un matiz: «¿y el oficial?» y «¿va a llover?» eran pasos del guion, no algo que Roberto «tuvo que» escribir, pero eso no cambia que los botones son genéricos.

### P21-lista-de-resultados · La lista de resultados ofrece opciones que no sirven o no son confiables, sin marcarlas

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 1 · escenarios: noticias-la-nacion, otra-cosa, dolar-desde-cero, turno-anses

Evidencia:
- noticias-la-nacion p1: «2. En Vivo | Los Detalles Y El Cronograma Oficial Del Papa…, youtube.com. 3. La Nacion, ingresar.lanacion.com.ar»: un video y una página de login.
- dolar p1: «2. Dólar hoy, dólar blue hoy: a cuánto cotiza este miércoles…». Es una nota del 24/09/2025.
- turno-anses p1: «2. ANSES, servicioswww.anses.gob.ar» (consulta de estudios con captcha) y «3. Turnos ANSES - ️ Sacar turno en ANSES, turnosanses.net» (no oficial y con un emoji invisible). Roberto: «A mi edad me da miedo caer en una estafa».
- «Ver más opciones (1)».

Causa probable: results() y ranked() filtran anuncios y ordenan por país y por sitio oficial, pero no bajan ni marcan logins (ingresar., /login), videos, notas viejas en consultas de «hoy», ni sitios no oficiales que imitan a uno oficial. El título se usa tal cual, con emojis.

Propuesta: Para «ir a un sitio», bajar los logins y los subdominios de servicio. Marcar «(sitio oficial)» y «(no es de ANSES)». En consultas de «hoy», bajar los resultados con fecha vieja. Limpiar emojis. Decir «Ver 1 opción más».

Escéptico: Está todo en las transcripciones y en paginas/. noticias-la-nacion p1 ofrece youtube.com e ingresar.lanacion.com.ar para «llevame a la nación». En dolar, paginas/01.txt muestra la nota «…miércoles 24 de septiembre-nid24092025», con el blue a $1385. En turno-anses p1 aparecen servicioswww.anses.gob.ar («Ingrese el código que se muestra en la imagen») y «Turnos ANSES - ️ Sacar», con U+FE0F suelto (bytes ef b8 8f). ranked() sólo sube lo .gob.ar y ordena por país: no baja logins ni videos, y además sube el subdominio de servicio por ser oficial. La primera opción, la que tocó el script, sí era buena en todos los casos. El problema está en la 2 y la 3, así que no es culpa del arnés.

### P22-rotor · La conversación no tiene encabezados por turno para moverse con el rotor

*menor* · confirmado · jueces: Marta · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, mercadolibre-auriculares, otra-cosa

Evidencia:
- noticias-la-nacion p6: un solo «[H] Asistente» para 24 elementos que se recorren de a uno.

Causa probable: Sólo el título «Asistente» tiene el rasgo de encabezado (/Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift:40). line() (AssistantPanel.swift:182-199) no marca los turnos de la persona.

Propuesta: Marcar cada «Vos: …» como encabezado (accessibilityAddTraits(.isHeader)).

Escéptico: En noticias-la-nacion/arbol-06.txt hay un único «[H] Asistente» y los 24 elementos restantes son [txt] o [btn]; los «Vos: …» son [txt]. En AssistantPanel.swift, sólo el Text("Asistente") del header lleva .accessibilityAddTraits(.isHeader). line() arma el label «Vos: …» sin ese rasgo.

### P23-campo-poco-visible · El campo de escribir y el botón Enviar casi no se ven con baja visión

*menor* · confirmado · jueces: Ana · escenarios: primera-vez, otra-cosa, banco-nacion, noticias-la-nacion

Evidencia:
- Ana (otra-cosa p3): «el campo apenas se distingue: gris claro sobre gris claro, con un cursor finito. El botón de enviar es una flecha gris que parece apagada».
- Ana (primera-vez p1): «El campo de abajo, gris sobre gris, casi no lo vi».

Causa probable: El composer (/Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift:201-227) usa fondo tertiarySystemFill y texto de ayuda en .secondary. La flecha queda deshabilitada, y gris, mientras el campo está vacío.

Propuesta: Borde de color en el campo cuando tiene el foco, texto de ayuda con más contraste, y un botón «Enviar» con la palabra y con color. Respetar el tamaño de texto del sistema en toda la conversación.

Escéptico: En otra-cosa/paso-03.jpg y primera-vez/paso-01.jpg el campo es una cápsula gris muy clara sobre fondo blanco, con el texto de ayuda en un gris pálido, y la flecha de enviar es un círculo gris que parece apagado. El composer usa .background(Color(.tertiarySystemFill)), la ayuda va en .foregroundStyle(.secondary) y el botón lleva .disabled(text…isEmpty), así que la flecha está deshabilitada y gris mientras el campo esté vacío. El comentario del código dice «más oscuro que el gris de siempre», pero la captura no lo muestra.

## Lo que funciona

- «Buscando: <consulta>.» dice qué se buscó. Gracias a eso los cuatro jueces notaron enseguida que en Wikipedia se había perdido el tema. No sacarlo.
- Llegar a una portada con una sola frase («Estás en la portada de La Nación. Los titulares principales son…») ubicó a todos.
- Los botones «Abrir «<título>»» usan el título real de la nota, no una etiqueta inventada por el modelo (arrived(), Assistant.swift:1842-1848).
- La pista «Primera de N opciones.» en el primer botón dice cuántas opciones hay sin agregar una frase a cada botón.
- «Seguir con los titulares» / «Seguir leyendo» y «Párrafo 3 de 8» dejan que la persona marque el ritmo y sepa por dónde va.
- «Volviendo.» es corto. «De vuelta en «Noticias de Argentina», Clarin.com.» ubica sin releer, en páginas que no son del buscador.
- El aviso de nota paga llega rápido y es honesto (isWall + rama de muro en accept()): no leyó la página de venta como si fuera la nota.
- No inventa: frente al captcha dijo que no podía dar el precio, y en Wikipedia dijo que la fecha no estaba. La verificación de cifras del Answerer sostiene que el blue, el oficial y la lluvia coincidieron con la página.
- Recuerda la segunda mitad del pedido («Cuando elijas, sigo con…») y la ejecuta de verdad: el go_url del muro de Mercado Libre muestra que buscó «auriculares-bluetooth».
- Pone primero el sitio oficial (argentina.gob.ar para ANSES, digital.bna.com.ar para el banco) gracias a official antes que nombre y a la región (a8e34c8). Filtra el anuncio de Amazon en Clarín, espejos y sandboxes, la Córdoba de España y homebanking.bna.com.es.
- En una pregunta de dato con sitio elegido contesta directo: «En DolarInfoHoy.» y el precio, o «No, no va a llover. La probabilidad…», primero el sí o el no.
- Entiende los seguimientos en contexto («¿y el oficial?», «¿va a llover?») sin volver a buscar, gracias a previousRequest.
- El ejemplo inicial «Llevame a La Nación» abre el diario directo, y «llevame a deportes» dentro de La Nación va directo a la sección (regla abrir sección del ruteador).
- «Otra cosa» deja escribiendo enseguida, con el foco en el campo.
- Dice dónde está en cada página nueva («Estás en Argentina.gob.ar, en la página para solicitar turnos en ANSES.»).
- «Tocando «…»» para un control de la página, distinto de «Abriendo «…»» para un enlace, deja entender qué pasó.
- Para baja visión: la pantalla completa de conversación antes de la primera página, los botones de ejemplo grandes, los botones con borde azul que se distinguen de los globos y cada titular numerado en su propio globo.
- Todo en castellano, y cada respuesta termina con botones, «Volver a la página anterior» cuando hay adónde volver, y «Otra cosa».
