# Auditoría de la cadena intención → contexto → elementos → próximos pasos

2026-09-23. Sólo código (rama `f1-arquitectura`, commit `4a9df19`), sin
simulador ni iPhone. Pedida por Daniel: revisar si la lógica, la tecnología y
el código sirven para una buena experiencia de quien usa JEF. Complementa
[diagnostico-2026-09-23.md](diagnostico-2026-09-23.md) y la auditoría de
reglas del 22/9 ([auditoria-hardcodeo.md](auditoria-hardcodeo.md)).

## Veredicto

**La tecnología es la correcta y las piezas están; la cadena no está
conectada.** Gemini para entender y redactar, Jev para juzgar rápido con
probabilidad, el código para los estándares y los seguros: ese reparto es
bueno. El problema es de estructura:

- cada eslabón vive en un lugar distinto;
- cada modelo ve una página distinta;
- la intención no se guarda;
- los botones los arman once lugares con reglas propias que se pisan entre sí.

Por eso cada arreglo puntual rompe otra cosa: no hay un lugar único donde se
decida "qué le ofrecemos a esta persona ahora".

## Los eslabones

### 1. Intención — crítico

- **No existe "la tarea".** Lo que la persona quiere vive en cinco variables
  con vidas distintas: `lastRequest`, `previousRequest`, `runningTask`,
  `waiting` y `pendingQuestion` (Assistant.swift). `lastRequest` se pisa con
  cualquier mensaje escrito ([Assistant.swift:287](../Sources/Intelligence/Assistant.swift)):
  después de «quiero sacar un turno en ANSES», un «volvé» o un «¿y eso qué
  es?» pasa a ser "lo que vino a hacer".
- **Cada uno recibe una intención distinta.** La orientación recibe
  `lastRequest`; Jev, sólo el mensaje actual; el ruteador, el mensaje actual y
  el anterior. Nadie recibe la tarea completa.
- **`rest` no es memoria.** Sólo sirve para una frase con dos pasos ("entrá a
  ANSES y pedí un turno"). Si la persona dice el segundo paso en otro mensaje,
  se pierde.
- **Qué falta:** una tarea explícita. La declara la persona y la mantiene el
  ruteador (sigue la misma / es nueva). Se pasa igual a Gemini y a Jev en cada
  paso. Es la fase F4 del plan.

### 2. Contexto (la web) — alto

- **El ruteador decide sin ver los elementos.** Recibe el texto de la página
  (cortado en 6000 caracteres) y sólo los campos de los formularios, no los
  links ni los botones ([Router.swift](../Sources/Intelligence/Router.swift),
  `decide`). Decide si algo "está en la página" (abrir/responder) o "hay que
  buscarlo" sin saber qué se puede tocar. De ahí salen, por ejemplo, «Sacar
  turno» → "orientar" o una dirección como búsqueda.
- **`Router.state` son conteos** ("la página lista 42 titulares"), no qué es
  la página ni para qué sirve.
- **Cada modelo ve un tamaño distinto de página.** El ruteador y reinterpretar
  ven 6000 caracteres; orientar, contestar y resumir, la página entera, sin
  límite ([Answerer.swift](../Sources/Intelligence/Answerer.swift): `texto`
  sin `prefix`). El que entiende a la persona ve menos que el que describe.
- **El tipo de página lo decide el código con umbrales y palabras**, y ese tipo
  cambia todo el recorrido:
  - `readsHeadlines`: portada si hay 8 titulares o más;
  - `isArticle`: nota si hay dos párrafos de 160 caracteres o más, salvo 15
    titulares con menos de 6 largos;
  - `isSubscription` / `isWall`: palabras "suscri|login|iniciar sesion|/ingresar";
  - `isChallenge`: "captcha|codigo de imagen…";
  - `isQuestion`: "quien|cuant|donde|cuand|porqu".
  
  Son justo las reglas que no escalan a miles de millones de sitios.

### 3. Elementos (orden, qué se ve) — alto

- **Cuatro vistas distintas de la misma página:**

  | Quién | Qué lista ve | Cuántos | Orden |
  |---|---|---|---|
  | Jev | `options(of:)`: todo, menús incluidos | hasta 240 | primero los botones sueltos, después listas y links |
  | Gemini al orientar | `candidates(of:)`: sin menú, encabezado ni pie | hasta 40 + formularios | primero lo que el código cree titulares |
  | Gemini al reinterpretar | `options(of:)`, numerada | todos | el de `options` |
  | Ruteador | ninguna (sólo formularios) | — | — |

  Consecuencias:
  - En La Nación, «Economía» está en el menú: Jev la ve y la orientación no.
  - En ANSES, «CONSULTAR TURNO» le llega a Gemini antes que los trámites,
    aunque en la página está abajo.
  - Los números o marcas de cada lista no coinciden entre modelos.
- **El orden lo pone el código, no la página ni la intención**
  (`options(of:)`, [Assistant.swift:3019](../Sources/Intelligence/Assistant.swift)).
  `readingOrder` (el orden real) se usa sólo para las opciones de una pregunta.
- **El corte a 40 lo decide el código**, poniendo primero lo que parecen
  titulares, no por relevancia para la tarea.

### 4. Cómo se muestra (próximos pasos) — alto

- **Once lugares arman los botones** (`offer = Offer(`), cada uno con reglas
  propias:
  - `arrived`: sugerencias de Gemini, pisadas por el código:
    - en una portada, los 4 primeros titulares;
    - en una nota, "Leer" y "Resumir" fijos más una nota que comparta una raíz
      de 5 letras con el título;
    - en una portada con pedido, lo que comparta una raíz de 5 letras con el
      pedido.
  - `closeTurn` ([2358](../Sources/Intelligence/Assistant.swift)): el
    formulario de la página siempre primero (el «Completar «buscador»» y
    «Pulsar «Search»» de ANSES), después Volver y Otra cosa, con un tope de 5.
  - `followUps`: formularios, Leer y Resumir según el tipo de página.
  - `present` (resultados), `offerChoices` (preguntas), `nextQuestions`,
    `searchInstead`, `failedTurn`, `submitAsked`, los ejemplos del inicio.
- **Las raíces de 5 letras dependen del idioma**: no andan con palabras cortas
  ("PAMI", "tren"), sinónimos, chino o japonés.
- **71 frases fijas en castellano rioplatense** (`say("…")`) conviven con lo
  que redacta Gemini en neutro/tú: el registro se mezcla, y en otro idioma
  JEF habla la mitad en castellano.
- **Instrucciones en vez de llevar:** si el ruteador llena `question`, la
  página de Google se contesta con sus fragmentos
  ([Assistant.swift:814](../Sources/Intelligence/Assistant.swift)), aunque la
  persona haya pedido hacer algo.

## Otros factores que definen la experiencia

### 5. Velocidad — medio-alto

En cada paso los modelos van en fila, sin paralelismo: ruteador (Gemini, con
razonamiento) → contestar (Gemini, si hubo pregunta) → Jev ¿cuál? (dos rondas)
→ reinterpretar (Gemini, si Jev duda) → carga de la página → orientar
(Gemini, página entera). La arquitectura acordada decía "Gemini ‖ Jev" en
paralelo y no está hecho. Un paso típico son 4 a 8 segundos; el peor, más de
10. Para quien escucha, es silencio.

### 6. La voz — medio

Un turno dice varios mensajes seguidos ("No está en esta página." ·
"Buscando: …" · "Estás en los resultados…"), cada uno en su propia cola de
VoiceOver. Es el problema n.º 1 de la ronda 17 (un solo mensaje, con el
foco) y sigue abierto.

### 7. Confianza y salida — bien

Esto está bien resuelto y hay que conservarlo:
- JEF no aprieta solo lo que paga o confirma;
- lo que se escribe tiene que haberlo dicho la persona;
- las contraseñas no viajan;
- las cifras se verifican contra la página;
- los resultados van en el orden del buscador y sin anuncios;
- siempre hay Volver y Otra cosa.

## Qué cambiar, por estructura (no por casos)

1. **Una tarea.** La mantiene el ruteador y viaja a todos.
2. **Un solo mapa de la página**, en el orden de la página, con marcas
   estables. Lo usan todos: Jev completo, Gemini completo o recortado igual, y
   el ruteador en versión compacta. Las mismas marcas en todos lados.
3. **Un solo lugar que decide los próximos pasos:** la orientación de Gemini,
   sobre ese mapa y con la tarea. Devuelve el tipo de página y los pasos
   ordenados por probabilidad: abrir, completar, buscar en el sitio, leer,
   resumir, o una pregunta con opciones. El código sólo valida (que la marca
   exista, los seguros) y agrega la salida. Se borran las reglas de los otros
   diez lugares.
4. **El tipo de página, del modelo.** Sale de esa misma llamada; se borran
   `readsHeadlines`, `isArticle`, `isWall`, `isSubscription`, `isQuestion` y
   las raíces de 5 letras.
5. **Velocidad:** Jev y Gemini en paralelo donde no dependen uno del otro, y
   el mismo tope de texto para todos. Se mide.
6. **Voz:** un mensaje por turno.
7. **Idioma de las frases fijas:** en la deuda (registro del idioma).

Los puntos 1 a 4 son el mismo cambio visto desde cuatro lados. Los 5 y 6 son
independientes.

## Costo (agregado después, con Daniel)

Daniel: "Además de eso es muy caro. Solamente lo que estuvimos probando me
costó esto (US$ 1,93 en Gemini, 22 y 23/9). El costo de la arquitectura
también hay que considerarlo."

Cuenta hecha con el tamaño real de las páginas de las pruebas (mediana ~4.000
caracteres, p90 ~12.000) y los prompts de hoy, con Gemini 3.1 Flash-Lite
($0,25 / $1,50 por millón de tokens):

| | Página mediana | Página grande (p90) |
|---|---|---|
| Ruteador | $0,0010 | $0,0011 |
| Orientar | $0,0014 | $0,0020 |
| Un paso típico | $0,0024 | $0,0031 |

Con 10 pasos por persona por día, 1.000 personas diarias cuestan unos
US$ 750–900 por mes. Los US$ 1,93 fueron casi todo pruebas (~700 llamadas).

Lo que más pesa es la salida (6 veces más cara que la entrada): el
razonamiento del ruteador (~300 tokens por mensaje), las listas que devuelve
orientar y nadie usa (en La Nación, ~30 cifras de toda la página), y hasta
cuatro llamadas a Gemini en un mismo paso. Palancas: una llamada de Gemini por
página, topes en los esquemas, medir el razonamiento del ruteador (lo decide
Daniel), caché por página en el backend (F5), y Jev donde alcance (unas 40
veces más barato por pregunta).

## Modelos candidatos

De la tabla de precios de Vercel que trajo Daniel, más inteligentes y más
baratos que Gemini 3.1 Flash-Lite: GLM-5.3 Flash ($0,15 / $0,50, AA 42),
Qwen 3.8 Flash-Next ($0,15 / $0,47, AA 40), DeepSeek V4.1 Flash ($0,15 /
$0,60 fuera de hora, AA 39), Xiaomi MiMo 2.6 Pro ($0,435 / $0,87, AA 46).
El índice no alcanza: deciden también la velocidad, que cumpla `json_schema`
siempre, los idiomas, la privacidad (qué proveedores no guardan los datos en
Vercel) y que el precio sea estable. **Daniel elige probar GLM-5.3 Flash,
después de los ajustes.**

### GLM-5.3 Flash contra Gemini 3.1 Flash-Lite (23/9, después del paso 1)

Daniel cargó crédito en Vercel (el plan gratis no da GLM). Comparación directa,
sin jueces, con los prompts de la app y páginas reales nuevas cargadas con el
extractor: Correos (España), SAT y Liverpool (México), USPS (EE. UU.), El
Tiempo (Colombia), Renfe (España), ChileAtiende (Chile), gob.pe (Perú) y gub.uy
(Uruguay); 30 pedidos, dos veces cada uno. La Registraduría (Colombia) se cayó
de la muestra: el extractor sacó un solo botón.

| | Gemini 3.1 Flash-Lite | GLM-5.3 Flash |
|---|---|---|
| Ruteador: acción correcta | 50 de 60 | 46 de 60 |
| Ruteador: tarea sigue/nueva | 10 de 14 | 13 de 14 |
| Ruteador: misma decisión dos veces | 25 de 30 | 21 de 30 |
| Ruteador: tiempo (mediana / peor) | 1,5 / 3,4 s | 1,9 / 7,7 s |
| Orientar: tiempo (mediana / peor) | 1,8 / 2,7 s | 2,1 / 4,9 s |
| Costo por decisión del ruteador | US$ 0,00064 | US$ 0,00043 |
| Costo por orientación | US$ 0,00138 | US$ 0,00061 |
| Un paso (ruteador + orientar) | ~US$ 0,0020 | ~US$ 0,0010 |

GLM cuesta la mitad y sus textos suelen ser más directos, pero comete más
errores que la persona no puede detectar: en Renfe ofreció «Buscar billete»
en un botón que resume la página y «Poner Madrid como origen» en un link a la
página de Madrid; en El Tiempo dijo «la abro para leerle los detalles» (no la
abre, y en usted) y ofreció «Leer la nota» en una portada; en el ruteador
escribió JSON adentro del campo `then` («buscame unos tenis Nike» quedaría
escrito y sin buscar). Gemini: marca «sigue» sin tarea, y en Correos puso el
número de seguimiento que dijo la persona entre sus cifras, así que la app
descartaría la orientación (la verificación de cifras no mira lo que dijo la
persona: error nuestro, de código).

**Recomendación:** seguir con Gemini por ahora y volver a medir GLM después del
paso 3, cuando la orientación devuelva pasos tipados que el código valida (ahí
el botón mal tipado deja de ser posible) y los topes del paso 4 bajen la
salida.

## Plan de ajustes (acordado con Daniel, 2026-09-23)

Un paso por vez; cada uno se prueba en un sitio nuevo de otro país y lo prueba
Daniel. Punto de partida marcado con la etiqueta `antes-de-ajustes`.

1. **La tarea:** el ruteador devuelve "tarea" (sigue / nueva); una sola
   variable en el código; la reciben Gemini y Jev.
   **Hecho (23/9):** `task` en Assistant; la reciben el ruteador, la
   orientación y reinterpretar. Probado en el IMSS (México) y en la cita del
   DNI (España): «nueva» al empezar, «sigue» en «medicina familiar», «volvé»,
   «renovación» y «¿qué necesito para la cita?»; al llegar, la orientación
   habla de la cita. **Jev todavía no la recibe:** medido en el IMSS con la
   lista real, sin la tarea Jev dice «ninguno» y decide Gemini; con la tarea
   (en un campo aparte o pegada al pedido) toca «Suscribirse a cita médica»
   (0,62–0,91), porque el link bueno se llama sólo «Leer». Con el link
   nombrado por su tarjeta y la tarea pegada al pedido, elige el bueno
   (0,89). Va en el paso 2, con el mapa, y se vuelve a medir ahí.
2. **Un solo mapa de la página:** en el orden de la página, con las mismas
   marcas para todos.
   **Hecho (23/9):** `options(of:)` es el mapa: en el orden de la página, con
   los links de adentro de los párrafos, y lo ven igual Jev, la orientación
   y reinterpretar (se borraron `candidates(of:)` y `readingOrder`). El
   extractor nombra un link que no se nombra solo con su tarjeta
   (`context`: «Agenda tu Cita Médica Digital — Leer», «¿Estás esperando un
   envío? — MÁS INFO»), por estructura y no por palabras; en 21 sitios
   cambió 20 nombres, todos a mejor. Jev recibe la tarea pegada al pedido.
   En el IMSS, «medicina familiar» ahora abre la cita y llega sola al
   formulario de Cita Médica Digital (antes tocaba «Suscribirse»). La
   orientación ve el menú y el pie (en el SAT, 46 elementos contra 3): ~500
   tokens más por página en promedio, US$ 0,00008 con GLM. El ruteador sigue
   con su lista de campos de formulario.
3. **Un solo lugar para los próximos pasos:** la orientación devuelve el tipo
   de página y los pasos ordenados (abrir, completar, buscar en el sitio, leer,
   resumir, o una pregunta con opciones); se borran las reglas de los otros
   lugares.
   **Hecho, primera parte (23/9):** la orientación devuelve `tipo_de_pagina`
   (portada, nota, otra) y los pasos en su orden, con un paso nuevo,
   `completar`: el buscador del sitio es un solo botón con nombre («Buscar en
   Gob.pe»), que pregunta qué buscar y busca. Se borraron `isWall`,
   `isSubscription`, `stems`, `formOptions`, el formulario primero de
   `closeTurn`, las reglas de nota de `arrived` y de `followUps`; `readsHeadlines`
   e `isArticle` leen lo que dijo el modelo; `isQuestion` mira los signos de
   pregunta, en cualquier escritura. Después de leer o contestar se vuelven a
   ofrecer los pasos de la orientación. El código verifica dos cosas del
   contrato: en una portada, sin tarea, no hay sugerencias además de los
   titulares; y leer y resumir los nombra el código. Probado: ANSES (ya no
   «Completar «buscador»» ni «Pulsar «Search»»; los trámites como pregunta),
   gob.pe (buscar «pasaporte» con un botón), El Comercio (portada y nota),
   IMSS.
   **Segunda parte (23/9):** los avisos que tapan la página (cookies, boletín,
   edad, otros) ponen sus botones primero y entran al mapa, así que Jev los
   encuentra si la persona los pide por escrito. Decide la persona: la app no
   acepta ni rechaza por nadie (la decisión escrita en `Overlay`). Al tocar
   uno, si la página quedó igual y sin aviso, «Listo: el aviso se cerró.» y
   siguen sus pasos, sin volver a describirla. Probado en La Vanguardia:
   «Rechazar» cerró el aviso y el sitio mostró otro (pagar o aceptar), que
   también quedó primero; El Mundo y 20minutos, con sus avisos primero.

   Vistos en las pruebas, para después (no son de este paso):
   - gob.pe: los resultados de su buscador llegan sin título (el extractor
     toma la institución y la descripción).
   - El Comercio: al leer una nota, los primeros párrafos son el menú.
   - El ruteador a veces devuelve como `rest` el mismo pedido
     («medicina familiar»), y se procesa dos veces.
   - «gob.pe» escrito sin www no carga (los navegadores prueban con www).
   - Los links `http://` los bloquea iOS (ATS); un link que descarga un
     archivo (RSS) deja a JEF sin página.
   - USPS: «FREE BOXES» del menú abre el buscador del sitio y Jev lo vuelve a
     elegir en los resultados.
   - Correos (correos.es) no se lee en el simulador («No readable content
     found»), también con el extractor anterior: ya pasaba.
   - GLM duda del tipo en páginas ambiguas (IMSS: portada, nota u otra) y a
     veces ofrece un solo paso donde se piden dos a cuatro.
4. **Costo y velocidad:** topes en los esquemas, el mismo tope de texto, Jev en
   paralelo.
   **Idea de Daniel (24/9), hecha:** las decisiones son variables en un JSON y
   las contesta Jev con probabilidad; el modelo grande, sólo si Jev duda.
   Primeras dos: `sitio` (tienda, gobierno, banco, diario, salud, educación,
   viajes, servicios, institución, referencia, buscador, landing, otra) y
   `pagina` (portada, nota, inicio, lista, producto, resultados, formulario,
   ingreso, pago, otra), en `criterios.json`. Medido en 27 páginas de 9
   países: con seguridad ≥ 0,7 (umbral `tipo`), 48 de 48 sitios y 45 de 45
   páginas bien, en 0,45 s. Lo seguro llega a la orientación como dato
   («site: store; page: home») y decide cómo se lee la página; si no, decide
   el modelo. Queda en el registro («tipo»). Probado: Liverpool (tienda →
   «Buscar productos en Liverpool»), El Universo (diario, portada), gob.cl.
   Los avisos: sólo los que piden una decisión de la persona (cookies, edad)
   van primero, sin su ruido pero nunca sin salida; la propaganda (bajar la
   app) no, porque no le impide nada a JEF.
   Pendiente: el tipo de aviso lo decide el extractor por palabras
   («cookie|consentimiento|privacidad»); es una variable para Jev.
   **Costo y velocidad (24/9):** un solo tope de texto de la página para los
   que deciden (`Gemini.pageLimit`, 6.000 letras: ruteador, orientación,
   reinterpretar); contestar y resumir leen la página entera. Con GLM lo que
   pesa es lo que se lee: en una portada grande (La Nación, Clarín, El Tiempo)
   ahorra ~3.500–4.300 tokens, la mitad de esa orientación; en la media, ~400.
   Jev busca en la página mientras el ruteador decide, y su respuesta se usa
   si la página, el pedido y los elementos son los mismos: en el IMSS, de
   pedir a «Abriendo…» pasó de 2,1–5,2 s a 1,5–2,2 s.
   Para decidir con Daniel: (1) el ruteador razonando o no (con GLM: 51 de 60
   y 2,0 s razonando; 47 de 60 y 1,3 s sin); (2) `cual_confianza` 0,5: en
   cinco corridas del IMSS, Jev eligió bien cuatro veces con ≥ 0,80 y una vez
   mal con 0,57 («Suscribirse»); con 0,7 esa iría al modelo.
5. **Voz:** un mensaje por turno.
6. **GLM-5.3 Flash** contra Gemini, en la estructura nueva.

Sitios de prueba, sin repetir: citas del IMSS (México), cita previa del DNI
(España), turnos del DMV (EE. UU.), INSS (Brasil), Amazon.

### Cuatro modelos baratos (23/9, a la noche)

Daniel: "No hay manera de poder usar Gemini. Vamos a usar GLM como nuestro
modelo base, pero comparemos con otros similares, donde no haya casi
diferencia de costo." Mismos 30 pedidos y 9 páginas que arriba.

| Ruteador | Acción correcta | Tarea bien | Rotas | Mediana | US$ por decisión |
|---|---|---|---|---|---|
| GLM-5.3 Flash, razonando | 51/60 | 10/14 | 4 | 2,0 s | 0,00043 |
| GLM-5.3 Flash, sin razonar | 47/60 | 12/14 | 0 | 1,3 s | 0,00036 |
| Qwen 3.8 Flash, sin razonar | 52/60 | 14/14 | 0 | 3,3 s | 0,00039 |
| Qwen 3.8 Flash, razonando | 40/60 | 8/14 | 7 | 18,3 s | 0,00077 |
| DeepSeek V4 Flash, sin razonar | 37/60 | 12/14 | 0 | 1,1 s | 0,00033 |
| MiMo 2.6 Flash | 46/60 | 5/14 | 55 de 56 fuera del esquema | 5,8 s | 0,00034 |

Orientar: Qwen, el más corto y directo (~140 caracteres, 3,9 s); GLM ~230
caracteres, con dos cifras que no están en la página; DeepSeek ~290 y un texto
cortado a la mitad. Los tres, ~US$ 0,0006 por página. Un paso cuesta ~US$ 0,0010
con cualquiera de los tres, la mitad que con Gemini.

En el simulador (DMV de California, Amazon México, INSS de Brasil; corridas
`Tests/corridas/2026-09-23_modelo-*`), una corrida por modelo: Qwen llegó a la
página de citas del DMV y explicó el primer paso; GLM escribió la pregunta en
el buscador del sitio; DeepSeek llegó al portal del INSS pero habla de más;
MiMo rompió la orientación ("Logo, Logo, Logo").

**Lo que marcó Daniel, y queda como criterio:** esto midió sólo el primer paso
y una o dos preguntas; lo que decide es quién completa la tarea entera. Y la
mayoría de las fallas vistas eran del código, no del modelo: links sin
contexto, reglas viejas en los botones, el pedido que se escribe en el campo
después de "¿Qué pongo en…?", las cifras que dijo la persona, las cookies y
ventanas emergentes que nadie cierra (el extractor las detecta con sus
botones, pero JEF sólo las menciona). **Primero se pule el código (pasos 2 a 5
y las ventanas emergentes); recién después se comparan los modelos con tareas
completas.** Mientras tanto la app usa GLM-5.3 Flash (`Gemini.base`), con los
ajustes de prueba `modelo` y `razonar`.
