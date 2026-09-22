# Veredicto — ronda-11

Ronda 11: 39 de 48 logros («sí») y un promedio de 3,80. La ronda 9 había dado 35/48 y 3,57. El escenario más bajo es turno-anses: los cuatro jueces lo dan «a medias» y promedia 3,05. En mercadolibre-auriculares ningún juez logró el objetivo (4 «no»): la prueba anti-robot no ofrece ninguna otra salida. Los mejores son banco-nacion (4,45), otra-cosa (4,40) y anti-robot-avanza-sola (4,30).

Los problemas que se repiten en todos los escenarios:
1. Nombrar un sitio conocido o hacer una pregunta de dato pasa siempre por una lista del buscador. Es una decisión explícita de arrive(), en Assistant.swift:783.
2. Los titulares de portada sólo se dicen por voz: no quedan escritos, y después JEF contesta «ya los dije».
3. Hay datos de estado que nadie verifica: el dominio «anses.gov.ar», «Fin de la nota» después de la introducción de Wikipedia y un «La página cambió» falso.

Ojo con las fechas: el commit 0c8a6a8 (19:45) es posterior a la corrida (19:35–19:44), así que hay tres cosas que quizá ya estén resueltas y hay que verificarlas en la próxima ronda:
- las plantillas rotas («sus titulares son:», «Te leo los titulares:») y las cotizaciones del dólar en la portada;
- el «La página cambió» falso del clima;
- el «ver sub-trámites» de ANSES.

Descarté lo que viene del arnés, no del producto:
- «localhost»: es el servidor de prueba.
- El «ya pasamos la verificación» que Lucía sintió adelantado: el fixture misma-pagina.html se resuelve solo con un setTimeout de 12 s y JEF lo detectó bien.
- La letra de tamaño estándar en las capturas: el simulador no tenía texto grande.
- Los cortes provocados por el toque rápido del script, como el saludo de primera-vez.
- El saludo inicial que no aparece en la captura.

Aparte, una falla del arnés: Scripts/probar-escenarios.py (líneas 279-284) no marca CORTADO un anuncio en cola que interrumpe otro sin cola. Por eso el pronóstico pisado del clima no figura como cortado.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.7 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.1 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |
| turno-anses | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.0 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 3.5 |
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.5 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.2 |
| clima-cordoba | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.4 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.3 |
| anti-robot-misma-pagina | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |

**Promedio general: 3.80**

## Problemas

### P01 · Frente a una prueba anti-robot no hay otro camino, y el aviso no dice qué tocar

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-misma-pagina

Evidencia:
- mercadolibre, paso 3: «Todavía está la prueba anti-robot en la página. Cuando esté resuelta, contesto eso.» Botones: [Ir a la prueba] · [Ya la resolví] · [Volver a la página anterior] · [Otra cosa].
- mercadolibre, paso 2: «El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella, y tiene opción de audio. Cuando esté resuelta, seguimos.» ⟶ CORTADO (~51 %).
- Roberto (bloqueante): «yo con lo poco que sé de VoiceOver no puedo resolver una prueba así, y no me dio ninguna otra salida. Me quedé sin auriculares.»
- Ana: «Arriba yo veo el cuadrito «No soy un robot», pero el asistente no me dice que lo puedo tocar yo ahí mismo.»
- Marta, en anti-robot-avanza-sola: «la acción ('Ir a la prueba') queda al final, detrás de la explicación».
- Los 4 jueces: «no» en mercadolibre-auriculares.

Causa probable: El botón «Buscarlo en otro sitio» ya existe en followUps (Assistant.swift:2285-2291), pero sólo aparece si challenge.resume es .question o .rest.

En Mercado Libre la tarea pendiente («buscame auriculares bluetooth») se gasta antes de chocar con el muro. accept() hace waiting = nil y llama a continueWith (1774-1778). La búsqueda dentro del sitio cae en el captcha, y de ahí describe() llama a askToSolve(), que arma resume = .look (1240-1242) porque ya no quedan ni waiting ni pendingQuestion. La pregunta que la persona hace después se guarda en challenge.after (289), y followUps no mira ese campo.

El texto de askToSolve (1261) está al revés: primero la explicación, después la acción y al final el plan. Además dice «El sitio web» en vez del nombre del sitio, y no dice qué tocar aunque el detector sabe que es un reCAPTCHA con audio.

Propuesta: 1. Pasar la tarea en curso a continueWith/askToSolve, para que la prueba quede anotada como .rest(tarea).
2. En followUps, ofrecer «Buscarlo en otro sitio» también cuando haya challenge.after o una tarea retomada. Ese botón busca en internet «precio auriculares bluetooth» fuera del sitio bloqueado.
3. Reescribir el aviso en dos frases, con la acción primero: «Mercado Libre pide una prueba anti-robot: la casilla «No soy un robot», con opción de audio. La tenés que resolver vos: tocá «Ir a la prueba». Si no podés, «Buscarlo en otro sitio».»

Escéptico: En mercadolibre, pasos 2 y 3, los únicos botones son [Ir a la prueba] · [Ya la resolví] · [Volver a la página anterior] · [Otra cosa]. No hay «Buscarlo en otro sitio»: en Assistant.swift:2287-2291 sólo se agrega con resume .question/.rest. El aviso dice «El sitio web» y no nombra la casilla «No soy un robot», que sí se ve en paso-02.jpg. Eso sí: el título exagera cuando dice que «no dice qué tocar», porque el aviso nombra «Ir a la prueba». Y los CORTADO (51 %, 40 %, 80 %) salen del ritmo del script, que escribió o tocó 5 a 11 s después del aviso.

### P02 · ANSES: nombra trámites que no tienen botón, y el primer botón es un trámite ajeno

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: turno-anses

Evidencia:
- Paso 4: «Hay opciones para el Plan de Pago de Deuda Previsional, solicitud de jubilación o pensión, asignaciones o por desempleo.» Botones: [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…»] · [Abrir «CONSULTAR TURNO»] · [Abrir «Reprogramación»].
- Roberto: «Soy jubilado. Me nombra la jubilación, pero no hay botón para eso, y la primera opción es para trabajadores en actividad. Para seguir tendría que escribir… Ahí me quedé.»
- Ana: «Nunca me preguntó para qué lo quería, y los botones que me dio no eran los míos.»
- paginas/04.txt sí tiene «Solicitud de Jubilación», «Solicitud de Pensión», «Trámites Jubilados y Pensionados», «Asignaciones Familiares», «Desempleo» y «Pensión Universal para Adultos Mayores», además del buscador «Buscar turno».
- Los 4 jueces: «a medias». Es el escenario con el promedio más bajo (3,05).

Causa probable: En arrived(), los botones salen de orientation.suggestions: el modelo los elige por número en Answerer.orient, sin relación con lo que su propio texto nombra. Nada comprueba que cada cosa nombrada tenga su botón. El modelo tomó el primer candidato de la lista, que era Plan de Pago.

La etiqueta termina en «ver…» porque la página ya trae «, , ver…» truncado, y el arreglo de 0c8a6a8 en short() sólo saca el «ver sub-trámites» completo.

Propuesta: 1. Regla de código: cada candidato cuyo nombre aparece en el texto de la orientación se vuelve botón, en el orden en que se nombró (hasta 4), antes que las sugerencias del modelo.
2. Si la página es una lista de trámites y la persona vino por un turno, preguntar «¿Para qué trámite es el turno?». Los botones son los trámites de la página: Jubilación, Pensión, Trámites de jubilados y pensionados, Asignaciones, Desempleo y «Otro».
3. Quitar el «ver…» que queda colgando en las etiquetas.
4. Si la página lo dice, adelantar en una frase qué se va a necesitar (CUIL, Clave de la Seguridad Social).

Escéptico: En el paso 4 la respuesta nombra «solicitud de jubilación o pensión, asignaciones o por desempleo», pero los botones son [Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…] · [CONSULTAR TURNO] · [Reprogramación]. En paginas/04.txt están «Solicitud de Jubilación», «Solicitud de Pensión», «Trámites Jubilados y Pensionados», «Asignaciones Familiares» y «Desempleo»; el «, , ver…» viene truncado de la página. Los botones y su orden los eligió la app, no el script.

### P03 · Se habla como si la persona viera, y falta guía para quien empieza

*grave* · confirmado · jueces: Roberto, Marta, Lucía, Ana · escenarios: primera-vez, banco-nacion, otra-cosa, anti-robot-misma-pagina

Evidencia:
- banco-nacion, paso 3: «¿Qué pongo en DNI? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.» Roberto (grave): «“Acá abajo” no me dice nada: no veo.»
- primera-vez, paso 3: «Estás en la portada de LA NACION. Arriba se ve la página, y esto es la conversación conmigo, JEF…» Roberto (grave): «Dije «no entiendo» y me contestó «arriba se ve la página». Yo no veo.» A Ana, en cambio, esa misma frase le ordenó la pantalla.
- primera-vez, paso 1: «…o tocar una de estas opciones.» Roberto: «no dónde están ni cómo llego: no sé que tengo que deslizar el dedo».
- anti-robot-misma-pagina, paso 2: «La prueba quedó a la vista, en la página.» Marta: «no me dice si el cursor de VoiceOver quedó en la prueba».
- otra-cosa, paso 3: «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» A Marta le molesta que se lo expliquen cada vez; Roberto no sabe dónde está el micrófono.
- primera-vez: Roberto lo da «a medias», con orientación 3 y ritmo 2.

Causa probable: Son frases fijas en Assistant.swift: 660 (complete), 1697 (Ir a la prueba), 1649 (Otra cosa) y 547-554 (orientar).

La frase sobre los gestos sólo se agrega al contestar «¿dónde estoy?», y sólo si UIAccessibility.isVoiceOverRunning (línea 551). En el simulador VoiceOver estaba apagado, así que no se oyó. La respuesta a «¿qué podés hacer?» sin página abierta no la trae nunca.

El código sí mueve el cursor: al campo cuando sube inputRequests, y a la página con pageFocusRequests + layoutChanged. Pero el texto no cuenta lo que hizo.

Propuesta: 1. Con VoiceOver activo, decir lo que el código ya hizo en lugar de dónde mirar: «El cursor ya está en el campo DNI: escribí o dictá»; «Te llevé a la prueba: el cursor está en la casilla de la página».
2. La primera vez, y en «¿qué podés hacer?», sumar una frase de gestos: «Deslizá un dedo a la derecha para oír las opciones y tocá dos veces para elegir; al final está el lugar para escribir».
3. Dejar «Arriba se ve la página» sólo cuando VoiceOver no está activo, porque a Ana le sirvió.
4. Explicar el dictado sólo la primera vez que se toca «Otra cosa», diciendo dónde está el micrófono. Las siguientes, sólo «¿Qué hacemos?».
5. Sumar un botón «Ver ejemplos» que vuelva a las opciones del inicio.

Escéptico: Las frases fijas están en las transcripciones y en el código: «dictar acá abajo» (banco-nacion p3; Assistant.swift:660), «Arriba se ve la página» (primera-vez p3; :554), «La prueba quedó a la vista» (:1697) y «tocar una de estas opciones» sin decir cómo (:542). Una parte sí es del arnés: sin VoiceOver en el simulador, «¿dónde estoy?» no agregó «deslizando a la derecha se llega a ellas» (:551-553). Pero «Arriba se ve la página» se dice igual con VoiceOver activo.

### P04 · Nombrar un sitio conocido pasa por una lista de resultados, y el botón de inicio va directo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, mercadolibre-auriculares, wikipedia-mar-del-plata, turno-anses, banco-nacion

Evidencia:
- noticias, paso 1: «Buscando: la nación.» y después «Estás en los resultados de «la nación». Los 3 más probables: 1. Últimas noticias de Argentina y el mundo - LA NACION, lanacion.com.ar. 2. LN+ EN VIVO…, youtube.com. 3. Kiosco LA NACION, edicionimpresa.lanacion.com.ar».
- primera-vez, paso 2: el botón [Llevame a La Nación] responde «Abriendo lanacion.com.ar.» y va directo. Marta: «Si el botón sabe ir directo, mi pedido escrito también debería.»
- mercadolibre, paso 1: [Mercado Libre Argentina… — www.mercadolibre.com.ar] · [Mercado Libre - Envíos Gratis en el día — www.mercadolibre.com] · [Mercado Libre — listado.mercadolibre.com.ar]. Lucía: «tres versiones del mismo sitio».
- turno-anses, paso 1: para «quiero sacar un turno en anses» dice «Buscando: anses.» El resultado que servía, «Solicitar turnos en ANSES», quedó tercero; el primero llevó a la página general, y se dieron dos pasos de más.
- Lucía: «“Los 3 más probables” suena a que está adivinando.»

Causa probable: Es una decisión explícita de arrive() (Assistant.swift:783-799: «Un buscador nunca navega solo: muestra la lista»). Se tomó después de que la apertura automática fallara con anses.fr, nacion.com (Costa Rica) y un captcha de ANSES.

Sólo los ejemplos del inicio (starters, 178-184) tienen una dirección fija, y de ahí sale la incoherencia.

El ruteador saca la intención de la búsqueda a propósito («anses» y no «turno anses»; comentario en 294-300). Después ranked() ordena por oficial, país y nombre, sin mirar la parte pendiente del pedido («turno»).

Propuesta: 1. Una lista corta y curada en código, nunca del modelo, con los sitios argentinos más pedidos y su dirección: La Nación, Clarín, Infobae, Página/12, Mercado Libre, ANSES, ARCA, home banking del Banco Nación y Wikipedia (es.wikipedia.org/wiki/<tema>). Si el pedido nombra uno, abrirlo directo como hace el botón de inicio, con «Abrí lanacion.com.ar» y un botón «Ver otros resultados».
2. Fuera de la lista, abrir directo sólo si el primer resultado es oficial (.gob.ar), o si su dominio coincide exactamente con lo nombrado y es del país.
3. Subir el resultado cuyo título tiene las palabras de lo que falta del pedido (por ejemplo «Solicitar turnos en ANSES»).
4. Cambiar «Los 3 más probables» por «Los primeros resultados».

Escéptico: «llevame a la nación», «clarín», «entrá a mercado libre…» y «quiero sacar un turno en anses» pasan todos por «Buscando: …» y la lista «Los 3 más probables». En cambio, el botón [Llevame a La Nación] responde «Abriendo lanacion.com.ar.» directo (primera-vez p2). En ANSES, «Solicitar turnos en ANSES» quedó tercero. La evidencia exagera un poco: fue un paso de más (ANSES, después Turnos), no dos. Que el script tocara el primero es mecánico, pero ese primer lugar lo decidió el ranking de la app.

### P05 · Una pregunta de dato (dólar, clima) termina en una lista de sitios y no en la respuesta

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero, clima-cordoba

Evidencia:
- dolar, paso 1: «Estás en los resultados de «a cuánto está el dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar…» Marta: el dato ya estaba en el título del primer resultado.
- clima, paso 1: «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:»
- dolar, paso 2: antes del dato suenan dos avisos seguidos, «Abriendo dolarinfohoy.com.ar.» y «En DolarInfoHoy.»
- Lucía: la pantalla de inicio sugiere «¿A cuánto está el dólar hoy?» como si fuera a contestarlo.

Causa probable: Cuando todavía no hay página, carry(.buscar) anota pendingQuestion y llama a arrive() (Assistant.swift:468-469), que presenta la lista. La pregunta recién se contesta cuando la persona elige un sitio (1759-1768). Antes de la respuesta va «En <sitio>.» como un anuncio aparte.

Propuesta: 1. Para una pregunta sin página abierta, abrir solo el primer resultado ranqueado y descartar los que tienen una fecha que no es la de hoy.
2. Contestar con la fuente dentro de la misma oración: «Según DolarInfoHoy, el blue está a $1.530 la compra y $1.550 la venta, actualizado hoy a las 15». Dejar la lista en un botón «Ver otras fuentes».
3. Si esa página no tiene la respuesta, probar con el segundo resultado antes de mostrar la lista.
4. Sacar el «En DolarInfoHoy.» suelto.

Escéptico: En dolar p1, la respuesta a «¿a cuánto está el dólar blue hoy?» es una lista, y el primer título ya dice «Dólar Blue Hoy $1550». En clima p1 pasa lo mismo: «Estás en los resultados de «tiempo mañana córdoba». Los 3 más probables:». El dato llega recién después de elegir un sitio, precedido de dos avisos sueltos: «Abriendo dolarinfohoy.com.ar.» y «En DolarInfoHoy.» (en clima, «En meteored.com.ar.»).

### P06 · Wikipedia: dice «Fin de la nota» cuando sólo leyó la introducción

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata

Evidencia:
- Paso 5: «Párrafos 3 a 4 de 4: […] Fin de la nota.»
- Verificador 1: después del párrafo 4, paginas/02.txt tiene las secciones plegadas «Historia, Demografía, Arquitectura, Geografía, Economía, Turismo…», y ningún botón las ofrece.
- Lucía: «Si confío en eso, creo que no hay nada más. Ya desde «de 4» me sonó raro.»

Causa probable: La versión móvil de Wikipedia pliega las secciones (su contenido tiene display:none), y extract.js descarta lo oculto (isPruned, extract.js:2499-2503). Por eso readablePieces() sólo ve 4 párrafos, y readAloud() anuncia «Fin de la nota.» (Assistant.swift:1504 y 1539) sin saber que quedan secciones plegadas. Los títulos de sección quedan como enlaces sueltos, no como partes de la lectura.

Propuesta: 1. Antes de extraer, desplegar las secciones plegadas. En Wikipedia móvil son las section.collapsible-block o sus encabezados .section-heading; en general, los <details> y el contenido marcado con aria-expanded=false. La otra opción es cargar una versión que traiga el artículo completo.
2. Mientras tanto, si después del último párrafo quedan encabezados sin leer, decir «Fin de la introducción. El artículo sigue con: Historia, Demografía, Geografía…», con esas secciones como botones, y contar los párrafos como «de la introducción».

Escéptico: En el paso 5 dice «Párrafos 3 a 4 de 4: … Fin de la nota.», con botones [Resumir la nota] · [Volver a la página anterior] · [Otra cosa]. Pero paginas/02.txt sigue después del cuarto párrafo con «Historia, Demografía, Arquitectura, Geografía, Economía, Turismo…» sin su contenido, o sea plegadas, y ningún botón ofrece esas secciones.

### P07 · El modelo inventa el dominio: «anses.gov.ar»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: turno-anses

Evidencia:
- Paso 4: «Estás en la página de turnos de anses.gov.ar.» La dirección cargada es servicioswww.anses.gob.ar, y el pie de la página dice «anses.gob.ar».
- Lucía: «que el asistente diga un dominio que no existe me hace pensar en phishing o en algo inventado».
- Roberto: «Me enseñaron que desconfíe de las páginas truchas, y un error así me hace dudar».
- Verificador 1: «Si una persona de 72 años lo escribe después, puede terminar en otro sitio.»

Causa probable: El «Estás en…» al llegar lo escribe el modelo en Answerer.orient, y lo único que se verifica son las «cifras» (figureAppears). Los dominios, los nombres de sitio y el tipo de página del texto libre no se comparan con la dirección real.

Propuesta: 1. Que el lugar lo diga siempre el código, con whereIs() y displaySite, y que el modelo agregue sólo de qué trata la página.
2. Revisar el texto del modelo: todo lo que tenga forma de dominio tiene que aparecer en la dirección o en la página. Si no aparece, reemplazarlo por el nombre del sitio o quitar la frase.
3. Agregar a la instrucción: «no nombres direcciones web».

Escéptico: turno-anses, paso 4: JEF escribe y dice «Estás en la página de turnos de anses.gov.ar.», pero la página cargada es https://servicioswww.anses.gob.ar/… y paginas/04.txt dice «PÁGINA: servicioswww.anses.gob.ar» y «anses.gob.ar». La captura paso-04.jpg muestra las dos cosas a la vez: «anses.gob.ar» en el pie de la página y «anses.gov.ar» en el globo de JEF. Answerer.orient sólo verifica las cifras (figureAppears, línea 179), así que el dominio inventado pasa sin control.

### P08 · «La página cambió» falso, que corta el pronóstico

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: clima-cordoba

Evidencia:
- Paso 2, a los +24,0 s: «La página cambió: ahora estás en la nota «Tiempo en Córdoba mañana», de meteored.com.ar.» Llega 1,7 s después de que empezó a sonar el pronóstico.
- Verificador 2: paginas/02.txt y 03.txt son idénticos. Del pronóstico «se habrán oído unos 1,7 s», y el cursor de VoiceOver termina en ese aviso.
- Roberto: «Yo no toqué nada y me dice que la página cambió.»

Causa probable: En el camino de la pregunta que esperaba sitio (accept, 1759-1768) no se anotaba knownURL. Cuando la página se volvió a leer, pageChanged() (2439) la comparó con la dirección del buscador y anunció el cambio.

Además, pageChanged pone interruptNext = true, que corta la respuesta que está sonando, y usa whereIs(), que le dice «nota» al pronóstico.

El commit 0c8a6a8 ya anota knownURL en ese camino, pero es posterior a esta ronda.

Propuesta: 1. Verificar 0c8a6a8 en la próxima ronda.
2. En pageChanged, callarse si la página es equivalente (page.isEquivalent o mismo título) aunque cambie algo de la dirección.
3. Poner ese aviso en cola en lugar de interrumpir una respuesta.
4. No dejar el cursor en el aviso cuando lo último pedido fue la respuesta.

Escéptico: En clima, paso 2, a los +24,0 s aparece «La página cambió: ahora estás en la nota «Tiempo en Córdoba mañana»…» con la misma URL, y paginas/02.txt y 03.txt son idénticos (diff sin diferencias). El registro muestra el aviso con cola:false 1,7 s después de que empezó el pronóstico (con cola:true); Registro.decir lo manda con accessibilitySpeechQueueAnnouncement=false, así que lo corta de verdad. Dos matices del arnés: la transcripción no marca el pronóstico como CORTADO, porque probar-escenarios.py sólo detecta cortes en anuncios sin cola (279-284). Y lo de que el cursor termina en el aviso no se sostiene: AssistantPanel.placeFocus, que no cambió desde antes de la corrida, lo lleva a la primera opción («¿Qué noticias hay?»).

### P09 · Los titulares sólo se dicen en voz: no quedan escritos, «Los 4 primeros ya los dije» y sus botones desaparecen

*grave* · confirmado · jueces: Roberto, Lucía, Ana, Marta, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, primera-vez, otra-cosa

Evidencia:
- Lo que queda escrito: «Estás en la portada de LA NACION, con las últimas noticias de Argentina y el mundo. Los titulares principales son las primeras opciones.»
- noticias, paso 3: «Los 4 primeros ya los dije. Titulares 5 a 7:» En arbol-03 ya no están los titulares 1 a 4.
- Verificador 1: la lista (533 caracteres, unos 38 s) empezó a los +20,9 s y la cortó este mensaje a los +29,1 s: «se habrá escuchado a lo sumo el titular 1».
- Roberto (grave): «Pedí los titulares justamente porque ya me había olvidado de los primeros, y me contestó que ya los había dicho.»
- Ana (grave): «A mí no me los dijo ni me los escribió: sólo los puso como botones, que quedaron arriba y fuera de la pantalla.»
- Marta (menor): «los botones de los titulares 1 a 4 desaparecieron».
- A Marta, que no se repitan le pareció bien.

Causa probable: arrived() escribe una sola frase y deja la lista sólo en el parámetro aloud (Assistant.swift:2551-2552). Los botones de los titulares se reemplazan en el turno siguiente.

Cuando se pide «titulares», ask() sigue desde readingFrom = lead.count (258-266 y 2600-2601), y readAloud antepone «Los N primeros ya los dije.» (1527). Se decidió así porque repetirlos molestaba.

Propuesta: 1. Escribir los titulares numerados como líneas de la conversación, igual que ya se hace con el 5 al 7. Los botones, cortos: «Abrir el 1: Bitcoins en negro…».
2. Si piden «los titulares» y pasó al menos un turno, decir «Los 4 primeros están más arriba» y ofrecer dos botones: «Repetir desde el 1» y «Seguir con el 5».
3. Al seguir con los titulares, dejar al final de la lista los botones de los ya dichos.

Escéptico: Lo escrito sólo dice «Los titulares principales son las primeras opciones.»; la lista numerada va únicamente en la voz. En el paso 3, JEF responde «Los 4 primeros ya los dije. Titulares 5 a 7:», y en arbol-03 ya no están los botones 1 a 4 (lo mismo pasa en primera-vez, paso 3). Parte depende del arnés: que la lista (533 caracteres, unos 38 s) se oyera sólo unos 8 s es porque el script escribió el pedido siguiente a los +29,1 s. Aun así, la app afirma «ya los dije» sin fijarse si se terminaron de decir.

### P10 · La llegada a una portada es larga y sucia: volantas, secciones, firmas, datos que nadie pidió y frases rotas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, primera-vez

Evidencia:
- Clarín, paso 2: «2. Renunció el secretario de Discapacidad … Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de… 4. Adorni trató de justificar su patrimonio: … Causa por enriquecimiento, Lucía Salinas, Adorni trató de justificar su…» Son 881 caracteres, unos 63 s según el verificador.
- Clarín: «Estás en la portada de Clarín y sus titulares son: Los titulares principales son las primeras opciones.»
- primera-vez: «La cotización del dólar oficial es de $1535,00, el dólar blue está en $1550,00, el dólar tarjeta a $1995,50 y el dólar MEP a $1538,32. Te leo los titulares: Los titulares principales son las primeras opciones.»
- Verificador 2: al sacar la volanta, «Bitcoins en negro…» pierde que se trata de Adorni.
- Roberto: «terminé mareado, sin saber dónde empezaba y dónde terminaba cada noticia».

Causa probable: 1. headlines(of:) (2843-2868) toma la etiqueta entera del enlace. En Clarín cada tarjeta es un solo <a>, y su texto junta título, bajada o volanta, sección, firma y otra vez el título truncado. El botón pasa por short(…,100) y queda limpio; la voz usa sentence(dekick()) sin cortar.
2. El comienzo lo escribía el modelo y se le pegaba la lista. 0c8a6a8, posterior a la ronda, se queda con la primera oración y reemplaza la que termina en «:». Pero sigue dependiendo de cómo puntúa el modelo: «…son: 1. El Gobierno» dejaría «…son: 1.».
3. dekick() saca volantas que a veces llevan el sujeto de la nota.

Propuesta: 1. Limpiar el titular donde se extrae. En extract.js, si el enlace contiene un encabezado (h1–h4) o un elemento de título, usar ese texto como etiqueta. En Swift, cortar en la primera «, » cuando un segmento posterior repite el comienzo del título.
2. En una portada, la frase de llegada sale 100 % de plantilla («Estás en la portada de Clarín.»). Del modelo, sólo media frase sobre lo que la persona vino a buscar, si vino por algo.
3. Verificar 0c8a6a8.
4. Conservar la volanta cuando el título sin ella se queda sin nombre propio.
5. Decir como máximo 3 o 4 titulares.

Escéptico: En Clarín, la voz de llegada tiene 881 caracteres (unos 63 s) e incluye «…Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…» y «…Causa por enriquecimiento, Lucía Salinas, Adorni trató de justificar su…». Así viene en paginas/02.txt, como etiqueta del enlace. Lo escrito es «Estás en la portada de Clarín y sus titulares son: Los titulares principales son las primeras opciones.», y en primera-vez se agregan las cuatro cotizaciones del dólar más «Te leo los titulares: Los titulares…». Además, paginas/02.txt de La Nación dice «La explicación de Adorni. Bitcoins en negro…» y JEF dice sólo «Bitcoins en negro…», sin la volanta.

### P11 · Con poca vista, los botones y los mensajes nuevos quedan fuera de la pantalla

*grave* · confirmado · jueces: Ana, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, turno-anses, clima-cordoba, mercadolibre-auriculares, primera-vez, anti-robot-avanza-sola, anti-robot-misma-pagina

Evidencia:
- Ana (general, grave): «cuando llega una respuesta larga, se ve sólo su comienzo. Los botones (y casi siempre «Otra cosa») quedan escondidos abajo».
- Clarín, paso 4 (Ana): «El botón «Seguir leyendo» queda abajo, escondido».
- Verificador 2, clima paso 2: «la conversación termina en el globo del pronóstico. El último mensaje y los cinco botones quedan fuera de la vista».
- Verificador 2, anti-robot-avanza-sola: «la conversación sigue donde estaba en el paso 1, con 'Abriendo localhost.' arriba de todo … los cuatro botones no se ven».

Causa probable: AssistantPanel.swift:128-138 lleva arriba de todo el comienzo de la respuesta (responseStart, 184-189), que es la primera línea de JEF después del último pedido de la persona. Cuando JEF agrega líneas solo (pageChanged, prueba resuelta), no hay pedido nuevo, así que la vista se queda en la respuesta anterior.

Con respuestas largas (dos párrafos de lectura, un pronóstico), las opciones quedan por debajo del panel, que ocupa el 55 % de la altura (ReaderView.swift:330).

Propuesta: 1. Anclar la vista a la primera línea nueva: guardar cuántos turnos había antes, en lugar de buscar el último pedido de la persona.
2. Si después de acomodar la vista la primera opción no se ve, mostrar una franja fija arriba del campo con esa opción y «Más opciones ↓».
3. Probar con el texto grande del sistema.

Escéptico: Las capturas lo confirman. clima paso-02.jpg: la vista termina en el globo del pronóstico, sin el aviso ni los 5 botones. solo-botones-clarin paso-04.jpg: se corta en el segundo párrafo y no se ve «Seguir leyendo». anti-robot-avanza-sola paso-02.jpg: arriba sigue «Abriendo localhost.» y no se ve ningún botón. AssistantPanel.responseStart ancla la vista a la primera línea de JEF después del último pedido de la persona, tal como dice la causa.

### P12 · Los carteles de la página nadie los menciona, y la página no muestra lo que se está diciendo

*grave* · confirmado · jueces: Ana, Verificador 1, Verificador 2 · escenarios: solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, clima-cordoba, mercadolibre-auriculares, turno-anses

Evidencia:
- Clarín (Ana, grave): «Acceder a Clarin.com con Google — Continuar … El asistente no dice nada. Yo veo ese botón y no sé si tengo que tocarlo o si es peligroso.»
- dolar: «Este sitio utiliza cookies — Aceptar / Rechazar». Clima: «Aviso de privacidad … ACEPTAR Y CONTINUAR». Wikipedia: «¿Sabías que Wikipedia tiene una aplicación? … Instalar». ANSES: un chat propio, «¿En qué puedo ayudarte?».
- Verificador 2, clima: «JEF no lo menciona en ningún momento ni ofrece aceptarlo o cerrarlo».
- Verificador 1, Clarín pasos 3 a 5: arriba se ven «Leé el diario de hoy» y los íconos de redes, no el título de la nota.

Causa probable: Esos carteles no llegan al texto extraído: paginas/02.txt de Meteored, de DolarInfoHoy y de Clarín no los tienen. Viven en iframes de terceros (Google One Tap, gestores de consentimiento) o se agregan después de cargar. Por eso page.overlay queda vacío, y ni describe() ni orient() pueden mencionarlos.

Además, al abrir una nota la vista de la página queda en el encabezado del sitio y no baja al título.

Propuesta: 1. En extract.js, detectarlos por tamaño y posición: un elemento fijo o un iframe visible que tape más de un 30 % de la pantalla cuenta como aviso de tipo «otro», aunque no se pueda leer.
2. Cerrar solos los de cookies (eligiendo «Rechazar»), el de Google One Tap y los de «Instalar la app». Si no se puede, decir en media frase «La página muestra un cartel encima; no hace falta tocarlo», con un botón «Cerrar el cartel».
3. Al abrir una nota, desplazar la página hasta su h1.

Escéptico: Las capturas muestran carteles encima de la página: «Acceder a Clarin.com con Google — Continuar» (Clarín paso-02), «Este sitio utiliza cookies — Aceptar/Rechazar» (dólar paso-02), «Aviso de privacidad… ACEPTAR Y CONTINUAR» (clima paso-02), «¿Sabías que Wikipedia tiene una aplicación?… Instalar» (Wikipedia paso-02) y las cookies de Mercado Libre. Ninguna transcripción menciona un cartel, aviso o cookies, y esos carteles no están en paginas/02.txt. En la nota de Clarín (paso-03 y paso-04) arriba se ve «Leé el diario de hoy» y los íconos de redes, no el título. Un matiz: en ANSES, «¿En qué puedo ayudarte?» es una burbuja de chat chica que no tapa la página.

### P13 · «Resumir» repite lo que se dijo al llegar a la nota y pone fechas absolutas

*grave* · confirmado · jueces: Marta, Lucía, Roberto, Ana, Verificador 1 · escenarios: noticias-la-nacion

Evidencia:
- Al llegar, paso 4: «El acusado, Loïk Le Priol, pidió disculpas a la familia del exPuma y descartó la premeditación. Admitió haberle pedido a su expareja que destruyera la tarjeta SIM…»
- Resumen, paso 5: «…pidió disculpas … durante su interrogatorio en el juicio, que se hizo el 21 de septiembre de 2026. Descartó la idea de premeditación y dijo que sufre de estrés postraumático, pero al final del día admitió que pidió destruir la tarjeta SIM…» ⟶ CORTADO (~29 %).
- Verificador 1: el juicio no fue un solo día; «21 de septiembre de 2026» es la fecha de la nota y del interrogatorio.
- Lucía (grave): el resumen «no dice nada sobre la frase de los dinosaurios, que fue lo que me hizo abrir la nota».
- Ana: «Me ofreció «Resumir la nota» justo después de habérmela resumido».

Causa probable: summarize() (1553-1610) le manda a answerer.answer una consigna fija («Resumí… qué pasó, quién, cuándo…») junto con la página, y nada más. No sabe lo que se dijo al llegar, ni qué titular tocó la persona, ni la fecha de hoy.

La llegada a una nota ya la resume (orient: «Si es una nota: de qué trata, en dos frases»), y aun así después se ofrece «Resumir la nota» (2587-2588).

Propuesta: 1. Pasarle a summarize lo que se dijo al llegar y el titular tocado, con la consigna «contá lo que falta (contexto, qué sigue) y explicá el titular».
2. Pasarle la fecha de hoy y pedir que diga «hoy» o «ayer».
3. Si no hay nada nuevo que contar, decir «Es lo que te conté al entrar. ¿Te la leo?».
4. Después de una llegada que ya resumió, ofrecer «Leer la nota» y «Más detalles» en lugar de «Resumir la nota».

Escéptico: Pasa. La llegada (paso 4) ya dijo «pidió disculpas… descartó la premeditación. Admitió haberle pedido a su expareja que destruyera la tarjeta SIM», y el resumen (paso 5) repite esos tres hechos. Agrega sólo «estrés postraumático» y «que se hizo el 21 de septiembre de 2026», que es hoy; la página dice «décima jornada de juicio», así que el juicio no fue un solo día. No menciona los dinosaurios, y después de la llegada igual se ofreció [Resumir la nota]. Lo único del arnés es el CORTADO ~29 %: el script escribió «volvé» 7 s después, cuando el resumen dura unos 25 s.

### P14 · «Abriendo «<titular cortado>…»» repite el botón que se acaba de tocar y demora la descripción

*grave* · confirmado · jueces: Marta, Lucía · escenarios: noticias-la-nacion, solo-botones-clarin

Evidencia:
- noticias, paso 4: «Abriendo «La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su…»». La descripción queda en cola y empieza a sonar recién a los +47,7 s.
- Clarín, paso 3: «Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos…»».
- Marta (grave): «Me repite entero el titular que acabo de tocar, y encima cortado a mitad de frase.»

Causa probable: En accept() (Assistant.swift:1735-1736), cuando la etiqueta empieza con «Abrir «», se dice «Abriendo «» seguido de la etiqueta ya recortada por short().

Propuesta: Decir sólo «Abriendo la nota.», o como mucho las primeras 3 o 4 palabras. Nunca repetir el texto del botón tocado.

Escéptico: Pasa en los dos escenarios. En La Nación, paso 4: 🔊 «Abriendo «La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comieron a su…»». En Clarín, paso 3: «Abriendo «El Gobierno apunta a un gas contaminado… casi dos…»». Lo arma accept() con say("Abriendo «" + label.dropFirst(...)), y la descripción queda en cola detrás (La Nación +45,1 s → +47,7 s; Clarín +34,5 s → +36,7 s). La demora es de unos 2 s: real, aunque chica.

### P15 · Botones de relleno: controles de audio, notas ajenas y preguntas que ya se contestaron

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, clima-cordoba, anti-robot-misma-pagina

Evidencia:
- [Abrir «Escuchar nota»] en La Nación y [Abrir «Reproducir audio»] en Wikipedia. Son reproductores que harían sonar audio encima de VoiceOver.
- [Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»] como tercera opción en la nota del apagón.
- Clima: [¿Qué noticias hay?] como primer botón. Después [¿Qué temperaturas se esperan?] · [¿Y el viento?], cuando ya había dicho «mínima de 6 °C y la máxima de 19 °C» y ráfagas de 33 km/h.
- anti-robot-misma-pagina: [¿Hay alguno con cancelación de ruido?], cuando ya había dicho «Auriculares con Cancelación de Ruido a $89.900».

Causa probable: En una nota, arrived() suma una sugerencia «abrir» del modelo (others.prefix(1), línea 2586). candidates() (2159-2197) no excluye los reproductores de audio y video, ni las notas populares del pie que no están en una zona de navegación.

fresh() (1306) compara sólo con la respuesta inmediata, no con lo que ya se dijo en la misma página.

«¿Qué noticias hay?» es una pregunta que propuso el modelo por la franja de noticias de Meteored.

Propuesta: 1. Sacar de candidates los controles de medios (escuchar, reproducir, audio, video, play).
2. En una nota, no ofrecer otras notas salvo que compartan palabras con el título. Si hace falta un tercer botón, «Volver a los titulares».
3. Que fresh() compare con todo lo que JEF dijo desde que llegó a esa página.
4. Pedirle al modelo preguntas sobre el tema del pedido.

Escéptico: Todo está en las transcripciones. [Abrir «Escuchar nota»] (La Nación, paso 4) y [Abrir «Reproducir audio»] (Wikipedia, paso 2). [Abrir «Clave Única PAMI…»] en la nota del apagón, que en paginas/03.txt está en la lista del pie junto a «Cuándo empieza la inscripción escolar…». En el clima, [¿Qué noticias hay?] como primer botón, y [¿Qué temperaturas se esperan?] · [¿Y el viento?] después de haber dicho «mínima de 6 °C y la máxima de 19 °C… ráfagas… 33 km/h». En anti-robot, [¿Hay alguno con cancelación de ruido?] después de haber dicho «Auriculares con Cancelación de Ruido a $89.900». Ninguno viene de un toque mecánico.

### P16 · Todo se llama «nota»: el artículo de Wikipedia y el pronóstico también

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: wikipedia-mar-del-plata, clima-cordoba

Evidencia:
- Wikipedia: [Leer la nota] · [Resumir la nota], y después «Fin de la nota.»
- Clima: «ahora estás en la nota «Tiempo en Córdoba mañana»» y [Leer la nota] · [Resumir la nota].
- Roberto: «Parece que el asistente no sabe dónde estoy.»

Causa probable: isArticle() decide por la cantidad de párrafos largos, y los nombres están fijos en arrived() (2587-2588), followUps (2322-2324), readAloud (1504) y summarize («Resumen de la nota»). Sólo whereIs() distingue Wikipedia («el artículo»).

Propuesta: Una sola función que dé el nombre de cada página y que usen todos esos lugares: «artículo» en enciclopedias, «pronóstico» en sitios del tiempo o con títulos de tiempo, clima o pronóstico, «nota» en diarios y «página» en el resto.

Escéptico: Pasa. En Wikipedia, [Leer la nota] · [Resumir la nota] y al final 🔊 «Fin de la nota.». En Meteored, «La página cambió: ahora estás en la nota «Tiempo en Córdoba mañana»» y [Leer la nota] · [Resumir la nota]. En el código, los nombres están fijos en 1504, 1604, 2326-2327 y 2587-2588, y whereIs() (2790-2791) sólo distingue Wikipedia.

### P17 · Lo que JEF va a hacer se dice al final y se pierde

*menor* · del script de prueba · jueces: Marta, Roberto, Lucía · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-misma-pagina

Evidencia:
- mercadolibre, paso 1: «Cuando elijas, sigo con «buscame auriculares bluetooth».» ⟶ DESCARTADO. Roberto: «Creí que se había olvidado de los auriculares».
- anti-robot: «…«Ir a la prueba» lleva hasta ella. Cuando esté resuelta, seguimos.» ⟶ CORTADO (~40 % y ~80 %). Roberto: «Es largo y lo que tengo que tocar está al final; lo escuché a medias.»

Causa probable: carry() dice «Cuando elijas…» (línea 359) después de present(), que ya dijo la lista entera como anuncio aparte (848-880). askToSolve (1261) ordena el mensaje así: explicación, acción, plan.

Propuesta: 1. Decir el plan antes de la lista: «Primero elegí cuál es Mercado Libre; después busco los auriculares.» Si P04 abre el sitio directo, esta frase no hace falta.
2. El aviso de la prueba, en dos frases y con la acción primero (ver P01).

Escéptico: El orden es el descripto: «Cuando elijas, sigo con…» va en cola detrás de una lista de ~18 s, y el aviso de la prueba termina en «Cuando esté resuelta, seguimos.». Pero la pérdida la causa el ritmo del script: en Mercado Libre tocó a los 5,6 s (+10,5 → +16,1 s), en misma-pagina tocó «Ir a la prueba» a los 5,4 s, y en avanza-sola lo cortó la página de prueba que se resolvió sola a los 10,9 s, cuando «seguimos» ya no hacía falta. Además, en Mercado Libre la línea queda escrita y el paso 2 sí sigue («Buscando auriculares bluetooth en mercadolibre.com.ar»). Y «Ir a la prueba» no está al final: está en el medio del mensaje y es el primer botón.

### P18 · La lista de resultados incluye opciones que confunden

*menor* · confirmado · jueces: Lucía, Ana, Roberto, Marta, Verificador 1 · escenarios: dolar-desde-cero, banco-nacion, otra-cosa, mercadolibre-auriculares, turno-anses

Evidencia:
- dolar: «Dólar hoy, dólar blue hoy: a cuánto cotiza este miércoles 24 de ...». Es una nota del 24/9/2025.
- banco: «Adiós al home banking del Banco Nación: cómo operar ahora…, radiomitre.cienradios.com». Ana: «Me asusta: ¿ya no existe?»
- otra-cosa: «Últimas noticias de Costa Rica | La Nación — www.nacion.com».
- mercadolibre: «Mercado Libre — listado.mercadolibre.com.ar», que es una pantalla de ingreso («¡Hola! Para continuar, ingresa a.»).
- ANSES: «ANSES — servicioswww.anses.gob.ar», que es una consulta de estudios con captcha.

Causa probable: ranked() manda al final los resultados de otro país, pero si hay pocos igual entran entre los tres primeros. Además no mira fechas, no agrupa las variantes de un mismo sitio, y el filtro de pantallas de ingreso mira el subdominio (ingresar., login.) pero no títulos como «Para continuar, ingresa».

Propuesta: 1. Si el pedido dice «hoy», descartar los resultados con otra fecha.
2. Dejar una sola variante por marca: mercadolibre.com.ar y no además .com.
3. Si se pidió entrar a un sitio, poner las notas de prensa después de los accesos.
4. Filtrar también los títulos de pantallas de ingreso.

Escéptico: Los cinco casos están en las páginas de resultados. Dólar: la opción 3 es de lanacion.com.ar, con la dirección «…miercoles-24-de-septiembre-nid24092025/, 2025-09-24». Banco: la opción 3 es «Adiós al home banking del Banco Nación… radiomitre». Otra-cosa: la opción 3 es «Últimas noticias de Costa Rica | La Nación — www.nacion.com». Mercado Libre: la opción 3 es listado.mercadolibre.com.ar, con el texto «¡Hola! Para continuar, ingresa a.», y la opción 2 es mercadolibre.com. ANSES: la opción 2 es servicioswww.anses.gob.ar/Z2CONSEDUCSitio, «Consulta para completar o iniciar estudios. Ingrese el código que se muestra en la imagen». Es el contenido de la lista, no la elección del script.

### P19 · Datos sin fuente o con alcance ambiguo, y nombres de producto cambiados

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 2 · escenarios: dolar-desde-cero, solo-botones-clarin, clima-cordoba, anti-robot-misma-pagina, anti-robot-avanza-sola

Evidencia:
- dolar: «El dólar oficial está a $1.482,52 para la compra y $1.534,23 para la venta.» No dice de dónde sale ni de qué oficial se trata.
- Clarín: al llegar dijo «casi dos millones de personas» y la nota dice «casi 600.000 usuarios». Las dos cifras están en la página, pero nadie explica la diferencia.
- Clima: «No, no va a llover.» Verificador 2: la página no trae ningún dato de lluvia.
- misma-pagina: «el Auricular In Ear Bluetooth Básico», cuando en la página dice «Auriculares In Ear Bluetooth Básicos». Avanza-sola: «el "Auriculares In Ear Bluetooth Básicos"».

Causa probable: Las instrucciones de Answerer no piden nombrar la fuente, ni copiar los nombres propios tal cual, ni avisar cuando algo es una deducción. Lo único que se verifica son las cifras.

Propuesta: 1. En respuestas con cifras, pedir «según <sitio>».
2. Copiar los nombres de productos tal cual y verificarlos como se verifican las cifras.
3. En pronósticos, decir «el pronóstico no marca lluvia» salvo que la página dé una probabilidad.
4. Si dos cifras parecen contradecirse, aclarar las dos: «600.000 usuarios, unos dos millones de personas».

Escéptico: Se sostienen el de clima (la página no trae datos de lluvia y la app dijo «No, no va a llover.») y el de misma-pagina («el Auricular In Ear Bluetooth Básico» cuando la página dice «Auriculares… Básicos»). Los de Clarín y el dólar están exagerados: la app repitió el título del diario, y el turno anterior había dicho «En DolarInfoHoy.».

### P20 · Nombres técnicos en lugar del nombre del sitio

*menor* · confirmado · jueces: Marta, Roberto, Ana, Verificador 1 · escenarios: mercadolibre-auriculares, turno-anses, noticias-la-nacion

Evidencia:
- mercadolibre, paso 2: «Estás en www.mercadolibre.com.ar.»
- ANSES, paso 1: «2. ANSES, servicioswww.anses.gob.ar». Roberto: «“servicioswww” leído en voz alta es un trabalenguas».
- Botones de resultados con «— www.lanacion.com.ar» y «— www.youtube.com». Ana: «tengo que leer cosas de computadora».

Causa probable: displaySite (PageModel.swift:75-89) devuelve el og:site_name tal cual cuando se parece al dominio, y el de Mercado Libre es «www.mercadolibre.com.ar». En la lista hablada, present() usa bare(host), que sólo quita un «www.» al principio y deja subdominios como «servicioswww».

Propuesta: 1. Quitar el «www.» también del nombre del sitio.
2. En la lista hablada y en los botones de resultados, usar el nombre del sitio o el dominio principal («anses.gob.ar»), nunca el subdominio.

Escéptico: En mercadolibre dice «Estás en www.mercadolibre.com.ar.» (es el og:site_name). La lista hablada de ANSES dice «servicioswww.anses.gob.ar» y los botones terminan en «— www.lanacion.com.ar» y «— www.youtube.com». Coincide con displaySite() y bare().

### P21 · Números y fechas que la voz no lee bien

*menor* · confirmado · jueces: Roberto, Lucía, Verificador 1 · escenarios: wikipedia-mar-del-plata, dolar-desde-cero

Evidencia:
- Wikipedia: «En 2022 tenía una población total de 644 234 habitantes.» En registro.jsonl el separador es un espacio común, que se leería como dos números.
- dolar: «se actualizó el 21/9 a las 15:00 hs» y, en la otra respuesta, «el 21 de septiembre a las 11:03 hs».
- Roberto: «Con los centavos, los números se hacen largos de escuchar».

Causa probable: forEar() (Assistant.swift:1095-1097) sólo saca el «,00». Todo lo demás llega a la voz tal como lo escribió el modelo.

Propuesta: 1. En forEar: «644 234» pasa a «644.234», «21/9» a «21 de septiembre» (o «hoy»), y «15:00 hs» a «a las 15».
2. Lo escrito queda exacto; evaluar redondear los centavos sólo en la voz.

Escéptico: En registro.jsonl, «644 234» lleva un espacio común (0x20), y la voz dice «el 21/9 a las 15:00 hs». forEar() sólo quita «,00». En cambio, «21 de septiembre» se escucha bien.

### P22 · «Volver a la página anterior» no dice adónde vuelve

*menor* · confirmado · jueces: Marta, Lucía, Roberto · escenarios: noticias-la-nacion, banco-nacion, anti-robot-avanza-sola

Evidencia:
- noticias, paso 6: en la portada, [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior]. Lucía: «¿a la búsqueda?».
- banco, paso 4: [Completar «Usuario»] · [Volver a la página anterior]. Marta: «en medio de un login me da miedo de perder lo que cargué».
- avanza-sola, Roberto: «“Volver a la página anterior” ¿me lleva de nuevo a la prueba?»

Causa probable: La etiqueta está fija en closeTurn() y followUps() (2235, 2293, 2319, 2333). El motor ya tiene la dirección anterior (engine.backURL, usada en ReaderView.back()), pero no se usa para el nombre del botón.

Propuesta: 1. Nombrar el destino: «Volver a los resultados de «la nación»», «Volver a la nota del juicio».
2. En un formulario con datos cargados, avisar que se pierden.
3. Saltar la página de la prueba ya resuelta.

Escéptico: Aparece un «Volver a la página anterior» sin destino en la portada después de «volvé», en el login del banco con el DNI ya cargado y en avanza-sola, donde volver lleva a captcha.html. La etiqueta es fija en Assistant.swift (líneas 2235, 2293, 2319 y 2333).

### P23 · En formularios no dice qué falta, si es el sitio oficial ni qué pasa con el dato

*menor* · confirmado · jueces: Marta, Roberto, Lucía · escenarios: banco-nacion

Evidencia:
- «Te pide tu DNI y tu usuario para entrar.» Roberto: «No me avisó que después viene la clave.»
- «Listo: quedó escrito en «DNI», terminado en 456.» y nada más. Marta: «no me dice qué falta para entrar».
- Lucía: «no me dice si el DNI pasa por el asistente o se guarda en algún lado» y «Tengo que deducirlo de «digital.bna.com.ar»».

Causa probable: La confirmación de ask() (254-265) y complete() no miran qué campos quedan. La orientación sólo ve el primer paso del ingreso.

Propuesta: 1. Después de escribir: «Falta Usuario; después viene la clave, que escribís vos».
2. En páginas con campos de ingreso, confirmar el sitio en una frase: «es el sitio del Banco Nación, bna.com.ar».
3. Al pedir el dato, decir: «Va sólo a la página del banco; no lo guardo».

Escéptico: Es cierto que no nombra la clave ni el botón «Continuar», y que tampoco lo ofrece. Pero el resto está exagerado: dijo «va directo a ese campo de la página», dijo «Home Banking del Banco Nación» y ofreció «Completar «Usuario»» como primera opción.

### P24 · Etiquetas de botones cortadas a mitad de frase

*menor* · confirmado · jueces: Lucía, Roberto, Ana, Verificador 2 · escenarios: noticias-la-nacion, otra-cosa, primera-vez, turno-anses

Evidencia:
- [Abrir «La aterradora frase … "Los dinosaurios que se comieron a su…»]
- [Abrir «El equipo que arrasa con goleadas … (ahora sin…»]. Verificador 2: corta justo «Messi» y deja el paréntesis abierto.
- [Abrir «Una jueza declaró la inconstitucionalidad … y sobreseyó a…»] y [Abrir «Plan de Pago … para trabajadores en actividad, ver…»].

Causa probable: short(…,100) (Assistant.swift:1103-1118) corta en la última palabra antes de las 100 letras, sin buscar una pausa natural. Como los titulares no quedan escritos (P09), el título completo no aparece en ningún lado.

Propuesta: 1. Botones cortos y numerados, con el título completo escrito arriba (P09).
2. O un accessibilityLabel con el título entero.
3. Si hay que cortar, hacerlo en una pausa natural (dos puntos, coma), y nunca dejar un paréntesis o unas comillas abiertos.

Escéptico: Aparecen «…que se comieron a su…» y «(ahora sin…», donde se corta justo «Messi». En ANSES el «ver…» ya viene así de la página, así que no lo cortó short(). Y sí hay título completo en otro lado: titulares 5 a 7 escritos y 1 a 4 dichos.

### P25 · El texto de ayuda del campo de escribir casi no se ve

*menor* · confirmado · jueces: Ana · escenarios: otra-cosa, banco-nacion

Evidencia:
- otra-cosa: «el texto gris clarito sobre fondo gris casi no se ve».
- banco: «El aviso de que ahora escribo en el DNI aparece dentro del campo, en gris muy clarito».

Causa probable: En AssistantPanel.swift (composer), el texto de ayuda usa .foregroundStyle(.secondary) sobre .tertiarySystemFill, con un borde .secondary de 1 punto.

Propuesta: 1. Texto de ayuda en .primary con opacidad alta, y un borde de 2 puntos con el color de acento cuando el campo está activo.
2. Mostrar «Estás escribiendo el DNI» arriba del campo, con letra normal.

Escéptico: Se ve en las capturas: en otra-cosa/paso-03.jpg «¿Qué querés hacer?» y en banco-nacion/paso-03.jpg «Escribir: DNI» están en un gris muy pálido sobre la cápsula gris del campo, casi sin contraste. El código coincide con la causa probable: Sources/UI/AssistantPanel.swift:216 usa `prompt: Text(...).foregroundStyle(.secondary)`, la línea 225 `.background(Color(.tertiarySystemFill), in: Capsule())` y la 227 `strokeBorder(Color.secondary, lineWidth: 1)`. Es un estilo de la app, no algo que haya hecho el script. Una salvedad: las dos personas de estos escenarios son ciegas y el texto sí les llega por VoiceOver (el árbol muestra `[campo] Pedido = Escribir: DNI (Va directo al campo «DNI» de la página.)`). Por eso el problema pega en usuarios con baja visión y la gravedad «menor» está bien puesta.

## Lo que funciona

- Banco Nación, la mejor sesión (4,45). Los botones «Completar «DNI»» y «Completar «Usuario»» se ofrecen primero; el campo pasa a decir «Escribir: DNI» y lo escrito va directo a la página. La confirmación es «Listo: quedó escrito en «DNI», terminado en 456.», y en la conversación queda «DNI terminado en 456», nunca el número entero. Los cuatro jueces lo destacan.
- Detecta sola que la prueba anti-robot se resolvió, incluso sin cambio de dirección (mira la página cada 2 s con watchChallenge), y retoma lo pendiente: «Listo, ya pasamos la verificación.» y la lista de precios. «Ya la resolví» queda como salida por si no se da cuenta.
- Con la prueba anti-robot en pantalla no inventa respuestas: «Todavía está la prueba anti-robot en la página. Cuando esté resuelta, contesto eso.»
- Contestar preguntas sobre la página abierta anda bien: el blue y el oficial exactos, primero compra y después venta, con la hora de actualización. Entiende «¿y el oficial?» por el pedido anterior. Contesta la fecha de fundación en una oración («Mar del Plata se fundó el 10 de febrero de 1874.») y responde «No, no va a llover.» empezando por sí o no. Los verificadores no encontraron cifras inventadas.
- El primer botón después de un dato es la pregunta que sigue: «¿A cuánto está el dólar oficial?».
- En la portada, 4 titulares textuales elegidos por el código, que son los mismos que los botones, y la primera opción siempre sensata. En solo-botones-clarin, tocando siempre la primera opción, se llegó a leer la nota.
- Al llegar a una nota, dice en 2 o 3 frases de qué trata antes de ofrecer «Leer la nota» como primer botón.
- La lectura va en tandas, con la posición adelante: «Párrafos 1 a 2 de 10:», «Seguir leyendo» primero, texto textual y sin las marcas de referencia de Wikipedia.
- «volvé» contesta corto y exacto: «De vuelta en la portada de LA NACION.»
- «llevame a deportes» abre la sección del mismo diario sin buscar (exactOption, sin modelo).
- «Otra cosa» deja escribir y ofrece «Volver a las opciones». Los jueces sintieron que el control era suyo (4,40).
- El botón de inicio «Llevame a La Nación» abre el diario directo, sin lista.
- Al ordenar resultados, descarta anuncios y copias de prueba (sandbox), baja la Córdoba de España y La Nación de Costa Rica, y pone primero lo oficial.
- Recuerda la tarea a través de las páginas: en ANSES, «Para sacar un turno, tenés la opción de ir a Turnos.»; en Mercado Libre, buscó los auriculares solo al entrar.
- «¿dónde estoy?» se contesta en una frase, con tres botones claros.
- Todos los turnos terminan con botones y «Otra cosa». El primer botón avisa «Primera de N opciones». Todo está en castellano y sin nombres internos.
