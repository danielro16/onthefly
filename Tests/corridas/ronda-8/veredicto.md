# Veredicto — ronda-8

Ronda 8, 12 escenarios, 4 jueces y 2 verificadores. Dos escenarios fallaron para los cuatro jueces: mercadolibre-auriculares (promedio 2,7) y otra-cosa (2,85). En tres el objetivo quedó a medias para todos: turno-anses (3,2), clima-cordoba (3,0) y, sólo para Ana, wikipedia-mar-del-plata. Los mejores son dolar-desde-cero y banco-nacion (4,1 cada uno). Hay dos bloqueantes. El primero es la prueba anti-robot: el aviso es un texto fijo que no lleva a la prueba, nombra VoiceOver aunque la persona no lo use, y cuando no se puede resolver no hay otra salida. El segundo es «llevame a deportes» dentro de La Nación: la llamada a Jev en run() falla, el catch genérico dice «No pude decidir» y el primer botón que ofrece es repetir lo mismo. Lo que más se repite, en 9 escenarios y con los 4 jueces, es el paso por la lista del buscador para sitios conocidos y preguntas de dato. Es una decisión explícita de Assistant.arrive y contradice al botón de ejemplo «Llevame a La Nación», que va directo. Después vienen fallas de datos e intención que dejan el objetivo a medias. En Córdoba da Fahrenheit sin aviso, y la verificación literal de cifras impide convertir. En ANSES se pierde el «turno»: el ruteador no devolvió rest y la deduplicación por host tiró el resultado de turnos. Otros problemas: los titulares se repiten sin botón para seguir, porque closeTurn recorta «Seguir con los titulares». Los avisos importantes se dicen en anuncios aparte en cola y se pierden. Los botones incluyen enlaces que no sirven y preguntas ya contestadas. Los titulares se parafrasean y no coinciden con los botones. Para Ana, los botones quedan fuera de la vista. Lo que anda y no hay que romper: el primer resultado ordenado bien, las respuestas sobre la página abierta, la lectura textual con la posición adelante, el ingreso al banco con el DNI tapado, y seguir solo cuando la prueba anti-robot se resuelve navegando. Descarté lo que sólo es del script, por ejemplo que la bienvenida se cortara al 65 % porque el script tocó el botón a los 7 segundos. Sí conservé que se pierdan anuncios en cola: cualquier gesto real de la persona los corta igual.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.1 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana a medias | 3.5 |
| turno-anses | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.2 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.7 |
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.1 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.7 |
| clima-cordoba | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.0 |
| otra-cosa | Marta no, Roberto no, Lucía no, Ana no | 2.9 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |
| anti-robot-ya-la-resolvi | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |

**Promedio general: 3.46**

## Problemas

### P01 · Prueba anti-robot: no hay cómo llegar a ella ni salida si no se puede resolver

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.» (igual en los tres escenarios)
- Mercado Libre, paso 2: «Tiene una opción de audio, dentro del recuadro de la prueba.» ⟶ DESCARTADO. En avanza-sola no se dice nada del audio
- Verificador A: paginas/03.txt no menciona ningún audio. La casilla reCAPTCHA «No soy un robot» no muestra un control de audio hasta que se abre un desafío
- Mercado Libre, paso 3: «Por lo tanto, no puedo decirte el precio del más barato.» Los botones siguen siendo [Ya la resolví] · [Volver a la página anterior] · [Otra cosa]
- Roberto: «Sólo sé deslizar, y no sé cuántas veces ni dónde parar… Acá me quedé trabado.» Ana: «Yo no uso VoiceOver, así que esa parte no me dice nada. Tampoco me dice qué tocar.»
- Verificador A: en paso-02.jpg el aviso de la prueba y el botón «Ya la resolví» quedan fuera de la pantalla

Causa probable: Assistant.askToSolve dice un texto fijo: «me pide», dicho como si la prueba se la pidieran a JEF, y «con VoiceOver» sin mirar UIAccessibility.isVoiceOverRunning. El aviso del audio es un segundo say() que queda en cola, porque interruptNext sólo vale para el primero. Además se afirma sólo porque el iframe es de recaptcha/hcaptcha (extract.js detectChallenge: audio = /recaptcha|hcaptcha/.test(src)), no porque la página lo muestre. Con una prueba pendiente, followUps devuelve sólo «Ya la resolví» y Volver: no existe una acción que lleve el foco de VoiceOver a la prueba, ni alternativas. closeTurn además suprime las preguntas sugeridas cuando hay captcha.

Propuesta: Un único anuncio, con lo que importa primero: «Mercado Libre pide confirmar que sos una persona. La prueba la resolvés vos (o alguien que te ayude); suele tener opción de audio.» Nombrar VoiceOver sólo si está activo. Para quien no lo usa: «Arriba, tocá el cuadradito No soy un robot». Primer botón «Ir a la prueba»: hace scrollIntoView del iframe y postea UIAccessibility.layoutChanged apuntando al WebView para que el cursor quede en el recuadro. Si la persona dice que no puede o pregunta algo que la prueba bloquea, ofrecer «Buscar [lo pedido] en otra tienda», «Buscar precios en internet» y «Volver». «Ya la resolví» va primero sólo después de «Ir a la prueba».

Escéptico: Pasa, pero exagerado. En los tres escenarios el aviso es el mismo texto fijo («El sitio web me pide resolver… con VoiceOver, antes de esta conversación»), no hay una acción que lleve el foco a la prueba, y en Mercado Libre, cuando la persona pregunta el precio, recibe «no puedo decirte el precio del más barato» con los mismos botones [Ya la resolví]·[Volver]·[Otra cosa] y ninguna alternativa. paso-02.jpg confirma que el aviso y «Ya la resolví» quedan fuera de pantalla. Lo exagerado: sí hay salida (Volver/Otra cosa), en las dos pruebas locales el flujo siguió bien («Listo, ya pasamos la verificación»), y el audio DESCARTADO se debe a que el script escribió a los 7,6 s, cuando el primer anuncio (~11 s) todavía sonaba; la línea sigue en la conversación.

### P02 · «Llevame a deportes» falla dentro del sitio y la primera salida es repetir el intento

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: otra-cosa

Evidencia:
- «No pude decidir a dónde ir desde acá. Se puede pedir de otra forma, o tocar una opción.»
- Botones: [Intentar de nuevo] · [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa]
- Verificador B: la portada (paginas/02.txt, línea 41) tiene la sección «Deportes» con 4 titulares propios, y el menú «Secciones» se ve en paso-04.jpg
- Roberto: «Me dice que lo pida "de otra forma" pero no me da ningún ejemplo, y a mí escribir me cuesta mucho.»

Causa probable: El ruteador manda «llevame a deportes» a .abrir, y eso va a run(), que le pregunta a Jev (PageAnalyzer.nextStep) con hasta 240 opciones. La llamada falló con un error que no es de red (http o decoding): el mensaje es exactamente el del catch genérico de run(), que no intenta nada más. El error no se escribe en el Registro, así que no se sabe cuál fue. Antes de Jev no se busca la coincidencia obvia («Deportes» contra las etiquetas de la página). closeTurn pone «Intentar de nuevo» primero porque failedTurn está en verdadero, y ese botón repite el mismo pedido.

Propuesta: Antes de Jev, y como respaldo si Jev falla, buscar en options(of:) una etiqueta que coincida exacta o por raíz con la referencia («deportes» → «Deportes») y abrirla diciendo «Abro Deportes». Escribir el error de Jev en el Registro. Si igual no se encuentra, decir qué se buscó y ofrecer como botones las secciones del menú (Deportes, Política, Economía…) y «Buscar deportes en La Nación». «Intentar de nuevo» va al final, nunca primero.

Escéptico: Confirmado en otra-cosa, paso 4. A «llevame a deportes» responde «No pude decidir a dónde ir desde acá. Se puede pedir de otra forma, o tocar una opción.», con [Intentar de nuevo] primero. paginas/02.txt tiene «Deportes» en la línea 41 y paso-04.jpg muestra el menú «Secciones». El texto es exactamente el del catch genérico de run() (Assistant.swift:1610), que además pone failedTurn = true.

### P03 · Turno en ANSES: se pierde la intención y no se llega a pedir el turno

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: turno-anses

Evidencia:
- Pedido: «quiero sacar un turno en anses». Respuesta: «Buscando: anses.» No aparece «Cuando elijas, sigo con…»
- Verificador A: el resultado exacto, «Solicitar turnos en ANSES - Argentina.gob.ar» (n.º 3 en 01.txt), no está entre los 3 ofrecidos
- Paso 4: «Los trámites disponibles son el Plan de Pago de Deuda Previsional para trabajadores en actividad, Solicitud de Jubilación, Solicitud de Pensión y Pensión no Contributiva por Invalidez Laboral.» 04.txt lista 18, entre ellos «Trámites Jubilados y Pensionados» y «Pensión Universal para Adultos Mayores»
- Primer botón: «Abrir «CONSULTAR TURNO»», que en 04.txt está bajo «¿Ya sacaste turno?»
- «Tenés la opción de buscar por nombre de trámite.» No hay ningún botón para hacerlo
- «Abrir «Solicitud de Jubilación, ver sub-trámites»»

Causa probable: Son cinco causas encadenadas. (1) El ruteador devolvió target «anses» sin rest, así que «sacar un turno» no sobrevivió y no hubo continuación automática. (2) Assistant.results deduplica por host y se queda con el primero: argentina.gob.ar/anses tapó a argentina.gob.ar/servicio/solicitar-turnos-en-anses. (3) En el sistema de turnos, el orden de los botones y la frase los arma el modelo de orient: eligió «CONSULTAR TURNO» (tiene «turno») y presentó 4 de 18 trámites como si fueran todos. (4) formOptions excluye los formularios de búsqueda (isSearch), así que el campo «Ingresá el nombre del trámite» nunca llega a ser un botón. (5) Las etiquetas pasan crudas: «, ver sub-trámites» y MAYÚSCULAS.

Propuesta: Si el ruteador no devuelve rest pero el pedido tiene palabras de contenido que no están en target, buscar con ellas («turnos anses») o guardarlas como rest. Al deduplicar por host, quedarse con el resultado cuyo título comparte más raíces con el pedido. En una página de trámites: preguntar «¿Para qué trámite es el turno?» con los frecuentes (jubilados y pensionados, PUAM, AUH, otro), agregar un botón «Buscar mi trámite» que complete el campo de búsqueda, y dejar «Consultar un turno que ya tenés» al final. Si la lista es parcial, decir «Hay 18 trámites; algunos: …». Limpiar «, ver sub-trámites» y pasar las mayúsculas a oración. Si la página pide CUIL y Clave de la Seguridad Social, avisarlo al entrar.

Escéptico: Los fallos del paso 4 son reales: «Los trámites disponibles son…» nombra 4 de los 18 de 04.txt; el primer botón es «CONSULTAR TURNO», que va bajo «¿Ya sacaste turno?»; dice «buscar por nombre de trámite» sin botón para hacerlo, y las etiquetas salen crudas («, ver sub-trámites»). Además, el resultado n.º 3 de 01.txt no se ofrece. Pero el título exagera: la intención no se pierde del todo, porque en el paso 2 dice «Para sacar un turno, tenés que ir a la sección de turnos» y en tres toques llega al sistema de turnos. «No se llega a pedirlo» es en parte porque el script terminó en el paso 4.

### P04 · El pronóstico sale en Fahrenheit, mph y AM/PM sin avisar

*grave* · del script de prueba · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: clima-cordoba

Evidencia:
- «La temperatura máxima será de 63º y la mínima de 40º. … el viento soplará desde el NE a 13 mph. El amanecer será a las 7:06 AM y el atardecer a las 7:12 PM.»
- paginas/02.txt: «Viento NE 13 mph», «Visibilidad, 6 mi», «Lluvias, 0 in»; la página muestra «63º» sin «F»
- Roberto: «¿63 grados? Me asusté.» Confianza 2 en los cuatro jueces

Causa probable: El sitio sirvió unidades imperiales, probablemente por la ubicación o el idioma de quien navega (la corrida no parece haber salido desde Argentina), y en la temperatura no escribe «F». Answerer.instructions pide «Decí siempre la unidad tal como está en la página»; como la página no dice «F», sale «63º». Además la verificación de «cifras» (Answerer.appears) exige que cada número aparezca literal en la página. Eso impide por diseño cualquier conversión: «17 °C» nunca pasaría.

Propuesta: Normalizar en código antes de hablar. Si la página trae mph, in, mi o AM/PM, tratar las temperaturas como °F y convertir: °C redondeados, km/h y horario de 24 h. Verificar contra la página la cifra de origen, no la convertida. Pedirle al sitio unidades métricas (Accept-Language es-AR en el WKWebView). Decir «Córdoba, Argentina» la primera vez.

Escéptico: Pasó (02.txt: «63º 40º», «NE 13 mph», «7:06 AM»), pero la causa es que la prueba corrió desde EE. UU. La copia que quedó en la caché del simulador trae `var units = "f"`. Pedida desde esta máquina (ipinfo: US) con encabezados de navegador, eltiempoen.com devuelve "f" con Accept-Language es-AR, es-ES o en-US, y en su HTML el cambio a °F sólo lo hace el selector de unidades, no el idioma. O sea que depende de la IP. Desde Argentina lo esperable es °C y km/h, y el arreglo propuesto (Accept-Language es-AR) no cambiaría nada. Queda un punto débil de la app: dice «63º» sin unidad.

### P05 · Un sitio conocido o una pregunta de dato pasan siempre por la lista del buscador

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, clima-cordoba, otra-cosa

Evidencia:
- «Estás en los resultados de «la nación». Los 3 más probables: 1. Últimas noticias de Argentina y el mundo - LA NACION, lanacion.com.ar. 2. LN+ EN VIVO | Últimas noticias de Argentina y el mundo, youtube.com. 3. Kiosco LA NACION, edicionimpresa.lanacion.com.ar»
- primera-vez: el botón «Llevame a La Nación» va directo: «Abriendo lanacion.com.ar.»
- «1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar» (el dato ya estaba en el título)
- «1. Mercado Libre Argentina…, mercadolibre.com.ar. 2. Mercado Libre…, mercadolibre.com. 3. Mercado Libre, listado.mercadolibre.com.ar»
- otra-cosa: «3. La Nacion, ingresar.lanacion.com.ar»
- Ana: arriba se ve el buscador con un anuncio en inglés, «Official Site - BlackAmerican News&Information»
- En los 9 escenarios, el botón 1 era el correcto

Causa probable: Es una decisión explícita en Assistant.arrive: «Un buscador nunca navega solo: muestra la lista». present() se llama siempre, y named() y ranked() sólo ordenan. El ejemplo «Llevame a La Nación» tiene un href fijo en starters, por eso escrito y tocado se comportan distinto. En una pregunta, carry(.buscar) guarda pendingQuestion pero igual presenta la lista y espera que la persona elija.

Propuesta: Abrir directo cuando la prueba es fuerte: named() encuentra el nombre exacto en el dominio, el dominio es del país (closer == 2) u oficial, y además es el primer resultado del buscador. Decir «Abro La Nación, lanacion.com.ar» y dejar «Otros resultados» como botón, que vuelve a la lista. Para preguntas de dato, abrir el primer resultado del país y contestar con la fuente en la misma frase («Según DolarInfoHoy, …»), con un botón «Ver otras fuentes». Mantener la lista cuando no hay coincidencia exacta del país: son los casos anses.fr y nacion.com que motivaron la regla. Sacar de la lista las páginas de ingreso (ingresar., login).

Escéptico: Confirmado. En los 9 escenarios el primer paso es «Estás en los resultados de …» con la lista, aunque el botón 1 era siempre el correcto (lanacion.com.ar, mercadolibre.com.ar, dolarinfohoy «Dólar Blue Hoy $1550», etc.). En primera-vez, el botón «Llevame a La Nación» abre directo («Abriendo lanacion.com.ar.»). otra-cosa ofrece «La Nacion — ingresar.lanacion.com.ar», y el anuncio «Official Site - BlackAmerican News&Information» figura en otra-cosa/paginas/01.txt. Es una decisión explícita del código (Assistant.swift:683, «Un buscador nunca navega solo: muestra la lista»).

### P06 · Pedir los titulares repite los ya dichos y no hay botón para los siguientes

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: noticias-la-nacion, solo-botones-clarin

Evidencia:
- La Nación, paso 3: «Titulares 1 a 3 de 144:», con los mismos tres del paso 2 (que había dado 4). Botones: 3 × Abrir, Volver y Otra cosa
- El 4.º titular («Renunció el secretario de Discapacidad…») desaparece del texto y de los botones
- Clarín: «Hay 126 notas. Las tres primeras:», sin «Más notas» ni «Seguir»

Causa probable: El atajo de ask() para «titulares» pone readingFrom = 0. arrived(), en el camino de orient, no registra que ya dijo 4 titulares. followUps sí agrega «Seguir con los titulares», pero closeTurn recorta a 3 opciones además de Volver (prefix(back == nil ? 4 : 3)), y los tres «Abrir» lo dejan afuera. Pasa lo mismo tras describe() en Clarín. El total sale de headlines(of:), que cuenta cualquier enlace con encabezado y cualquier ítem de 25 letras o más.

Propuesta: Al orientar una portada, dejar readingFrom en la cantidad de titulares dichos. «dame los titulares» sigue desde ahí («Titulares 5 a 7») o avisa «Empiezo de nuevo». Proteger del recorte a «Siguientes titulares», como ya se hace con Volver. Cambiar «de 144» por «hay muchos más».

Escéptico: Confirmado. En La Nación, paso 3, dice «Titulares 1 a 3 de 144:» con los mismos tres del paso 2 (que había dado cuatro), y el 4.º («Renunció el secretario de Discapacidad…») desaparece del texto y de los botones: 3×Abrir + Volver + Otra cosa. En Clarín: «Hay 126 notas. Las tres primeras:», también sin botón para seguir. closeTurn recorta con prefix(back == nil ? 4 : 3) (Assistant.swift:1972), y «Seguir con los titulares» se agrega recién en followUps, así que queda afuera.

### P07 · «Leeme la nota» en Wikipedia arranca con la cabecera, lee «[2 ]» y da un total falso

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: wikipedia-mar-del-plata

Evidencia:
- «Párrafos 1 a 2 de 6: ciudad de la provincia de Buenos Aires, Argentina / «Marplatense» redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).»
- «…«Puerto de la Laguna de los Padres». [2 ]»; «un 301  %», «siglo  XVIII»
- Verificador A: 02.txt tiene además 20 secciones plegadas (Historia, Geografía…) y «de 6» deja la Historia fuera de alcance
- Botones «Leer la nota · Resumir la nota» en un artículo de enciclopedia

Causa probable: readablePieces toma cualquier párrafo de 40 caracteres o más, así que entran la descripción corta y el aviso de redirección. extract.js no descarta .hatnote, .shortdescription ni sup.reference, y forEar sólo saca «,00». En la Wikipedia móvil las secciones están plegadas y ocultas, e isHidden las deja afuera: el total es sólo la introducción. arrived() y followUps rotulan «Leer la nota» en cualquier página que isArticle reconozca como nota.

Propuesta: En extract.js, descartar .hatnote, .shortdescription, .dablink y sup.reference. En readablePieces, sacar los «[n]» y normalizar los espacios, incluido el NBSP. En un artículo, empezar la lectura en el primer párrafo de 160 caracteres o más. Incluir las secciones plegadas, o decir «Introducción, párrafos 1 a 2 de 6» y ofrecer las secciones como botones. Usar «artículo» fuera de los diarios.

Escéptico: Pasa tal cual. La persona escribió «leeme la nota» y JEF respondió «Párrafos 1 a 2 de 6: ciudad de la provincia de Buenos Aires, Argentina / «Marplatense» redirige aquí…». Después lee «…Laguna de los Padres». [2 ]», «301  %» y «siglo  XVIII». En paginas/02.txt, Historia, Geografía, etc. aparecen sólo como títulos plegados (son 18, no 20), así que «de 6» cuenta únicamente la introducción. Los botones dicen «Leer la nota · Resumir la nota» en Wikipedia.

### P08 · Lo importante va en anuncios aparte, en cola, y se pierde; «Seguir leyendo» saltea lo que no sonó

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador A · escenarios: noticias-la-nacion, solo-botones-clarin, mercadolibre-auriculares, wikipedia-mar-del-plata

Evidencia:
- «3. Filtraciones, desconfianza y una denuncia judicial…» ⟶ DESCARTADO
- Clarín: titulares 2 y 3 DESCARTADOS. «El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía…» (título y bajada pegados)
- «Cuando elijas, sigo con: buscame auriculares bluetooth.» ⟶ DESCARTADO. En Mercado Libre, «Sigo con: …» y «Buscando auriculares bluetooth en mercadolibre.com.ar.» los descarta el aviso del captcha
- Clarín: el párrafo 2 queda DESCARTADO y «Seguir leyendo» da «Párrafos 3 a 4 de 10:»

Causa probable: readAloud, describe y present emiten un say() por pieza, y Voz los encola. heard() y askToSolve ponen interruptNext, que corta y descarta toda la cola. En ask(), «Cuando elijas, sigo con…» se dice después de present(), detrás de la lista larga. readingFrom avanza por lo que se emitió, no por lo que se escuchó. describe usa el título del listado de Clarín, que trae volanta y bajada separadas por coma, y lo corta con short(…, 140).

Propuesta: Un anuncio por turno, con el aviso de estado primero y la lista corta en el mismo texto («Elegí el sitio y sigo con los auriculares. 1… 2… 3…»). Leer de a un párrafo, o que «Seguir leyendo» retome desde el primer fragmento que Voz no terminó (Habla ya lleva la cuenta de lo pendiente). En los listados, quedarse sólo con el título: cortar antes de la bajada.

Escéptico: Es real sólo en parte: casi todos los DESCARTADO que se citan los provoca el script, que tocó a los 10-15 s cuando el audio en cola duraba 23-50 s. En La Nación tocó a +39.9 s y el titular 3 recién sonaba a ~44.9 s; en Clarín tocó a +37.5 s, justo cuando terminaba el titular 1; y tocó «Seguir leyendo» a los 9.8 s, cuando el párrafo 1 dura ~25 s. En cambio, es culpa de la app que en Mercado Libre el aviso del captcha (cola:false, +26.7 s) descarte sus propios «Sigo con: …» y «Buscando auriculares…», que «Cuando elijas, sigo con…» vaya detrás de una lista de ~18 s y que Clarín pegue título y bajada («…dos millones de personas, La Secretaría de Energía…»).

### P09 · En Mercado Libre, JEF le indica a la persona que busque y un segundo después busca solo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: mercadolibre-auriculares

Evidencia:
- «Estás en Mercado Libre Argentina, la página de inicio. Para buscar auriculares bluetooth, tenés un campo que dice "Ingresá lo que quieras encontrar".»
- Botones: [Abrir «Ingresá lo que quieras encontrar»] · [Abrir «Crear cuenta»] · [Abrir «Abrir app de Mercado Libre»]
- Un segundo después: «Sigo con: buscame auriculares bluetooth.» (DESCARTADO)
- Lucía: «No sé si la búsqueda se hizo ni en qué página estoy.»

Causa probable: accept() llama primero a landed(), que orienta con goal = el pedido entero, y recién después a continueWith(waiting). orient no sabe que el asistente va a seguir solo, así que describe el campo y propone botones de la portada.

Propuesta: Si hay una tarea esperando (waiting), saltear la orientación y decir una sola línea: «Estoy en Mercado Libre. Busco auriculares bluetooth.» Seguir sin mostrar los botones de la portada.

Escéptico: Pasa como se describe. A los +22.1 s JEF dice «Para buscar auriculares bluetooth, tenés un campo que dice "Ingresá lo que quieras encontrar"» y ofrece [Abrir «Ingresá…»] · [Abrir «Crear cuenta»] · [Abrir «Abrir app…»]. En ese mismo instante escribe «Sigo con: buscame auriculares bluetooth.» y a los +23.1 s «Buscando auriculares bluetooth en mercadolibre.com.ar.», las dos en cola y descartadas por el aviso del captcha. El script sólo eligió el resultado correcto: la búsqueda automática la hace la app.

### P10 · No distingue sitios oficiales en trámites y banca

*grave* · confirmado · jueces: Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: turno-anses, banco-nacion

Evidencia:
- «3. ANSES - Mi Anses, mianses.org». Verificador A: en 01.txt se describe como «Web dedicada a brindar ayuda si la necesitas con tus tramites…»
- «2. ANSES, servicioswww.anses.gob.ar»: en 01.txt es «Consulta para completar o iniciar estudios»
- Banco: «1. … digital.bna.com.ar. 2. … bna.com.ar. 3. … bnanet.bna.com.ar». La descripción del primero dice «Accedé a BNA Digital Empresas»
- Roberto: «Con el banco me da miedo meterme en una página falsa y no sé cuál es la buena.»

Causa probable: ranked() pone primero lo .gob.ar, pero completa los tres con cualquier otro dominio y no marca nada como oficial. El título del resultado se usa tal cual, aunque describa otra página. No hay noción del dominio propio de un organismo o de un banco.

Propuesta: En pedidos de trámites (cuando hay resultados .gob.ar), no poner dominios no oficiales entre los tres primeros, o avisarlo: «no es un sitio oficial». Decir «Es el sitio oficial» cuando el dominio es .gob.ar o es el dominio registrado de la entidad (bna.com.ar). Si la descripción dice «Empresas», mencionarlo.

Escéptico: En ANSES, el tercero ofrecido es «ANSES - Mi Anses, mianses.org», que en 01.txt es «Web dedicada a brindar ayuda…», y el segundo es servicioswww.anses.gob.ar, descripto como «Consulta para completar o iniciar estudios». Ninguno está marcado como oficial o no oficial, y el resultado oficial «Solicitar turnos en ANSES» (argentina.gob.ar) quedó afuera. En el banco los tres son subdominios de bna.com.ar, así que el problema ahí es sólo que no se dice «oficial» ni se aclara que el primero es «BNA Digital Empresas».

### P11 · Con baja visión, los botones quedan fuera de la vista después de casi cada respuesta

*grave* · confirmado · jueces: Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, primera-vez, clima-cordoba, otra-cosa, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- Verificador A: «En paso-05.jpg el resumen llena el panel y no se ve ningún botón»
- Verificador A (ANSES): «En paso-04.jpg es además el único botón visible»
- Verificador B (avanza-sola): «la conversación no se desplazó hasta la respuesta nueva. Arriba siguen «Abriendo localhost.» y el mensaje de la prueba anti-robot»
- Ana: «Veo el texto, pero no las opciones: tengo que adivinar que hay que deslizar.»

Causa probable: AssistantPanel desplaza al comienzo de la respuesta (scrollTo(start, anchor: .top)). Con la página arriba, la conversación tiene media pantalla, y una respuesta larga deja los botones abajo, sin ningún indicio. responseStart toma la línea que sigue al último turno de la persona. Cuando la respuesta nueva llega sola por pageChanged (avanza-sola), esa línea es vieja y queda a la vista lo anterior.

Propuesta: Fijar la primera opción, más un «Ver opciones ↓», sobre el campo de escribir, fuera del scroll. O, cuando settled, si la respuesta más el primer botón no entran, achicar la página de arriba. Calcular responseStart desde la primera línea de JEF nueva desde el último desplazamiento, no desde el último turno de la persona.

Escéptico: Las capturas lo confirman. En noticias-la-nacion/paso-05.jpg el resumen llena el panel y no se ve ningún botón. En turno-anses/paso-04.jpg el único botón visible es «Abrir «CONSULTAR TURNO»». En avanza-sola/paso-02.jpg arriba siguen «Abriendo localhost.» y el aviso del captcha, la respuesta nueva queda cortada y no hay botones a la vista. Pasa lo mismo en clima-cordoba/paso-02 (se ve sólo el primer botón) y en otra-cosa/paso-02 (ninguno). Es el desplazamiento de la app, no del script.

### P12 · Titulares parafraseados, con agregados, que no coinciden con los botones

*grave* · confirmado · jueces: Lucía, Marta, Roberto, Ana, Verificador B · escenarios: noticias-la-nacion, primera-vez, otra-cosa

Evidencia:
- Dicho: «Filtraciones y desconfianza en la Quinta de Olivos sobre la salida de una ladera de Karina.» Botón: «Abrir «Filtraciones, desconfianza y una denuncia judicial: la trastienda de…»»
- otra-cosa: «2. Una jueza declaró inconstitucional la ley que baja la punibilidad a 14 años y sobreseyó un caso.» («un caso» no está en la página)
- otra-cosa: «3. … colaboradora de Karina Milei, que generó una denuncia judicial.» (la relación de causa no está en el título)
- primera-vez: «Adorni explicó sobre bitcoins en negro y vivir como si el dinero no existiera.»
- Ana: una vez en párrafo corrido, otra en lista numerada

Causa probable: arrived() le pasa al modelo los titulares literales, pero el prompt de orient pide «cada uno en una frase corta con el HECHO», así que el modelo reescribe. Los botones usan short(dekick(title)), cortado a 70 caracteres con «…». La volanta («Quinta de Olivos.») se saca del botón, pero el modelo la usa en lo que dice.

Propuesta: En una portada, armar la frase en código: «Portada de La Nación. 1. … 2. …», con el título literal sin volanta, en una lista numerada. Los botones, con el mismo texto numerado («Abrir 1: Bitcoins en negro…»), cortados en un «:» o en una frase completa y no a los 70 caracteres. El modelo no redacta titulares.

Escéptico: Los títulos literales de paginas/02.txt son «Quinta de Olivos. Filtraciones, desconfianza y una denuncia judicial: la trastienda de la salida de una ladera de Karina» y «…la punibilidad a 14 años y sobreseyó». JEF dice «Filtraciones y desconfianza en la Quinta de Olivos sobre la salida de una ladera de Karina», agrega «sobreseyó un caso» y «que generó una denuncia judicial». Los botones van cortados («…la ley que bajó la…»). En noticias-la-nacion los titulares salen en párrafo corrido y en otra-cosa en lista numerada.

### P13 · El resumen es largo, trae cifras con centavos y tuerce los hechos

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador A · escenarios: noticias-la-nacion

Evidencia:
- «…La versión presenta baches y movimientos llamativos, como la venta de 296.785,46 dólares en efectivo a un desconocido el 5 de agosto de 2017.» Unos 35 s de voz
- Verificador A: en 03.txt es «un desconocido le pagó casi 300.000 “dólares billete”» a Adorni; la frase de JEF lo da vuelta
- «invirtió 200.000 dólares con su mujer y ganaron otros 300.000 …, acumulando un total de 565.000»: las cifras no suman

Causa probable: summarize() pide «dos o tres frases, con los hechos concretos: qué pasó, quién, cuándo, las cifras», y la verificación de cifras exige copia literal, lo que empuja a «296.785,46». La verificación comprueba que el número exista, no que la frase lo use bien.

Propuesta: Pedir dos oraciones cortas (40 palabras como máximo), con la idea central primero y las cifras redondeadas («casi 300.000 dólares»). Verificar que el número redondeado corresponda a uno de la página, con tolerancia, en lugar de exigir la copia literal. Agregar esta nota como caso de prueba por la inversión de quién compra y quién vende.

Escéptico: En noticias-la-nacion, paso 5, el resumen tiene 3 oraciones, 81 palabras y 509 caracteres (unos 36 s de voz), e incluye «296.785,46 dólares». La nota (paginas/03.txt) dice que Adorni vendió bitcoins y que «un desconocido le pagó casi 300.000 “dólares billete”»; JEF dice «la venta de 296.785,46 dólares en efectivo a un desconocido», o sea que el dinero va al revés. Matiz: 200.000, 300.000 y 565.000 figuran tal cual en la nota; el error es de JEF, que las encadena con «acumulando un total de», como si fueran una suma. Que la voz se cortara al 23% se debe al «volvé» que el script escribió 8 s después, pero el problema no depende de ese corte.

### P14 · Botones sacados de la página que no sirven: controles del sitio, epígrafes, notas ajenas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, mercadolibre-auriculares, clima-cordoba, turno-anses

Evidencia:
- «Abrir «Guardar nota»»
- «Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»» en la nota del apagón (según el Verificador A viene del pie de página)
- «Abrir «Desde arriba hacia abajo, y de izquierda a derecha: Vista de la Playa…»» (epígrafe del collage)
- «Abrir «Crear cuenta»», «Abrir «Abrir app de Mercado Libre»», «Abrir «Ingresá lo que quieras encontrar»» (un campo)
- «Completar «Selecionar localidad»»
- «Abrir «Obtener Certificación Negativa de ANSES»»

Causa probable: Assistant.candidates filtra sólo pagar, suscribirse, descargar y app store, más las zonas header, nav y footer. No filtra los controles del sitio (guardar, compartir, escuchar, crear cuenta, ingresar, abrir app), los epígrafes ni los enlaces a imágenes. En una nota, arrived() conserva una sugerencia «sug-» del modelo sin mirar si tiene que ver con la nota. Toda sugerencia de abrir se rotula «Abrir «…»», aunque sea un campo. formOptions ofrece cualquier formulario que no sea de búsqueda (el selector de localidad), aunque lo pedido ya esté contestado.

Propuesta: Ampliar el filtro de useful(): guardar, compartir, escuchar, crear cuenta, ingres, iniciar sesi, abrir app, notificaciones. Excluir los enlaces a archivos de imagen y los textos que vienen de un figcaption. En una nota, la tercera opción sólo si comparte raíces con la nota; si no, «Siguiente titular». Un campo nunca se rotula «Abrir»: «Buscar en Mercado Libre» o «Completar «…»». Cambiar el selector de localidad por «Ver otra ciudad» y ponerlo después de las preguntas.

Escéptico: Todo aparece tal como se describe: «Abrir «Guardar nota»» (La Nación, paso 4); «Abrir «Clave Única PAMI…»», que en 04.txt está después de «Más juegos», en la lista final de notas ajenas; el epígrafe «Desde arriba hacia abajo…» (Wikipedia, paso 2); «Abrir «Ingresá lo que quieras encontrar»», que es un FORMULARIO, junto con «Crear cuenta» y «Abrir app de Mercado Libre»; y «Completar «Selecionar localidad»» (clima). El caso de ANSES es el más débil: la opción sale de «Trámites relacionados» y está en tercer lugar, detrás de «Pedir turno». Son opciones que ofrece la app, no el script.

### P15 · Las preguntas sugeridas ya se contestaron y falta el paso siguiente

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: wikipedia-mar-del-plata, clima-cordoba, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «Mar del Plata fue fundada el 10 de febrero de 1874 por Patricio Peralta Ramos.» → [¿Quién la fundó?] primero
- «No hay probabilidad de lluvia…» → [¿Lloverá mañana en Córdoba?]. En el paso 3: [¿Qué clima hará mañana?] · [¿A qué hora amanece?]
- Después de listar los tres modelos con precio: [¿Y el más caro?] · [¿Cuáles son los otros?], y [Leer la página] · [Resumir la página]
- Roberto: «Después de oír los auriculares no tengo cómo abrir uno ni cómo volver.»

Causa probable: Answerer.instructions pide «preguntas que ESTA página contesta», sin pasarle la respuesta recién dada y sin prohibir que repita. followUps considera «resumida» la página sólo si lastDone == summaryID, así que una orientación que ya resumió no cuenta. No hay sugerencias de acción sobre un elemento mencionado, como abrir el más barato.

Propuesta: Pasarle al modelo la respuesta que acaba de dar, con la regla: «no propongas lo ya contestado; proponé el paso siguiente». Además, filtrar en código las preguntas cuyas raíces ya están en esa respuesta (stems). Después de una orientación que listó elementos o cifras, no ofrecer «Resumir». Ofrecer «Abrir el más barato (12.499)», «¿Y pasado mañana?» o «Volver».

Escéptico: Wikipedia, paso 3: responde «fundada… por Patricio Peralta Ramos» y ofrece primero [¿Quién la fundó?]. Clima: después de «No hay probabilidad de lluvia» ofrece [¿Lloverá mañana en Córdoba?], y en el paso 3 [¿Qué clima hará mañana?] y [¿A qué hora amanece?], dos cosas ya dichas. Anti-robot: después de listar los tres modelos con precio ofrece [Resumir la página], y más tarde [¿Y el más caro?] y [¿Cuáles son los otros?]. En ningún momento ofrece abrir un modelo. Las preguntas las escribió el script, pero las sugerencias son de la app.

### P16 · Lo que se ve arriba no coincide con lo que dice: avisos que tapan la página, pie de página en vez de la nota

*grave* · confirmado · jueces: Ana, Verificador A · escenarios: solo-botones-clarin, dolar-desde-cero, mercadolibre-auriculares

Evidencia:
- Clarín, paso 2: un cartel «Acceder a Clarin.com con Google — Continuar» tapa la portada y JEF no lo menciona
- Clarín, pasos 3 a 5: se ve el pie («Seguinos en Google», «Términos y Condiciones») mientras dice «Estás en Clarín, en una nota sobre el apagón masivo.»
- DolarInfoHoy: el cartel «Este sitio utiliza cookies — Aceptar / Rechazar» tapa la mitad de la página y no se menciona
- Mercado Libre: el cartel de cookies tapa en parte la casilla «No soy un robot»

Causa probable: extract.js (wakeLazyContent) baja hasta el final para despertar el contenido perezoso y después vuelve arriba. ReaderModel.go llama a scrollToTop una sola vez, y en Clarín la página igual quedó en el pie, el mismo síntoma que ya anota el comentario de scrollToTop. Probablemente el sitio agrega o reubica contenido después, y las re-extracciones tardías no vuelven a subir. El cartel de Google (One Tap) no lo detecta detectOverlay. Cuando la respuesta sale por reply() (pendingQuestion), page.overlay no se mira.

Propuesta: Llamar a scrollToTop, o hacer scrollIntoView del h1, después de cada extracción y al abrir una nota. Reconocer el One Tap de Google como aviso de inicio de sesión. Si hay un aviso de cookies o de ingreso, decirlo en media frase y ofrecer el botón «Cerrar el aviso», con las opciones que ya trae overlay.choices, sin decidir por la persona.

Escéptico: En las capturas: Clarín paso-02.jpg muestra «Acceder a Clarin.com con Google — Continuar»; los pasos 03 a 05 muestran «Seguinos en Google» y «Términos y Condiciones» mientras JEF habla de la nota; dolar paso-02.jpg muestra el cartel de cookies tapando la mitad de la página. Ninguna transcripción menciona un aviso. Una parte es falsa: en mercadolibre paso-02/03.jpg el cartel de cookies queda debajo de «Continuar» y la casilla «No soy un robot» se ve entera.

### P17 · La bienvenida y «¿dónde estoy?»: frase sin verbo, tono impersonal, sin gestos, y «JEF» contra «Asistente»

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: primera-vez, anti-robot-ya-la-resolvi

Evidencia:
- «Para empezar, un sitio o algo para buscar; o una de estas opciones.»
- «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- Ana: el título de la conversación dice «Asistente», pero habla de «JEF»
- «Te muestro los tres modelos disponibles…», dicho a una persona ciega

Causa probable: Son textos fijos en carry(.orientar) y en el encabezado de AssistantPanel («Asistente»). La orientación usa page.sectionTitle, el título técnico de la página. En ningún momento se explican los gestos, ni se ofrece ayuda o volver al inicio.

Propuesta: Bienvenida: «Decime un sitio o qué buscar, escribiendo o dictando en el campo de abajo, o tocá una opción.» Para «no entiendo»: «Estás en la portada del diario La Nación. Arriba está la página; abajo hablás conmigo. Para oír las opciones deslizá a la derecha; para elegir, tocá dos veces.», con un botón «Ayuda» o «Volver al inicio». Encabezado «JEF». Evitar «te muestro».

Escéptico: Las frases están literales. En primera-vez: «Para empezar, un sitio o algo para buscar; o una de estas opciones.» (no tiene verbo) y «…la conversación con JEF: se le pide algo escribiendo, o se toca una opción.» (impersonal, usa el título técnico de la página y no explica gestos). El encabezado visible dice «Asistente». En anti-robot-ya-la-resolvi aparece «Te muestro los tres modelos…». Lo de «te muestro» es el punto más discutible, porque es un giro habitual. El corte de la bienvenida al 65% se debe a que el script tocó 7 s después, pero no forma parte de este problema.

### P18 · Si la prueba se resuelve sin cambiar de página, JEF no se entera

*menor* · confirmado · jueces: Marta, Lucía, Ana, Verificador B · escenarios: anti-robot-ya-la-resolvi

Evidencia:
- Paso 2: 15 s sin ningún anuncio, con paso-02.jpg mostrando ya la lista de auriculares
- Sólo siguió cuando la persona tocó «Ya la resolví» (+35,9 s). En avanza-sola, donde la página navegó, siguió solo
- Ana: «arriba ya estaban los auriculares y abajo el asistente seguía pidiendo la prueba»

Causa probable: Assistant.pageChanged depende de que el motor entregue una página nueva: una navegación o el observador de cambios tardíos de extract.js (watchLateChanges: 20 nodos o más, ventana de 90 s, 6 rondas). El cambio dentro de la misma dirección no cruzó ese umbral, o no se tomó como página distinta, y sólo «Ya la resolví» fuerza reread().

Propuesta: Mientras haya una prueba pendiente (challenge != nil), vigilar específicamente que desaparezca el iframe o el texto de la prueba, o hacer reread() cada 2 s, y seguir solo. En el aviso, decir: «Cuando termines sigo solo; si no, tocá Ya la resolví».

Escéptico: En anti-robot-ya-la-resolvi el paso 2 no tiene ningún anuncio, y paso-02.jpg ya muestra la lista de auriculares debajo de «Cuando esté resuelta, continuamos.». registro.jsonl no tiene eventos entre la carga (t≈…205) y «Ya la resolví» (t≈…232). La página de prueba es sintética (fixtures/anti-robot/misma-pagina.html cambia el innerHTML a los 12 s sin cambiar la dirección) y el escenario ya contaba con que se tocara «Ya la resolví», que funcionó; pero la app no detectó el cambio y su propio aviso promete seguir sola.

### P19 · El lugar se anuncia con el título técnico, y cada vez distinto

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: solo-botones-clarin, dolar-desde-cero, clima-cordoba, noticias-la-nacion, primera-vez

Evidencia:
- «En Noticias de Argentina — Clarin.com.»
- «En DolarInfoHoy.» y «En eltiempoen.com.», como anuncios sueltos antes del dato
- «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.»
- Contra «Estás en la portada de La Nación.» en la llegada

Causa probable: Hay cinco caminos distintos. orient lo redacta el modelo. describe dice «En \(sectionTitle) — \(displaySite).». goBack dice «De vuelta en «sectionTitle»». .orientar dice «Estás en «sectionTitle»». accept, con pendingQuestion, dice «En \(displaySite).». Clarín cayó a describe porque orient devolvió nil (falló o no pasó la verificación de cifras); no queda registrado por qué.

Propuesta: Una sola función placeName(page): «la portada de X» si readsHeadlines, «una nota de X» si isArticle, «X» si no. Usarla en describe, goBack y .orientar. En las respuestas de dato, poner la fuente dentro de la frase («Según DolarInfoHoy, …»). Registrar el motivo cuando orient devuelve nil.

Escéptico: Está en las transcripciones. Clarín paso 2 dice «En Noticias de Argentina — Clarin.com.». En dólar y clima, «En DolarInfoHoy.» (+19.1s) y «En eltiempoen.com.» (+18.9s) suenan sueltos antes del dato. En La Nación sale «Estás en la portada de La Nación.», pero al volver dice «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.». En primera-vez, la misma portada es primero «Estás en la portada de LA NACION.» y después «Estás en «Últimas noticias de Argentina y el mundo», LA NACION.». Son frases de la app, no del script.

### P20 · El campo de escribir y «Otra cosa»: la pista no cambia, los botones desaparecen y el eco del DNI suena a viñetas

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: otra-cosa, banco-nacion, primera-vez

Evidencia:
- «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» y ningún botón en el árbol
- «Pedido  = Escribir: DNI  (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)»
- «Vos: •••••456» (VoiceOver dice «viñeta» cinco veces). «Listo, escrito en DNI.» no confirma cuál
- «[grp] Barra de herramientas», una barra con flechas y una tilde que aparece después de escribir el DNI
- Ana: el texto de la caja «¿Qué querés hacer?» se ve gris claro sobre gris

Causa probable: accept(otherID) dice un texto fijo y retorna antes de closeTurn, así que no quedan botones. En AssistantPanel, accessibilityLabel («Pedido») y accessibilityHint son fijos: sólo cambia el texto de ayuda visible. masked() usa «•». Después de reader.fill, el foco del WKWebView queda en el campo del banco y aparece la barra de formulario del sitio. El texto de ayuda usa .secondary sobre tertiarySystemFill.

Propuesta: Después de «Otra cosa», decir sólo «¿Qué hacemos?», explicar el dictado una sola vez y dejar un botón «Volver a las opciones». Mientras espera un dato: etiqueta = nombre del campo, y pista «Va directo al campo de la página; no lo guardo». Eco accesible «Vos: DNI terminado en 456», y confirmar «Listo, puse el DNI que termina en 456». Sacar el foco del campo de la página después de escribir (blur). Oscurecer el texto de ayuda.

Escéptico: En otra-cosa paso 3, después de «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» el árbol sólo tiene el campo y Enviar: no queda ningún botón. En banco-nacion paso 3 el campo dice «Pedido = Escribir: DNI» con la misma pista «Escribí a dónde querés ir…». En el paso 4 aparecen el eco «Vos: •••••456» y «Listo, escrito en DNI.», y el árbol suma «[grp] Barra de herramientas»: la captura paso-04.jpg muestra la barra ∧ ∨ ✓. Las capturas también muestran «¿Qué querés hacer?» en gris claro sobre gris. Que VoiceOver diga «viñeta» cinco veces es una deducción, porque el simulador no corre VoiceOver, pero el eco con «•» es real.

### P21 · Cotizaciones con formato cambiante, sin decir qué dólar oficial es y con siglas

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero

Evidencia:
- «El dólar blue hoy se vende a $1.550,00 y se compra a $1.530,00.»
- «El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. La última actualización fue el 21 de septiembre a las 11:03 hs.»
- Botones «¿Y el MEP?» y «¿Y el CCL?»

Causa probable: El texto lo redacta el modelo, sin una pauta para cotizaciones. La verificación exige las cifras literales, con centavos, y forEar sólo quita «,00». Las preguntas sugeridas las escribe el modelo con las siglas del sitio.

Propuesta: Pauta fija para cotizaciones: compra y venta en ese orden, sin centavos, qué cotización es (Banco Nación, promedio, mayorista) y la hora cuando está. Poner la fuente en la misma frase. En los botones, escribir las siglas completas: «¿Y el dólar MEP (de la bolsa)?», «¿Y el contado con liquidación?».

Escéptico: En dolar-desde-cero, el blue sale como «se vende a $1.550,00 y se compra a $1.530,00»: venta primero y sin hora, aunque la página dice «Última actualización 21/9 15:00 hs». El oficial sale como «$1.482,52 para la compra y $1.534,23 para la venta… a las 11:03 hs»: compra primero y con hora. Los botones dicen «¿Y el MEP?» y «¿Y el CCL?». Un matiz: la página sólo dice «Dólar Oficial» y no aclara si es Banco Nación o promedio, así que esa parte depende de la fuente.

### P22 · Etiquetas de resultados y ecos largos, crudos y como encabezados

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, banco-nacion, clima-cordoba, otra-cosa, turno-anses

Evidencia:
- Encabezado del rotor: «Vos: Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar»
- «Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com» (el dominio dos veces y el «|»)
- «2. ANSES, servicioswww.anses.gob.ar» dicho de corrido
- «Ver más opciones (1)»
- La persona escribió «clarín» y JEF muestra «Buscando: clarin.»

Causa probable: present() arma el botón con el título crudo más el host con www. heard(action.label) guarda la etiqueta entera como turno de la persona, con rasgo de encabezado. «Ver más opciones (n)» aparece aunque quede uno solo. El texto que se muestra es el target del ruteador, sin tildes.

Propuesta: En el botón, el título limpio (sin «|» ni el dominio repetido) y el dominio sin www. El eco, abreviado: «Vos: abrir La Nación». Si queda un solo resultado, mostrarlo directo; si quedan más, «Ver 2 opciones más». Mostrar lo que se busca con las palabras de la persona.

Escéptico: Está en los árboles: «[H] Vos: Últimas noticias de Argentina y el mundo - LA NACION — www.lanacion.com.ar» aparece como encabezado, y el botón «Clima mañana en Córdoba | Hora a hora - eltiempoen.com — eltiempoen.com» repite el dominio. En turno-anses se escucha «2. ANSES, servicioswww.anses.gob.ar» (ese es el subdominio real, pero se dice pegado). La Nación muestra «Ver más opciones (1)». En Clarín, la persona escribe «clarín» y JEF responde «Buscando: clarin.»; lo mismo pasa con «la nación», que queda en «la nacion». Que el script tocara la primera opción sólo eligió cuál etiqueta se repite: cualquier toque la repetiría igual.

## Lo que funciona

- El orden de los resultados: el primer botón fue siempre el sitio correcto (lanacion.com.ar, clarin.com, dolarinfohoy, es.wikipedia, argentina.gob.ar, mercadolibre.com.ar, digital.bna.com.ar, eltiempoen.com). Se descartan los anuncios patrocinados y la Córdoba de España (Meteored España).
- En la portada de La Nación (cuando orient funciona): «Estás en la portada de La Nación» con los 4 primeros titulares, y un botón «Abrir» por cada uno, en el mismo orden (verificado contra 02.txt).
- Al abrir una nota: «Estás en la nota de LA NACION sobre…» o «Estás en Clarín, en una nota sobre el apagón masivo», con «Leer la nota» y «Resumir la nota» como primeros botones.
- La lectura es textual, con la posición adelante («Párrafos 1 a 2 de 10»), y «Seguir leyendo» siempre queda primero.
- Las preguntas sobre la página abierta se contestan sin moverse y rápido: «¿y el oficial?» en 2 s sin repetir el contexto; «¿cuándo se fundó?» exacto en 1,6 s; «No va a llover, … 0%» con la respuesta primero; «cuesta 12.499 pesos».
- No inventa: frente al captcha dijo que no veía los productos, y ante «deportes» no fingió haber llegado.
- «volvé» vuelve en menos de un segundo y dice adónde.
- Banco: «Te pide tu DNI y tu usuario para ingresar», «Completar «DNI»» primero y «va directo a ese campo de la página». El DNI queda tapado en la conversación y completo en la página, no se dice en voz alta, sigue «Completar «Usuario»» y JEF nunca envía el formulario.
- Anti-robot: cuando la página navega después de resolverla, sigue solo con «Listo, ya pasamos la verificación.» y retoma la tarea. «Ya la resolví» responde en medio segundo.
- Recuerda un pedido compuesto: la búsqueda de auriculares en Mercado Libre sí se hizo sola (go_url a listado/auriculares-bluetooth).
- El ejemplo de inicio «Llevame a La Nación» va directo, y los tres ejemplos de inicio son concretos.
- «Arriba está la página; acá abajo, la conversación» explica cómo está armada la pantalla.
- «Otra cosa» deja el cursor en el campo con el teclado abierto.
- En ANSES dice dónde está en cada página, y «Turnos» y «Pedir turno» fueron los primeros botones.
- «¿Y el dólar oficial?» como primer botón anticipó lo que se iba a pedir, y dice la hora de actualización.
- En otra-cosa, los titulares en lista numerada, uno por renglón, se leen mucho mejor con baja visión.
- La pista «Primera de N opciones» en el primer botón.
- Todo en castellano, y toda respuesta termina con «Otra cosa».
