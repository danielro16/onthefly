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
3. **Un solo lugar para los próximos pasos:** la orientación devuelve el tipo
   de página y los pasos ordenados (abrir, completar, buscar en el sitio, leer,
   resumir, o una pregunta con opciones); se borran las reglas de los otros
   lugares.
4. **Costo y velocidad:** topes en los esquemas, el mismo tope de texto, Jev en
   paralelo.
5. **Voz:** un mensaje por turno.
6. **GLM-5.3 Flash** contra Gemini, en la estructura nueva.

Sitios de prueba, sin repetir: citas del IMSS (México), cita previa del DNI
(España), turnos del DMV (EE. UU.), INSS (Brasil), Amazon.
