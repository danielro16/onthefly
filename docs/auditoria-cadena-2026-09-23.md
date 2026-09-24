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
