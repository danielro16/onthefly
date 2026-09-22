# Veredicto — ronda-17

Cuatro jueces (Marta, Roberto, Lucía y Ana) y dos verificadores videntes recorrieron los 17 escenarios: 45 de 68 intentos terminaron en «sí», 8 «a medias» y 15 «no», con un promedio general de 3,33 sobre 5. El producto ya hace bien lo más difícil de ganar: llega al sitio oficial correcto siempre, dice el dominio, entiende repreguntas en contexto, y en Banco Nación resuelve un formulario con dato sensible mejor que cualquier app que estos jueces usen. Lo que lo frena no es la inteligencia: es el canal. El problema número uno es que una respuesta se dice en tres o cuatro anuncios que se encolan y se pisan —casi cuarenta anuncios cortados, descartados o sonando hasta 28 segundos tarde—, y como lo escrito dice menos que lo hablado, lo que se perdió no se puede recuperar con el rotor ni existe un botón para repetirlo. El segundo es que la primera opción, que es la que toca todo el mundo, suele ser basura de la página: el formulario del boletín en Meteored, Adidas y una casa de apuestas en la página oficial de entradas de Boca, «Enlace sin nombre» en el Correo, el botón de Google cuando se quería Mercado Libre. El tercero es de pantalla: con una respuesta larga no se ve NINGÚN botón, lo que para Ana (baja visión, no usa VoiceOver) es quedarse sin camino. Los cinco escenarios que fracasaron —Mercado Libre, PAMI, Boca, Correo y ANSES a medias— fracasan por estas causas y no por falta de capacidad: en PAMI dos botones se llaman igual («Completar «Ingresar sólo números»») porque el campo se nombra por su placeholder y hasta comparten el id; en Mercado Libre el asistente se va a Google a contestar y de paso aprieta un botón en otra página. Dos reclamos de los jueces los descarto como artefactos de la prueba: que con el asistente cerrado «no queda nada para recorrer» (el volcado del árbol sólo toma los controles de la app, no el contenido web), y que «Otra cosa» no lleve el foco al campo (AssistantPanel.swift sí lo mueve y abre el teclado; el registro no anota foco, así que no hay medición que lo contradiga).

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.5 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.4 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |
| primera-vez | Marta a medias, Roberto a medias, Lucía sí, Ana sí | 3.9 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.6 |
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.6 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana a medias | 3.6 |
| infobae-titulares | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| clima-cordoba | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| cerrar-asistente | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| anti-robot-misma-pagina | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.4 |
| turno-anses | Marta a medias, Roberto no, Lucía a medias, Ana a medias | 2.8 |
| correo-seguimiento | Marta no, Roberto a medias, Lucía no, Ana no | 2.6 |
| entradas-boca | Marta no, Roberto no, Lucía no, Ana no | 2.3 |
| pami-turno | Marta no, Roberto no, Lucía no, Ana a medias | 2.2 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 1.6 |

**Promedio general: 3.33**

## Problemas

### voz-se-pisa · Una respuesta = varios anuncios: se pisan, llegan hasta 28 s tarde o no suenan nunca

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, infobae-titulares, cerrar-asistente, mercadolibre-auriculares, primera-vez, anti-robot-avanza-sola, anti-robot-misma-pagina

Evidencia:
- noticias-la-nacion, paso 3: «3. La Fiscalía apeló el fallo que declaró la inconstitucionalidad del régimen penal juvenil» ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara; el titular 2 «en cola: empieza a sonar a los +42.5s» (se pidió a los +31,9 s).
- wikipedia-mar-del-plata, paso 5: «La ciudad cuenta con un complejo deportivo que fue subsede del Mundial de Fútbol 1978…» ⟶ en cola: empieza a sonar a los +79.6s (28 s después del toque).
- cerrar-asistente, paso 6: «3. Garbarino y su dueño, en quiebra…» ⟶ en cola: empieza a sonar a los +71.1s (15 s después de pedir los titulares).
- anti-robot-misma-pagina, paso 2: «La prueba quedó a la vista, en la página, con el asistente cerrado…» ⟶ CORTADO por el anuncio siguiente (se habría escuchado ~43%) — lo cortó el propio JEF con «Listo, ya pasamos la verificación».
- primera-vez, paso 1: «Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar…» ⟶ CORTADO (se habría escuchado ~61%).
- mercadolibre-auriculares, paso 1: los cuatro anuncios del paso quedaron DESCARTADOS, incluido «Cuando elijas, sigo con «auriculares bluetooth».»
- Roberto: «casi cuarenta anuncios cortados, descartados o encolados… Para mí eso es que el teléfono se colgó.»

Causa probable: Cada línea escrita dispara su propio anuncio: `say()` en /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:217 llama a `Voz.decir` una vez por turno, y una sola respuesta emite tres o cuatro turnos (`readAloud`, líneas 1281-1293, dice el encabezado y después un `say` por párrafo/titular). Los anuncios van en cola (`accessibilitySpeechQueueAnnouncement` en /Users/daniel/Developer/JEF- BROWSER/Sources/Engine/Registro.swift:19-23), así que el segundo espera a que termine el primero —40 s de titulares— y el pedido siguiente, que pone `interruptNext = true` (Assistant.swift:232), descarta todo lo que quedaba. Además el propio JEF se corta a sí mismo: Assistant.swift:2285 fuerza `interruptNext = true` antes de «Listo, ya pasamos la verificación», y Assistant.swift:1038 hace lo mismo con el aviso del captcha.

Propuesta: Un solo anuncio por respuesta, armado como una frase corrida y corta: lo accionable primero («Tres titulares, están abajo», «Resolvé la prueba vos y sigo solo»), la explicación después. Que `readAloud` y la lista de titulares escriban todas sus líneas pero hablen una sola vez. Y una regla de caducidad: si un anuncio no entró a sonar en 2-3 segundos, que se descarte y quede sólo escrito (hoy espera indefinidamente en la cola). Un anuncio propio nunca debe interrumpir al anterior: sacar los `interruptNext = true` de las líneas 1038 y 2285.

Escéptico: Confirmado en las transcripciones y en el propio registro de la app: una respuesta emite 3-4 anuncios encolados (wikipedia paso 5: «La ciudad cuenta con un complejo deportivo…» ⟶ «en cola: empieza a sonar a los +79.6s», 28 s después del toque de +51,8 s; cerrar-asistente paso 6: titular 3 a los +71.1s) y JEF se corta a sí mismo — en anti-robot-misma-pagina el registro muestra «Listo, ya pasamos la verificación» con "cola": false 4,8 s después del anuncio anterior, que queda CORTADO al ~43%. El código lo respalda: `say()` llama a `Voz.decir` una vez por turno, `Voz.decir` encola por defecto, y `heard()`/línea 2285/línea 1038 ponen `interruptNext = true`. Dos matices menores que no tumban el hallazgo: «los cuatro anuncios» de mercadolibre paso 1 son en realidad tres (el primero, +6,9 s, sí sonó), y el corte de primera-vez lo provocó el script al tocar el botón 1 a los +15 s; el «casi cuarenta» de Roberto es exageración (conté 22 marcas entre CORTADO/DESCARTADO/en cola).

### opciones-fuera-de-pantalla · Con la respuesta larga no se ve ningún botón: quien lee la pantalla se queda sin camino

*bloqueante* · confirmado · jueces: Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, infobae-titulares, anti-robot-avanza-sola, anti-robot-misma-pagina, correo-seguimiento, cerrar-asistente, pami-turno, entradas-boca, turno-anses, clima-cordoba, dolar-desde-cero, otra-cosa, mercadolibre-auriculares

Evidencia:
- Verificador, noticias-la-nacion paso 4: «En paso-04.jpg, debajo del texto de JEF viene directamente el campo «¿Qué querés hacer?»: no se ve ninguno de los 4 botones. Lo mismo en paso-03.jpg (0 de 6 visibles) y paso-02.jpg (se ven 2 de 6, el segundo cortado al medio).» — verificado a ojo en la captura: el globo de la nota llena el panel y abajo sólo está el campo.
- Ana, solo-botones-clarin paso 4 (bloqueante): «Después de esos dos párrafos larguísimos no se ve ningún botón en la pantalla. Y yo en este escenario sólo toco lo que me ofrecen: si no veo «Seguir leyendo», me quedé.»
- Verificador, infobae-titulares paso 4: «del primer botón sólo asoma una línea azul de un par de píxeles arriba del campo de texto».
- Ana, general: «En todas las pantallas la última opción visible queda partida al medio… lo que quedó abajo, para mí no existe.» (14 de 17 escenarios)

Causa probable: El panel hace scroll al comienzo de la respuesta y no más: `.onChange(of: assistant.turns.count)` → `scroll.scrollTo(start, anchor: .top)` en /Users/daniel/Developer/JEF- BROWSER/Sources/UI/AssistantPanel.swift:216-226. Si la respuesta es más alta que el panel (detent medio), los botones —que se agregan después, al cerrar el turno— quedan abajo del pliegue y nadie vuelve a mover el scroll. Encima el degradado inferior de 14 pt (AssistantPanel.swift:48-51) corta visualmente la última fila y no hay ninguna marca de «hay más abajo».

Propuesta: Dos cosas: (1) cuando aparecen las opciones (`offer`), hacer un segundo scroll que garantice la primera opción visible arriba del campo —anclar la primera opción, no el comienzo de la respuesta, si la respuesta no entra entera—; (2) plegar o achicar los globos anteriores cuando llega uno nuevo, y dejar debajo de la lista un espacio libre del alto del campo para que ningún botón quede cortado por el degradado. Complemento barato: un renglón «4 opciones» arriba de la lista, como pidió Ana.

Escéptico: Verificado a ojo en las capturas: en noticias-la-nacion paso-04.jpg debajo del globo viene directo el campo «¿Qué querés hacer?» (0 de 4 botones), paso-03.jpg 0 de 6, paso-02.jpg 2 de 6 con el segundo partido al medio; infobae paso-04.jpg muestra sólo una línea azul del primer botón; entradas-boca paso-02.jpg 1 de 4; turno-anses paso-03.jpg corta «Abrir «CONSULTAR TURNO»» con el degradado. El código lo explica: `AssistantPanel.swift:216-224` sólo hace `scroll.scrollTo(responseStart, anchor: .top)` `.onChange(of: turns.count)` y no vuelve a mover el scroll cuando llegan las opciones; el único remedio es `placeFocus()`, que mueve el foco de VoiceOver — no sirve a quien mira la pantalla.

### primera-opcion-basura · La primera opción suele ser basura de la página: newsletter, sponsors, enlaces sin nombre, filas de tabla

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: clima-cordoba, entradas-boca, correo-seguimiento, dolar-desde-cero, mercadolibre-auriculares, pami-turno

Evidencia:
- clima-cordoba, paso 2: «[Completar «Introduce tu email»] (Primera de 5 opciones.)» — verificador: «es el campo de suscripción al boletín de Meteored… A alguien que preguntó el clima se le ofrece, antes que nada, dejar su correo a un sitio.»
- entradas-boca, paso 2: «🔘 Botones: [Abrir «Adidas»] · [Abrir «Betsson»]» — las dos únicas opciones son auspiciantes, y la segunda una casa de apuestas.
- correo-seguimiento, paso 2: «[Abrir «Enlace sin nombre»] (Primera de 3 opciones.)» — único botón de contenido de la pantalla.
- dolar-desde-cero, paso 2: «[Abrir «Dólar Tarjeta $ 1.995,5 0.00%»]» presentado como «titular principal».
- mercadolibre-auriculares, paso 3: «[Pulsar «Buscar con Google»] (Primera de 6 opciones.)» estando ya en la página de resultados.
- Roberto: «Yo toco siempre lo primero, porque escribir me cuesta.»

Causa probable: Tres fugas distintas: (1) los campos de formulario van SIEMPRE primeros — `closeTurn` arma `var options = form + current.options` en /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift (bloque «Completar va primero»), y `pageForm` (línea 2239) toma el primer formulario no-buscador de la página, que en Meteored es el del boletín; `isSubscription` (línea 1088) sólo mira URL y título, así que un formulario de newsletter dentro de una página normal no se filtra. (2) Los enlaces sin nombre se filtran en `page.actions` (`where action.unnamed != true`, línea 2605) pero NO en la rama del stream, que agrega cualquier `entry.kind == "link"` sin mirar `entry.noise`, que existe en /Users/daniel/Developer/JEF- BROWSER/Sources/Engine/PageStream.swift:21 y que extract.js sí marca (/Users/daniel/Developer/JEF- BROWSER/Sources/Extraction/extract.js:2939, «Enlace sin nombre», noise: true). (3) El filtro `useful()` de `candidates` (línea 1990) sólo descarta por región chrome, largo <5 y una lista de palabras de pago/suscripción: una tira de logos de sponsors en main pasa entera.

Propuesta: Filtrar antes de ofrecer y ordenar por el pedido, no por el orden de la página: descartar `noise`/`unnamed` también en la rama del stream; no ofrecer formularios de suscripción (detectar el formulario por sus campos —un solo email + «suscribirme»— y no por la URL); descartar las tiras de logos de auspiciantes (links agrupados por `group` en el stream, sin texto propio, apuntando a otros dominios); y sacar de la lista los controles del propio buscador cuando ya se está en sus resultados. Si después de filtrar no queda nada útil, decirlo con todas las letras («no encuentro en esta página cómo comprar entradas») en vez de rellenar.

Escéptico: Las cinco citas están textuales y el problema es qué se ofrece primero, no qué tocó el script: clima-cordoba paso 2 «Completar «Introduce tu email» (Primera de 5 opciones.)» —la página extraída dice «El Tiempo en tu email … Suscribirme» y «FORMULARIO que pide: Introduce tu email, Accept»—; entradas-boca paso 2 sólo ofrece «Abrir «Adidas»» y «Abrir «Betsson»»; correo-seguimiento paso 2 «Abrir «Enlace sin nombre» (Primera de 3 opciones.)»; dolar-desde-cero paso 2 «Abrir «Dólar Tarjeta $ 1.995,5 0.00%»» como titular 1; mercadolibre paso 3 «Pulsar «Buscar con Google» (Primera de 6 opciones.)» ya en los resultados. El código coincide: `closeTurn` arma `var options = form + current.options`, `isSubscription` sólo mira URL y título, y `options(of:)` filtra `unnamed != true` en `page.actions` pero la rama `case "link"` del stream no mira `noise` (extract.js:2939 marca «Enlace sin nombre» con noise: true).

### campos-por-placeholder-y-duplicados · Los campos se llaman por el cartelito gris, y dos quedan idénticos: en PAMI no hay forma de saber en cuál va el documento

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: pami-turno, mercadolibre-auriculares, clima-cordoba

Evidencia:
- pami-turno, paso 3 (árbol): «12 [btn] Completar «Ingresar sólo números» (Primera de 7 opciones.) / 13 [btn] Completar «Ingresar sólo números» (Primera de 7 opciones.)» — dos botones idénticos, los dos anunciados como el primero.
- pami-turno, paso 4: «¿Qué pongo en Ingresar sólo números? Se puede escribir o dictar acá abajo» y el campo rotulado «Escribir: Ingresar sólo números».
- Verificador: «en paso-03.jpg la página tiene dos campos bien distintos: «N° Afiliación» y «N° Documento», los dos con el texto gris «Ingresar sólo números»».
- mercadolibre-auriculares, paso 2: «Listo, escrito en Ingresá lo que quieras encontrar.» — no dice qué escribió ni dónde.
- Ana: «Sólo me di cuenta porque miré la página de arriba… si no viera nada no habría podido.»

Causa probable: `spoken(field)` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1008) devuelve `field.name` tal cual, y ese nombre viene de extract.js, que cae al `placeholder` cuando no encuentra label (extract.js:877-878). En PAMI los dos campos tienen el mismo placeholder, así que `formOptions` (Assistant.swift:2225-2228) genera dos acciones con el MISMO label y el MISMO id (`askPrefix + "completá el campo \(name)"`): por eso las dos dicen «Primera de 7 opciones» (AssistantPanel.swift:202 compara `option.id == offer.options.first?.id`) y por eso el ForEach de SwiftUI trabaja con ids repetidos. Y al confirmar lo escrito (Assistant.swift:605 y 1781) se dice el nombre del campo pero nunca el valor ni el sitio.

Propuesta: Nombrar el campo por la etiqueta que la página muestra al lado (en PAMI «N° Afiliación» y «N° Documento» están en el texto de la página: `nearbyLabel` tiene que ganarle al placeholder también cuando el label está en otra caja), y si aun así dos quedan con el mismo nombre, distinguirlos («el de arriba», «el de abajo») y darles ids distintos sí o sí. Preguntar por el dato, no por el cartelito: «¿Cuál es tu número de afiliación?». Y al escribir, decir qué y dónde: «Escribí «auriculares bluetooth» en el buscador de Mercado Libre».

Escéptico: Textual en pami-turno arbol-03: «12 [btn] Completar «Ingresar sólo números» (Primera de 7 opciones.) / 13 [btn] Completar «Ingresar sólo números» (Primera de 7 opciones.)», y paso-03.jpg muestra la página con «N° Afiliación» y «N° Documento», ambos con el placeholder «Ingresar sólo números» (la extracción lo confirma: «FORMULARIO que pide: Ingresar sólo números, Ingresar sólo números»). Paso 4: «¿Qué pongo en Ingresar sólo números?» y el campo rotulado «Escribir: Ingresar sólo números». En mercadolibre paso 2, «Listo, escrito en Ingresá lo que quieras encontrar.» no dice qué escribió ni dónde. El id duplicado también está explicado: `formOptions` usa `askPrefix + "completá el campo \(name)"` y `AssistantPanel.swift:202` compara `option.id == offer.options.first?.id`, por eso los dos dicen «Primera de 7».

### promete-lo-que-no-ofrece · La descripción manda a lugares que no están entre los botones, y a acciones que una persona ciega no puede hacer

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: entradas-boca, correo-seguimiento, dolar-desde-cero, noticias-la-nacion

Evidencia:
- entradas-boca, paso 2: «Para avanzar, podés dirigirte a la sección de entradas o revisar los beneficios disponibles.» — verificador: «No hay ningún botón que lleve a la sección de entradas… en paso-02.jpg la página grita «COMPRA TUS ENTRADAS» y el asistente no ofrece ninguna manera de llegar ahí.»
- correo-seguimiento, paso 3: «La página indica que tenés que escanear el código de barras que figura en la etiqueta de tu envío para poder seguirlo.» — Lucía: «Soy ciega y tengo el número escrito, no un escáner.»
- dolar-desde-cero, paso 2: «Los titulares principales son las primeras opciones» dicho sobre las cajitas de cotización.
- Marta, entradas-boca: «Me mandó a un lugar que no existe en la lista.»

Causa probable: El texto y los botones se arman por caminos separados y nadie los cruza: `landed()` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2360-2410) pide al modelo una orientación sobre el texto entero de la página y después construye las opciones a partir de `orientation.suggestions`, que el modelo elige de la lista de candidatos ya filtrada. Si la sección que el modelo nombró no sobrevivió al filtro de `candidates`, la frase queda igual. No hay ninguna verificación de que lo nombrado en el texto exista como opción, ni un chequeo de accesibilidad de lo que la página pide (escanear, mirar, arrastrar).

Propuesta: Regla de oro, verificable en código: antes de decir la orientación, cruzar los sustantivos de acción que nombra contra las etiquetas de las opciones; si nombra algo que no está, o se agrega el botón o se saca la frase. Y cuando lo que la página pide no se puede hacer sin ver (escanear un código, resolver una imagen), decirlo y ofrecer la alternativa que sí existe: el campo de número de seguimiento, o el teléfono.

Escéptico: Confirmado: entradas-boca paso 2 dice «podés dirigirte a la sección de entradas o revisar los beneficios disponibles» y los únicos botones son «Abrir «Adidas»» y «Abrir «Betsson»» —la página tiene «Compra tus entradas» en el contenido y «Entradas» en el menú, pero `candidates` descarta la región nav—; correo-seguimiento paso 3 dice «tenés que escanear el código de barras» (es fiel a la página, que dice «Escaneá el código de barras de la etiqueta») sin ofrecer alternativa accesible en esa respuesta; dolar-desde-cero paso 2 llama «titulares principales» a «Dólar Tarjeta $ 1.995,5 0.00%». El código no cruza texto con opciones: `landed()` pide la orientación sobre `saying(page)` entero y arma los botones aparte desde `orientation.suggestions` sobre `candidates` ya filtrados. Único flojo: noticias-la-nacion figura en la lista de escenarios sin evidencia propia.

### sale-del-sitio-y-hace-dos-cosas · Un pedido dentro de un sitio se resuelve en Google, y mientras contesta toca botones en otra página

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: mercadolibre-auriculares

Evidencia:
- Paso 3: «Buscando: auriculares bluetooth más baratos.» → «📄 Cargó https://www.google.com/search?q=auriculares%20bluetooth%20m%C3%A1s%20baratos» estando parada en mercadolibre.com.ar con el texto ya escrito en su buscador.
- Paso 3: «Pulsando «Buscar».» — verificador: «El botón «Buscar» era el de Mercado Libre… Se ejecutó sobre la página de Google: la URL que cargó a continuación es google.com/search?q=auriculares+bluetooth+más+baratos». La acción anunciada y la hecha no son la misma.
- Paso 1: «Buscando: mercado libre.» dos veces seguidas, con los mismos tres resultados duplicados en la conversación y los tres anuncios descartados.
- Roberto: «Me contestó desde un lado y me dejó parado en otro. No entendí en qué página quedé.»

Causa probable: En `ask()` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:341-380) se ejecutan hasta tres cosas del mismo turno sin mirarse entre sí: `carry(decision.action)`, después `carry(next)` —que en este caso repitió la misma búsqueda, de ahí el duplicado— y después `continueWith(rest)`. La parte guardada («Cuando elijas, sigo con «auriculares bluetooth»») quedó pendiente, escribió en el buscador de ML pero no lo envió, y cuando llegó la pregunta nueva el envío se disparó tarde, ya sobre la página de Google que la respuesta había cargado. Y no hay ninguna regla de «si estoy dentro de un sitio con buscador, buscar ahí»: la pregunta va al ruteador, que elige buscar en internet.

Propuesta: Una acción por pedido: no encadenar `action` + `then` sin comprobar que no son la misma, y no ejecutar una acción pendiente sobre una página distinta de aquella en la que se preparó (guardar la URL junto con el pendiente y descartarlo si cambió). Si el sitio donde se está tiene buscador y el pedido es del rubro del sitio, buscar ahí; si hay que salir, decirlo antes: «en Mercado Libre no pude ver los precios, ¿busco en internet?».

Escéptico: Todo textual en mercadolibre-auriculares: paso 1 repite «Buscando: mercado libre.» dos veces con los mismos tres resultados duplicados y tres anuncios DESCARTADOS; paso 3, estando en mercadolibre.com.ar con el texto ya escrito («Listo, escrito en Ingresá lo que quieras encontrar», +28,6 s), dice «Buscando: auriculares bluetooth más baratos» y carga google.com/search; y el pendiente «Pulsando «Buscar»» (+46,6 s) se ejecutó sobre Google —la URL que carga a continuación trae los parámetros del formulario de Google (sca_esv, ei, oq=auriculares+bluetooth+más+baratos)—, así que la acción anunciada y la hecha no son la misma. El código lo explica: `ask()` encadena `carry(decision.action)`, `carry(next)` y `continueWith(rest)` sin compararlos, y `waiting`/«Cuando elijas, sigo con «auriculares bluetooth»» no guarda la URL donde se preparó.

### sin-repetir-ni-donde-estoy · No hay forma de volver a escuchar lo que se perdió ni de preguntar dónde estoy sin escribir

*grave* · confirmado · jueces: Roberto, Marta, Lucía · escenarios: noticias-la-nacion, correo-seguimiento, primera-vez, anti-robot-avanza-sola, anti-robot-misma-pagina, infobae-titulares, turno-anses, cerrar-asistente

Evidencia:
- Roberto, noticias-la-nacion paso 5: «Pedí que me resumiera la nota y el resumen se me cortó cuando iba por menos de la mitad… Y no hay ningún botón que diga «repetilo».»
- Roberto, primera-vez paso 3: «Para preguntar dónde estaba tuve que escribirlo yo. Escribir es justo lo que menos puedo hacer, y esa es la pregunta que más me hago.»
- correo-seguimiento, paso 2: «La línea de atención al cliente es 0810-777-7787» dicho de corrido en el medio de una frase larga, sin botón para repetirlo.
- Roberto lo marcó bloqueante: «Con todo lo que se corta y se pisa, esto es lo que más me falta de todo.»

Causa probable: Las opciones fijas de cada turno se arman en `closeTurn` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift, bloque final) y sólo se agrega «Otra cosa» y a veces «Volver»: no existe ninguna acción de repetir (`latest` ya guarda el último texto, en Assistant.swift:221) ni de reubicar. La respuesta a «¿dónde estoy?» existe y es de las mejores de la ronda, pero hay que tipearla.

Propuesta: Dos botones fijos al lado de «Otra cosa», en todas las pantallas: «Repetilo» (vuelve a decir la última respuesta entera, usando `latest` o el bloque de turnos de la última respuesta) y «¿Dónde estoy?» (la misma respuesta que hoy se da escribiéndola). Son dos acciones locales, sin red.

Escéptico: Conté todos los botones ofrecidos en los 17 escenarios y no aparece ninguno de repetir ni de ubicarse (sólo «Otra cosa» 62 veces, «Volver a los resultados» 26, etc.), y en primera-vez el paso se titula «escribe «no entiendo, ¿dónde estoy?»»: la mejor respuesta de la ronda hay que tipearla. Salvedad: los 5 CORTADO de toda la ronda los provocó el propio paso siguiente del script (el resumen de la nación se corta a los +67,9 s porque el script escribió «volvé» a los +66,8 s), y lo escrito sí queda recorrible — lo que de verdad se pierde para siempre es lo que se dijo y no se escribió (problema 2).

### hablado-distinto-de-escrito · Lo que se dice y lo que queda escrito no son el mismo texto, y lo escrito siempre es más pobre

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: noticias-la-nacion, solo-botones-clarin, infobae-titulares, otra-cosa, primera-vez, cerrar-asistente, dolar-desde-cero

Evidencia:
- noticias-la-nacion, paso 2: escrito «Estás en la portada de La Nación. Los titulares principales son las primeras opciones.» / hablado «…Los titulares principales: 1. Trump amenazó con "aniquilar" a Irán… 2. Milei llegó a Nueva York… 3. La Fiscalía apeló… 4. Jorge Macri activa…»
- Verificador: «Quien se pierda el anuncio (o lo corte con otro pedido) no tiene los titulares escritos en ningún lado.»
- Ana (baja visión, no escucha): «Los titulares no están en el texto: están adentro de los botones, y en la pantalla entra uno y medio de los seis.»
- Roberto: «Es como si alguien me leyera el diario y después me lo escondiera.»

Causa probable: El parámetro `aloud` de `say()` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:217 y 2408-2409) existe justamente para decir más de lo que se escribe. Se hizo para no duplicar los titulares en pantalla —están en los botones—, pero los botones llevan el titular recortado con «…» (`Self.short`), así que el texto completo no queda en ningún lado recorrible.

Propuesta: Una sola versión del texto: lo que se dice es lo que queda escrito, palabra por palabra. Los cuatro titulares numerados como cuatro renglones del mensaje, y los botones como la acción sobre ellos («Abrir el 2»). Si preocupa el largo, que sea corto en los dos lados, nunca dos textos distintos.

Escéptico: Textual en noticias-la-nacion paso 2: 💬 «Estás en la portada de La Nación. Los titulares principales son las primeras opciones.» contra 🔊 «…Los titulares principales: 1. Trump amenazó… 4. Jorge Macri activa…»; el mismo par aparece en clarín, infobae, otra-cosa, primera-vez, cerrar-asistente y dólar paso 2. Los botones llevan el titular cortado con «…» y la captura paso-02.jpg muestra que en pantalla entran el primero y medio segundo de seis, así que el titular entero no queda en ningún lado.

### repite-lo-ya-dicho · Repite los mismos titulares y sugiere preguntas que acaba de contestar

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, infobae-titulares, cerrar-asistente, clima-cordoba, correo-seguimiento, mercadolibre-auriculares

Evidencia:
- noticias-la-nacion, paso 3 (8 s después de haber dicho los cuatro al entrar): «Titulares 1 a 3:» y los mismos tres.
- infobae-titulares, paso 3: «Titulares 1 a 3» — Lucía: «Son los mismos tres que ya me había leído al entrar a la portada, veinte segundos antes. Y encima el tercero se descartó y el segundo sonó a los +43 s.»
- clima-cordoba, paso 3: primer botón «¿Cuándo empieza a llover?» cuando la frase anterior ya dijo «las precipitaciones recién están previstas a partir del sábado».
- correo-seguimiento, paso 3: primera opción «¿Cuál es el teléfono de atención al cliente?» después de haber dicho el 0810 sin que se lo pidieran.

Causa probable: El código YA lleva la cuenta (`readingFrom = lead.count` y `leadSaid` en /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2405-2463, con el prefijo «Los N primeros ya los dije»), pero la rama que atiende «dame los titulares» la borra: al recibir la acción de leer, Assistant.swift:1431 hace `readingFrom = 0` y vuelve a empezar por el 1. En las preguntas sugeridas, el prompt pide no repetir («sin las que tu respuesta ya contestó», /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift) pero nadie lo verifica del lado del código.

Propuesta: No resetear `readingFrom` cuando la página es la misma que ya se leyó: seguir por donde iba y decir «esos ya te los dije, sigo con el cuarto». Y filtrar las preguntas sugeridas contra el texto de la respuesta recién dada: si la respuesta ya contiene el dato, se cae la sugerencia.

Escéptico: Confirmado literal: la nación dice los 4 titulares a los +23,8 s y a los +33,3 s arranca «Titulares 1 a 3:» con los mismos, sin el prefijo «Los N primeros ya los dije» que el propio código tiene previsto; infobae igual (+23,4 → +33,2, con el 3.º DESCARTADO y el 2.º recién a los +43,1 s); clima paso 3 ofrece «¿Cuándo empieza a llover?» después de contestar «a partir del sábado» y correo paso 3 ofrece «¿Cuál es el teléfono de atención al cliente?» después de haber dicho el 0810-777-7787. Único desliz: Lucía dice «veinte segundos antes» y fueron 9,8 s.

### lectura-de-a-dos-con-total-inflado · Leer una nota es de a dos párrafos, con un total que no es real, y sin manera de saltar a una sección

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: solo-botones-clarin, wikipedia-mar-del-plata, noticias-la-nacion

Evidencia:
- wikipedia-mar-del-plata, paso 4: «Párrafos 1 a 2 de 326:» — verificador: «El texto que JEF tenía delante tiene 136 líneas con contenido en total, y de artículo propiamente dicho hay unos 5 párrafos… le anuncia a la persona una lectura 60 veces más larga de la que hay.»
- solo-botones-clarin, paso 4: «Párrafos 1 a 2 de 17:» = nueve toques para una nota de diario.
- Roberto, solo-botones-clarin: «Ese párrafo nunca sonó, y cuando toqué «Seguir leyendo» me llevó a «Párrafos 3 a 4». O sea que me salté un párrafo entero sin enterarme.»
- Marta: «Trescientos veintiséis párrafos, de a dos. Son ciento sesenta y tres toques.»

Causa probable: `readablePieces` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1199-1219) mete en la misma bolsa encabezados («— Historia —»), citas y listas además de los párrafos, y `readAloud` (línea 1285) anuncia `pieces.count` como si fueran párrafos de la nota: de ahí el 326 de Wikipedia. El tamaño del bocado está fijo en 2 (línea 1272) y `readingFrom += chunk.count` (línea 1292) avanza aunque el anuncio de ese párrafo se haya descartado.

Propuesta: Contar sólo los párrafos del cuerpo (o no contar: «es larga, unos veinte minutos»). Leer de corrido hasta que la persona diga basta —un solo anuncio continuo— o de a un párrafo por toque, y retomar por el párrafo que no llegó a decirse, no por el siguiente. En artículos con secciones, ofrecer las secciones («Historia», «Economía», «Turismo») en vez de un contador, y aceptar «leeme la parte de historia».

Escéptico: Textual «Párrafos 1 a 2 de 326:» en wikipedia paso 4 cuando el volcado que ve JEF (paginas/02.txt) tiene 136 líneas con contenido y sólo 4 párrafos de artículo; el 326 sale de que readablePieces mete encabezados, citas y listas y readAloud anuncia pieces.count. También verifiqué que clarín paso 4 descarta el párrafo 2 y paso 5 salta a «Párrafos 3 a 4» (readingFrom += chunk.count avanza igual). Matices: el «de 17» de Clarín no está inflado —el cuerpo tiene unos 17 bloques— y ese descarte lo disparó el toque del script 9,7 s después, aunque el mecanismo de saltear es del producto.

### tramites-sin-orientacion · En los trámites no se sabe si se avanzó, cuánto falta ni qué van a pedir; y se elige por la persona

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: turno-anses, pami-turno, correo-seguimiento, entradas-boca

Evidencia:
- turno-anses, pasos 2, 3 y 4: tres páginas distintas descriptas las tres como «Estás en la sección de turnos de ANSES…».
- turno-anses, paso 3: «[Abrir «Solicitud de Jubilación»] (Primera de 5 opciones.)» cuando el pedido fue «quiero sacar un turno». Verificador: «paginas/03.txt lista 19 trámites… y arriba de todo un buscador… JEF ofrece sólo 3 opciones, no dice que hay más ni ofrece «Ver más opciones»».
- pami-turno, paso 2: «podés solicitar un nuevo turno para atención en agencias» — Roberto quería el médico de cabecera y avanzó tres pantallas por el camino equivocado sin que nadie se lo cruzara.
- turno-anses, paso 2: «podés solicitar una cita para atención presencial en cualquiera de nuestras oficinas» — JEF hablando con la voz de ANSES.

Causa probable: Cada aterrizaje se describe de cero: `landed()` manda al modelo la página actual sin la anterior ni el objetivo acumulado (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2360-2380), y el prompt de `orient` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:230-266) pide «contale dónde está y qué hay» pero no «decí qué cambió» ni prohíbe copiar el folleto del sitio en primera persona. El tope de opciones es 3-5 (`prefix` en `closeTurn`) y sólo la lista de resultados del buscador tiene «Ver más opciones»; las listas de trámites de la página, no.

Propuesta: Pasarle al modelo la descripción anterior y lo que la persona vino a hacer, y pedirle que diga QUÉ CAMBIÓ («Elegiste Jubilación; ahora hay que elegir el tipo») en vez de volver a presentar el sitio. Al entrar a un trámite, decir el camino y los datos: «Son tres pasos: elegir el trámite, poner tu CUIL y elegir oficina y día». Prohibir el «nuestro/nuestra» en el prompt. En una lista larga de trámites, decir cuántos hay y ofrecer «Ver todos» o «Decime qué trámite es». Y si lo que la página ofrece no es lo que se pidió (turnos de agencia vs. médico de cabecera), decirlo antes de dejar avanzar.

Escéptico: Las tres páginas de ANSES arrancan literalmente «Estás en la sección de turnos de ANSES…» (pasos 2, 3 y 4), el paso 2 dice «en cualquiera de nuestras oficinas» hablando como ANSES, y en el paso 3 paginas/03.txt lista 18 trámites más un buscador («Ingresá el nombre del trámite a buscar») mientras arbol-03.txt muestra sólo «Abrir «Solicitud de Jubilación» (Primera de 5 opciones)» sin «Ver más opciones». Lo que no se sostiene es la parte de PAMI: la persona sólo escribió «quiero sacar un turno en pami», nunca dijo médico de cabecera, y la página dice textual «Turnos para agencias», así que JEF no tenía con qué cruzarlo.

### datos-sin-fuente-ni-hora · Cifras sin fuente ni hora, con frases de robot, y números que no cierran entre un paso y el siguiente

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero, clima-cordoba, mercadolibre-auriculares

Evidencia:
- dolar-desde-cero, paso 1: «El dólar blue cotiza hoy en Buenos Aires a $1.535 para la compra y $1.555 para la venta.» — sin fuente ni hora; en el paso 3 sí las da: «…actualizado a las 13:20 hs».
- dolar-desde-cero, paso 3: la venta del oficial ($1.535) es exactamente la compra del blue del paso 1, sin una palabra que lo explique.
- clima-cordoba, paso 1: «una máxima que puede variar entre 26 °C y 28 °C según los registros» y un paso después «máxima de 27°».
- mercadolibre-auriculares, paso 3: «La información encontrada indica que los Xiaomi Redmi Buds 6 Play se pueden conseguir por $30.000» — verificador: sale del fragmento de un blog de terceros dentro de los resultados de Google.

Causa probable: El Answerer contesta sobre el texto de la página cargada, sea un sitio o una página de resultados de Google, y el prompt (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:75-110) sólo exige hora «si la página lo dice» y nunca exige nombrar de qué sitio salió el dato. Cuando la página es un SERP, el dato viene de un recuadro o del fragmento de un tercero y el modelo lo tapa con «la información encontrada indica» / «según los registros». Tampoco hay nada que compare la respuesta nueva con las cifras ya dichas en la conversación.

Propuesta: Cuando la página es una de resultados, decir de qué resultado salió el dato («según Dolarhoy, a las 13:20») o no darlo. Prohibir en el prompt las fórmulas sin sujeto («la información encontrada indica», «según los registros»). Y guardar las cifras dichas en el turno anterior: si una cifra nueva repite o contradice una anterior del mismo tipo, aclararlo en media frase («ojo: da lo mismo que la compra del blue»).

Escéptico: Las cuatro citas son textuales: dólar paso 1 «$1.535 para la compra y $1.555 para la venta» sin fuente ni hora (copiado del recuadro de Google, paginas/01.txt línea 8) contra el paso 3 «actualizado a las 13:20 hs», y la venta del oficial ($1.535) coincide exactamente con la compra del blue sin una palabra; clima «entre 26 °C y 28 °C según los registros» y al paso siguiente «máxima de 27°»; y el $30.000 de los Redmi Buds sale del fragmento del blog vastto.com.ar dentro del SERP (paginas/07.txt línea 97), tapado con «La información encontrada indica».

### titulares-que-no-son-titulares · Se cuelan como titulares cosas que no son noticias, y en Clarín se saltea el titular principal

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: infobae-titulares, dolar-desde-cero, solo-botones-clarin, cerrar-asistente

Evidencia:
- infobae-titulares, paso 2: «4. Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan.» ofrecido como cuarto titular principal y como botón para abrir.
- dolar-desde-cero, paso 2: «Los titulares principales: 1. Dólar Tarjeta $ 1.995,5 0.00%. 2. Dólar MEP $ 1.535,71 0.28%.» — son las fichas del ticker de El Cronista.
- Verificador, solo-botones-clarin y cerrar-asistente: «El titular de apertura de Clarín ese día… es «Milei llegó a Nueva York…». JEF lo saltea y arranca por el segundo. La persona de este escenario toca siempre la primera opción: nunca va a llegar a la nota principal del diario.»
- Roberto: «Cuando algo así se cuela en la lista, empiezo a desconfiar del resto de la lista.»

Causa probable: `headlines(of:)` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2705-2730) toma cualquier enlace que además sea encabezado con 20 caracteres o más, o cualquier ítem de listado con 25 o más: no pide que haya un hecho (verbo), así que entra el elenco de un programa y entran las filas de una tabla de cotizaciones. Y al revés: la nota principal de Clarín no está marcada como enlace-encabezado y por eso se cae de la lista, aunque la página la repite tres veces arriba de todo.

Propuesta: Pedirle al titular que parezca una noticia (verbo conjugado, no una lista de nombres propios separados por comas) y descartar los bloques que vienen de un ticker o tabla de datos; en una página de cotizaciones, leerla como tabla («tarjeta $1.995,50; MEP $1.535,71») y no ofrecer cada fila como algo para abrir. Para el titular principal: considerar también el enlace más prominente del bloque de apertura aunque no sea encabezado, y comprobar contra el orden en que la página lo repite.

Escéptico: Verificado en las tres partes: Infobae paso 2 ofrece «4. Con Maru Duffard, Andrei Serbin Pont, Fede Mayol y Facundo Kablan» (línea 32 de paginas/02.txt, el elenco de un programa) como titular y como botón para abrir; en dolar-desde-cero paso 2 los dos primeros «titulares» son «Dólar Tarjeta $ 1.995,5 0.00%» y «Dólar MEP $ 1.535,71 0.28%», que son las cuatro primeras líneas del ticker de cronista (paginas/02.txt); y en Clarín paginas/02.txt la apertura es «Milei llegó a Nueva York: busca profundizar el reclamo por Malvinas...», repetida en las líneas 7 y 10, mientras JEF arranca por «Trump afirmó que “Cuba caerá”» (línea 14) y ni siquiera ofrece la principal entre las cuatro. Nada de esto lo causa el arnés: el script sólo tocó la opción que la app puso primera.

### estado-del-asistente-mudo-o-falso · Abrir y cerrar el asistente es mudo, y cuando lo cierra solo dice cosas que no son ciertas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: cerrar-asistente, anti-robot-misma-pagina, banco-nacion, primera-vez

Evidencia:
- cerrar-asistente, paso 3: «toca «Cerrar el asistente» (ningún 🔊 en todo el paso)»; paso 5: «toca «Abrir el asistente» (ningún 🔊 en todo el paso)».
- anti-robot-misma-pagina, paso 2: «La prueba quedó a la vista, en la página, con el asistente cerrado» — Ana: «Ese mensaje sigue ahí, arriba de todo, con el asistente ABIERTO delante de mis ojos.»
- anti-robot-misma-pagina, paso 2: «si no, está el botón «Asistente»» — el botón se llama «Abrir el asistente».
- banco-nacion, paso 2: primero «🔘 Botones: [Abrir «Recuperar usuario y contraseña»]» y un segundo después la lista entera con «Completar «DNI»» adelante: la lista cambió debajo del dedo.

Causa probable: `close()` y `openPanel()` en /Users/daniel/Developer/JEF- BROWSER/Sources/UI/ReaderView.swift:542-556 sólo animan el panel y mueven el foco; no postean ningún anuncio ni agregan una línea a la conversación. El texto que promete «con el asistente cerrado» está escrito a mano en Assistant.swift:1455 y queda en la conversación aunque el panel vuelva a abrirse, y ahí mismo se nombra el botón como «Asistente» cuando su etiqueta real es «Abrir el asistente» (ReaderView.swift:618). La lista que cambia sola es `closeTurn` publicando opciones antes de que estén todas (formulario que llega después).

Propuesta: Anunciar cada cambio de estado en una línea corta y verdadera: «Asistente cerrado, la página quedó entera. Para volver, «Abrir el asistente», abajo» y «Volvimos. Estás en la portada de Clarín». Nombrar los botones exactamente como dicen en pantalla (una constante compartida, no literales sueltos). Reemplazar el mensaje «quedó cerrado» cuando el panel vuelve, en vez de dejarlo colgado. Y no publicar `offer` hasta tener la lista completa.

Escéptico: Confirmado en el registro: en cerrar-asistente no hay ningún evento «voz» entre +22,6 s y +54,5 s, o sea que cerrar (paso 3) y reabrir (paso 5) son mudos, y `close()`/`openPanel()` (ReaderView.swift:542-556) sólo animan; además el texto fijo dice «está el botón «Asistente»» cuando la etiqueta real es `accessibilityLabel("Abrir el asistente")` (ReaderView.swift:618), y «La prueba quedó... con el asistente cerrado» sigue en la conversación con el panel abierto (anti-robot-misma-pagina, árbol del paso 2, línea 7). Sólo no se sostiene el inciso de banco-nación: los dos publicados de botones están a 0,0003 s (1790098195.733652 y .733982), mismo frame, no «un segundo después».

### botones-mal-nombrados · Los botones no dicen qué hacen ni adónde llevan: tres verbos para lo mismo y volver que miente

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: pami-turno, turno-anses, anti-robot-avanza-sola, cerrar-asistente, banco-nacion, mercadolibre-auriculares

Evidencia:
- pami-turno, paso 3: «[Abrir «Continuar»] · [Abrir «VOLVER»] · [Abrir «N° Afiliación»]» — ninguno abre nada; «N° Afiliación» es el rótulo de un campo.
- pami-turno, paso 3: «[Volver a la portada]» viniendo de turnos.pami.org.ar, donde no hubo ninguna portada.
- turno-anses, paso 4: «[Abrir «Volver a todos los trámites»] · [Volver a «ANSES | Turnos - Prestaciones»]» — dos volver distintos juntos, uno con el título técnico y la barra.
- anti-robot-avanza-sola, paso 2: «[Volver a «Verificación de seguridad»]» — volver al captcha ya resuelto.
- cerrar-asistente, paso 3: «1 [btn] Volver» a secas, sin decir adónde.
- banco-nacion, paso 2: «[Pulsar «Continuar»]» ofrecido mientras el botón de la página está gris y deshabilitado.

Causa probable: El verbo sale del `kind` del elemento del DOM (`target.kind == .link ? "Abrir" : "Tocando"`, /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1575, más «Pulsar» en `formOptions`, línea 2230): un `<a>` que en realidad envía un formulario sale como «Abrir». `backLabel` (Assistant.swift:2090-2105) decide el nombre por la URL anterior: si su path es «/» devuelve literalmente «Volver a la portada», que es lo que pasó en PAMI; si tiene título, lo usa crudo, con barras y guiones. Y el «Volver» pelado de la barra (ReaderView.swift:591) tiene `accessibilityLabel("Volver")` sin destino.

Propuesta: Un verbo por tipo de acción, decidido por lo que hace y no por la etiqueta HTML: «Abrir» sólo si lleva a otra página, «Tocar» para un botón de la página, «Completar» para escribir. Nunca convertir un rótulo de formulario en un botón de abrir. Un solo «Volver» por pantalla, nombrado por el lugar real y en criollo («Volver a Turnos de PAMI», «Volver a la lista de trámites»), sin títulos con barras; «Volver» de la barra con destino en la etiqueta. No ofrecer botones deshabilitados ni volver a una verificación ya superada.

Escéptico: Todas las citas están tal cual: pami paso 3 ofrece «[Abrir «N° Afiliación»] · [Abrir «Continuar»] · [Abrir «VOLVER»]» y paso-03.jpg muestra que «N° Afiliación» es el rótulo de un campo y «CONTINUAR» un botón de la página; turno-anses paso 4 pone juntos «[Abrir «Volver a todos los trámites»]» y «[Volver a «ANSES | Turnos - Prestaciones»]»; anti-robot-avanza-sola paso 2 ofrece «Volver a «Verificación de seguridad»» con el captcha ya pasado; y banco-nación paso 2 ofrece «Pulsar «Continuar»» mientras paso-02.jpg muestra el botón gris deshabilitado.

### carteles-que-tapan · Avisa de los carteles que tapan la página pero no ofrece cerrarlos, y a veces ni los ve

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: clima-cordoba, noticias-la-nacion, mercadolibre-auriculares

Evidencia:
- clima-cordoba, paso 2: «Hay un aviso de cookies que tapa parte de la página.» — verificador: «tapa toda la parte visible de la página, no «parte». Y JEF avisa del problema pero no ofrece ninguna opción para aceptarlo o cerrarlo».
- noticias-la-nacion, paso 4: «Hay un aviso sobre la página que solicita agregar el medio como preferido en Google.» sin ningún botón para sacarlo.
- mercadolibre-auriculares, paso 2: «Estás en www.mercadolibre.com.ar.» — verificador: «la página está tapada de punta a punta por el cartel «Abrí la app y obtené envío gratis»… JEF no lo menciona ni ofrece «Por ahora no»».
- Roberto: «Me deja con el problema y sin solución. Además yo no sé qué es una cookie.»

Causa probable: El overlay se detecta bien y hasta trae sus controles (`overlay.choices`, extract.js:2010 y siguientes), pero `landed()` sólo lo pega como texto para el modelo («HAY UN AVISO ENCIMA DE LA PÁGINA…», /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2366-2367) y nunca convierte esas opciones en botones: sólo la rama vieja `describe()` las nombra en voz (línea 2515-2516). En Mercado Libre el cartel de la app no cayó en la detección y quedó invisible para todo el flujo.

Propuesta: Si hay un cartel encima, la PRIMERA opción es sacarlo: «Aceptar y seguir» o «Cerrar el aviso», construida desde `overlay.choices`; si se puede aceptar solo sin riesgo (cookies), aceptarlo y no mencionarlo. Decir cuánto tapa, en criollo («un cartel de aviso tapa toda la página», no «cookies»). Y si no se puede cerrar y no molesta, no nombrarlo.

Escéptico: clima-cordoba paso-02.jpg muestra el aviso de privacidad de Meteored ocupando toda la parte visible (no «parte»), y las opciones ofrecidas son «Completar «Introduce tu email»», «Por horas…» y «Más información»: ninguna lo acepta ni lo cierra; en mercadolibre paso-02.jpg el cartel «Abrí la app y obtené envío gratis» tapa la página de punta a punta y sus controles («Abrir app de Mercado Libre», «Por ahora no») están en paginas/03.txt línea 10, pero JEF sólo dice «Estás en www.mercadolibre.com.ar.». El código lo respalda: `landed()` pega el aviso como texto y nunca convierte `overlay.choices` en botones.

### dice-lo-que-la-pagina-no-dice · Completa de su cosecha: datos inventados, un dato al revés del artículo y un lugar agregado al pedido

*grave* · confirmado · jueces: Marta, Lucía, Verificadores · escenarios: wikipedia-mar-del-plata, noticias-la-nacion, entradas-boca, pami-turno

Evidencia:
- wikipedia-mar-del-plata, paso 2: «Es el principal centro turístico del país» — el artículo dice «la localidad balnearia más importante del país y el segundo destino turístico después de Buenos Aires», y esa frase aparece dos mensajes más abajo en la misma conversación.
- noticias-la-nacion, paso 4: «Hay un aviso sobre la página que solicita agregar el medio como preferido en Google» — verificador: «en paginas/03.txt lo único que figura es la línea suelta «Agregar en»».
- entradas-boca, paso 2: «o revisar los beneficios disponibles» — verificador: «no existe ninguna sección ni palabra «beneficios»; lo que JEF llama beneficios son los logos de los auspiciantes».
- pami-turno, paso 1: «Buscando: sacar turno en pami Buenos Aires.» — nadie dijo dónde vive.

Causa probable: La verificación estricta de /Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift sólo alcanza a las CIFRAS (`figureAppears`, línea 436): el resto del texto se dice tal cual lo devuelve el modelo. `orient` no verifica nada, y su prompt pide comprimir («como mucho tres frases»), que es donde «segundo destino turístico después de Buenos Aires» se convierte en «el principal». El «Buenos Aires» agregado a la búsqueda viene del ruteador, que mete la ubicación (/Users/daniel/Developer/JEF- BROWSER/Sources/Engine/Ubicacion.swift) sin decirlo.

Propuesta: Extender la verificación a las afirmaciones superlativas y a los avisos: si la orientación dice «el principal/el primero/el único», exigir que esas palabras estén en la página, como ya se hace con los números. Al describir un cartel, decir sólo lo que el cartel dice, sin completarlo. Y si se agrega la ciudad a una búsqueda, decirlo («busco para Buenos Aires»).

Escéptico: Los cuatro casos se verifican: Wikipedia paginas/02.txt línea 12 dice «la localidad balnearia más importante del país y el segundo destino turístico después de Buenos Aires» y JEF dice «Es el principal centro turístico del país» (y la frase real aparece dos mensajes más abajo, línea 13 del árbol del paso 4); en La Nación paginas/03.txt lo único que hay es «Agregar en» (línea 19) y paso-04.jpg no muestra ningún cartel sobre Google; en Boca paginas/02.txt no existe la palabra «beneficios» y lo ofrecido son «Adidas» y «Betsson», que son auspiciantes; y en PAMI el pedido fue «quiero sacar un turno en pami» pero la búsqueda salió «sacar turno en pami Buenos Aires» sin avisarlo.

### resumen-no-empieza-por-lo-principal · El resumen empieza por un detalle de color en vez del hecho central

*grave* · confirmado · jueces: Marta, Roberto, Lucía · escenarios: noticias-la-nacion

Evidencia:
- noticias-la-nacion, paso 5: «Resumen de la nota: La delegación iraní abandonó la sala ante las amenazas de Trump, quien también llamó a los miembros de la Corte Penal Internacional a retirarse de inmediato.» — el hecho del titular (la amenaza a Irán y el acuerdo) no aparece.
- Lucía: «Un resumen que se saltea el hecho central me hace dudar de todos los resúmenes.»
- Marta: «Y encima el resumen arranca por un detalle de color, no por lo principal, que es lo que decía el titular.»

Causa probable: El prompt del Answerer (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Answerer.swift:75-110) pide «contá de qué trata» en dos o tres frases pero no dice por dónde empezar, y el texto que recibe es la nota entera, donde el arranque en vivo suele traer la anécdota. El título de la nota no se usa como ancla.

Propuesta: En un resumen de nota, pedir explícitamente: primero el hecho que da el título, después los detalles; y pasarle el título como dato aparte para que lo use de ancla. Verificar que la primera frase del resumen comparta sustantivos con el título.

Escéptico: El resumen del paso 5 arranca «La delegación iraní abandonó la sala ante las amenazas de Trump...» y en ninguna de sus tres frases aparece el hecho del título —«amenazó con “aniquilar” a Irán si no acepta un acuerdo»— que está en el primer párrafo de paginas/03.txt. Matiz al planteo del juez: la salida de la delegación no es un detalle de color inventado, está en la bajada de la nota; lo que falla es que el resumen no encabeza (ni menciona) el hecho central.

### opciones-que-no-van-con-la-pagina · Opciones que no tienen sentido donde se está, y una noticia mezclada entre las acciones

*menor* · confirmado · jueces: Ana, Marta, Roberto, Lucía, Verificadores · escenarios: dolar-desde-cero, clima-cordoba, infobae-titulares, banco-nacion, correo-seguimiento

Evidencia:
- dolar-desde-cero, paso 3: «[¿Y el dólar tarjeta?] · [Leer los titulares] · [Resumir la portada]» estando en la sección Dólar de El Cronista — verificador: «no hay ninguna portada… es contradictorio con lo que él mismo dijo dos mensajes antes».
- clima-cordoba, paso 3: «[Leer la página]» con el aviso de cookies tapándola entera.
- infobae-titulares, paso 4: «[Leer la nota] · [Resumir la nota] · [Abrir «Jorge Macri anticipó que hubo un acuerdo para posponer la Marcha del Orgullo…»]» — una nota distinta metida entre las acciones de esta nota.
- banco-nacion, paso 4: después de cargar el DNI no hay ninguna opción para corregirlo.

Causa probable: Las opciones de seguimiento salen de `followUps` (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:2110 y siguientes), que decide por tipo de página con reglas gruesas (si tiene titulares, ofrece leerlos y resumir «la portada»), sin mirar la sección real ni si hay un overlay tapando. Las notas relacionadas entran en la misma lista plana que las acciones, sin grupo.

Propuesta: Ofrecer sólo lo que se puede hacer en la página que se tiene delante, con el nombre de esa página («Resumir esta sección», no «Resumir la portada»); no ofrecer leer una página tapada por un cartel; separar «Notas relacionadas» en un grupo después de las acciones sobre esta nota; y agregar «Corregir» después de completar un campo.

Escéptico: Las cuatro citas están textuales en las transcripciones: dolar-desde-cero paso 3 ofrece «[¿Y el dólar tarjeta?] · [Leer los titulares] · [Resumir la portada]» dos mensajes después de decir «Estás en la sección Dólar de El Cronista»; infobae paso 4 mete «[Abrir «Jorge Macri anticipó que hubo un acuerdo para posponer la Marcha del Orgullo por la visita del Papa»]» en la misma lista plana que «[Leer la nota] · [Resumir la nota]»; banco-nacion paso 4, después de «Listo: quedó escrito en «DNI», terminado en 456», sólo quedan «[Completar «Usuario»] · [Pulsar «Continuar»] · [Volver a los resultados] · [Otra cosa]», sin forma de corregir; y clima-cordoba paso 3 ofrece «[Leer la página]» (y «[Completar «Introduce tu email»]» como primera opción) con la captura paso-03.jpg mostrando el «Aviso de privacidad» de Meteored tapando todo el alto visible de la web. La causa está confirmada en el código: followUps hace `out.append(option(Self.readID, "Leer los titulares"))` y `option(Self.summaryID, "Resumir la portada")` por tipo de página, sin mirar sección ni overlay (Assistant.swift:2148-2160), y formOptions excluye el campo ya completado (`except: filledFields…`, Assistant.swift:2141 y 2221), que es por qué desaparece la opción del DNI. Nada de esto depende de que el script tocara la primera opción: es lo que la app ofreció. Matiz: en clima-cordoba el texto que JEF extrajo (paginas/02.txt) sí trae el pronóstico y no el cartel, así que «Leer la página» habría funcionado — lo contradictorio es el cartel, no que la lectura falle.

### habla-de-mas-y-con-tecnicismos · Frases de máquina y palabras que no son de una persona

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificadores · escenarios: primera-vez, otra-cosa, mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-misma-pagina, turno-anses, dolar-desde-cero

Evidencia:
- primera-vez, paso 2: «Abriendo Llevame a La Nación.» — repite la etiqueta del botón como si fuera el sitio.
- mercadolibre-auriculares, paso 3: «Estás en los resultados de «auriculares+bluetooth+más+baratos».» — VoiceOver lee los signos más.
- anti-robot, paso 1: «Abriendo localhost.»
- otra-cosa, paso 3: «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» — Marta: «Hace veinte años que uso VoiceOver».
- primera-vez: «Estás en la portada de La Nación» en un mensaje y «De vuelta en la portada de LA NACION» en otro.
- turno-anses, paso 3: «trámites previsionales y sociales»; anti-robot-avanza-sola: «resolver» tres veces en dos renglones.

Causa probable: Varios literales sin pulir: el «Abriendo…» de la rama de resultados usa la etiqueta del botón cuando no hay dominio que mostrar (/Users/daniel/Developer/JEF- BROWSER/Sources/Intelligence/Assistant.swift:1512, y el starter «Llevame a La Nación» entra por ahí porque su id empieza con «res-»); `searchQuery` (Assistant.swift:852-860) lee el parámetro q con `queryItems`, que decodifica los %XX pero NO convierte los «+» en espacios; el nombre del sitio sale a veces del título de la página (LA NACION, en mayúsculas) y a veces del dominio; el texto de «Otra cosa» explica el teclado cada vez.

Propuesta: Una limpieza única para todo lo que va a la voz y a los botones: «+» a espacios en la consulta, dominios legibles («una página de este teléfono» en vez de localhost), un único nombre por sitio con mayúscula y minúscula normales, sin emojis ni porcentajes dentro de un título. Decir el sitio y no la frase del botón: «Abriendo La Nación». Explicar el dictado una sola vez, la primera.

Escéptico: Todas las frases citadas están literales en los registros: primera-vez paso 2 «Abriendo Llevame a La Nación.», mercadolibre paso 3 «Estás en los resultados de «auriculares+bluetooth+más+baratos».», anti-robot-avanza-sola y anti-robot-misma-pagina paso 1 «Abriendo localhost.», otra-cosa paso 3 «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.», turno-anses paso 3 «trámites previsionales y sociales», y anti-robot «pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página» (tres «resolver» en dos renglones). La causa también se verifica: el starter es `.link(id: "res-inicio-lanacion", label: "Llevame a La Nación"…)` (Assistant.swift:202) y la rama de resultados hace `action.label.components(separatedBy: " — ").last` (Assistant.swift:1511), que sin el « — » devuelve la etiqueta entera; y searchQuery lee `parts.queryItems?.first(where: { $0.name == "q" })?.value` (Assistant.swift:856), que decodifica %XX pero deja los «+». Nada es artefacto del arnés: son literales que la app compuso y dijo. Una imprecisión de atribución, no de fondo: «De vuelta en la portada de LA NACION» es de noticias-la-nacion:181, no de primera-vez; pero primera-vez tiene la misma incoherencia adentro — «Estás en la portada de La Nación» (paso 2) contra «Estás en la portada de LA NACION» (paso 3).

## Lo que funciona

- Llegar al sitio correcto: en los 17 escenarios el primer resultado fue siempre el oficial y nunca un revendedor ni un intermediario — bocajuniors.autoentrada.com (y no Viagogo, que estaba en la página), turnos.pami.org.ar, anses.gob.ar/turnos, digital.bna.com.ar, la página de seguimiento del Correo (no la portada). Los cuatro jueces lo nombran como lo que más los tranquiliza.
- Decir el dominio en voz alta al abrir un resultado («Abriendo www.lanacion.com.ar») y nombrar el sitio como oficial («Estás en el sitio oficial de venta de entradas de Boca Juniors»): es lo único con lo que una persona ciega puede verificar que no la estafaron.
- Banco Nación entero: avisa qué va a pedir antes de pedirlo, los botones son los pasos del formulario en orden, el campo de abajo cambia a «Escribir: DNI» con la pista «Va directo al campo DNI de la página», y al cargar el dato confirma «quedó escrito en «DNI», terminado en 456» sin cantar el documento ni en voz ni en pantalla ni en el registro. Los cuatro jueces lo marcaron como el modelo a copiar.
- El camino de a un toque: en Clarín, escribiendo una sola palabra y tocando siempre la primera opción se llega a leer una nota. La primera opción fue la correcta en clarin.com, el titular principal, «Leer la nota» y «Seguir leyendo».
- Contestar sin obligar a entrar a ningún sitio: el dólar en 14 segundos, el clima en 15, la fecha de fundación de Mar del Plata en una frase con fecha y fundador.
- Entender la repregunta en contexto: «¿y el oficial?» sin repetir «dólar», «¿va a llover?» sin repetir ciudad ni día, y contestando además cuándo sí («recién a partir del sábado»).
- Las preguntas sugeridas como botones cuando son de verdad las que siguen: «¿Y el dólar tarjeta?», «¿Cuántos habitantes tiene?», «¿Cuándo empieza a llover?» — para quien escribir le cuesta, es lo que le ahorra el teclado.
- «llevame a deportes» resuelto dentro de La Nación, sin volver al buscador, y avisando «Estás en la sección de Deportes de La Nación».
- «Otra cosa» está siempre, al final, y deja «Volver a las opciones» para arrepentirse sin perder nada.
- La prueba anti-robot: dice de frente que no la puede resolver él, deja «Ir a la prueba» y «Ya la resolví», se da cuenta solo cuando se resolvió —incluso sin que cambie la dirección— y sigue con lo que estaba haciendo («Listo, ya pasamos la verificación»).
- Cerrar y volver a abrir el asistente no pierde nada: la conversación vuelve intacta y el botón de volver dice en qué sitio se está («Abrir el asistente, clarin.com»).
- No inventar cifras: el 301 % raro de Wikipedia se leyó tal cual, el precio del más barato coincidió entre la descripción y la respuesta, y la fecha de fundación coincidió con el artículo leído después.
- «volvé» funciona escrito en criollo y confirma dónde quedó («De vuelta en la portada de LA NACION»).
- Funciona igual en un sitio nunca probado (Infobae) que en los dos de siempre.
- Los tres ejemplos del arranque («Llevame a La Nación», «¿A cuánto está el dólar hoy?», «¿Cómo va a estar el tiempo mañana?») enseñan para qué sirve la app sin tutorial, y la respuesta a «¿dónde estoy?» («Arriba se ve la página, y esto es la conversación conmigo») fue la mejor frase de la ronda para tres de los cuatro jueces.
