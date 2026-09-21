# Veredicto — ronda-9

Ronda 9: 12 escenarios, 4 jueces, 48 juicios. 35 «sí», 9 «a medias» y 4 «no». Los cuatro «no» son de mercadolibre-auriculares. Los «a medias» vienen de turno-anses (los 4 jueces), clima-cordoba (3), wikipedia (1) y primera-vez (1). Mejores: banco-nacion (4,3), anti-robot-avanza-sola (4,35) y dolar-desde-cero (4,1). Peores: mercadolibre (2,65), clima (3,05) y wikipedia (3,15).

Cuatro problemas impiden cumplir el objetivo:
- Frente a una prueba anti-robot, JEF no ofrece otra salida.
- En ANSES muestra sólo 4 trámites, sin «ver más».
- El clima sale en °F y mph.
- Casi todo pedido de un sitio conocido o de un dato pasa por una lista del buscador (9 escenarios), aunque el botón «Llevame a La Nación» va directo.

Dos problemas atraviesan varios escenarios:
- La lectura sale rota: cortes a mitad de palabra, conteos que no cuadran, basura de Wikipedia, de a 2 párrafos, y «Seguir leyendo» retoma desde lo escrito, no desde lo oído.
- Los titulares de portada los reescribe un modelo (Answerer.orient). Eso contradice el principio de Assistant.swift de que ninguna palabra la redacta un modelo.

Para Ana (baja visión) lo central es otro: los botones quedan escondidos debajo del texto, y la página de arriba no muestra lo que se habla.

Descartado por ser del script:
- El corte de la bienvenida (primera-vez, +14,3 s).
- El corte del resumen al 47 % (noticias).
- El corte del primer aviso en anti-robot-ya-la-resolvi.

Matizado:
- «Ladera» y «discapacitados» son textuales de La Nación.
- «Dos millones de personas» contra «600.000 usuarios» son el título y el cuerpo de la nota de Clarín.
- «localhost» sale del fixture.
- Lo que dicen los jueces del cursor que queda en la frase no coincide con el código. placeFocus lo lleva a la primera opción, o al campo después de «Otra cosa». Hay que confirmarlo en un dispositivo con VoiceOver.
- Los °F pueden depender de la IP o del idioma de la máquina de prueba. Igual es un problema del producto, porque JEF no normaliza las unidades.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.1 |
| wikipedia-mar-del-plata | Marta a medias, Roberto sí, Lucía sí, Ana sí | 3.1 |
| turno-anses | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.4 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.6 |
| banco-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.3 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.5 |
| clima-cordoba | Marta a medias, Roberto sí, Lucía a medias, Ana a medias | 3.0 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.3 |
| anti-robot-ya-la-resolvi | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |

**Promedio general: 3.57**

## Problemas

### P01 · Ante una prueba anti-robot no hay otra salida, y no queda claro quién la resuelve

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- mercadolibre paso 3: «La página actual es de seguridad, así que no te puedo dar información sobre los precios de los auriculares bluetooth.» Botones: [Ir a la prueba] · [Ya la resolví] · [Volver a la página anterior] · [Otra cosa]
- «El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba: «Ir a la prueba» lleva hasta ella. Cuando esté resuelta, continuamos.»
- Roberto (bloqueante): «No entiendo si la prueba la tengo que resolver yo o el asistente («me pide»). Yo solo no la puedo resolver, y no me ofrece otra salida»
- Los 4 jueces: logro «no» en mercadolibre-auriculares.

Causa probable: - El texto está fijo en askToSolve (Assistant.swift:1106-1123). Dice «me pide» y «Cuando esté resuelta» sin decir quién la resuelve.
- followUps, cuando hay prueba (Assistant.swift:2029-2034), sólo ofrece Ir a la prueba, Ya la resolví y Volver. No hay «Buscar en otro sitio».
- Una pregunta con la prueba activa va igual al modelo (reply o answer sobre la página de seguridad). El modelo contesta con jerga («la página actual es de seguridad») en lugar de una plantilla que recuerde la prueba y lo que queda pendiente.

Propuesta: - Un solo aviso armado en código: «Mercado Libre pide una prueba anti-robot que tenés que resolver vos; tiene opción de audio. Tocá «Ir a la prueba». Cuando la resuelvas, sigo solo con la búsqueda de auriculares bluetooth.»
- Con la prueba pendiente, sumar «Buscar en otro sitio» (arrive con la tarea pendiente, sin el dominio) y mantener Volver.
- Si challenge no es nil y llega una pregunta, no llamar al modelo. Contestar por plantilla: «Todavía está la prueba anti-robot; cuando se resuelva te digo el más barato.»

Escéptico: Se confirma en mercadolibre-auriculares paso 2-3. El aviso dice «El sitio web me pide resolver una prueba anti-robot… Cuando esté resuelta, continuamos», sin decir quién la resuelve (texto fijo en askToSolve, Assistant.swift:1117). Ante «¿cuánto sale el más barato?» el modelo contesta «La página actual es de seguridad, así que no te puedo dar información…». Los botones son sólo [Ir a la prueba] · [Ya la resolví] · [Volver a la página anterior] · [Otra cosa] (followUps, Assistant.swift:2029-2033), sin ninguna alternativa del tipo «buscar en otro sitio». Dos matices: «no hay otra salida» exagera, porque Volver y Otra cosa existen. Y el «bloqueante» pesa menos de lo que dice: el script nunca intentó resolver la prueba, y en anti-robot-avanza-sola y anti-robot-ya-la-resolvi el flujo sigue solo («Listo, ya pasamos la verificación» y después los precios).

### P02 · ANSES: la lista de trámites trae 4 opciones sin «ver más», no pregunta cuál y no adelanta requisitos

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: turno-anses

Evidencia:
- «Podés sacar un turno para trámites como el Plan de Pago de Deuda Previsional, Solicitud de Jubilación o de Pensión, y Pensión no Contributiva por Invalidez Laboral. Para sacar un turno, tocá en el tipo de trámite que necesitas.»
- Botones: [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…»] · [Abrir «Solicitud de Jubilación, ver sub-trámites»] · [Abrir «Solicitud de Pensión, ver sub-trámites»] · [Abrir «Pensión no Contributiva por Invalidez Laboral, ver sub-trámites»] · [Volver…] · [Otra cosa]
- Verificador 1: paginas/04.txt lista 18 trámites (Jubilados y Pensionados, AUH, PUAM, Desempleo…) y un buscador «Buscar turno». Ninguno de los dos se ofrece.
- Paso 3: «La página te explica cómo pedir un turno por internet para trámites en ANSES.» No dice nada de CUIL ni de clave.

Causa probable: - Las opciones salen de Answerer.orient. El prompt pide «entre 2 y 4 opciones» y el código recorta con suggestions.prefix(4) (Answerer.swift:248-250, 296).
- closeTurn sólo tiene «Ver más» para resultados del buscador (moreID), no para opciones de una página.
- El orden lo pone el modelo copiando la página, así que Plan de Pago queda primero.
- short() corta a 70 caracteres (Assistant.swift:976-985) y no limpia «, ver sub-trámites».
- El prompt de orient no pide contar requisitos.

Propuesta: - Cuando la página es una lista de opciones parecidas y la persona vino a algo, preguntar «¿Para qué trámite es el turno?» con las 3 o 4 más comunes para quien pregunta, más «Ver más trámites (14)» (con el mismo mecanismo pending/moreID) y «Completar «Buscar turno»».
- Limpiar sufijos como «ver sub-trámites» y no cortar las etiquetas.
- En páginas de trámite, pedirle a orient una frase con lo que la página exige: «Vas a necesitar tu CUIL y la Clave de la Seguridad Social».

Escéptico: En turno-anses/paginas/04.txt hay 18 trámites y el campo «Buscar turno». JEF ofrece sólo los 4 primeros en el orden de la página, [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…»] y tres «…, ver sub-trámites», sin «ver más» ni Completar «Buscar turno». Viene del prompt de orient («entre 2 y 4 opciones») y de suggestions.prefix(4). En el paso 3 dijo sólo «La página te explica cómo pedir un turno por internet», sin el «¿Qué necesito?» de 03.txt («un dispositivo con internet», «datos personales acreditados»). Matiz: en esa página CUIL y Clave aparecen sólo para cancelar el turno, no para pedirlo.

### P03 · El clima llega en grados Fahrenheit y millas por hora, sin aviso

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: clima-cordoba

Evidencia:
- «Mañana en Córdoba la temperatura máxima va a ser de 63º y la mínima de 40º. […] El viento soplará del NE a 13 mph.»
- Verificador 2: paginas/02.txt dice «Viento NE 13 mph», «Lluvias 0 in», «Visibilidad, 6 mi». Son unos 17 °C y 4 °C.
- Ana: «¿63 grados en Córdoba? … Pensé que estaba todo mal y no le creí.»

Causa probable: - La página se sirvió en unidades de EE. UU. Es el mismo síntoma que DuckDuckGo con la interfaz en inglés («Search», «Next Page >», en todos los escenarios). El arreglo de la ronda 7 (developmentLanguage: es en project.yml) no alcanzó, o el sitio elige unidades por la IP de la máquina de prueba.
- Además, el Answerer no normaliza. Su prompt pide decir la unidad «tal como está en la página» (Answerer.swift:85-86), y el modelo igual la omitió.
- La verificación de «cifras» (Answerer.swift:173-174) exige que cada número esté literal en la página. Una conversión a °C quedaría descartada.

Propuesta: - Convertir en código: si el texto trae °F, mph, in o mi, pasarlo a °C, km/h, mm y km antes de mandarlo al modelo, y aceptar esas cifras convertidas en la verificación.
- Decir los puntos cardinales en palabras (NE → noreste).
- Mandar Accept-Language es-AR explícito en las cargas del WebView. Comprobarlo con DuckDuckGo, que tiene que salir en castellano.

Escéptico: clima-cordoba/paginas/02.txt trae «63º 40º», «Viento NE 13 mph», «Lluvias 0 in» y «Visibilidad, 6 mi». JEF dice «máxima… de 63º y la mínima de 40º… a 13 mph», sin grados F ni conversión. La página ni siquiera escribe «F», así que la verificación de cifras y el prompt («tal como está en la página») no alcanzan. No es del script: el HTML que el WebView de la app guardó en caché trae server-side `var units = "f"` con «13 mph» (data-value 21 km/h). Pedidos por curl desde la misma máquina salieron a veces «c» y a veces «f»: el sitio elige las unidades del lado del servidor, en forma variable. Le puede pasar a cualquier usuario.

### P04 · Pedir un sitio conocido o un dato pasa por la lista del buscador, y el botón de inicio no

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, clima-cordoba, otra-cosa

Evidencia:
- «Buscando: la nación.» / «Estás en los resultados de «la nación». Los 3 más probables: 1. Últimas noticias de Argentina y el mundo - LA NACION, lanacion.com.ar. 2. LN+ EN VIVO | …, youtube.com. 3. Kiosco LA NACION, …»
- «Estás en los resultados de «dólar blue hoy». Los 3 más probables: 1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar…»: el dato ya estaba en el primer título.
- primera-vez: [Llevame a La Nación] da «Abriendo lanacion.com.ar.» directo, sin lista.
- Marta: «la misma frase hace dos cosas distintas según si la escribo o la toco.»

Causa probable: - Es una decisión explícita en Assistant.arrive (Assistant.swift:676-692): «Un buscador nunca navega solo: muestra la lista». Se tomó después de errores con anses.fr y La Nación de Costa Rica.
- El botón de inicio tiene la dirección fija (Assistant.swift:158-161). Por eso el mismo pedido se comporta distinto escrito que tocado.
- Las preguntas (pendingQuestion) también esperan a que la persona elija.
- present() lee de cada resultado el título SEO, recortado a 60 caracteres, más el dominio (Assistant.swift:747-750).

Propuesta: - Abrir directo cuando la certeza se puede comprobar: (a) una tabla corta de sitios del país con su dominio oficial (La Nación, Clarín, Mercado Libre, Banco Nación, ANSES, Wikipedia), igual que el botón de inicio; (b) si no, el resultado cuyo dominio coincide exacto con el nombre pedido y es del país (named() ya lo calcula).
- Decir: «Abriendo La Nación, lanacion.com.ar. Si no era, tocá Volver», con un botón «Ver otros resultados».
- Para preguntas de dato, abrir el primer resultado que no sea publicidad y contestar citando la fuente.
- Cuando sí haya lista, leer sólo el nombre del sitio.

Escéptico: En noticias-la-nacion, «llevame a la nación» escrito da «Buscando: la nación.» y una lista de 3. En primera-vez, el botón [Llevame a La Nación] da «Abriendo lanacion.com.ar.» directo, porque tiene href fijo (Assistant.swift:158-161). En dolar-desde-cero, el primer resultado ya decía «Dólar Blue Hoy $1550» y aun así se pidió elegir. Es una decisión explícita del código («Un buscador nunca navega solo: muestra la lista», Assistant.swift:676-692). Que el script tocara siempre el botón 1 no lo explica: ese botón era el sitio correcto en todos los casos, lo que refuerza que la lista es un paso de más.

### P05 · En los resultados se pierde el resultado exacto y aparecen sitios no oficiales o de ingreso

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: turno-anses, otra-cosa, mercadolibre-auriculares, banco-nacion

Evidencia:
- «quiero sacar un turno en anses» → «Buscando: anses.» … «3. ANSES - Mi Anses, mianses.org» (sitio no oficial)
- Verificador 1: paginas/01.txt tenía como n.º 3 «Solicitar turnos en ANSES - Argentina.gob.ar». No se ofreció. En su lugar apareció «ANSES — servicioswww.anses.gob.ar», que es una consulta de estudios con captcha.
- otra-cosa: «3. La Nacion, ingresar.lanacion.com.ar». En mercadolibre, [Mercado Libre — listado.mercadolibre.com.ar] es una pantalla de ingreso.
- banco: el primer resultado dice «Accedé a BNA Digital Empresas…» y JEF no lo menciona (Verificador 2, Ana).

Causa probable: - Assistant.results deduplica por host (seen.insert(host), Assistant.swift:864). «Solicitar turnos» vive en www.argentina.gob.ar, igual que el primero, y se descarta.
- El ruteador redujo el pedido a target «anses» y perdió «turno».
- ranked() sube lo .gob.ar, pero no baja los dominios que imitan al organismo (mianses.org) ni los subdominios de ingreso.
- Sólo se leen título y dominio. La descripción del resultado nunca se mira.

Propuesta: - Deduplicar por URL y no por host, o permitir dos por host si el título es distinto.
- Buscar con la tarea incluida («turnos anses»).
- Si hay un .gob.ar, no ofrecer entre los 3 primeros dominios que imitan el nombre del organismo, o avisar «no es el sitio oficial».
- Excluir resultados de login o ingreso.
- En bancos, confirmar «sitio oficial del Banco Nación» y mencionar la descripción si dice «Empresas».

Escéptico: En turno-anses/paginas/01.txt el n.º 3 es «Solicitar turnos en ANSES - Argentina.gob.ar» (www.argentina.gob.ar/servicio/…). Se descarta por deduplicar por host (seen.insert(host), Assistant.swift:864). En su lugar entran servicioswww.anses.gob.ar, que es «Consulta para completar o iniciar estudios. Ingrese el código que se muestra en la imagen», y mianses.org. El pedido también se redujo a «Buscando: anses.». En otra-cosa se ofrece «La Nacion — ingresar.lanacion.com.ar» (/login), y en mercadolibre «listado.mercadolibre.com.ar» («¡Hola! Para continuar, ingresa a.»). La parte del banco es débil: el primer resultado sí dice «Accedé a BNA Digital Empresas», pero lleva al ingreso con DNI que la persona quería.

### P06 · Los titulares de portada los reescribe el modelo: salen deformados, cambian en cada sesión y no coinciden con los botones

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, primera-vez, otra-cosa, solo-botones-clarin

Evidencia:
- primera-vez: «Una jueza declaró inconstitucional una ley que bajaba la punibilidad a 14 años y sobreseyó. Se filtró la desconfianza y una denuncia judicial tras la salida de una asistente de Karina.»
- noticias: «…y sobreseyó a un acusado». Según el Verificador 1, «a un acusado» no está en la página.
- Tres versiones del mismo titular: «Adorni explicó la decisión de vivir como si el dinero “no existiera” por bitcoins…», «Adorni explicó la existencia de bitcoins en negro…», «Adorni explicó la situación de los Bitcoins en negro…». El botón dice [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»].
- Nota: «ladera» es textual de La Nación, no un error de JEF.

Causa probable: - arrived() le pasa los 4 titulares al modelo (Assistant.swift:2258-2263).
- Answerer.orient le pide «cada uno en una frase corta con el HECHO» (Answerer.swift:217-219). El modelo parafrasea, y distinto cada vez.
- Eso contradice el principio del encabezado de Assistant.swift: que ninguna palabra la escriba un modelo.
- Los botones, en cambio, usan el título literal recortado por short().

Propuesta: - En portadas, armar el texto en código: «Estás en la portada de La Nación. Los principales: 1. … 2. …», con el título literal (dekick y tidy), entero.
- Si hace falta el modelo, que escriba sólo la primera frase.
- Numerar, y usar el mismo texto o el mismo número en el botón («Abrir la 1: …»).
- Reescribir sólo cuando la persona pide «Resumir la portada».

Escéptico: El mismo titular sale en tres versiones: «Adorni explicó la existencia de bitcoins en negro…» (primera-vez), «…la decisión de vivir como si el dinero “no existiera” por bitcoins en negro…» (noticias) y «…la situación de los Bitcoins en negro…» (otra-cosa). El botón, en cambio, dice [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»]. En la página el titular termina en «…y sobreseyó» (la línea viene cortada). JEF lo deja trunco («y sobreseyó.») o le agrega «a un acusado», que en la página sólo aparece en otro titular (Aramburú). También agrega «Milei» a «Karina». Todo sale del prompt de orient («cada uno en una frase corta con el HECHO»).

### P07 · Conteos y listas que no cuadran: «5 a 7 de 143», «7» contra «6» párrafos, «35 notas» con bajadas y una nota de otra sección

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, wikipedia-mar-del-plata, otra-cosa

Evidencia:
- Ante «dame los titulares»: «Titulares 5 a 7 de 143:», sin explicar por qué arranca en el 5.
- wikipedia: «Es una nota de 7 párrafos. Empieza así:» y dos pasos después «Párrafos 1 a 2 de 6:»
- otra-cosa: «Hay 35 notas. Las tres primeras:», con «El ciclo de Hansi Flick…» (la bajada de la primera) como segunda nota, y «La aterradora frase de un acusado…» (un policial) como tercera. Según el Verificador 2, la tercera real era «Bombazo. River vuelve a la AFA…».

Causa probable: - headlines(of:) (Assistant.swift:2493-2512) cuenta todo link-encabezado de 20 letras o más y todo ítem de listado de 25 o más. No junta título con bajada ni detecta duplicados con y sin volanta. Así salen 143 en la portada y 35 en Deportes, que incluyen ítems concatenados.
- arrived() deja readingFrom en 4 (Assistant.swift:2319-2320) para no repetir los titulares. readAloud no lo avisa.
- describe() cuenta paragraphs.count (7 bloques, Assistant.swift:2403). readAloud cuenta readablePieces, que descarta los de menos de 40 letras y suma encabezados (6).
- La nota policial está en la grilla del propio sitio. JEF no la distingue.

Propuesta: - Un solo conteo (readablePieces) para describe y para readAloud.
- Agrupar título y bajada por href o por tarjeta, y descartar duplicados con volanta.
- No decir totales enormes («hay muchos más»).
- Si arranca en el 5, avisar: «Los 4 principales ya te los dije; sigo con el 5». O empezar por el 1 cuando la persona pide los titulares.
- Preferir las notas cuya URL cae bajo la sección pedida (/deportes/).

Escéptico: Está en las transcripciones. En noticias, «dame los titulares» devuelve «Titulares 5 a 7 de 143:» sin explicar el salto: el código hace readingFrom = lead.count (Assistant.swift:2320) porque los 4 ya se dijeron en la portada. En wikipedia dice «Es una nota de 7 párrafos» (paragraphs.count, :2403) y después «Párrafos 1 a 2 de 6:». En otra-cosa, «Hay 35 notas. Las tres primeras:» pone como segunda nota la bajada «El ciclo de Hansi Flick…». Un matiz: el policial «La aterradora frase…» sí está en la grilla de /deportes/ (paginas/03.txt, línea 27), así que ése viene del sitio.

### P08 · Textos cortados a mitad de palabra: titulares, adelantos y botones

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: noticias-la-nacion, wikipedia-mar-del-plata, otra-cosa, turno-anses, solo-botones-clarin, primera-vez

Evidencia:
- «6. La aterradora frase de un acusado a la familia del asesinado: "Los dinosaurios que se comi»
- «…Es la cabecera del partido de General Pueyrredón, un importante puerto, la localidad balnear»
- «…uno de los ejes del fenómeno tras el gran…»
- [Abrir «Plan de Pago de Deuda Previsional para trabajadores en actividad, ver…»] · [Abrir «Bitcoins en negro, ventas a escondidas y la decisión de vivir como si…»]

Causa probable: - extract.js corta los títulos de tarjeta a 120 caracteres sin respetar palabras (title.slice(0, 120), extract.js:1609 y 1805). «El crimen de Martín Aramburú. La aterradora… se comi» son exactamente 120.
- extract.js corta las etiquetas de link a 160 (extract.js:2566).
- describe() adelanta opening.prefix(220) (Assistant.swift:2404) y los titulares de sección con short(…, 140) (2386).
- Los botones usan short(…, 70).

Propuesta: - No truncar títulos en extract.js, o cortar en una palabra y marcar que se truncó.
- Si el mismo href aparece entero en otro lugar de la página (el titular completo estaba en «Más leídas»), usar ése.
- En describe, cortar al final de una oración o leer el primer párrafo entero.
- En los botones, acortar sólo el texto visible y dejar el accessibilityLabel completo.

Escéptico: «…"Los dinosaurios que se comi» tiene exactamente 120 caracteres (el title.slice(0, 120) de extract.js), y el titular completo figura en paginas/02.txt:142. El adelanto de Wikipedia termina en «la localidad balnear», que son justo 220 (opening.prefix(220)). Los botones y el short(…, 140) cortan en una palabra con «…», pero igual pierden el final: «…ver…» por «ver sub-trámites», «vivir como si…». Sólo los dos primeros quedan a mitad de palabra.

### P09 · Wikipedia: se leen como artículo los avisos, la descripción corta y las marcas de cita

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata

Evidencia:
- «leeme la nota» → «Párrafos 1 a 2 de 6:» / «ciudad de la provincia de Buenos Aires, Argentina» / ««Marplatense»  redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).»
- «…que más tarde recibió el nombre de «Puerto de la Laguna de los Padres». [2 ]», y «301  %», «404  km» con espacio doble.
- El comienzo real del artículo recién suena con «Seguir leyendo», y repite lo ya dicho en el paso 2.

Causa probable: - readablePieces (Assistant.swift:1291-1311) toma todo párrafo de 40 letras o más.
- El extractor no descarta la descripción corta ni los avisos de Wikipedia (shortdescription, hatnote, dablink) ni las referencias (sup.reference). En paginas/02.txt aparecen como contenido.
- Los espacios duros no se normalizan.

Propuesta: - En extract.js, excluir .shortdescription, .hatnote, .dablink, sup.reference y .mw-editsection. Descartar también los párrafos que empiezan con «Para otros usos», «No debe confundirse» o contienen «redirige aquí».
- Normalizar los espacios.
- Si describe ya adelantó el primer párrafo, decirlo en «Leer la nota», o seguir desde ahí.

Escéptico: Con «leeme la nota», los párrafos 1 y 2 son «ciudad de la provincia de Buenos Aires, Argentina» y ««Marplatense»  redirige aquí…». Recién «Seguir leyendo» trae el comienzo real, que repite el adelanto del paso 2. Se oye «[2 ]», «301  %» y «404  km». En extract.js no hay ninguna exclusión de shortdescription, hatnote o sup.reference: el grep no encuentra nada.

### P10 · La lectura va de a 2 párrafos o 3 titulares, y «Seguir leyendo» saltea lo que no llegó a sonar

*grave* · del script de prueba · jueces: Marta, Roberto, Lucía · escenarios: solo-botones-clarin, noticias-la-nacion, wikipedia-mar-del-plata

Evidencia:
- clarín: «Párrafos 1 a 2 de 10:». El párrafo 2 («Según pudo confirmar Clarín… interruptor L46…») quedó DESCARTADO, y «Seguir leyendo» siguió con «Párrafos 3 a 4 de 10:».
- noticias: «7. Las grandes cadenas dejaron sin audio a Trump…» quedó DESCARTADO.
- Marta: «Para una nota de 10 tengo que tocar «Seguir leyendo» cinco veces y esperar cada vez.»

Causa probable: - readAloud (Assistant.swift:1361-1375) lee de a 2 párrafos o 3 titulares. Cada pieza es un anuncio en cola, y readingFrom avanza apenas se escriben.
- Habla (Registro.swift:36-48) cuenta cuándo terminan los anuncios pero ignora el flag de éxito (UIAccessibilityAnnouncementKeyWasSuccessful). El código no sabe qué se escuchó entero.
- Con VoiceOver, deslizar hasta el botón corta la cola. En la prueba lo cortó el toque del script, pero un gesto real hace lo mismo.

Propuesta: - Registrar por pieza si su anuncio terminó con éxito, y que «Seguir leyendo» o «Seguir con los titulares» retome desde la primera pieza no escuchada.
- Sumar «Leer todo de corrido»: encadenar hasta el final o hasta que la persona toque algo.

Escéptico: El mecanismo existe: de a 2 párrafos o 3 titulares (Assistant.swift:1364), y readingFrom avanza al escribir. En clarín, el párrafo 2 quedó DESCARTADO y «Seguir leyendo» siguió con «Párrafos 3 a 4 de 10». Pero lo cortó el script, que tocó el botón a los +53,1 s, 9,6 s después de empezar una lectura de unos 700 caracteres (~50 s). En noticias, el titular 7 lo cortó el toque en «Abrir…», no un «Seguir». Una persona que espera no pierde nada, y el párrafo sigue escrito en el chat (línea 14 del árbol).

### P11 · Lo importante sale partido en varios anuncios, y los siguientes lo cortan o lo descartan

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Verificador 1 · escenarios: mercadolibre-auriculares, otra-cosa

Evidencia:
- «Cuando elijas, sigo con: buscame auriculares bluetooth.» ⟶ DESCARTADO
- «Sigo con: buscame auriculares bluetooth.» ⟶ DESCARTADO; «Buscando auriculares bluetooth en mercadolibre.com.ar.» ⟶ DESCARTADO
- «Tiene una opción de audio, dentro del recuadro de la prueba.» ⟶ DESCARTADO
- Verificador 1: la frase «usá el cuadro de texto…» también quedó cortada a los +25,3 s por el aviso de la prueba, aunque la transcripción no la marca.
- otra-cosa: cinco anuncios en cola («En Noticias de Deportes…», «Hay 35 notas…» y tres titulares). Roberto: «casi medio minuto escuchando antes de poder elegir».

Causa probable: - Cada say() es un anuncio (Assistant.swift:176-185), y un mismo turno emite varios: present más «Cuando elijas…»; orient más «Sigo con» más «Buscando…»; askToSolve más «Tiene una opción de audio».
- askToSolve pone interruptNext = true (Assistant.swift:1113) y descarta lo que estaba en cola.
- Lo accionable suele ir último.

Propuesta: - Juntar en un solo anuncio lo que se dice en voz alta en cada turno (acumular y emitir al cerrar el turno o antes de una espera), con lo accionable primero: «Busqué auriculares y Mercado Libre pide una prueba anti-robot con opción de audio.»
- Los pasos intermedios («Buscando…») pueden quedar escritos sin anuncio, o sonar como un tono.

Escéptico: Según el registro, la prueba anti-robot se anuncia con "cola": false (askToSolve, interruptNext = true, :1113). Ese anuncio descartó «Sigo con…» y «Buscando auriculares…», que la app misma había encolado, y cortó «Estás en Mercado Libre…» a unos 59 caracteres, antes de «usá el cuadro de texto» (lo que decía el Verificador 1). «Cuando elijas…» y «Tiene una opción de audio» sí los descartó el ritmo del script. En otra-cosa son cinco anuncios encolados, de +43,6 s a ~+73 s.

### P12 · JEF le indica a la persona que haga lo que él mismo va a hacer medio segundo después

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: mercadolibre-auriculares

Evidencia:
- «Estás en Mercado Libre Argentina. Para encontrar auriculares bluetooth, usá el cuadro de texto que dice "Ingresá lo que quieras encontrar".» Y a +21,6 s: «Buscando auriculares bluetooth en mercadolibre.com.ar.»
- Botones: [Abrir «Ingresá lo que quieras encontrar»] · [Abrir «Ir a Categorías»] · [Abrir «Abrir app de Mercado Libre»]

Causa probable: - Al elegir el resultado, accept() llama a landed() y arrived(), que llaman a orient con goal = lastRequest (la frase entera). Su prompt dice «empezá diciendo si esta página sirve para eso y dónde» (Answerer.swift:242-245).
- Recién después corre la tarea guardada en waiting con continueWith (Assistant.swift:1578-1584). Orient no sabe que JEF va a seguir solo.
- Los botones «Abrir «…»» se arman igual para un campo que para un link (Assistant.swift:2278-2286).
- El filtro de candidates no excluye «app».

Propuesta: - Si hay una tarea en waiting, no orientar. Decir «Entré a Mercado Libre. Busco auriculares bluetooth.» y seguir.
- Un campo se ofrece como «Completar…» o «Buscar en…», nunca como «Abrir».
- Excluir «Abrir app…» de las opciones.

Escéptico: A los +21,1 s: «usá el cuadro de texto que dice "Ingresá lo que quieras encontrar"». A los +21,6 s la app misma dice «Buscando auriculares bluetooth en mercadolibre.com.ar.». Los botones ofrecidos son [Abrir «Ingresá lo que quieras encontrar»] y [Abrir «Abrir app de Mercado Libre»]. El código llama a landed() antes de continueWith(rest) (Assistant.swift:1578-1584), y el prompt de orient pide decir dónde está lo que la persona busca.

### P13 · Prueba en la misma página: JEF no nota que se resolvió, e «Ir a la prueba» no deja a la persona en la prueba

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: anti-robot-ya-la-resolvi

Evidencia:
- Paso 2, al tocar «Ir a la prueba»: «Listo: la prueba está en la página. Cuando esté resuelta, continuamos.», y otra vez [Ir a la prueba] como primera opción.
- Paso 3: 18 s sin ningún anuncio. En paso-02.jpg y paso-03.jpg arriba ya se ven los auriculares.
- Sólo avanzó al tocar «Ya la resolví» a +40,8 s. Ana: «Pasaron unos 25 segundos sin que se diera cuenta.»

Causa probable: - El vigilante de cambios tardíos de extract.js ignora cambios de menos de 20 nodos (LATE_THRESHOLD = 20, extract.js:3563). Cambiar la prueba por el listado son unos 12, así que Assistant.pageChanged nunca se entera.
- ReaderView.pageChangedOnItsOwn descarta además las lecturas «equivalentes» (misma URL y título).
- showChallenge (ReaderView.swift:153-160) manda .layoutChanged al WebView entero, no al recuadro de la prueba.
- Al cerrar el turno, placeFocus (AssistantPanel.swift:157-170) vuelve a poner el cursor en la primera opción de la conversación (otra vez «Ir a la prueba») y deshace el salto. Visualmente no se marca nada.

Propuesta: - Mientras haya una prueba pendiente, releer la página cada 2 s (reread), o que extract.js avise sin umbral cuando desaparece el iframe de reCAPTCHA, hCaptcha o Turnstile. Seguir solo, como en el caso donde cambia la dirección.
- En «Ir a la prueba»: enfocar el iframe, no devolver el foco a la conversación en ese turno, resaltarlo con un borde grueso, decir «Te dejé en la prueba» y poner «Ya la resolví» primero.

Escéptico: El fixture misma-pagina.html cambia la prueba por el listado 12 s después de cargar, o sea hacia +20 s. paso-02.jpg (unos +22 s) y paso-03.jpg ya muestran los auriculares, y registro.jsonl no tiene ningún evento hasta «Ya la resolví» a +40,8 s: fueron unos 20 s sin que JEF se diera cuenta. El cambio pesa unos 16 nodos, menos que LATE_THRESHOLD = 20 (extract.js:3563), así que pageChanged nunca se dispara. Además, después de «Ir a la prueba» la respuesta es «Listo: la prueba está en la página…» con [Ir a la prueba] otra vez primero, y placeFocus (AssistantPanel.swift:157-170) vuelve a poner el cursor en esa opción, lo que deshace el .layoutChanged de showChallenge.

### P14 · Con baja visión, las opciones quedan escondidas debajo de las respuestas largas

*grave* · confirmado · jueces: Ana · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, turno-anses, primera-vez, clima-cordoba, otra-cosa, mercadolibre-auriculares, anti-robot-avanza-sola

Evidencia:
- Ana, portada: «El párrafo de los cuatro titulares llena todo el panel de abajo y queda cortado por el campo de escribir. En la pantalla no se ve ni un botón «Abrir…»»
- Clarín: «Párrafos 1 a 2 de 10: … El botón «Seguir leyendo» queda muy abajo, fuera de la pantalla»
- mercadolibre: el aviso de la prueba queda fuera de la pantalla y lo último visible es «Buscando auriculares bluetooth…».

Causa probable: - El panel ocupa el 55 % de la pantalla (ReaderView.swift:300). Al terminar, se desplaza al comienzo de la respuesta con anchor .top (AssistantPanel.swift:134).
- Con respuestas largas y letra grande, los botones quedan abajo, detrás del campo, sin ninguna señal de que existen.
- En la portada, el texto repite lo mismo que los botones (ver P06).

Propuesta: - Una bandeja fija de opciones encima del campo de escribir (las 2 o 3 primeras visibles y «Más opciones»), o un botón para agrandar el panel.
- Si las opciones no entran, mostrar «Más opciones abajo».
- En portadas, mostrar los titulares sólo como botones, con el texto completo.

Escéptico: Las capturas lo confirman, y eso que el tamaño de letra es el normal. En La Nación, paso-02.jpg termina con el párrafo de titulares cortado por el campo y no se ve ningún «Abrir…». En Clarín, paso-04.jpg muestra «Párrafos 1 a 2» y un segundo párrafo, sin botones. En Mercado Libre, paso-02.jpg termina en «Buscando auriculares bluetooth…» y el aviso de la prueba queda fuera de la pantalla, porque scrollTo(responseStart, anchor: .top) ancla en «Abriendo mercadolibre.com.ar.».

### P15 · La página de arriba no muestra lo que se está diciendo: carteles que nadie menciona, comentarios en vez de la nota, buscador en inglés

*grave* · confirmado · jueces: Ana, Verificador 1 · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, mercadolibre-auriculares, clima-cordoba

Evidencia:
- La Nación, nota abierta: arriba «Sumate a la conversación / INICIAR SESIÓN / SUSCRIBIRTE / TODOS LOS COMENTARIOS 42» (paso-04.jpg y paso-05.jpg).
- Clarín: un cartel «Acceder a Clarin.com con Google — Continuar» tapa la portada.
- dólar: «Este sitio utiliza cookies… Aceptar / Rechazar» tapa las cotizaciones. Según el Verificador 1, el cartel no figura en paginas/02.txt.
- DuckDuckGo con «Search», «Next Page >» y «Sponsored link».

Causa probable: - Los carteles que viven en iframes de terceros (Google One Tap, gestores de cookies) o que aparecen después de la extracción no los ve detectOverlay de extract.js.
- wakeLazyContent baja hasta el final para despertar contenido. La relectura automática (la nota de La Nación se leyó dos veces, a +43,2 s y +47,5 s) no vuelve arriba: scrollToTop sólo corre después de go() (HeadlessWebView.swift:238).
- La vista no sigue la lectura.
- El buscador se muestra tal cual, en inglés (ver P03).

Propuesta: - Cerrar solos los avisos de cookies (rechazando) y el de Google cuando se pueda. Si no se puede, avisar y ofrecer «Cerrar el aviso».
- Al abrir una nota, llevar la vista al título (h1), también después de cada relectura.
- Al leer, desplazar la página hasta el párrafo en curso y resaltarlo.
- Mandar Accept-Language es-AR.

Escéptico: En La Nación, paso-04.jpg y paso-05.jpg muestran «Sumate a la conversación / INICIAR SESIÓN / SUSCRIBIRTE / TODOS LOS COMENTARIOS 42» mientras se habla de la nota. En Clarín, paso-02.jpg tiene el cartel «Acceder a Clarin.com con Google — Continuar», y en paso-04.jpg se ven los íconos de redes mientras lee el párrafo 1. En dólar, paso-02.jpg tiene el aviso «Este sitio utiliza cookies… Aceptar / Rechazar», que no figura en paginas/02.txt. En DuckDuckGo, paso-01.jpg muestra «Search», «Any Time», «Next Page >» y «Sponsored link». Ningún texto de JEF menciona estos carteles.

### P16 · «Otra cosa» deja sin opciones y sin forma de volver, y la pista del campo no cambia

*grave* · confirmado · jueces: Marta, Roberto, Lucía · escenarios: otra-cosa, banco-nacion, noticias-la-nacion, primera-vez

Evidencia:
- «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» Después, ningún botón.
- banco: «[campo] Pedido = Escribir: DNI (Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.)»
- «¿Qué pongo en DNI? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.»

Causa probable: - En accept(), «Otra cosa» (Assistant.swift:1478-1482) vuelve antes de registrar closeTurn, y ya había puesto offer = nil. No queda ninguna opción.
- La pista del campo es fija (AssistantPanel.swift:221), aunque el placeholder cambie con awaiting (línea 208).
- Los textos dicen «acá abajo» y hablan del micrófono.
- El código sí intenta llevar el cursor al campo (placeFocus, AssistantPanel.swift:162-165). Lo que dicen los jueces sobre el cursor hay que confirmarlo en un dispositivo.

Propuesta: - «Otra cosa» → «¿Qué querés?» + botón «Volver a las opciones» (que restaure la oferta anterior) y, si hay página, dos ideas de esa página (sus secciones).
- Pista dinámica: con awaiting, «Tu DNI. Va directo al campo del banco»; sin él, algo corto. Lo del dictado, sólo la primera vez.
- «Escribí tu DNI, sin puntos» en vez de «acá abajo».

Escéptico: En otra-cosa, paso 3, después de «¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.» el árbol sólo tiene el campo y Enviar: ningún botón, tampoco para volver. Es así por código: Assistant.swift sale antes de closeTurn con offer = nil. En banco-nacion, paso 3, el campo figura como «Pedido = Escribir: DNI (Escribí a dónde querés ir. …)»: la pista es fija aunque cambie el placeholder, y el texto dice «acá abajo». Lo del cursor no se puede comprobar en el simulador, pero lo principal está a la vista.

### P17 · La bienvenida y «¿dónde estoy?» están pensadas para quien ve

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: primera-vez

Evidencia:
- «Para empezar, un sitio o algo para buscar; o una de estas opciones.» (sin verbo)
- «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.»
- Roberto: nunca le dice que deslice para encontrar las opciones.

Causa probable: - Son textos fijos en carry(.orientar) (Assistant.swift:503 y 509): frase sin verbo, JEF en tercera persona, referencias de lugar («arriba», «abajo»), ningún gesto.
- Con una página abierta, nombra la página por su título técnico (page.sectionTitle).

Propuesta: - «Soy JEF. Decime un sitio o qué buscar, o elegí una opción: deslizá a la derecha para escucharlas.»
- Si VoiceOver está activo, hablar de gestos; si no, de arriba y abajo.
- «¿dónde estoy?» → «Estás en la portada de La Nación», más «¿Qué puedo hacer acá?» y «Empezar de nuevo».

Escéptico: primera-vez tiene los dos textos literales. La bienvenida dice «Para empezar, un sitio o algo para buscar; o una de estas opciones.», sin verbo. «¿dónde estoy?» contesta «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF…»: usa el título técnico, habla de arriba y abajo, nombra a JEF en tercera persona y no menciona ningún gesto. Son textos fijos en Assistant.swift:503 y 509.

### P18 · Sugerencias que sobran (ya contestadas, ajenas, de login, campos del sitio) y alguna que falta

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1 · escenarios: wikipedia-mar-del-plata, clima-cordoba, noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, anti-robot-avanza-sola

Evidencia:
- «La fundó Patricio Peralta Ramos.» → [¿Quién la fundó?]
- «0% de probabilidad de precipitaciones» → [¿Lloverá mañana en Córdoba?]; después [¿Qué clima hará mañana en Córdoba?]
- [Abrir «Iniciar sesión»] en la nota del Papa; [Abrir «Clave Única PAMI…»] en la del apagón; [Completar «Selecionar localidad»]; [¿Qué es la brecha del dólar oficial?]
- anti-robot-avanza-sola: tras «El auricular más barato es el In Ear Bluetooth Básico…» no hay botón para abrirlo.

Causa probable: - Assistant.fresh (Assistant.swift:1157-1160) compara sólo con la pregunta hecha, no con lo que ya dijo la respuesta.
- candidates() excluye pago, suscripción y app, pero no login ni ingreso (Assistant.swift:1923).
- En una nota se admite una nota ajena elegida por el modelo sin comprobar que tenga relación (Assistant.swift:2300-2306).
- formOptions ofrece cualquier formulario que no sea de búsqueda.

Propuesta: - Descartar las preguntas cuyas palabras ya están en la respuesta, y pedírselo también al modelo.
- Excluir iniciar sesión, ingresar, mi cuenta y registrarse.
- Ofrecer otra nota sólo si comparte palabras con la actual.
- Formularios sólo si la tarea los necesita, con un nombre claro («Cambiar de ciudad»).
- Si la respuesta nombra algo que tiene link, ofrecer «Abrir «…»» primero.

Escéptico: Todos los casos citados están en las transcripciones. En wikipedia, «La fundó Patricio Peralta Ramos.» viene seguido de [¿Quién la fundó?]. En clima, «0% de probabilidad de precipitaciones» viene seguido de [¿Lloverá mañana en Córdoba?], y después de contestar el tiempo aparece [¿Qué clima hará mañana en Córdoba?], junto con [Completar «Selecionar localidad»]. En La Nación aparece [Abrir «Iniciar sesión»], y en Clarín [Abrir «Clave Única PAMI…»] en la nota del apagón. En anti-robot-avanza-sola, después de «El auricular más barato es el In Ear Bluetooth Básico…» las opciones son [¿Y el siguiente?]·[Leer la página]… y no hay «Abrir». fresh() compara sólo contra la pregunta, y el filtro de candidates() no excluye login. Es un problema menor; lo de la brecha del dólar es discutible.

### P19 · Lugares con nombres técnicos en vez de los corrientes

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: noticias-la-nacion, primera-vez, wikipedia-mar-del-plata, clima-cordoba, turno-anses, solo-botones-clarin, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.»
- «En Mar del Plata — es.wikipedia.org.»
- «…xn--tiempomaana-8db.net» (en la página figura tiempomañana.net); «servicioswww.anses.gob.ar»
- «Buscando: clarin.» (sin tilde); «Estás en localhost» (viene del fixture)

Causa probable: - goBack (Assistant.swift:2154), orientar (509) y describe (2380) usan page.sectionTitle y displaySite tal cual.
- present() lee el host punycode que devuelve URL.host() (748).
- El ruteador devuelve el target sin tildes.
- Cuando un sitio no tiene nombre, se lo nombra por su dirección (localhost).

Propuesta: - «La portada de La Nación», «Wikipedia, el artículo sobre Mar del Plata».
- Decodificar los dominios internacionales, o usar el dominio tal como lo muestra el buscador.
- Si el sitio no tiene nombre, usar el título de la página.
- En «Buscando:», usar las palabras de la persona.

Escéptico: Las citas están en las transcripciones: «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.» (noticias-la-nacion, paso 6), «Estás en «Últimas noticias…», LA NACION.» (primera-vez), «En Mar del Plata — es.wikipedia.org.», «…xn--tiempomaana-8db.net», cuando paginas/01.txt de clima dice «www.tiempomañana.net», y «Buscando: clarin.» después de que la persona escribió «clarín». Las plantillas de Assistant.swift:509, 2154 y 2380 usan sectionTitle y displaySite tal cual. Sólo lo de «Estás en localhost» sale del arnés, porque el fixture no tiene nombre de sitio; «servicioswww.anses.gob.ar» es el dominio real, aunque suena técnico.

### P20 · La voz del asistente es despareja: tuteo, sujetos equivocados, concordancia

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 1, Verificador 2 · escenarios: turno-anses, anti-robot-avanza-sola, anti-robot-ya-la-resolvi, mercadolibre-auriculares, primera-vez

Evidencia:
- «tocá en el tipo de trámite que necesitas»
- «Encontraste tres modelos disponibles con envío gratis» (la página dice «Encontramos»)
- «tres opciones disponibles con envío gratis, ordenados por precio»
- «Sigo con: buscame auriculares bluetooth.»; «la conversación con JEF: se le pide algo»

Causa probable: - Los prompts piden evitar las formas que cambian entre tú y vos (Answerer.swift:81-82 y 233-235) en vez de pedir voseo, y el modelo cae en tuteo.
- El modelo cambia el sujeto al parafrasear.
- Las plantillas repiten la orden de la persona tal cual («Sigo con:», Assistant.swift:322 y 358).

Propuesta: - Pedir voseo rioplatense explícito, y que la página sea el sujeto («la página muestra…»).
- Que el ruteador devuelva la tarea pendiente en infinitivo («buscar auriculares bluetooth») y la plantilla diga «Después busco auriculares bluetooth».

Escéptico: Está en las transcripciones: «Podés sacar un turno… tocá en el tipo de trámite que necesitas» (turno-anses, paso 4), «Encontraste tres modelos disponibles» cuando la página dice «Encontramos tres auriculares» (anti-robot-ya-la-resolvi), «tres opciones disponibles con envío gratis, ordenados por precio» (anti-robot-avanza-sola) y «Sigo con: buscame auriculares bluetooth.» (mercadolibre). Además, Answerer.swift:81-82 pide evitar las formas de tú y de vos en lugar de pedir voseo.

### P21 · Respuestas con dato sin fuente ni forma directa, y resúmenes largos

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero, clima-cordoba, noticias-la-nacion, solo-botones-clarin

Evidencia:
- «El dólar oficial está hoy a $1.482,52 para la compra y $1.534,23 para la venta. La variación es de +0,01%.»: no dice qué oficial es ni de qué hora. El blue lo había dado al revés, primero venta y después compra.
- «La probabilidad de lluvia mañana en Córdoba es del 0%.»: sin el «No» adelante.
- El resumen de la nota del Papa dura unos 26 s (Roberto).
- «casi dos millones de personas» (título de Clarín) contra «casi 600.000 usuarios» (cuerpo de la nota).

Causa probable: - Answerer.instructions no pide fuente ni hora, ni un orden fijo para compra y venta, ni contestar sí o no primero, y admite «dos o tres frases».
- summarize pide también «dos o tres frases» (Assistant.swift:1429).

Propuesta: - En el prompt: «sí o no primero»; «compra y después venta»; «qué cotización y de qué hora, si la página lo dice»; variaciones sólo si se piden.
- Resumen de dos frases como máximo, con un botón «Contame más».
- En la presentación de una nota, preferir las cifras del cuerpo, o aclarar la diferencia con el título.

Escéptico: Del blue dice «un valor de venta de $1.550,00 y de compra de $1.530,00» y del oficial «$1.482,52 para la compra y $1.534,23 para la venta»: el orden cambia de una respuesta a la otra. Omite la hora aunque la página dice «Última actualización 21/9 11:03 hs»; qué oficial es no se puede decir, porque la página sólo pone «Dólar Oficial». «La probabilidad de lluvia… es del 0%» no arranca con el «No». El resumen del Papa tiene 359 caracteres, unos 26 s. Lo de Clarín es débil: la app repite el título («dos millones de personas»), y el cuerpo habla de «600.000 usuarios», que es otra unidad; la diferencia viene de la fuente, no la inventa la app.

### P22 · Banco: el DNI no se confirma, la máscara se lee como puntos y queda una «Barra de herramientas» suelta

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador 2 · escenarios: banco-nacion

Evidencia:
- «Listo, escrito en DNI.»
- «Vos: •••••456»
- arbol-04: «[grp] Barra de herramientas» después de «Enviar». En paso-04.jpg se ven ˄ ˅ ✓.
- Lucía: la app no le dice si su DNI pasa por el asistente o por algún servidor.

Causa probable: - La confirmación es una plantilla sin dato. masked() se usa también como etiqueta de accesibilidad.
- __jefFill hace el.focus() en el campo de la página (extract.js:3236) y lo deja enfocado. El WebView muestra entonces su barra de formulario.

Propuesta: - «Listo, DNI terminado en 456», en voz y en texto.
- Etiqueta de accesibilidad: «Vos: DNI terminado en 456».
- Hacer blur() después de llenar (salvo en autocompletados), u ocultar la barra del formulario.
- La primera vez, una frase de privacidad: «Va sólo al campo del banco; no se lo mando a nadie».

Escéptico: En banco-nacion, paso 4: «Listo, escrito en DNI.» sin ningún dato, y el árbol muestra «[H] Vos: •••••456» (AssistantPanel.swift:198 usa el texto enmascarado como etiqueta). También aparece «17 [grp] Barra de herramientas», y en paso-04.jpg se ve la barra ˄ ˅ ✓ con el cursor en el DNI, porque extract.js hace el.focus() sin blur. Lo de la privacidad es parcial: la app ya dice «va directo a ese campo de la página», aunque no aclara lo del servidor.

### P23 · Textos de ayuda en gris claro y la pregunta que queda fuera de la pantalla

*menor* · confirmado · jueces: Ana · escenarios: banco-nacion, otra-cosa, dolar-desde-cero, clima-cordoba, primera-vez

Evidencia:
- Ana: «La pista de que lo que escriba va al DNI está en gris muy clarito dentro del campo»
- «¿Qué querés hacer?», «Escribir: DNI» y la flecha de enviar, en gris.
- «A veces la pregunta que hice sale de la pantalla y veo solo la respuesta.»

Causa probable: - El placeholder usa .foregroundStyle(.secondary) (AssistantPanel.swift:208).
- El botón Enviar se muestra gris cuando está deshabilitado.
- scrollTo ancla la vista en el comienzo de la respuesta, no en la pregunta.

Propuesta: - Placeholder más oscuro, o un rótulo visible encima del campo.
- Respetar el tamaño de letra del sistema.
- Anclar el scroll en la pregunta de la persona.

Escéptico: En paso-03.jpg de dolar y de clima se ven la respuesta y los botones, pero no la pregunta de la persona: responseStart (AssistantPanel.swift:176-180) ancla el scroll en la línea que sigue a la pregunta. En banco-nacion paso-03.jpg, «Escribir: DNI» y la flecha de enviar están en gris claro, y el prompt usa .foregroundStyle(.secondary) (línea 208), aunque el comentario del código dice que es «más oscuro».

## Lo que funciona

- El botón de inicio «Llevame a La Nación» va directo, sin lista (primera-vez).
- «llevame a deportes» se resuelve dentro del sitio con exactOption, sin buscador («Abriendo «Deportes».»).
- «volvé» es rápido y dice dónde quedó, con «Leer los titulares» y «Resumir la portada».
- Al abrir una nota: una o dos frases de qué trata, y «Leer la nota» y «Resumir la nota» primero. La nota se lee textual.
- Los resúmenes son concretos y fieles (Verificador 1: fechas, lugares y la visita de 1987 coinciden con la página).
- Preguntas de dato: el blue en una frase con compra y venta; «¿y el oficial?» se entiende por contexto (previousRequest); «¿cuándo se fundó?» exacto; el precio del más barato exacto.
- Después de elegir el sitio, la pregunta pendiente se contesta sola, diciendo de dónde sale («En DolarInfoHoy.», «En eltiempoen.com.»).
- La siguiente pregunta sugerida suele acertar («¿Cómo está el dólar oficial?», «¿Y el siguiente?»).
- En los resultados se saltean las publicidades y los sitios de otro país (Costa Rica, la Córdoba de España, homebanking.bna.com.es).
- Tocando siempre la primera opción se llega a leer una nota de Clarín: la primera opción fue siempre la correcta.
- «Párrafos 1 a 2 de 10» dice cuánto falta.
- Banco: «Te pide tu DNI y usuario para entrar»; «Completar «DNI»» aparece primero; el dato va directo al campo de la página, queda tapado en la conversación y no viaja al modelo; después se ofrece «Completar «Usuario»».
- Prueba anti-robot: se detecta; «Ya la resolví» responde al instante; cuando cambia la dirección, JEF sigue solo («Listo, ya pasamos la verificación.») y retoma la tarea pendiente.
- Recuerda la segunda mitad del pedido («Cuando elijas, sigo con…»).
- Es honesto: en la página de seguridad no inventó precios.
- Toda respuesta termina con botones y «Otra cosa», y «Volver a la página anterior» siempre está.
- La pista «Primera de N opciones» está en el primer botón.
- Cada pedido es un encabezado para el rotor.
- «$1.550,00» se dice «$1.550».
- ANSES: cada página empieza con «Estás en…», y la primera opción siempre acerca al turno («Abrir «Turnos»», «Abrir «Pedir turno»»).
- «¿dónde estoy?» se contesta corto, con «Leer los titulares» y «Resumir la portada».
- Los botones tienen texto oscuro con borde de color, y se leen bien cuando entran en pantalla (Ana).
