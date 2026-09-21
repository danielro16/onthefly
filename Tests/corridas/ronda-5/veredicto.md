# Veredicto — ronda-5

Cuatro jueces evaluaron 12 escenarios: de 48 juicios, 35 son «sí», 5 «a medias» y 8 «no». El promedio general es 3,49 sobre 5.

**Fracasos:**
- **Turno en ANSES** (1,95): JEF afirmó un camino que la página no dice y no ofreció el botón de la sección que él mismo nombró.
- **Mercado Libre** (2,70): no hay forma de llegar a la prueba anti-robot desde la conversación, y el aviso quedó tapado por una descripción de promociones.

**A medias:** en el Banco Nación los cuatro jueces se frenaron al cargar el DNI. No saben dónde escribirlo ni qué pasa con el dato, y el código no recuerda que está esperando ese valor.

**Problemas que cruzan casi todo:**
- Nombrar un sitio o hacer una pregunta de un dato termina en una lista de resultados leída entera, de unos 18 s. En cambio, el botón de inicio abre directo: es una decisión explícita en `arrive()`.
- La lectura por párrafos no es confiable: lee de a tres, saltea lo que no sonó, los conteos se contradicen, lee restos de Wikipedia y dice un «Fin de la nota» falso.
- Los botones no coinciden con lo dicho: los titulares llevan volanta, y dentro de una nota aparecen notas ajenas y falta «Resumir la nota».

**Lo que anda:** las respuestas a datos puntuales son exactas y rápidas, y el primer resultado siempre fue el correcto.

**Descartado por ser del script o del simulador:**
- Los cortes absolutos de anuncios se deben al ritmo fijo del script. Se conserva sólo el orden: lo importante va al final y en cola.
- «localhost» sale del fixture, aunque la regla que lo produce es real.
- La frase con el gesto de VoiceOver ante la prueba no aparece porque el simulador no corre VoiceOver.
- Los botones de bienvenida que reaparecen en el registro tras cada pedido son probablemente un ReaderModel descartable. `@State private var model = ReaderModel()` se re-evalúa en cada init de ReaderView, y cada instancia crea un Assistant y un motor web nuevos. Ninguna captura muestra ese flash; conviene verificarlo aparte.

## Tablero

| Escenario | Logros | Promedio (1-5) |
|---|---|---|
| noticias-la-nacion | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.5 |
| solo-botones-clarin | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |
| dolar-desde-cero | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.2 |
| wikipedia-mar-del-plata | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.2 |
| turno-anses | Marta no, Roberto no, Lucía no, Ana no | 1.9 |
| mercadolibre-auriculares | Marta no, Roberto no, Lucía no, Ana no | 2.7 |
| banco-nacion | Marta a medias, Roberto a medias, Lucía a medias, Ana a medias | 3.5 |
| primera-vez | Marta sí, Roberto a medias, Lucía sí, Ana sí | 3.8 |
| clima-cordoba | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.0 |
| otra-cosa | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.2 |
| anti-robot-avanza-sola | Marta sí, Roberto sí, Lucía sí, Ana sí | 4.2 |
| anti-robot-ya-la-resolvi | Marta sí, Roberto sí, Lucía sí, Ana sí | 3.8 |

**Promedio general: 3.49**

## Problemas

### P01 · En un trámite, JEF afirma pasos que la página no dice y no ofrece el paso que él mismo nombra

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: turno-anses

Evidencia:
- Paso 2: «Estás en la portada de ANSES. Para sacar un turno, tenés que ir a la sección Turnos.» Botones: [Abrir «Clave de la Seguridad Social»] · [Abrir «Libreta de Asignación Universal»] · [Abrir «Consulta Mis Asignaciones»] · [Abrir «Embarazo, pareja y familia»]. «Turnos» figura en el contenido de paginas/02.txt.
- Paso 3: «Para sacar un turno, antes vas a necesitar esta clave.» paginas/03.txt no relaciona la clave con los turnos. Único botón de contenido: [Abrir «Personas que se encuentren en el exterior (sin apoderado), Si residís…»].
- Paso 4: «Estás en la página de Clave de la Seguridad Social de ANSES. Para sacar el turno, ingresá tu CUIL y pulsá Continuar.» La página es el «Formulario Responsabilidad en el Uso del Identificador de Usuario» (paso-04.jpg) y no hay ningún botón Continuar entre las opciones.

Causa probable: - `Answerer.orient` recibe «LA PERSONA VINO A: quiero sacar un turno en anses» en cada página del recorrido: es `goal: lastRequest` en `Assistant.swift:2094`.
- El prompt le exige «empezá diciendo si esta página sirve para eso y dónde, y la primera opción tiene que ser la que la acerca» (`Answerer.swift:242-245`). Por eso el modelo conecta cualquier página con el turno.
- Sólo se verifican cifras; las afirmaciones de camino no.
- La regla `forGoal`, que sube primero el botón del objetivo, sólo corre en portadas con titulares (`Assistant.swift:2132-2145`). ANSES no tiene titulares, así que nada comprueba que la sección nombrada esté entre los botones.
- Con razón, JEF no envía formularios que no son búsqueda, pero el modelo igual dice «pulsá Continuar».

Propuesta: - Si la orientación nombra un control de la página («sección Turnos»), buscarlo entre los candidatos y ponerlo primero como «Abrir «Turnos»». Si no existe, no nombrarlo. Extender `forGoal` a todas las páginas.
- Cambiar el prompt: con el objetivo presente, decir sólo lo que la página dice sobre eso. Si la página es de otro trámite, decirlo («Esta página es para crear la Clave desde el exterior, no para el turno») y ofrecer volver.
- Pasarle al modelo el título o encabezado del formulario.
- No decir nunca «pulsá X» si X no es una opción ofrecida. Si es un envío que JEF no hace: «el botón «Continuar» lo tocás vos en la página», con un botón que lleve el foco ahí.

Escéptico: Pasa. En el paso 2 JEF dice «tenés que ir a la sección Turnos», pero entre los botones no hay «Abrir «Turnos»», aunque «Turnos» figura en el contenido de paginas/02.txt. En el paso 3 dice «Para sacar un turno, antes vas a necesitar esta clave», y paginas/03.txt no relaciona la clave con los turnos (sólo aparece «acercarte sin turno»). En el paso 4 dice «Para sacar el turno, ingresá tu CUIL», y paso-04.jpg muestra el «Formulario Responsabilidad en el Uso del Identificador de Usuario». Un matiz: «Turnos» y «Continuar» sí existen en la página. Lo falso es presentarlos como el camino al turno sin ofrecer el botón. El camino lo eligió el script, pero la mala primera opción y lo que se afirma son de la app.

### P02 · Prueba anti-robot: no hay cómo llegar a ella, el aviso se pierde y «continuamos» no siempre se cumple

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: mercadolibre-auriculares, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «El sitio web me pide resolver una prueba anti-robot. Hay que resolverla en la página, arriba. Cuando esté resuelta, continuamos.» En Mercado Libre quedó en cola detrás de la descripción de la portada y terminó DESCARTADO. La única línea que quedó es «Tiene una opción de audio, dentro del recuadro de la prueba.», suelta.
- En los dos escenarios anti-robot no se menciona la opción de audio.
- Mercado Libre, paso 3: «La página me pide que complete un paso de seguridad y no me deja ver los productos. No puedo saber el precio…» Botones: [Ya la resolví] · [Volver a la página anterior] · [Otra cosa].
- anti-robot-ya-la-resolvi, paso 2: 15 s sin ningún anuncio, mientras paso-02.jpg ya mostraba la lista de auriculares. Hubo que tocar «Ya la resolví».
- Ana, en Mercado Libre: «Arriba veía «No soy un robot», pero nada me decía que eso era para mí».

Causa probable: - `askToSolve` (`Assistant.swift:1049-1065`) sólo dice texto. No hay ninguna acción que mueva el foco de accesibilidad a la página o al iframe.
- La frase con el gesto se dice sólo si VoiceOver está activo (por eso no aparece en la prueba), y a Ana no le llega nunca.
- Sólo el primer anuncio después de un pedido interrumpe (`heard` pone `interruptNext`). El aviso de la prueba se encola detrás de la orientación de la portada.
- La detección de la prueba resuelta en la misma página depende del observador tardío de `extract.js`, que ignora cambios de menos de 20 nodos (`LATE_THRESHOLD`, `extract.js:3558`).
- En el fixture se cambian h1+p+iframe por h1+p+ul de tres ítems: pesa menos de 20, así que `pageChanged` nunca se entera.
- Mientras la prueba sigue, `followUps` sólo ofrece «Ya la resolví» y «Volver» (`Assistant.swift:1876-1880`).

Propuesta: - Primer botón «Ir a la prueba»: que haga scrollIntoView del iframe y mueva el foco de VoiceOver a la página con UIAccessibility.post(.layoutChanged). Decir cómo volver: escape con dos dedos.
- El aviso de la prueba tiene que interrumpir lo que se esté diciendo, y no hay que describir la página que quedó atrás.
- Decir siempre qué es: «casilla No soy un robot, con opción de audio».
- Mientras haya una prueba pendiente, releer la página cada 2 o 3 s y comprobar `hasChallenge`, en vez de depender de mutaciones.
- El texto tiene que coincidir con lo que pasa: «cuando la resuelvas sigo solo» sólo si se puede detectar; si no, «tocá «Ya la resolví»».
- Si sigue trabada, ofrecer «Buscar en otro sitio».

Escéptico: Pasa, salvo un punto. Mientras hay prueba, los botones son sólo [Ya la resolví] · [Volver] · [Otra cosa], sin ninguno que lleve a ella. En Mercado Libre el aviso salió en cola ("cola": true en registro.jsonl), detrás de los ~300 caracteres de la portada que ya había quedado atrás. En anti-robot-ya-la-resolvi, paso 2 no tiene ningún 🔊 mientras paso-02.jpg ya muestra la lista: el cambio pesa unos 12 nodos, menos que LATE_THRESHOLD=20. Lo que sí es del arnés: que no se mencione el audio en los escenarios anti-robot. El fixture usa src="about:blank" y la app deduce el audio del src. Además, el corte exacto depende del ritmo del script, que escribió a los 7 s.

### P03 · Al pedir un dato personal (DNI), no dice dónde escribirlo, repite el mismo botón y no aclara qué pasa con el dato

*bloqueante* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: banco-nacion, turno-anses

Evidencia:
- Toca [Completar «DNI»] y en la conversación aparece «Vos: completá el campo DNI».
- JEF: «¿Qué pongo en DNI?». Botones: [Completar «DNI»] · [Completar «Usuario»] · [Volver a la página anterior] · [Otra cosa].
- El campo sigue con «¿Qué querés hacer?» y la pista «Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.» (arbol-03, paso-03.jpg).
- ANSES: «ingresá tu CUIL», sin decir para qué es el formulario.
- Los cuatro jueces se detuvieron acá: «Con mi banco, si no estoy segura, no sigo».

Causa probable: - `complete()` pregunta y termina (`Assistant.swift:559-561`). No queda ningún estado que diga que se espera el DNI.
- Lo próximo que se escriba se vuelve a rutear desde cero con Gemini a través del AI Gateway (`Router.swift:189`). El DNI sale del teléfono hacia un tercero y queda escrito como «Vos: …».
- Si el ruteador no lo clasifica como completar, puede terminar en buscar, y de ahí en una búsqueda en DuckDuckGo del número.
- `closeTurn` vuelve a poner `formOptions` primero (`Assistant.swift:1831, 1892`), por eso el mismo botón reaparece.
- El botón lleva un pedido escrito «completá el campo X» (`Assistant.swift:1957`). Así el turno de la persona no muestra lo que tocó.
- No hay un campo seguro en la conversación.

Propuesta: - Al tocar «Completar «DNI»», abrir un modo de dato: un campo propio con la etiqueta «DNI para el Banco Nación», teclado numérico, foco ahí y un botón Cancelar.
- El valor va directo a `reader.fill`, sin pasar por el ruteador ni por ningún modelo.
- Avisar antes: «Lo escribo sólo en la página del banco; no queda en la conversación ni se manda a ningún otro lado». En la conversación, mostrarlo enmascarado.
- Para contraseñas: un SecureField, o un botón que lleve el foco al campo de la página.
- Mientras espera el dato, no volver a ofrecer el mismo «Completar».

Escéptico: Pasa tal cual. Al tocar el botón queda «Vos: completá el campo DNI». JEF responde «¿Qué pongo en DNI?» y vuelve a ofrecer [Completar «DNI»] primero. En arbol-03 el campo sigue como «Pedido = ¿Qué querés hacer?», con la pista genérica. En el código, `complete()` sólo hace say("¿Qué pongo en…") y return, y el valor que se escriba después pasa por el ruteador (ai-gateway, gemini). Tocar «Completar DNI» en un login era una primera opción razonable: la falla es lo que pasa después.

### P04 · La búsqueda pierde lo que la persona vino a hacer y descarta el resultado que servía

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: turno-anses

Evidencia:
- El pedido fue «quiero sacar un turno en anses» y JEF dijo «Buscando: anses.», sin «Cuando elijas, sigo con…».
- En paginas/01.txt, el resultado 3 era «Solicitar turnos en ANSES - Argentina.gob.ar — Podés solicitar un turno por internet…». No se ofreció.
- En cambio se ofreció «ANSES - Mi Anses — mianses.org», un sitio no oficial, sin ninguna advertencia.
- La opción 2, «ANSES — servicioswww.anses.gob.ar», es una consulta de estudios con captcha.

Causa probable: - El ruteador devolvió ir con target «anses» y sin `rest`. La regla de `Router.swift:126-130` espera dos pedidos explícitos, y «sacar un turno en anses» es uno solo.
- `results()` deduplica por host (`seen.insert(host)`, `Assistant.swift:807`). Como el resultado 1 ya era www.argentina.gob.ar, «Solicitar turnos», del mismo host, se descartó.
- Nada marca como no oficial un dominio que imita el nombre de un organismo.

Propuesta: - Que el target conserve la tarea («turno anses»), o completar `rest` siempre que haya un verbo de trámite.
- Deduplicar por URL cuando el título es distinto, o aceptar hasta dos resultados por dominio oficial.
- Subir el resultado cuyo título contiene las palabras del pedido.
- Marcar como «no oficial» los dominios que llevan el nombre de un organismo sin .gob.ar, y en trámites no ofrecerlos.

Escéptico: Pasa. El pedido «quiero sacar un turno en anses» quedó en «Buscando: anses.», sin «Cuando elijas, sigo con…». En paginas/01.txt el resultado 3 es «Solicitar turnos en ANSES», en www.argentina.gob.ar, el mismo host que el 1. Lo descarta `guard seen.insert(host)`. En su lugar se ofreció mianses.org, sin advertencia. La opción 2 es la consulta de estudios con código de imagen («Ingrese el código que se muestra en la imagen»).

### P05 · Nombrar un sitio o preguntar un dato siempre termina en una lista de resultados leída entera, aunque el botón de inicio abre directo

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, clima-cordoba, otra-cosa, primera-vez

Evidencia:
- «Estás en los resultados de «la nación». Los 3 más probables: 1. Últimas noticias de Argentina y el mundo - LA NACION, lanacion.com.ar. 2. LN+ EN VIVO | …, youtube.com. 3. La Nacion, ingresar.lanacion.com.ar». Son unos 18 s, y el 3 es la página de login.
- primera-vez: el botón [Llevame a La Nación] responde «Abriendo lanacion.com.ar.», directo.
- Dólar: «1. Dólar Blue Hoy $1550 | Cotización en tiempo real, dolarinfohoy.com.ar». El precio ya estaba en el título y no se dijo.
- Mercado Libre: «Cuando elijas, sigo con: buscame auriculares bluetooth.» se dijo después de la lista y quedó DESCARTADO.
- Mercado Libre: «3. Mercado Libre, listado.mercadolibre.com.ar» es la pantalla «¡Hola! Para continuar, ingresa a.».
- Clima: «Tiempo cada hora en Cordoba, Córdoba, Argentina |…, accuweather.com», con un «|» colgando.

Causa probable: - Es una decisión deliberada de `arrive()` (`Assistant.swift:619-635`, «Un buscador nunca navega solo: muestra la lista»), tomada después de errores con anses.fr y nacion.com.
- El botón de inicio tiene el href fijo (`Assistant.swift:150`), por eso se comporta distinto.
- `present()` lee título más dominio de los tres resultados (`Assistant.swift:686-693`).
- El «sigo con…» se dice recién después, en cola (`Assistant.swift:268-273`).
- Las preguntas de un dato quedan en `pendingQuestion` hasta que la persona elige un resultado.

Propuesta: - Abrir directo cuando `named()` encuentra una coincidencia exacta de dominio del país (lanacion.com.ar, clarin.com, mercadolibre.com.ar, bna.com.ar): «Abrí La Nación. Si no era, tocá «Otros resultados»».
- Para preguntas de un dato: abrir el primer resultado del país y contestar nombrando la fuente, con un botón «Ver en otro sitio».
- Si igual hay lista: en voz alta, sólo «Encontré 3; el primero es La Nación». Los resultados, sólo como botones con el nombre del sitio, sin www ni «|».
- Decir la tarea pendiente antes de la lista, y avisar cuando un resultado es de inicio de sesión.

Escéptico: Pasa. En los nueve escenarios que empiezan nombrando un sitio o preguntando un dato, la primera respuesta es «Estás en los resultados de… Los 3 más probables: 1…2…3…», con título y dominio en voz alta. En primera-vez, el botón [Llevame a La Nación] responde «Abriendo lanacion.com.ar.» directo. El 3 de La Nación es ingresar.lanacion.com.ar/login. El de Mercado Libre es la página «¡Hola! Para continuar, ingresa a.». El de clima termina en «|…». Es una decisión deliberada de `arrive()`, pero es de la app. Un matiz: el $1550 del dólar sí sonó dentro del título, sólo que no como respuesta.

### P06 · Lectura por párrafos: lee de a tres, «Seguir leyendo» saltea lo que no sonó y la posición llega al final

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: solo-botones-clarin, wikipedia-mar-del-plata, noticias-la-nacion

Evidencia:
- Clarín, paso 4: tres párrafos más «Párrafo 3 de 11.». Los párrafos 2 y 3 y la posición quedaron DESCARTADOS.
- Clarín, paso 5: «Seguir leyendo» empezó en «Aunque desde el Gobierno también insistieron…», que es el párrafo 4.
- El botón [Leer la nota completa] leyó 3 de 11.
- La Nación: «Titular 3 de 139.» quedó DESCARTADO.
- Wikipedia: «Fin de la nota.» quedó en cola hasta +132 s.
- Ana: «Párrafo 3 de 11» y los botones quedaron fuera de la vista.

Causa probable: - `readAloud()` (`Assistant.swift:1250-1261`) escribe tres piezas seguidas, cada una como un anuncio en cola.
- `readingFrom` avanza por lo que se escribió, no por lo que sonó. Un pedido nuevo descarta la cola, pero el contador ya avanzó.
- La posición es el último `say`.
- La etiqueta «completa» la inventa el modelo en `orient`.

Propuesta: - Leer un párrafo por toque (o dos si son cortos).
- Poner la posición al principio («Párrafo 4 de 11:») o en el botón («Seguir leyendo, 5 de 11»).
- Avanzar `readingFrom` recién cuando termina de sonar cada anuncio; `Habla` ya lleva la cuenta de pendientes. Retomar desde el primer párrafo cortado.
- Usar una etiqueta fija: «Leer la nota (11 párrafos)».

Escéptico: El mecanismo es real. `readAloud` escribe 3 piezas y suma `readingFrom += chunk.count` al escribirlas, y la posición es el último say. «Seguir leyendo» arrancó en «Aunque desde el Gobierno…», que es la línea 23, el cuarto párrafo en paginas/05.txt. El botón «Leer la nota completa» leyó 3 de 11. En paso-04.jpg la posición y los botones quedan fuera de la vista. Hay una salvedad de arnés: los DESCARTADO pasan porque el script toca entre 8 y 11 s después de empezar una lectura de ~56 s. Una persona que espera oiría todo, así que el salteo sólo aparece cuando se interrumpe.

### P07 · El texto que lee no es confiable: conteos que no cierran, restos de la página y un «Fin de la nota» falso

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: wikipedia-mar-del-plata, otra-cosa, noticias-la-nacion

Evidencia:
- Al llegar dijo «Es una nota de 7 párrafos. Empieza así:» y después «Párrafo 3 de 6.».
- «…un importante puerto, la localidad balnear»: corte a mitad de palabra.
- Leídos como párrafos 1 y 2: «ciudad de la provincia de Buenos Aires, Argentina» y ««Marplatense» redirige aquí. Para la capa estratigráfica, véase Marplatense (edad).».
- «[2 ]», «[3 ]», «[4 ] [5 ]» leídos en medio del texto.
- «Fin de la nota.» al terminar la introducción, cuando paginas/02.txt sigue con Historia, Demografía, Geografía y otras secciones (sólo sus títulos).
- Deportes: «Hay 35 notas. Las tres primeras:» y la segunda es «Además, cómo está la tabla anual…», que es la bajada de la primera.
- Deportes: «…a su padre soy…», cortado justo antes de «yo».

Causa probable: - `describe()` cuenta todos los bloques de párrafo (`Assistant.swift:2213`). `readablePieces()` cuenta los párrafos de 40 letras o más, más encabezados y listas (`Assistant.swift:1183-1203`). Son dos criterios.
- `opening.prefix(220)` corta por caracteres, no por palabra.
- `extract.js` no filtra la descripción corta, los avisos de desambiguación ni las llamadas de referencia.
- En Wikipedia móvil las secciones están plegadas: sólo se extraen sus títulos, y `readAloud` dice «Fin de la nota» (`Assistant.swift:1238`).
- `headlines()` deduplica por texto y no por href (`Assistant.swift:2303-2321`), así que la bajada cuenta como otra nota.
- `short(title, 140)` recorta lo que se dice en voz alta (`Assistant.swift:2202`).

Propuesta: - Usar un solo contador, el de `readablePieces`, en `describe` y en la lectura.
- Cortar el adelanto al final de una oración.
- En `extract.js`, sacar `.shortdescription`, `.hatnote`, `.dablink`, `sup.reference` y `.noprint`.
- En Wikipedia, desplegar las secciones o decir «Fin de la introducción; siguen Historia, Geografía…» con un botón por sección.
- Nunca decir «Fin de la nota» si quedan secciones plegadas.
- Deduplicar titulares por href, uniendo título y bajada.
- No recortar lo que se dice en voz alta.

Escéptico: Todo se ve en las transcripciones. En Wikipedia dice «Es una nota de 7 párrafos» y después «Párrafo 3 de 6.»; el adelanto corta en «la localidad balnear»; lee como párrafos «ciudad de la provincia de Buenos Aires, Argentina» y «“Marplatense” redirige aquí…» y también «[2 ]», «[4 ] [5 ]»; y dice «Fin de la nota.» cuando paginas/02.txt sigue con los títulos Historia, Demografía y Geografía. En Deportes (otra-cosa/paginas/03.txt), «Además, cómo está la tabla anual…» es la bajada de la primera nota, y «…a su padre soy…» corta el «soy yo» del original. El código confirma el corte de caracteres (`opening.prefix(220)`, línea 2214) y el «Fin de la nota» (línea 1238).

### P08 · En una nota ofrece notas ajenas y no «Resumir la nota»; en una sección nombra notas y no ofrece abrirlas

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, otra-cosa

Evidencia:
- Nota de La Nación: [Leer la nota] · [Abrir «Salud masculina…»] · [Abrir «Salva vidas”…»] · [Abrir «Tenía 27 años. Murió Presley Gerber…»]. No hay «Resumir la nota»: la persona tuvo que escribirlo.
- Nota de Clarín: [Leer la nota completa] · [Abrir «Clave Única PAMI…»] · [Abrir «ANSeS semana del 21 al 25…»] · [Abrir «Habrá feriado…»].
- Deportes: «Hay 35 notas. Las tres primeras:» y los botones son [Leer los titulares] · [Resumir la portada] · [Volver a la página anterior] · [Otra cosa], sin ningún «Abrir».

Causa probable: - En una nota, `arrived()` sólo garantiza «Leer la nota» (`Assistant.swift:2124-2131`). «Resumir» depende de que el modelo lo proponga.
- `candidates(of:)` pone primero los «titulares» (`Assistant.swift:1768-1771`), que en una nota son las recomendadas. El modelo completa con ellas las 2 a 4 opciones.
- En Deportes, el pedido pasó por `run()`: después de abrir la sección, el analizador contestó `.done` y se llamó a `describe()` (`Assistant.swift:1523-1525`), no a `arrived()`.
- `describe()` no marca `lastDone`/`lastChunk`, así que `followUps` no arma los «Abrir» (`Assistant.swift:1897`).
- La etiqueta «Resumir la portada» es fija (`Assistant.swift:1908`).

Propuesta: - En una nota, botones fijos por código: Leer, Resumir, Volver y Otra cosa. Las relacionadas, sólo detrás de «Otras notas».
- Cuando `run()` llega a una página nueva, cerrar con `landed()`/`arrived()`.
- Si `describe()` nombra titulares, marcar `lastChunk` para que salgan los «Abrir».
- Fuera de la home, decir «Resumir la sección Deportes».

Escéptico: En la nota de La Nación los botones son [Leer la nota] · [Abrir «Salud masculina…»] · [Abrir «Salva vidas”…»] · [Abrir «Tenía 27 años…»]: son recomendadas que no tienen que ver (paginas/03.txt, líneas 47-49) y no hay «Resumir la nota». En Clarín pasa igual, con PAMI, ANSeS y el feriado. En Deportes dijo «Hay 35 notas. Las tres primeras:» y los botones son [Leer los titulares] · [Resumir la portada] · [Volver…] · [Otra cosa], sin ningún «Abrir». Son botones que armó la app, no elecciones del script.

### P09 · Los botones de titulares no dicen lo mismo que los titulares hablados (volanta, recorte, paráfrasis)

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: noticias-la-nacion, primera-vez, otra-cosa

Evidencia:
- Hablado: «Un gas contaminado habría causado el apagón…». Botón: [Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»].
- Otros botones: [Abrir «Por carta. El secretario…»] · [Abrir «Escalada. …»] · [Abrir «70 horas de frenesí. Tres misas…»].
- «dame los titulares» respondió «1. Por carta. El secretario de Discapacidad presentó su renuncia…».
- Clarín, sin volanta, funcionó: «Los titulares que me leyeron en la portada coinciden con los botones» (Lucía).

Causa probable: - En La Nación, la volanta viene dentro del mismo enlace o encabezado. `headlines()` y `tidy()` no la separan (`Assistant.swift:1925-1930`).
- Los botones usan ese texto recortado a 70 caracteres (`short()`, `Assistant.swift:2135`).
- Lo hablado lo reescribe el modelo: el prompt pide «una frase corta con el HECHO» (`Answerer.swift:217-219`). Hay dos fuentes para lo mismo.

Propuesta: - Separar la volanta en `extract.js`: el elemento propio antes del título, o el patrón de una a cuatro palabras más punto al inicio.
- Decir los titulares literales, sin volanta, armados por código.
- Que cada botón empiece con esas mismas palabras, recortado en una frase y no a mitad.

Escéptico: En La Nación dijo «Un gas contaminado habría causado el apagón que dejó sin luz…», pero el botón es [Abrir «Interruptor L46. Un gas contaminado sería la causa del apagón que…»] y el titular de la página (paginas/02.txt) trae la volanta. «dame los titulares» leyó «1. Por carta. El secretario de Discapacidad presentó su renuncia…». En primera-vez y otra-cosa lo hablado también es otra paráfrasis de los mismos botones.

### P10 · Afirma como hecho lo que la página no dice: causas, deducciones y datos sin fuente

*grave* · confirmado · jueces: Lucía, Marta, Roberto, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, primera-vez, clima-cordoba, dolar-desde-cero, mercadolibre-auriculares, banco-nacion

Evidencia:
- «El secretario de Discapacidad renunció por la puja en el área.» La página dice «en medio de la puja».
- Clarín: «por la interna sobre los recortes». La nota dice «en medio de la interna», y Vilches alegó «razones estrictamente personales».
- Resumen: «renunció … por razones personales», dicho como un hecho y no como la versión del Gobierno.
- «el Papa tendrá tres misas y orfebrería diplomática».
- «No va a llover.» La página no trae ningún dato de lluvia.
- «El dólar oficial está hoy a $1.482,52 … La variación es del +0,01%.» No dice cuál oficial ni de dónde sale.
- Mercado Libre: «promociones de hasta 45% … y en Comprá Ahora». Comprá Ahora sólo ofrece cuotas.
- Banco: «home banking del Banco Nación», cuando el resultado decía «BNA Digital Empresas».

Causa probable: - El Answerer sólo verifica cifras (`Answerer.swift:167-174`, `279-280`), no relaciones causales ni deducciones.
- Los prompts piden «frase corta con el HECHO» y «contestala directo». Eso empuja a convertir «en medio de» en «por» y a deducir la lluvia a partir de «despejado».
- Nada pide atribuir las versiones de parte.

Propuesta: - Cambiar los prompts: atribuir («según el Gobierno»), no convertir contexto en causa y, si falta el dato, decirlo («el pronóstico no menciona lluvia; dice cielo despejado»).
- En cotizaciones, decir cuál y la fuente, redondeado a pesos.
- En portadas, usar titulares literales (ver P09).

Escéptico: Casos confirmados: «renunció por la puja», cuando la página dice «en medio de la puja»; Clarín «por la interna», cuando la nota dice «en medio de la interna» y Vilches alegó «razones estrictamente personales»; «No va a llover», sin ningún dato de lluvia en clima-cordoba/paginas/02.txt; y «hasta 45% … y en Comprá Ahora», cuando esa línea sólo dice «¡HASTA 18 CUOTAS SIN INTERÉS!». Dos ejemplos flojos: los $1.482,52/$1.534,23 y el +0,01% están en la página, bajo «Dólar Oficial»; y la página del banco se titula «Home banking». Tampoco es la «versión del Gobierno»: en La Nación esas razones las da el propio Vilches.

### P11 · Con baja visión, los botones quedan escondidos debajo del campo de escribir

*grave* · confirmado · jueces: Ana, Verificador A, Verificador B · escenarios: noticias-la-nacion, solo-botones-clarin, wikipedia-mar-del-plata, otra-cosa, primera-vez, mercadolibre-auriculares, clima-cordoba, dolar-desde-cero, anti-robot-avanza-sola, anti-robot-ya-la-resolvi, turno-anses

Evidencia:
- paso-02.jpg de La Nación: del primer botón [Abrir «Por carta…»] sólo asoma el borde.
- otra-cosa, paso-02.jpg: no se ve ninguno de los 6 botones.
- Clarín, pasos 4 y 5: «Seguir leyendo» queda varias pantallas más abajo.
- Clima, paso 3: «Otra cosa» queda escondido.

Causa probable: - `AssistantPanel` desplaza al comienzo de la respuesta, anclado arriba (`AssistantPanel.swift:126-135`), y los botones van después, en el mismo ScrollView.
- El panel mide max(380, 55% de la pantalla) (`ReaderView.swift:289`).
- «Primera de N opciones» existe sólo como pista de VoiceOver.

Propuesta: - Poner una fila de opciones fija fuera del ScrollView, encima del campo (al menos la primera y «Otra cosa»), o un indicador visible «6 opciones más abajo».
- Agrandar la conversación cuando la respuesta es larga.

Escéptico: En noticias-la-nacion/paso-02.jpg sólo asoma el borde de [Abrir «Por carta…»] encima del campo. En otra-cosa/paso-02.jpg no se ve ningún botón. En clima-cordoba/paso-03.jpg se ven cuatro opciones y «Otra cosa» queda abajo. En solo-botones-clarin/paso-05.jpg sólo se ven párrafos. La captura muestra cómo deja la app la pantalla: se desplaza al comienzo de la respuesta, no es algo que haya hecho el script.

### P12 · Esperas largas sin ningún aviso y los botones desaparecen mientras piensa

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana · escenarios: dolar-desde-cero

Evidencia:
- «¿y el oficial?» a +29,1 s y respuesta a +38,5 s, sin nada en el medio.
- Roberto: «Pensé que se había colgado».
- Ana: «desaparecieron los botones y no apareció ningún «buscando…»».

Causa probable: - `ask()` borra las opciones apenas llega el pedido (`offer = nil`, `Assistant.swift:199`).
- El único indicio de trabajo es un ProgressView chico en el encabezado (`AssistantPanel.swift:42-46`), que no se anuncia.
- Una pregunta con la página abierta hace dos llamadas en serie a modelos: primero el ruteador y después el Answerer, cada una con reintentos.

Propuesta: - Pasados 1,5 a 2 s de silencio, anunciar y escribir qué está haciendo («Busco el oficial…»).
- Dejar las opciones anteriores atenuadas hasta que lleguen las nuevas.
- Si es una pregunta y hay página abierta, ir directo al Answerer sin pasar por el ruteador.

Escéptico: En dolar-desde-cero/registro.jsonl el pedido «¿y el oficial?» llega a t=…380.27 y en el mismo momento aparece «botones», «opciones»: [] (se borran). La respuesta llega recién a t=…389.64, así que son 9,4 s sin ningún turno ni anuncio de voz en el medio. Coincide con `offer = nil` en `ask()` (Assistant.swift:199). Es un solo caso medido, pero pasa como está descripto.

### P13 · Repite lo ya dicho y describe de más: título antes del resumen, titulares repetidos, promociones con una tarea pendiente

*grave* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A · escenarios: noticias-la-nacion, mercadolibre-auriculares, clima-cordoba, otra-cosa

Evidencia:
- «De «El secretario de Discapacidad presentó su renuncia en medio de la puja por el rumbo del área»: Alejandro Vilches renunció…». Unos 7 s de título: de lo nuevo se escuchó casi nada.
- «dame los titulares» repitió los tres que ya había dicho al llegar.
- Al volver a la portada se ofrece «Leer los titulares» desde el 1.
- Mercado Libre: «También hay promociones de hasta 45% de descuento y 18 cuotas sin interés … Además, te avisan que usan cookies.», con la búsqueda de auriculares pendiente. Tapó el aviso de la prueba.
- Clima: «No va a llover. Mañana, martes 22 de septiembre, en Córdoba va a haber cielos despejados…».
- «Estás en la portada de LA NACION, un portal de noticias.»

Causa probable: - `summarize()` antepone «De «título»:» (`Assistant.swift:1322`).
- `arrived()` dice los cuatro primeros titulares pero no marca `readingFrom`. `goBack()` lo pone en 0 (`Assistant.swift:1970`).
- Con una tarea en espera, `accept()` orienta completo con `landed()` antes de `continueWith` (`Assistant.swift:1451-1457`).
- El Answerer no ve su respuesta anterior.

Propuesta: - Resumen sin título.
- Si al llegar se dijeron cuatro titulares, «dame los titulares» sigue desde el 5, con el total al principio.
- Al volver a la portada, ofrecer «Seguir con los titulares (desde el N)».
- Con una tarea pendiente, no orientar: «Entré a Mercado Libre, busco auriculares…».
- Pasarle al Answerer lo último que se dijo y pedirle sólo lo nuevo.

Escéptico: Está en las transcripciones: el resumen empieza con «De «El secretario de Discapacidad presentó su renuncia…»:», «dame los titulares» vuelve a leer los mismos 1 a 3 que ya se habían dicho al llegar, el clima repite «Mañana, martes 22 de septiembre… cielos despejados» y en Mercado Libre la orientación de unos 21 s («promociones… cookies», en cola a +21.4s) deja el aviso de la prueba esperando hasta que se descarta. Lo único que depende del script es el «~23%»: el corte viene de que escribió «volvé» 7 s después; la repetición en sí es de la app.

### P14 · La presentación, «¿dónde estoy?» y «Otra cosa» no dicen cómo seguir

*grave* · confirmado · jueces: Roberto, Marta, Lucía, Ana, Verificador B · escenarios: primera-vez, otra-cosa

Evidencia:
- «Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.» La frase no tiene verbo y lo accionable va al final (se habría escuchado ~68%).
- «Estás en «Últimas noticias de Argentina y el mundo», LA NACION. Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.» Mientras tanto, el encabezado dice «Asistente».
- Después de «Otra cosa» desaparecen todos los botones y no hay forma de volver a las opciones.
- Ana: al abrir la primera página, la pantalla se parte sin ningún aviso.

Causa probable: - Los textos son fijos: `Assistant.swift:450` y `Assistant.swift:456`.
- `accept()` con «Otra cosa» retorna antes del `defer` de `closeTurn` y deja `offer` en nil (`Assistant.swift:1346, 1360-1364`).
- El texto inicial del panel está en tercera persona (`AssistantPanel.swift:58`).

Propuesta: - Bienvenida con la acción primero: «Decime un sitio o qué buscar, escribiendo o dictando, o tocá una de las opciones de abajo».
- «¿dónde estoy?»: «Estás en la portada del diario La Nación. Soy JEF…», con el gesto concreto si VoiceOver está activo.
- Usar un solo nombre para el asistente.
- «Otra cosa» conserva las opciones y suma «Volver a las opciones».
- La primera vez que aparece una página: «Arriba ahora está la página».

Escéptico: Los hechos están: la bienvenida no tiene verbo («Para empezar, un sitio o algo para buscar; o una de estas opciones»), el encabezado dice «Asistente» mientras el texto habla de «JEF», después de «Otra cosa» el árbol sólo tiene Pedido y Enviar, y paso-02.jpg muestra la pantalla partida sin que nadie lo avise. El título exagera, porque «¿dónde estoy?» sí dice «se le pide algo escribiendo, o se toca una opción» y «Otra cosa» dice «Se puede escribir, o dictar»; y el «~68%» es del arnés, que tocó el botón a +14.3s.

### P15 · Carteles de la página (cookies, privacidad, «Acceder con Google») tapan la mitad de arriba y JEF no los menciona

*grave* · confirmado · jueces: Ana, Verificador A, Verificador B · escenarios: solo-botones-clarin, dolar-desde-cero, clima-cordoba

Evidencia:
- Clarín, paso-02.jpg: «Acceder a Clarin.com con Google — Continuar», sin ninguna mención.
- DolarInfoHoy: «Este sitio utiliza cookies» con Aceptar y Rechazar, tapando las cotizaciones.
- Meteored: «Aviso de privacidad» con «ACEPTAR Y CONTINUAR».

Causa probable: - Los carteles no llegan al texto extraído (no figuran en paginas/*.txt). One Tap es un iframe de accounts.google.com, y las plataformas de consentimiento suelen vivir en iframes o shadow DOM.
- Sin `page.overlay`, `arrived()` no tiene nada que mencionar (`Assistant.swift:2079-2081`).

Propuesta: - Detectar en `extract.js` los iframes de One Tap, las plataformas de consentimiento conocidas y los elementos fijos que cubren más del 30% de la pantalla.
- Cerrarlos con Rechazar o la X, nunca aceptando ni iniciando sesión, o avisar en una línea que no hace falta tocarlos.

Escéptico: Las capturas lo muestran: el cartel «Acceder a Clarin.com con Google / Continuar» (solo-botones-clarin/paso-02.jpg), «Este sitio utiliza cookies / Aceptar / Rechazar» (dolar-desde-cero/paso-02 y 03) y «Aviso de privacidad / ACEPTAR Y CONTINUAR» (clima-cordoba/paso-02) tapan buena parte de la página. Ninguno aparece en paginas/*.txt ni en lo que dice JEF («En DolarInfoHoy.», «En meteored.com.ar.»). En Mercado Libre, en cambio, el aviso de cookies sí estaba en el texto y sí se mencionó.

### P16 · Sugiere preguntas ya contestadas y no ofrece el paso natural

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador A, Verificador B · escenarios: wikipedia-mar-del-plata, clima-cordoba, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- [¿Quién la fundó?] justo después de «…por Patricio Peralta Ramos».
- Clima: [¿Qué temperaturas habrá?] · [¿Cómo va a estar el viento?].
- Auriculares: [¿Y el más caro?] · [¿Cuáles son los otros dos?].
- El primer botón del pronóstico es [¿A qué hora sale el sol?], sin «¿Va a llover?».
- No hay «Abrir el más barato».

Causa probable: - El prompt pide preguntas que la página contesta (`Answerer.swift:97-99`), pero no excluye las ya contestadas.
- «¿Va a llover?» quedó afuera porque Meteored no trae datos de lluvia.
- Después de una respuesta, `closeTurn` no ofrece abrir lo que se nombró.

Propuesta: - Descartar sugerencias ya cubiertas por la respuesta.
- Permitir la pregunta natural del tema aunque la página no la conteste.
- Si la respuesta nombra un enlace de la página, ofrecer «Abrir «…»».

Escéptico: Después de «se fundó… por Patricio Peralta Ramos» ofrece [¿Quién la fundó?]; el clima ofrece [¿Qué temperaturas habrá?] y [¿Cómo va a estar el viento?], que ya se habían contestado; y los auriculares ofrecen [¿Y el más caro?] y [¿Cuáles son los otros dos?] cuando ya se habían dicho los tres precios. Lo de que falta «Abrir el más barato» es del fixture: la página de localhost (paginas/02.txt) no tiene ningún enlace a los productos.

### P17 · Nombres técnicos y etiquetas que no corresponden al tipo de página

*menor* · confirmado · jueces: Marta, Roberto, Lucía, Ana, Verificador B · escenarios: anti-robot-avanza-sola, anti-robot-ya-la-resolvi, clima-cordoba, wikipedia-mar-del-plata, primera-vez, noticias-la-nacion, otra-cosa, dolar-desde-cero

Evidencia:
- «Estás en localhost…», «En meteored.com.ar.», «En Mar del Plata — es.wikipedia.org.».
- «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.»
- [Leer la nota] en un pronóstico; «Es una nota de 7 párrafos» en Wikipedia; [Resumir la portada] en Deportes.
- «Titular 3 de 139», «+0,01%».

Causa probable: - `displaySite` vuelve al host si falta `og:site_name` o no se parece al dominio (`PageModel.swift:75-90`).
- `sectionTitle` es el título de la pestaña.
- `isArticle` llama «nota» a cualquier página con dos párrafos largos, y las etiquetas «nota»/«portada» son fijas (`Assistant.swift:1907-1916`).
- «localhost» es del fixture, pero la regla que lo produce es la misma.

Propuesta: - Nombres legibles («Meteored», «Wikipedia», «la portada del diario La Nación»).
- Si no hay nombre, usar el título de la página y no el dominio.
- Vocabulario por tipo de página: artículo, pronóstico, página, sección.
- Cantidades grandes en palabras.

Escéptico: Aparecen todas las citas: «En meteored.com.ar.», «En Mar del Plata — es.wikipedia.org.», «De vuelta en «Últimas noticias de Argentina y el mundo», LA NACION.», [Leer la nota] en el pronóstico, «Es una nota de 7 párrafos» en Wikipedia, [Resumir la portada] en Deportes, «Titular 3 de 139.» y «+0,01%». «Estás en localhost» sale del fixture, pero la regla que lo produce es la misma que dice «meteored.com.ar».

### P18 · El texto de botones y turnos sale alterado: palabras que la persona no dijo y signos perdidos

*menor* · confirmado · jueces: Marta, Lucía, Ana, Roberto, Verificador A · escenarios: banco-nacion, noticias-la-nacion, solo-botones-clarin, mercadolibre-auriculares

Evidencia:
- Tocó [Completar «DNI»] y quedó «Vos: completá el campo DNI».
- [Abrir «Salva vidas”. El medicamento…»]: falta la comilla de apertura.
- [Abrir «Habrá feriado por la visita del Papa León XIV?: …»]: falta el «¿».
- «Buscando: clarin.», sin tilde.
- [Abrir «Electrodomésticos y Aires Ac.»].

Causa probable: - El id del botón de `formOptions` guarda un pedido escrito, y `accept()` lo pasa a `ask()`, que lo registra como dicho por la persona (`Assistant.swift:1341-1344, 1957`).
- `short()` recorta puntuación de los dos extremos (`Assistant.swift:927`) y se come «“» y «¿».
- El target del ruteador pierde las tildes.

Propuesta: - Registrar el texto del botón tocado.
- En `short()`, recortar puntuación sólo al final.
- En «Buscando: …», usar las palabras de la persona.

Escéptico: Es cierto que tocó [Completar «DNI»] y quedó «Vos: completá el campo DNI»; que el original «“Salva vidas”» terminó en «Salva vidas”» y «¿Habrá feriado…» en «Habrá feriado…?», los dos recortados por short(); y que la persona escribió «clarín» y salió «Buscando: clarin.». Lo de «Electrodomésticos y Aires Ac.» no cuenta: es el texto tal cual de Mercado Libre (paginas/02.txt:76), no algo que haya cambiado JEF.

### P19 · Campo de escribir y botón Enviar poco visibles; la pista repite lo del dictado

*menor* · confirmado · jueces: Ana, Marta · escenarios: noticias-la-nacion, solo-botones-clarin, dolar-desde-cero, wikipedia-mar-del-plata, turno-anses, mercadolibre-auriculares, banco-nacion, primera-vez, clima-cordoba, otra-cosa, anti-robot-avanza-sola, anti-robot-ya-la-resolvi

Evidencia:
- «¿Qué querés hacer?» en gris sobre gris; Enviar es un círculo sin palabra.
- Pista en cada paso: «Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.»

Causa probable: - El placeholder usa `.secondary` (`AssistantPanel.swift:208`).
- El botón es sólo el ícono `arrow.up.circle.fill` (`AssistantPanel.swift:223-228`).
- La pista es fija (`AssistantPanel.swift:221`).

Propuesta: - Placeholder más oscuro y grande.
- Botón «Enviar» con texto y color fuerte.
- Pista breve («Pedido»); el dictado se explica una sola vez.

Escéptico: Real y de la app. En todas las capturas (por ejemplo primera-vez/paso-01.jpg y solo-botones-clarin/paso-03.jpg) se ve «¿Qué querés hacer?» en gris claro sobre fondo gris y, al lado, un círculo gris con una flecha, sin la palabra Enviar. El código coincide: `prompt: Text("¿Qué querés hacer?").foregroundStyle(.secondary)`, el botón es sólo `Image(systemName: "arrow.up.circle.fill")` y la pista es fija: «Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.» Un matiz: VoiceOver dice la pista cada vez que se llega al campo, no en cada paso, y el botón está gris porque se desactiva cuando el campo está vacío.

### P20 · La página de arriba no acompaña lo que se lee abajo

*menor* · confirmado · jueces: Ana · escenarios: solo-botones-clarin, wikipedia-mar-del-plata

Evidencia:
- Clarín: arriba nunca se vio el título de la nota, sólo el logo y las redes.
- Wikipedia: la página seguía arriba de todo mientras leía el final.

Causa probable: - `ReaderModel.go()` llama a `engine.scrollToTop()` (`ReaderView.swift:94`) y nada sincroniza el desplazamiento de la página con la lectura.

Propuesta: - Al abrir una nota, bajar la página hasta el h1.
- Al leer, hacer scrollIntoView del párrafo que se está leyendo.

Escéptico: Real y de la app. En Clarín, paso-03.jpg y paso-05.jpg muestran arriba sólo el logo, «Leé el diario de hoy» y los íconos de redes, sin el título de la nota, mientras abajo se lee el cuerpo. En Wikipedia, paso-05.jpg sigue mostrando el comienzo de la página («Mar del Plata / ciudad de la provincia…») mientras se leen los últimos párrafos, hasta «Fin de la nota». `ReaderView.swift:94` llama a `engine.scrollToTop()` y en el código no aparece nada que baje la página al compás de la lectura.

## Lo que funciona

- Respuestas a datos puntuales exactas y cortas, verificadas contra la página: blue «$1.530 / $1.550», fundación «10 de febrero de 1874», clima con fecha, mínima, máxima y viento, «El más barato… $12.499».
- Entiende la continuación del contexto: «¿y el oficial?» sin repetir «dólar», y «llevame a deportes» como sección del sitio donde se está (`abrir`), sin volver a buscar.
- El orden de resultados acertó siempre con el primero: oficial primero, patrocinados salteados, Córdoba de España descartada. Tocando siempre la primera opción se llegó a leer la nota de Clarín.
- Llegadas cortas y útiles: «Estás en el home banking del Banco Nación. Te pide tu DNI y tu usuario para ingresar.», «Estás en Clarín, en una nota sobre…», y cuatro titulares de la portada de un solo tirón.
- En Clarín, los titulares dichos y los botones coinciden: es el modelo a copiar para La Nación.
- «volvé» es inmediato y corto: «De vuelta en…».
- Recuerda la segunda mitad del pedido («Cuando elijas, sigo con…») y busca solo en el sitio.
- Honesto cuando está bloqueado: no inventó un precio detrás del captcha y pregunta el valor en vez de inventarlo.
- Detecta la prueba anti-robot. Cuando cambia la dirección, sigue solo con «Listo, ya pasamos la verificación» y retoma la tarea. «Ya la resolví» funciona en menos de un segundo.
- En una nota, «Leer la nota» va primero; «Seguir leyendo» es el primer botón y los párrafos se leen textuales.
- Los campos del formulario aparecen como botones «Completar «DNI»» / «Completar «Usuario»», y JEF nunca toca la contraseña.
- Toda respuesta termina en «Otra cosa», y «Otra cosa» lleva el cursor al campo.
- Cada pedido es un encabezado en la conversación y se puede recorrer con el rotor. Todo está en castellano, sin nombres internos.
- La pantalla inicial, sin página, es clara y deja las opciones a la vista (Ana).
