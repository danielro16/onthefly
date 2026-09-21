# Veredicto — ronda-7

Ronda 7: 12 escenarios, 4 jueces y 2 verificadores. Las rutas de código son relativas a /Users/daniel/Developer/JEF- BROWSER/Sources.

**Resultados**
- Los cuatro jueces dieron «sí» en seis escenarios: clarín, wikipedia, banco, otra-cosa y los dos anti-robot. En primera-vez también, salvo Roberto («a medias»).
- Los cuatro dieron «a medias» en noticias-la-nacion, dolar-desde-cero y clima-cordoba, y «no» en turno-anses y mercadolibre.
- Mejor promedio: banco-nacion (4,1). Peor: mercadolibre (2,65). En dólar, los cuatro pusieron confianza 1.

**Bloqueantes**
1. A «¿y el oficial?» respondió «cuándo se fundó el dólar blue». Lo más probable es que el ruteador copiara un ejemplo de sus propias instrucciones y que reply() usara esa reescritura en lugar de las palabras de la persona.
2. En ANSES la primera opción fue «CONSULTAR TURNO». La sube una coincidencia por la palabra «turno», y la lista de trámites se trata como una portada.
3. La prueba anti-robot se señala, pero no hay forma de llegar a ella ni otra salida.

**Causas que se repiten en el código**
- arrive() nunca abre un sitio que la persona nombra.
- El respaldo describe() no deja «Abrir» y «Leer los titulares» repite lo ya dicho.
- extract.js corta a 160 caracteres, a mitad de palabra.
- followUps() retorna antes de agregar «Volver».
- El panel desplaza hasta el comienzo de la respuesta, y los botones quedan abajo, fuera de la vista.
- El proyecto sólo declara inglés: por eso °F, mph y DuckDuckGo en inglés.
- El DNI escrito queda guardado como lastRequest y en el turno siguiente se manda al modelo.

**Descartado por ser del script**
- «localhost» (es el servidor del fixture).
- La bienvenida cortada en primera-vez: el script tocó a los 7 s.
- Los titulares 2 y 3 descartados en La Nación y Clarín: el script actuó a los 8-9 s, antes de que terminara la cola.
- El cursor «en la última línea»: AssistantPanel.placeFocus lleva el foco a la primera opción cuando VoiceOver termina. Conviene confirmarlo en un iPhone.

Hay un cambio sin commitear en Intelligence/Assistant.swift. Ataja «titulares» antes del ruteador y amplía dekick(). Resuelve el caso de La Nación, pero no el patrón general (ver P05).

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.3 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.4 |
| dolar-desde-cero | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.0 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.4 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 3.0 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.6 |
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.1 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.6 |
| clima-cordoba | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.0 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.4 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |
| anti-robot-ya-la-resolvi | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |

**Promedio general: 3.37**

## Problemas

### P01 · «¿y el oficial?» se contesta sobre una pregunta que nadie hizo y desaparece el botón que la resolvía

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: dolar-desde-cero

Evidencia:
- Paso 3: «💬 Persona: ¿y el oficial?» → «💬 JEF: La página no dice cuándo se fundó el dólar blue.» (1,2 s después).
- Paso 2, botones: «[¿A cuánto está el dólar oficial?] · [¿Y el dólar MEP?] · [Leer la página] · [Volver a la página anterior] · [Otra cosa]». Paso 3: «[Leer la página] · [Resumir la página] · [Volver a la página anterior] · [Otra cosa]».
- Verificador A: paginas/02.txt tiene el bloque «Dólar Oficial», con compra $1.482,52 y venta $1.534,23. La página sí tenía el dato.
- Lucía sospechó que se mezclaban sesiones. No hay estado compartido entre sesiones: la palabra «fundó» sale de las instrucciones del ruteador (ver causa).

Causa probable: Router.swift, l.157-160: la regla junta los ejemplos «¿cuándo se fundó?» y «¿y el oficial?» y pide completarlos con el tema de la página («cuándo se fundó Mar del Plata»). Flash-Lite casi seguro devolvió responder con question = «¿cuándo se fundó el dólar blue?». Assistant.carry(.responder), l.463, usa reply(decision.question ?? goal): el que responde recibe la reescritura del ruteador y no las palabras de la persona, y nadie controla que la reescritura hable de lo mismo. Answerer, l.77-78, pide decir «la página no lo dice» como texto en vez de devolver null. Por eso reply() lo toma como respuesta válida: no se ofrece «Buscarlo en internet» y nextQuestions queda vacía, con lo que desaparece el botón del oficial. El registro no anota la decisión del ruteador, así que no se puede confirmar.

Propuesta: 1) Separar ese ejemplo del prompt del ruteador y no mezclar ejemplos de temas distintos en una misma regla.
2) En responder, pasarle al que responde el texto literal de la persona más el pedido anterior. Descartar la reescritura del ruteador si trae palabras de contenido que no están ni en el pedido ni en el anterior.
3) Antes del ruteador, si lo escrito coincide con un botón ofrecido (por ejemplo «oficial» ↔ «¿A cuánto está el dólar oficial?»), ejecutar ese botón (ver P05).
4) Si la página no tiene el dato, que Answerer devuelva null. Así se ofrece «Buscarlo en internet» y se conservan las preguntas pendientes.
5) Anotar en Registro la decisión del ruteador.

Escéptico: En dolar-desde-cero, paso 3, a «¿y el oficial?» la app contesta «La página no dice cuándo se fundó el dólar blue.», y los botones pasan a «[Leer la página] · [Resumir la página] · …»: ya no está «¿A cuánto está el dólar oficial?». Sin embargo, paginas/02.txt trae el bloque «Compra hoy $1.482,52 / Venta hoy $1.534,23 … Dólar Oficial». El «se fundó» coincide con el ejemplo de Router.swift l.157-159. La persona escribió el pedido, así que el script no tuvo nada que ver.

### P02 · ANSES: la primera opción lleva a consultar un turno cuando se pidió sacar uno, y no hay camino para elegir el trámite

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: turno-anses

Evidencia:
- Paso 3: «Estás en la página de turnos de Anses. Para sacar un turno, tenés que buscar el trámite.» Botones: «[Abrir «CONSULTAR TURNO»] · [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…»] · [Abrir «Solicitud de Jubilación, ver sub-trámites»] · [Abrir «Solicitud de Pensión, ver sub-trámites»] · …».
- Paso 4: «Esta página sirve para consultar turnos que ya pediste, te pide el número de CUIL del titular y el número de solicitud.» Botones: «[Completar «CUIL»] · [Completar «Número de solicitud»] · [Abrir «mi ANSES»] · [Abrir «VOLVER»] · [Volver a la página anterior] · [Otra cosa]».
- Verificador A: la página tiene 18 trámites y un buscador («Ingresá el nombre del trámite a buscar»). Se ofrecen 4 trámites, sin buscador ni «Ver más», y quedan afuera «Trámites Jubilados y Pensionados» y «Pensión Universal para Adultos Mayores».

Causa probable: Assistant.arrived(), l.2186-2252:
- Con 18 ítems de 25 letras o más, readsHeadlines() da verdadero y la lista de trámites se trata como una portada: los botones son los 4 primeros «titulares» en el orden de la página.
- forGoal (l.2248-2251) pone primero la sugerencia del modelo que comparte una raíz de 5 letras con lastRequest. «turno» está en «CONSULTAR TURNO» y en «quiero sacar un turno», así que sube justo la opción contraria.
- formOptions() excluye los formularios de búsqueda (isSearch), por eso el buscador de trámites nunca se ofrece.
- En el paso 4, closeTurn() (l.1909-1914) pone los «Completar» siempre primero, aunque la orientación diga que la página no sirve para lo pedido.
- El «VOLVER» de la página y el Volver propio conviven porque el dedup es por id o por etiqueta exacta.

Propuesta: 1) Que la coincidencia con el pedido sea por intención y no por palabra: descartar opciones con verbos opuestos (consultar/cancelar/reimprimir frente a sacar/pedir/solicitar), o pedirle a orient() que marque qué opción sirve para lo que la persona vino a hacer.
2) No tratar una lista de trámites como portada: exigir enlaces con nivel de encabezado, o un sitio de noticias.
3) Si la página tiene buscador y se pidió un trámite, preguntar «¿Para qué es el turno? Por ejemplo jubilación, pensión o asignación». La respuesta se escribe en «Buscar turno», que es una búsqueda y se puede enviar. Agregar «Ver más trámites».
4) Si la orientación dice que la página no sirve (consulta en vez de pedido), la primera opción es «Volver a elegir el trámite» y los «Completar» van después.
5) Fusionar el «VOLVER» de la página con el Volver propio.

Escéptico: Paso 3: la primera opción es «Abrir «CONSULTAR TURNO»» aunque se pidió «quiero sacar un turno». De los 18 trámites de paginas/03.txt se ofrecen solo 4, sin el buscador «Ingresá el nombre del trámite a buscar» y sin «Ver más». Quedan afuera «Trámites Jubilados y Pensionados» y «Pensión Universal para Adultos Mayores». El script tocó la opción 1, pero esa opción era mala por decisión de la app. El único matiz es que «Otra cosa» permite escribir el trámite, así que «no hay camino» exagera un poco.

### P03 · Prueba anti-robot: dice dónde está pero no lleva, no aclara quién la resuelve y no ofrece otra salida

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.»
- ML paso 2: «Tiene una opción de audio, dentro del recuadro de la prueba.» ⟶ DESCARTADO. Verificador A: el recuadro es sólo la casilla «No soy un robot». El audio aparece recién si se abre el desafío de imágenes.
- Botones: «[Ya la resolví] · [Volver a la página anterior] · [Otra cosa]» en ML y «[Ya la resolví] · [Otra cosa]» en los fixtures.
- ML paso 3: «La página no muestra ningún auricular bluetooth en este momento, solo pide que completes un paso de seguridad para acceder.»
- Roberto: «No sé llegar ‹arriba, antes de esta conversación›… Me quedé trabado.» Ana: «Yo no uso VoiceOver, así que esa parte me confunde.»

Causa probable: Assistant.askToSolve(), l.1094-1111:
- El texto es fijo, en primera persona («me pide»), y nombra a VoiceOver sin mirar UIAccessibility.isVoiceOverRunning.
- El aviso de audio va en otro say(), detrás de un mensaje de unos 12 s, y afirma algo que la casilla no tiene.
- followUps() (l.1962-1966) ofrece sólo «Ya la resolví» y Volver.
- No hay ninguna acción que lleve el foco de VoiceOver a la página ni al recuadro, ni un camino para quien no puede resolverla.

Propuesta: 1) Texto: «Mercado Libre pide que resuelvas una prueba anti-robot: una casilla «No soy un robot». Si después aparecen imágenes, hay opción de audio.» Sin VoiceOver: «Está arriba, en la página: tocá la casilla «No soy un robot».»
2) Botón «Ir a la prueba»: scrollIntoView del iframe y UIAccessibility.post(.layoutChanged, argument: webView), para que VoiceOver caiga en la página a la altura del recuadro.
3) Botón «No puedo resolverla», con «Buscar en otra tienda» (la misma búsqueda sin el sitio) y «Volver».
4) Mantener «Ya la resolví» primero.

Escéptico: El texto fijo de Assistant.swift l.1106 dice «El sitio web me pide resolver… con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.»: no dice que la resuelve la persona ni ofrece acción para llegar a la prueba. Los botones son solo «[Ya la resolví] · [Otra cosa]» en los fixtures y «[Ya la resolví] · [Volver…] · [Otra cosa]» en ML. En paso-02.jpg de ML se ve solo la casilla «No soy un robot». Una parte sí es del arnés: el DESCARTADO del aviso de audio. Ese aviso estaba en cola detrás de un mensaje de unos 11 s y el script escribió a los 7 s.

### P04 · El clima llega en Fahrenheit, millas y pulgadas sin aviso (y el buscador, en inglés)

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: clima-cordoba, dolar-desde-cero, noticias-la-nacion

Evidencia:
- Paso 2: «La máxima va a ser de 63º y la mínima de 40º. … El viento soplará del NE a 13 mph.»
- Paso 3: «La probabilidad de lluvia es del 0%, y las lluvias se indican en 0 in.»
- paginas/02.txt de clima: «63º 40º», «Viento NE 13 mph», «Lluvias 0 in», «Amanecer 7:06 AM».
- El texto de DuckDuckGo que ve el asistente dice «Next Page >». Ana: el buscador aparece con «Search», «Next Page», «Any Time».
- Paso 2: «se esperan unas condiciones de nubes».

Causa probable: JEFBrowser.xcodeproj/project.pbxproj, l.165-169: developmentRegion = en y knownRegions = (Base, en). La app sólo declara inglés, cosa que el propio Answerer.swift documenta («la app no tiene traducciones, así que iOS le asigna inglés»). El WKWebView pide las páginas como en-US: eltiempoen.com responde en °F, mph, pulgadas y AM/PM, y DuckDuckGo arma su interfaz en inglés aunque kl=ar-es. La regla de Answerer (l.85-86: «Decí siempre la unidad… 63 °F») no alcanza, porque la página escribe «63º» sin F.

Propuesta: 1) Declarar castellano como localización (es y es-AR en knownRegions/CFBundleLocalizations, developmentRegion es), o fijar el Accept-Language del WebView al idioma del teléfono.
2) En código, si el texto de la página trae «mph», « in», «°F» o «AM/PM», avisarle al Answerer que las temperaturas están en °F y pedirle que las diga en °C, km/h y mm. O convertir las cifras en código.
3) Con lluvia cero, decir «no se espera lluvia».
4) Pedirle al Answerer vocabulario del parte local: «nublado», «parcialmente nublado».

Escéptico: En clima-cordoba se dijo «La máxima va a ser de 63º y la mínima de 40º… a 13 mph» y «las lluvias se indican en 0 in». paginas/02.txt trae «63º 40º», «Viento NE 13 mph», «Lluvias 0 in» y «7:06 AM». El texto de DuckDuckGo en el registro dice «Next Page >» y «Search». project.pbxproj declara solo developmentRegion = en y knownRegions = (Base, en). Así la app no le avisa a la persona que los valores vienen en unidades imperiales.

### P05 · Un pedido escrito que equivale a un botón ofrecido falla con un mensaje ajeno («No pude decidir a dónde ir»)

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: noticias-la-nacion, dolar-desde-cero

Evidencia:
- Paso 3: «💬 Persona: dame los titulares» → «No pude decidir a dónde ir desde acá. Se puede pedir de otra forma, o tocar una opción.» Botones: «[Intentar de nuevo] · [Leer los titulares] · [Resumir la portada] · …».
- Paso 4 («Intentar de nuevo»): «Titulares 1 a 3 de 139:». El mismo pedido anduvo la segunda vez.
- dolar-desde-cero: el botón «¿A cuánto está el dólar oficial?» existía cuando se escribió «¿y el oficial?» (ver P01).

Causa probable: El ruteador (Flash-Lite, no determinista) tomó «dame los titulares» como abrir. run() le pidió a Jev un destino, Jev falló con un error que no es de red, y run() (l.1580-1587) dice siempre «No pude decidir a dónde ir desde acá», aunque no se haya pedido ir a ningún lado. En el reintento el mismo texto salió como leer. closeTurn() (l.1937-1939) pone «Intentar de nuevo» antes que las acciones de la página. En ningún punto se compara lo escrito con los botones ofrecidos. El cambio sin commitear (Assistant.swift, l.254-262) ataja «titulares», pero sólo esa palabra, y cualquier frase con «titulares» que no sea pregunta (por ejemplo «abrí el segundo de los titulares») pasaría a leer desde el 1.

Propuesta: 1) Antes del ruteador, comparar lo escrito (sin tildes, por raíces) con las etiquetas de la oferta vigente y ejecutar el botón que coincida con claridad.
2) Si run() falla, reintentar una vez solo. Si vuelve a fallar, decir «No entendí «dame los titulares»» (no «a dónde ir») y poner primero la opción ofrecida más parecida; «Intentar de nuevo» después.
3) Reemplazar el atajo de «titulares» por esa comparación general.

Escéptico: En noticias-la-nacion, paso 3, a «dame los titulares» la app contesta «No pude decidir a dónde ir desde acá…», y con «Intentar de nuevo» da «Titulares 1 a 3 de 139:». El mensaje es el genérico del catch de run() (l.1585). Un matiz: en La Nación todavía no se había ofrecido «Leer los titulares» (en el paso 2 solo había Abrir×4, Volver y Otra cosa). La equivalencia con un botón ofrecido solo se cumple en dólar-desde-cero.

### P06 · Con poca vista, los botones y el mensaje que pide acción quedan escondidos debajo de la respuesta

*grave* · confirmado · jueces: Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, primera-vez, otra-cosa, wikipedia-mar-del-plata, mercadolibre-auriculares, anti-robot-avanza-sola, dolar-desde-cero

Evidencia:
- Verificador A, paso-02.jpg de La Nación: el resumen ocupa todo el panel y no se ve ninguno de los 6 botones sin desplazar. Pasa lo mismo en paso-04.jpg.
- Verificador A, paso-02.jpg de ML: se ve «Abriendo…», «Estás en Mercado Libre…», «Sigo con…» y «Buscando auriculares…». El aviso de la prueba y «Ya la resolví» quedan fuera de la vista.
- Verificador B, paso-02.jpg de primera-vez: el texto queda cortado en «Grandes cadenas le cortaron el audio a Trump» y no se ve ningún botón.
- Ana: «Mientras me lee la nota, arriba se ven el menú y los íconos de redes, no la nota.»

Causa probable: AssistantPanel.swift, l.127-135: onChange(turns.count) hace scrollTo(responseStart, anchor: .top) a propósito, para que la respuesta se lea desde su comienzo. responseStart es la primera línea de JEF después del último pedido. Con respuestas largas (orientaciones de 400-500 caracteres, tres titulares, párrafos de Wikipedia) las opciones quedan abajo. En ML el comienzo es «Abriendo mercadolibre.com.ar.», así que lo único que pedía una acción queda escondido. El panel ocupa menos de la mitad de la pantalla, y la página de arriba no sigue lo que se lee.

Propuesta: 1) Al cerrar el turno: si la respuesta y la primera opción entran en el panel, desplazar hasta la primera opción (anchor .bottom). Si no entran, mostrar el comienzo del último mensaje y fijar las 1-2 primeras opciones sobre el campo de escribir, o poner un botón visible «Opciones ↓».
2) Un mensaje que pide acción (la prueba anti-robot, un campo esperando un dato) siempre queda a la vista.
3) Con respuestas largas, agrandar el panel.
4) Mientras se lee una nota, llevar la página de arriba al párrafo que se está leyendo.

Escéptico: En las capturas de noticias-la-nacion, paso-02.jpg y paso-04.jpg, el panel queda ocupado por el resumen o los titulares y no se ve ningún botón. En primera-vez, paso-02.jpg, el texto se corta en «Grandes cadenas le cortaron el audio a Trump». En mercadolibre, paso-02.jpg, se ve de «Abriendo…» a «Buscando auriculares…» y quedan fuera de la vista el aviso anti-robot y «Ya la resolví». Viene del scrollTo(start, anchor: .top) de AssistantPanel.swift l.134, que es una decisión de la app.

### P07 · Nombrar un sitio conocido pasa por el buscador, y una pregunta de dato obliga a elegir un resultado

*grave* · confirmado · jueces: Marta, Roberto, Lucía · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, mercadolibre-auriculares, banco-nacion, dolar-desde-cero, clima-cordoba, turno-anses

Evidencia:
- «💬 Persona: llevame a la nación» → «Buscando: la nación.» → «Estás en los resultados de «la nación». Los 3 más probables:».
- primera-vez: «💬 Persona: Llevame a La Nación» (botón) → «Abriendo lanacion.com.ar.», directo.
- «entrá a mercado libre y buscame auriculares bluetooth» → «Buscando: mercado libre.». «clarín» → «Buscando: clarin.». «quiero entrar al home banking del banco nación» → «Buscando: home banking banco nacion.»
- Dólar, paso 1: el dato ya estaba en el primer resultado: «1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar.»
- La Nación, paso 6: «volvé» lleva a los resultados del buscador, un paso que la persona no había pedido.

Causa probable: Assistant.arrive(), l.664-680: «Un buscador nunca navega solo: muestra la lista». Se decidió así después de tres falsos positivos: anses.fr, La Nación de Costa Rica, y una página interna de ANSES con captcha. El botón de inicio tiene la dirección escrita (starters, l.160), por eso anda directo. Las preguntas de dato quedan en pendingQuestion hasta que la persona elige un resultado.

Propuesta: 1) Abrir directo sólo si es «ir» (no una pregunta) y el mejor resultado cumple las tres condiciones que fallaron antes:
- su nombre de sitio es exactamente el pedido sin espacios ni tildes (lanacion, clarin, mercadolibre);
- el dominio es del país;
- la ruta es la raíz (depth 0).
2) Al abrir, decir «Abriendo lanacion.com.ar, el diario La Nación» y dejar un botón «Ver otros resultados».
3) Mantener la lista cuando es ambiguo (banco nación, turnos anses).
4) En preguntas de dato, abrir el primer resultado del país cuyo título tenga los términos de la pregunta, contestar diciendo de dónde sale el dato y ofrecer «Ver otra fuente».

Escéptico: Pasa tal cual. En La Nación «llevame a la nación» da «Buscando: la nación.» y después «Estás en los resultados…», mientras que el botón de inicio va directo («Abriendo lanacion.com.ar.» en primera-vez). En Mercado Libre sale «Buscando: mercado libre.», en Clarín «Buscando: clarin.», y en dólar y clima hay que tocar un resultado antes de tener la respuesta. Es una decisión tomada a propósito en el código (Assistant.swift l.673, «Un buscador nunca navega solo»). Banco Nación y ANSES no son ejemplos del problema: ahí la lista tenía sentido.

### P08 · Tras nombrar notas de una portada o una sección no se ofrece abrirlas, y «Leer los titulares» repite las mismas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: solo-botones-clarin, otra-cosa, noticias-la-nacion

Evidencia:
- Clarín, paso 2: «En Noticias de Argentina — Clarin.com.» / «Hay 126 notas. Las tres primeras:». Botones: «[Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa]».
- Clarín, paso 3 («Leer los titulares»): «Titulares 1 a 3 de 126:», las mismas tres notas.
- Deportes: «Hay 36 notas. Las tres primeras:». Botones: «[Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa]».
- La Nación, paso 4: «Titulares 1 a 3 de 139:» repite los tres que la llegada ya había dicho.

Causa probable: Al llegar a una portada hay dos caminos. orient() (el modelo) arma el texto y los botones «Abrir». Si devuelve nil, arrived() cae en describe() (l.2304-2311). describe() dice «En {título} — {sitio}.» y tres títulos, pero no fija lastDone, lastChunk ni readingFrom. Por eso followUps() ofrece «Leer los titulares», que arranca en 0, y ningún «Abrir». En Clarín y en Deportes orient no devolvió nada: el registro muestra la plantilla de describe(). El motivo no se anota. Lo probable es la verificación de cifras (Answerer.swift, l.280): si una sola cifra no aparece literal en la página (por ejemplo «2 millones» por «dos millones»), se descarta la orientación entera. En La Nación orient sí anduvo, pero readingFrom queda en 0 después de nombrar 4 titulares.

Propuesta: 1) Que describe() haga con los titulares lo mismo que orient: fijar lastChunk y lastDone, y ofrecer «Abrir «…»» de los tres y «Seguir con los titulares».
2) Después de nombrar N titulares al llegar, dejar readingFrom = N, así el botón sigue desde el N+1.
3) Anotar en Registro por qué orient devolvió nil.
4) Ante una cifra que no se verifica, sacar sólo esa frase o reintentar, en vez de descartar toda la orientación.

Escéptico: Clarín, paso 2: «Hay 126 notas. Las tres primeras:», con botones [Leer los titulares]·[Resumir la portada]·[Volver]·[Otra cosa] y ningún «Abrir». En el paso 3, «Titulares 1 a 3 de 126:» repite esas mismas tres notas, y en Deportes pasa lo mismo. En La Nación, el paso 4 repite los titulares que ya se habían dicho al llegar. En el código, describe() no fija lastChunk ni lastDone, y la acción de leer pone readingFrom = 0. Que orient devolvió nil y se cayó a describe() está confirmado (l.2197). Que la causa sea la verificación de cifras es una suposición.

### P09 · Titulares leídos crudos: título, bajada y sección pegados, cortes a mitad de palabra y bajadas contadas como notas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: solo-botones-clarin, otra-cosa, noticias-la-nacion

Evidencia:
- «1. El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el probl»
- «2. Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el»
- «3. … Habrá tres misas masivas, Política, El Gobierno espe»
- Deportes: «“Juegan otro deporte”. El equipo que arrasa con goleadas…» / «El ciclo de Hansi Flick tiene cifras que asombran…» (es la bajada de la misma nota) / «…Los dinosaurios que se comieron a su padre soy…».
- «Titulares 1 a 3 de 139:», «Hay 126 notas.»

Causa probable: extract.js, putLink(), l.2566: en Clarín la tarjeta entera es un solo enlace. La etiqueta es todo su texto (título, bajada, sección y el título otra vez) cortado con label.slice(0, 160), a mitad de palabra. Assistant.headlines(of:) (l.2411-2430) toma esas etiquetas como titulares, y readablePieces() las lee enteras. En Deportes, título y bajada son dos enlaces al mismo destino, y headlines(of:) deduplica por texto y no por href: la bajada cuenta como nota y deja afuera la tercera real (según el verificador, «Accidente en Rafaela…»). short(…, 140) corta dentro de una cita. Los totales cuentan todo enlace-encabezado de 20 letras o más.

Propuesta: 1) En extract.js, si el enlace contiene un encabezado (h1–h4), usar sólo ese texto como etiqueta; si no, la primera oración. Nunca cortar a mitad de palabra.
2) En headlines(of:), una nota por href: el título y no la bajada, sin sección ni repeticiones.
3) Cortar en fin de frase y no dentro de comillas.
4) No decir «de 139»: decir «Titulares 1 a 3» y «hay muchos más».

Escéptico: Lo confirma el texto de la página de Clarín: cada enlace dice «…afectó a casi dos millones de personas, La Secretaría de Energía informó que el probl» o «…Otra salida del Gobierno, Política, Renunció el». En Deportes (otra-cosa/paginas/03.txt), «El ciclo de Hansi Flick…» es la bajada de «Juegan otro deporte», y «Accidente en Rafaela…» (l.31) quedó afuera. headlines(of:) descarta repetidos por texto, no por href, y extract.js corta con label.slice(0,160).

### P10 · Al llegar a una portada, el modelo reescribe los titulares: inventa sujetos y causas, cada vez distinto, y no coinciden con los botones

*grave* · confirmado · jueces: Lucía, Marta, Roberto, Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, primera-vez, otra-cosa, solo-botones-clarin

Evidencia:
- La Nación: «Adorni explicó la trama de bitcoins en negro y ventas a escondidas de un funcionario.» La página dice: «La explicación de Adorni. Bitcoins en negro, ventas a escondidas y la decisión de vivir como si el dinero “no existiera”».
- «Grandes cadenas le cortaron el audio a Trump por la guerra con la prensa tras vetar a CNN, Politico y MS NOW.» La página dice «tras el veto a CNN, Politico y MS NOW».
- primera-vez: «…lo que generó una denuncia judicial y la salida de una colaboradora de Karina Milei.» otra-cosa: «…tras la salida de una colaboradora de Karina…».
- Botones: «[Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»]» y el botón «Abrir «A partir de este momento». Renunció el secretario de Discapacidad en…»», que conserva la comilla de cierre y perdió la de apertura.
- Nota de Clarín: «…el apagón masivo que afectó a casi 600.000 usuarios», justo después del titular «casi dos millones de personas».

Causa probable: Answerer.orient() (l.217-219) pide decir cada titular «en una frase corta con el HECHO». El modelo reescribe los titulares literales que el código le pasa en «TITULARES PRINCIPALES» (Assistant.swift, l.2186-2191), con lo que contradice la regla de cabecera del propio archivo («Ni una palabra… la escribe un modelo»). Los botones usan el titular literal (dekick + short a 70 caracteres), así que lo que se dice y los botones no coinciden. short() (l.964-973) recorta puntuación en los dos extremos: se lleva la comilla de apertura y deja la de cierre. El cambio sin commitear en dekick() quitaría esta volanta en particular, pero no arregla el recorte de short().

Propuesta: 1) En portadas, armar el texto en código: «Estás en la portada de La Nación. Titulares: 1. … 2. … 3. …», con el titular literal sin volanta y cortado en fin de frase.
2) Botones «Abrir 1: …» con el mismo texto que se dijo.
3) Usar el modelo sólo para notas y resúmenes pedidos.
4) short(): recortar sólo al final y cerrar o quitar las comillas desparejas.
5) En resúmenes, si una cifra difiere de la del titular, aclarar de qué es cada una («600.000 usuarios»).

Escéptico: Las tres corridas dicen distinto el mismo titular («…ventas a escondidas de un funcionario», «…tras lo de los Bitcoins…», «…colaboradora de Karina Milei»). «funcionario» no aparece en ninguna parte de la página. Los botones usan el texto literal. short() recorta la puntuación con trimmingCharacters en los dos extremos, así que se pierde la comilla de apertura de «A partir de este momento". Un detalle: el comentario «Ni una palabra… la escribe un modelo» es de describe(), no una regla de todo el archivo.

### P11 · Demasiado para escuchar de corrido, y el aviso anti-robot corta lo que había en cola

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador A · escenarios: mercadolibre-auriculares, noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, otra-cosa, primera-vez

Evidencia:
- ML, paso 2: «Sigo con: buscame auriculares bluetooth.» ⟶ DESCARTADO; «Buscando auriculares bluetooth en mercadolibre.com.ar.» ⟶ DESCARTADO. Los dos los corta el aviso de la prueba.
- ML, paso 1: primero se dice la lista de resultados (unos 18 s) y después «Cuando elijas, sigo con: buscame auriculares bluetooth.» ⟶ DESCARTADO.
- Wikipedia, paso 5: el segundo párrafo queda «en cola: empieza a sonar a los +89.1s», 41 s después de pedirlo.
- Roberto (otra-cosa): «el último empezó unos 24 segundos después de llegar».
- Lo que es del script: en La Nación y Clarín, titulares 2 y 3 «DESCARTADO: lo cortó un pedido nuevo», y en primera-vez la bienvenida «CORTADO». El script actuó a los 7-9 s.

Causa probable: Del producto:
- askToSolve() pone interruptNext = true y vacía la cola; así se perdieron «Sigo con…» y «Buscando…».
- La opción de audio va en un anuncio aparte, detrás de uno de 12 s.
- readAloud() y describe() emiten un anuncio por renglón, de 120-160 caracteres cada uno.
- Lo accionable («Cuando elijas, sigo con…») va después de la lista.

Del script: los descartes de La Nación, Clarín y primera-vez ocurren porque actúa antes de que termine la cola. AssistantPanel.placeFocus (l.157-170) mueve el foco recién cuando Habla.pendientes llega a 0, y a la primera opción, no a la última línea. Conviene confirmarlo en un iPhone con VoiceOver.

Propuesta: 1) Decir primero lo accionable: «Cuando elijas, sigo con…» antes de la lista, y la opción de audio dentro del mismo mensaje de la prueba.
2) Si el aviso de la prueba corta la cola, que resuma lo que cortó: «Busqué auriculares en Mercado Libre y el sitio pide una prueba…».
3) Renglones cortos (sólo el título), para que tres titulares duren unos 10 s.
4) En Wikipedia, un párrafo por vez cuando supera los 500 caracteres.

Escéptico: Lo central es del producto. En el registro de Mercado Libre, el aviso de la prueba sale con cola:false a los 25.44 s, cuando «Sigo con…» y «Buscando…» todavía esperaban detrás de la orientación, que terminaba cerca de los 32.6 s. Además, Wikipedia tarda de 48.2 a 89.1 s y Deportes de 45.3 a 69.0 s. Esto sigue valiendo aunque la voz vaya más rápido que 14 caracteres por segundo. Del script son los descartes de La Nación, Clarín y primera-vez, el «Cuando elijas…» del paso 1 de Mercado Libre (el script tocó a los 16.1 s) y «Tiene una opción de audio», que cortó el paso 3.

### P12 · «Volver» falta después de leer titulares, aparece duplicado en ANSES, y «Otra cosa» deja sin ningún botón

*grave* · confirmado · jueces: Roberto, Marta, Lucía, Ana, Verificador A · escenarios: noticias-la-nacion, otra-cosa, turno-anses, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- La Nación, pasos 4 y 5: «[Abrir «…»] · [Abrir «…»] · [Abrir «…»] · [Seguir con los titulares] · [Otra cosa]», sin Volver aunque hay historial.
- otra-cosa, paso 3: «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.», sin ningún botón.
- ANSES, paso 4: «[Abrir «VOLVER»] · [Volver a la página anterior]».
- Anti-robot: «[Ya la resolví] · [Otra cosa]».

Causa probable: followUps() (l.1983-1991): la rama «recién leídos» hace return antes de agregar «Volver a la página anterior». accept() (l.1433-1437): «Otra cosa» deja offer = nil y retorna antes del defer que llama a closeTurn(), así que no queda ningún botón. El «VOLVER» de la página entra como sugerencia del modelo y no se fusiona con el propio. En los fixtures anti-robot no hay historial, así que no hay a dónde volver: lo que falta ahí es otra salida (P03).

Propuesta: 1) Agregar Volver en la rama de titulares recién leídos.
2) Después de «Otra cosa», dejar «Volver a las opciones», que restaure la oferta anterior.
3) Descartar los enlaces de la página que digan volver, atrás o regresar cuando ya está el Volver propio.
4) Sin historial, ofrecer «Empezar de nuevo».

Escéptico: En La Nación, los pasos 4 y 5 no tienen «Volver» aunque había historial (en el paso 6, «volvé» anduvo), porque la rama de titulares hace return en l.1981. En otra-cosa, el paso 3 queda sin ningún botón porque accept() retorna antes de closeTurn (l.1433), y es a propósito. En ANSES, el paso 4 muestra [Abrir «VOLVER»] y [Volver a la página anterior]. Lo de anti-robot no prueba nada: se escribió la URL como primer paso y no había historial.

### P13 · Botones de relleno o mal ordenados: preguntas ya contestadas, epígrafes, promociones, notas ajenas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: wikipedia-mar-del-plata, clima-cordoba, solo-botones-clarin, mercadolibre-auriculares, noticias-la-nacion, anti-robot-ya-la-resolvi, anti-robot-avanza-sola

Evidencia:
- Wikipedia, paso 3: «Mar del Plata se fundó el 10 de febrero de 1874 por Patricio Peralta Ramos.» → «[¿Quién la fundó?] · [¿Cuántos años hace que se fundó?] · …».
- Clima, paso 3: «[¿Qué clima hará mañana en Córdoba?] · [¿A qué hora amanece y atardece?] · [Completar «Selecionar localidad»]».
- Wikipedia, paso 2: «[Abrir «Desde arriba hacia abajo, y de izquierda a derecha: Vista de la Playa…»]».
- Nota de Clarín: «[Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»]».
- ML: «[Abrir «ELECTROBEAUTY ¡HASTA 45% OFF Y 18X SIN INTERÉS! Ver ofertas»] · [Abrir «ILUMINACIÓN …»] · [Abrir «ACCESORIOS …»]».
- La Nación, paso 3: «[Intentar de nuevo] · [Leer los titulares] · …».
- ya-la-resolvi, paso 3: «[Leer la página] · [Resumir la página] · [Otra cosa]», justo después de un resumen con precios.

Causa probable: - Answerer.instructions (l.97-99) pide preguntas probables sin excluir las que la respuesta ya contesta.
- candidates() (l.1858) filtra pagar, suscribirse y descargar, pero no promociones («% OFF», «ofertas», «sin interés») ni epígrafes o enlaces a imágenes.
- En una nota, arrived() (l.2230-2234) deja una nota ajena, que sale de «más leídas».
- formOptions() ofrece cualquier formulario que no sea de búsqueda, como «Selecionar localidad».
- closeTurn() pone «Intentar de nuevo» antes que las opciones de la página.
- orient sugirió «Resumir» justo después de un resumen.

Propuesta: 1) Descartar las preguntas sugeridas cuyas palabras de contenido ya estén en la respuesta.
2) Sacar de candidates las promociones, los epígrafes (figcaption, enlaces a Archivo: o a imágenes) y los enlaces del pie.
3) En una nota, no ofrecer otras notas salvo que se pidan.
4) «Completar» sólo cuando el formulario es el destino (un ingreso o un trámite) o cuando el pedido nombra el campo.
5) Después de nombrar un producto, poner primero «Abrir «…»». Hay que confirmarlo con una página real, porque el fixture usa enlaces #a.

Escéptico: Las citas están en las transcripciones. Wikipedia paso 3: «se fundó … por Patricio Peralta Ramos» y el primer botón es «[¿Quién la fundó?]». Clima paso 3: «[¿Qué clima hará mañana en Córdoba?]», que ya se contestó en el paso 2, y «Completar «Selecionar localidad»» (paginas/02.txt l.57). Wikipedia: el epígrafe «Desde arriba hacia abajo…». Clarín: «Clave Única PAMI», que en paginas/05.txt viene de la lista de otras notas del pie. ML: «ELECTROBEAUTY ¡HASTA 45% OFF…», aunque esos botones duraron 0,6 s antes de que siguiera la búsqueda. La Nación: «[Intentar de nuevo]» antes de «[Leer los titulares]». Anti-robot: «[Leer la página] · [Resumir la página]» después de un resumen con precios. Es lo que la app ofrece, no una elección del script.

### P14 · Wikipedia: «leeme» empieza por la cabecera, lee sólo la introducción y deja marcas de referencia

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: wikipedia-mar-del-plata

Evidencia:
- Paso 4: «Párrafos 1 a 2 de 6:» / «ciudad de la provincia de Buenos Aires, Argentina» / ««Marplatense»  redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).»
- Paso 5: «…«Puerto de la Laguna de los Padres». [2 ]», «301  %», «siglo  XVIII». Paso 2: «644 234 habitantes».
- Botones: «[Leer la nota] · [Resumir la nota]».
- Verificador A: paginas/02.txt tiene 18 secciones plegadas cuyo texto no se extrajo.

Causa probable: Assistant.readablePieces() (l.1246-1266) acepta cualquier párrafo de 40 letras o más: entran la descripción corta y el aviso «redirige aquí». Las otras dos notas de desambiguación no entraron, así que el filtro es incoherente. La versión móvil de Wikipedia pliega las secciones y el extractor no las abre, por eso «de 6». extract.js conserva las llamadas <sup> de referencia y los espacios duros. El rótulo sale de isArticle(), que no distingue una enciclopedia de un diario.

Propuesta: 1) En extract.js, descartar .shortdescription, .hatnote, .dablink, .rellink y sup.reference, y normalizar los espacios duros.
2) Desplegar las secciones antes de extraer. Si igual se lee sólo la introducción, decirlo: «Introducción, 4 párrafos. Después vienen Historia, Geografía…».
3) En Wikipedia, «Leer el artículo».
4) Separador de miles con punto.

Escéptico: Paso 4: «Párrafos 1 a 2 de 6:», después «ciudad de la provincia de Buenos Aires, Argentina» y ««Marplatense» redirige aquí…». Paso 5 trae «301  %», «siglo  XVIII» y «[2 ]», y los botones dicen «Leer la nota». En paginas/02.txt, las 18 secciones (de Historia a Enlaces externos) aparecen sólo como títulos repetidos, sin su texto. Por eso se lee sólo la introducción.

### P15 · Datos personales y sitios oficiales: el DNI queda a la vista y viaja al modelo en el turno siguiente, sin avisos de sitio oficial

*grave* · confirmado · jueces: Lucía, Marta, Roberto, Ana, Verificador A, Verificador B · escenarios: banco-nacion, turno-anses

Evidencia:
- Banco, paso 4: «💬 Persona: 30123456». En el árbol queda «[H] Vos: 30123456».
- «Listo, escrito en DNI.»: Roberto quería oír el número para quedarse tranquilo; Marta y Lucía no quieren que se repita.
- ANSES, paso 1: «3. Turnos ANSES - ️ Sacar turno en ANSES, turnosanses.net», sin aviso de que no es oficial.
- Banco: «Abriendo digital.bna.com.ar.», sin confirmar que es el oficial. Verificador B: el buscador lo describía como «BNA Digital Empresas», y otro resultado anunciaba que el Home Banking pasa a BNA+.

Causa probable: Assistant.ask() (l.211 y l.219-220) llama a heard(goal) y guarda lastRequest = goal antes de ver que se estaba esperando un campo (l.227). Resultado: el DNI queda escrito como pedido. En el turno siguiente se manda al modelo como «Lo que pidió antes: «30123456»» (Router.state) o como PEDIDO ANTERIOR (Answerer.answer). Si lo siguiente es llegar a una página, también va a orient como «LA PERSONA VINO A». La escritura en el campo, en cambio, no pasa por la nube: va directo con reader.fill. isOfficial() (l.1170) sólo reconoce .gob.ar y .gov.ar, y ranked() ordena lo oficial primero pero no marca lo que no lo es.

Propuesta: 1) En la rama del campo, no tocar lastRequest ni previousRequest.
2) Mostrar «Vos: DNI escrito (termina en 456)», y para contraseñas nada.
3) Decir una vez «Tu DNI va sólo a la página del banco».
4) Botones «Repetir lo escrito» y «Corregir el DNI»: Roberto confirma a pedido, sin que se diga siempre en voz alta.
5) En trámites y bancos, decir «sitio oficial» o «no es un sitio oficial», con .gob.ar más una lista corta de bancos del país.

Escéptico: En el árbol queda «[H] Vos: 30123456». En Assistant.ask(), heard(goal) y «lastRequest = goal» (l.209 y 219-220) se ejecutan antes del «if let field = awaitingField» (l.227). En el turno siguiente, previousRequest llega a Router.state («Lo que pidió antes: «…»») y a Answerer («PEDIDO ANTERIOR»), las dos al gateway de Vercel. Esto se confirma en el código, porque el escenario termina antes. isOfficial() sólo mira .gob/.gov: «turnosanses.net» se ofrece sin aviso y «Abriendo digital.bna.com.ar.» no dice si es oficial.

### P16 · Los avisos que tapan la página (cookies, inicio de sesión con Google) no se pueden cerrar desde la conversación

*grave* · confirmado · jueces: Lucía, Marta, Roberto, Ana, Verificador A · escenarios: mercadolibre-auriculares, solo-botones-clarin, dolar-desde-cero

Evidencia:
- ML, paso 2: «Hay un aviso sobre el uso de cookies que tapa la página.», con botones de ofertas y ninguno para cerrarlo.
- Clarín: en paso-02.jpg y paso-03.jpg el cartel «Acceder a Clarin.com con Google / Continuar» tapa la página, y JEF no lo menciona (Verificador A, Ana).
- Dólar: el aviso de cookies «Aceptar / Rechazar» tapa los precios y no se menciona (Ana).

Causa probable: arrived() y orient() sólo mencionan el aviso en el texto («decilo en media frase al final») y nunca convierten overlay.choices en botones. describe() nombra las opciones, pero sólo si orient falla, y tampoco como botones. extract.js no toca los avisos de cookies a propósito, porque es una decisión de la persona. El inicio de sesión de Google es un iframe de otro origen que el detector no reconoce.

Propuesta: 1) Cuando page.overlay trae opciones, ofrecerlas como botones antes del resto («Rechazar cookies», «Aceptar cookies», «Cerrar el aviso»), activando el control real.
2) Reconocer el iframe de accounts.google.com/gsi y decir «Hay un cartel para entrar con Google: no hace falta», con un botón «Cerrar el cartel».

Escéptico: En ML, JEF dice «Hay un aviso sobre el uso de cookies que tapa la página.» y no ofrece ningún botón para cerrarlo; paso-02.jpg muestra «Aceptar cookies / Configurar cookies». En Clarín, paso-02.jpg y paso-03.jpg muestran «Acceder a Clarin.com con Google / Continuar» y JEF no lo menciona. En Dólar, paso-02.jpg muestra «Este sitio utiliza cookies – Aceptar / Rechazar» y la conversación no lo nombra. En el código, overlay.choices sólo se dice en describe() (l.2296-2297) y nunca se convierte en botón.

### P17 · Primera vez: la bienvenida no dice cómo se usa y «no entiendo» no explica cómo moverse

*grave* · confirmado · jueces: Roberto, Marta, Lucía, Ana · escenarios: primera-vez

Evidencia:
- «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.»
- «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- Paso 2: «Estás en la portada de LA NACION, un portal de noticias. Los titulares principales son: …», casi medio minuto seguido para alguien que recién empieza.

Causa probable: Son textos fijos de carry(.orientar), l.491 y l.497. La frase de bienvenida no tiene verbo, no dice que se escribe o dicta abajo ni cómo se llega a las opciones, y nombra a «JEF» en tercera persona sin haberse presentado. La ubicación usa page.sectionTitle, el título técnico. El corte de la bienvenida que muestra la transcripción es del script.

Propuesta: 1) Bienvenida: «Soy JEF. Decime qué sitio querés abrir o qué querés buscar: escribilo o dictalo abajo. O tocá una de estas opciones.»
2) Ante «no entiendo»: «Estás en la portada del diario La Nación. Yo soy JEF y te ayudo a usar la página.» Con VoiceOver activo, agregar «Para elegir, deslizá a la derecha hasta escuchar la opción y tocá dos veces»; sin VoiceOver, «tocá una opción de abajo».
3) Las primeras veces, llegar a una portada con dos titulares y un botón «Seguir con los titulares».

Escéptico: El texto es el de l.491: «Para empezar, un sitio o algo para buscar; o una de estas opciones.», sin verbo y sin decir dónde escribir o dictar. Ante «no entiendo», l.497 contesta «Estás en «Últimas noticias de Argentina y el mundo», LA NACION… la conversación con JEF: se le pide algo…». Usa el título técnico, nombra a JEF en tercera persona y no dice cómo llegar a las opciones con VoiceOver. En el paso 2, la llegada a La Nación dura unos 34 s seguidos. El corte de voz de la bienvenida sí es del script, pero el problema ya lo aclara y no se apoya en él.

### P18 · Dónde se está se dice con el título técnico y con un formato distinto en cada camino; «nota» y «portada» mal usadas

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: solo-botones-clarin, dolar-desde-cero, clima-cordoba, primera-vez, otra-cosa, wikipedia-mar-del-plata

Evidencia:
- Así se dice la llegada según el camino: «En Noticias de Argentina — Clarin.com.», «En DolarInfoHoy.», «En eltiempoen.com.», «En Noticias de Deportes — LA NACION.», «Estás en «Últimas noticias de Argentina y el mundo», LA NACION.», frente a «Estás en la portada de La Nación.».
- «[Leer la nota]» en Wikipedia; «[Resumir la portada]» en la sección Deportes.

Causa probable: Cada camino tiene su plantilla: describe() dice «En {sectionTitle} — {displaySite}.»; la pregunta pendiente, «En {displaySite}.»; orientar, «Estás en «{sectionTitle}», …»; goBack, «De vuelta en «…»»; y orient deja que el modelo lo redacte. Los rótulos salen de readsHeadlines() e isArticle(): «portada» para cualquier lista de titulares (también secciones y trámites) y «nota» para cualquier texto largo.

Propuesta: 1) Una sola función «dónde estoy», según el tipo de página, usada en todos los caminos: «Estás en Clarín, en la portada», «…en la sección Deportes de La Nación», «…en DolarInfoHoy, cotizaciones del dólar».
2) Rótulos por tipo: «artículo» en Wikipedia, «sección» cuando la ruta no es /, «portada» en la raíz.

Escéptico: En las transcripciones aparecen «En Noticias de Argentina — Clarin.com.», «En DolarInfoHoy.», «En eltiempoen.com.», «En Noticias de Deportes — LA NACION.» (otra-cosa, paso 4), «Estás en «Últimas noticias de Argentina y el mundo», LA NACION.» (primera-vez) y «Estás en la portada de La Nación.». Además, «[Leer la nota]» sale en Wikipedia y «[Resumir la portada]» en /deportes/. Es inconsistencia de la app, de gravedad menor.

### P19 · Cuando JEF espera un dato, el campo de escribir no lo dice y aparece una barra «Toolbar»

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: banco-nacion, otra-cosa, noticias-la-nacion, primera-vez

Evidencia:
- Banco, paso 3: «[campo] Pedido  = Escribir: DNI  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)»
- Banco, paso 4: «[grp] Toolbar». En paso-04.jpg hay una barra con ⌃ ⌄ ✓.
- otra-cosa: «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.», la misma explicación cada vez.

Causa probable: En AssistantPanel.swift, l.221, el accessibilityHint del campo es fijo. En l.208 el texto de ayuda cambia a «Escribir: DNI», pero en gris (.secondary). «Otra cosa» (l.1434) explica el dictado cada vez. __jefFill (extract.js, l.3236) hace el.focus() sobre el campo de la página y nunca lo suelta, así que iOS muestra la barra de formulario, que VoiceOver lee como «Toolbar».

Propuesta: 1) Que la pista siga a awaiting: «Escribí tu DNI; va directo al campo DNI de la página».
2) Una etiqueta oscura «Escribiendo en: DNI» y un borde de color en el campo.
3) Explicar el dictado sólo la primera vez.
4) Hacer blur() después de llenar desde la conversación, salvo en campos con autocompletado.
Roberto pidió que el cursor vaya al campo: el código ya lo hace (inputRequests → focused = «campo»). Falta verificarlo en un dispositivo.

Escéptico: Pasa, aunque el título exagera. El campo sí dice el dato («[campo] Pedido = Escribir: DNI»), pero la pista fija lo contradice: «(Escribí a dónde querés ir. Con el dictado…)», que es el accessibilityHint fijo de AssistantPanel.swift l.221. En el paso 4 aparece «17 [grp] Toolbar», y en paso-04.jpg se ve la barra ⌃ ⌄ ✓ con el cursor todavía en el campo DNI de la página: __jefFill hace el.focus() y nunca blur(). Lo de «la misma explicación cada vez» no se puede ver en esta ronda: «Otra cosa» se tocó una sola vez (otra-cosa, paso 3). Lo que sí se repite en cada paso es la pista del dictado en el campo.

### P20 · Si la prueba anti-robot se resuelve sin cambiar de página, JEF no se entera

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: anti-robot-ya-la-resolvi

Evidencia:
- Paso 2: 15 segundos sin ningún anuncio, mientras paso-02.jpg ya mostraba la lista de auriculares.
- Sólo al tocar «Ya la resolví»: «Listo, ya pasamos la verificación.»

Causa probable: extract.js (l.3562-3628) vuelve a leer una página que cambia sola sólo si pasa una de estas cosas:
- el cambio suma 20 nodos o más (LATE_THRESHOLD) dentro de los 90 s (LATE_WINDOW_MS);
- cambia la ruta;
- cambia el título.
El fixture reemplaza un bloque chico sin tocar la dirección ni el título, así que pageChanged() nunca se ejecuta. En avanza-sola la dirección sí cambia, y ahí funcionó.

Propuesta: 1) Mientras haya una prueba pendiente (challenge != nil), releer la página cada 3 s o vigilar, sin umbral, que desaparezca el iframe o el recuadro de la prueba.
2) Si pasan unos 20 s, recordar: «Cuando esté resuelta, tocá «Ya la resolví»».

Escéptico: En el paso 2 no hay ni un anuncio en 21 s, y paso-02.jpg ya muestra los tres auriculares. Sólo después de «Ya la resolví» dice «Listo, ya pasamos la verificación.». El fixture cambia el innerHTML de <main> sin tocar la dirección ni el título. Con weight() el cambio pesa unos 16 nodos, por debajo de LATE_THRESHOLD = 20, así que pageChanged() nunca corre, aunque sí sabe manejar el caso de la misma dirección (Assistant.swift l.2096). El cambio del fixture es chico, pero el umbral y la ventana de 90 s son decisiones del producto. En avanza-sola, que sí cambia de dirección, funcionó.

### P21 · Etiquetas de resultados larguísimas y ecos: el título entero como mensaje propio, «Ver más opciones (1)», dominios raros

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa, dolar-desde-cero, clima-cordoba, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion

Evidencia:
- «💬 Persona: Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar»
- «[Ver más opciones (1)]»
- «2. ANSES, servicioswww.anses.gob.ar»
- «[Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com]»
- «Buscando: clarin.», con la tilde perdida.
- «[La Nacion — ingresar.lanacion.com.ar]» (la página de ingreso) entre los tres más probables.

Causa probable: present() (l.735-745) arma la etiqueta con el título completo del resultado más el host. accept() escribe esa etiqueta como si la hubiera dicho la persona (heard(action.label)). El botón dice «Ver más opciones (N)». bare() sólo quita «www.». El target del ruteador llega sin tildes. Las páginas de ingreso no bajan en el orden.

Propuesta: 1) Etiquetas cortas: «La Nación — lanacion.com.ar», sin repetir el sitio ni la barra.
2) Mensaje de la persona: «Vos: abrir La Nación».
3) «Ver 1 resultado más».
4) Decir el dominio como sitio: «anses.gob.ar, servicios».
5) En «Buscando», usar lo que escribió la persona.
6) Bajar /login e ingresar.* en la lista.

Escéptico: Está todo, tal cual lo describen. «💬 Persona: Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar» y «Vos: …» en el árbol salen de heard(action.label). También aparecen «[Ver más opciones (1)]», «2. ANSES, servicioswww.anses.gob.ar» (ese host existe de verdad, pero así dicho suena raro), «[Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com]», «Buscando: clarin.» después de que la persona escribió «clarín», y «[La Nacion — ingresar.lanacion.com.ar]» entre los tres. El script tocó el botón 1 mecánicamente, pero cualquier botón habría dejado el mismo eco, porque la etiqueta se arma en present() (l.739-745).

### P22 · Redacción del modelo con calcos y errores de concordancia

*menor* · confirmado · jueces: Marta, Lucía, Ana · escenarios: clima-cordoba, anti-robot-avanza-sola

Evidencia:
- «Mañana en Córdoba se esperan unas condiciones de nubes.»
- «El más barato es el Auriculares In Ear Bluetooth Básicos, que sale $12.499.»

Causa probable: Answerer traduce literal el rótulo de la página («Nubes») y copia el nombre del producto sin ajustar el artículo al plural.

Propuesta: En las instrucciones de Answerer, pedir vocabulario local («nublado», «parcialmente nublado») y concordancia con nombres en plural: «Los más baratos son los Auriculares In Ear Bluetooth Básicos, a $12.499».

Escéptico: El error de concordancia es del modelo: «El más barato es el Auriculares In Ear Bluetooth Básicos, que sale $12.499.» (anti-robot-avanza-sola, paso 3). El calco, en cambio, no lo inventó el modelo: la página ya dice «Mañana en Córdoba se esperan unas condiciones de nubes con una probabilidad…» (clima-cordoba/paginas/02.txt l.53), y Answerer la copió. La causa probable («traduce literal el rótulo Nubes») está mal para esa mitad.

## Lo que funciona

- Banco Nación, de punta a punta: «Te pide tu DNI y tu usuario para ingresar.», «Completar «DNI»» como primera opción, «¿Qué pongo en DNI? … va directo a ese campo de la página.», «Listo, escrito en DNI.» y después «Completar «Usuario»». El dato que se escribe en el campo no pasa por el ruteador (rama awaitingField).
- Honestidad cuando no hay dato: «Todavía no hay una nota abierta: estás en la portada de LA NACION. ¿Cuál abro?», «La página no muestra ningún auricular bluetooth… solo pide que completes un paso de seguridad» (no inventó un precio) y, en ANSES, «Esta página sirve para consultar turnos que ya pediste».
- Respuesta de dato directa: «El dólar blue hoy tiene un valor de venta de $1.550,00 y de compra de $1.530,00. No tuvo variación en el día.» forEar() quita los «,00» al leerlo, y las preguntas siguientes («¿A cuánto está el dólar oficial?», «¿Y el dólar MEP?») eran justo las que seguían.
- Anti-robot con cambio de página: siguió solo («Listo, ya pasamos la verificación.») y retomó lo que estaba haciendo. «Ya la resolví» siempre queda primero y funciona al instante.
- Memoria de la tarea compuesta: «Cuando elijas, sigo con: buscame auriculares bluetooth.», y la retomó sola después de elegir.
- El botón de inicio «Llevame a La Nación» abre directo, y «llevame a deportes» dentro de un diario va a la sección sin pasar por el buscador.
- En la llegada a una portada por orient(), los titulares nombrados y los botones «Abrir» son los mismos y en el mismo orden, porque los elige el código.
- La posición va adelante («Titulares 1 a 3 de…», «Párrafos 1 a 2 de 10») y «Seguir leyendo» o «Seguir con los titulares» quedan primero mientras se lee. En una nota, «Leer la nota» va antes que «Resumir».
- «volvé» responde en menos de un segundo y no relee la lista: «De vuelta en los resultados de «la nación».»
- «Otra cosa» lleva el cursor al campo con el teclado abierto.
- La pista «Primera de N opciones.» en el primer botón.
- El orden de resultados: lo oficial primero (argentina.gob.ar en ANSES), lo de otro país al final (Córdoba de España y La Nación de Costa Rica descartadas) y sin enlaces patrocinados.
- Orientación según el objetivo: «Estás en la página de Argentina.gob.ar para solicitar turnos en ANSES», con «Pedir turno» primero.
- La explicación «Arriba está la página; acá abajo, la conversación con JEF…» (Lucía: «la mejor explicación de la app que escuché»).
- Lo visual: botones con texto oscuro y borde de color, grandes, y una primera pantalla con cuatro opciones fácil de leer.
- Todo en castellano y sin nombres internos a la vista (según los verificadores).
