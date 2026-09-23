# Notas de Daniel — prueba en el iPhone

Lo que Daniel va marcando al usar la app. Se anota tal cual, con dónde está
en el código, y se resuelve después, de a una.

## 2026-09-23

### 1. La pantalla de inicio no puede tener sugerencias cableadas

Al abrir la app aparecen tres botones fijos: «Llevame a La Nación», «¿A cuánto
está el dólar hoy?» y «¿Cómo va a estar el tiempo mañana?». Son de Argentina y
están escritos en el código: la app es global. Hay que pensar cómo es la
página de inicio al abrir el navegador.

- Dónde: `Assistant.starters` (`Sources/Intelligence/Assistant.swift`), que
  también se ofrece al tocar «orientar» sin página y cuando no queda otra
  opción; el texto de bienvenida, en `Sources/UI/AssistantPanel.swift:148`.
- Estado: por pensar, con Daniel.

### 2. «Quiero sacar turnos en Anses»: "No encontré resultados"

Buscó «Anses turnos» en Google y dijo "No encontré resultados". Enseguida:
"La página cambió: ahora estás en los resultados de «Anses turnos»". En el
teléfono apareció un cartel de Google pidiendo iniciar sesión con la cuenta.
Con «Intentar de nuevo» abrió «Solicitar turnos en ANSES» (argentina.gob.ar).

- Pista: "La página cambió" dice que los resultados aparecieron después de que
  JEF leyó la página; el cartel de Google puede estar tapándolos o
  demorándolos. En el simulador pasó lo mismo (ANSES y el clima, 2026-09-22):
  Google mostró los resultados sin la dirección en el título y el extractor
  sacó cero.
- Dónde: `Assistant.arrive` → `organic` → `results(of:)`.
- **Causa (registro del iPhone, 17:03):** Google mostró los resultados en otro
  formato: «Resultado web con vínculos a sitio, Solicitá un turno…», sin la
  dirección del sitio en el texto. `results(from:)` acepta un resultado de
  Google sólo si su texto trae la dirección (el link pasa por un salto de
  Google, `/url`), así que los descartó todos. A las 17:08, con «turnos
  Anses», vino el formato de siempre («Turnos, ANSES, https://www.anses.gob.ar»)
  y anduvo. El cartel de iniciar sesión no fue la causa: «La página cambió»
  releyó el mismo formato.
- Lo que se vio al arreglarlo: el destino del salto de Google viene cifrado
  (`/goto?url=CAES…`), no se puede leer. La causa real estaba en el extractor
  (`itemOf`): tomaba como título de la tarjeta el primer título aunque fuera
  invisible («Resultado web con vínculos a sitio», recortado a 1 píxel) y
  descartaba el texto del link, que es donde Google escribe el sitio.
- **Resuelto (2026-09-23):** el título de una tarjeta es el primer título
  visible, y la dirección que muestra su link se guarda aparte (`shown`); los
  resultados de Google la usan para saber el sitio. En el simulador, «anses
  turnos» vuelve a dar «Turnos — www.anses.gob.ar». Regresión del extractor
  (12 sitios) idéntica; búsquedas guardadas, 61 de 62 como antes.
- También: si al buscar carga otra cosa que la página de resultados (Google
  pidiendo comprobar que no es un robot), se cuenta lo que hay en vez de
  decir "No encontré resultados".

### 3. En ANSES quería sacar un turno y le ofreció consultar y reprogramar

Después de «Abrir «Solicitar un turno»», JEF llegó a la página de turnos de
ANSES (servicioswww.anses.gob.ar, "Buscar turno") y dijo: "Para lo que
viniste, la opción de consultar un turno ya sacado se encuentra en la lista
como número 4". Los botones fueron «CONSULTAR TURNO», «Reprogramación»,
«Resumir servicios», «Volver a «Turnos | ANSES»» y «Otra cosa».

- **Se perdió la intención.** La persona quiere *sacar* un turno, y le
  ofrecieron consultar y reprogramar uno ya sacado.
- **No ofreció lo que la página pide.** La página es la lista de trámites
  para los que se saca turno (Plan de Pago de Deuda Previsional, Solicitud de
  Jubilación, Solicitud de Pensión, Asignación Universal por Hijo, Desempleo,
  Progresar, Apoderado, Pensión Universal para Adultos Mayores…) y un buscador
  («Ingresá el nombre del trámite»). Lo ideal, según Daniel: preguntar "¿para
  qué trámite querés sacar el turno?", con los trámites como opciones.
- **Nombró un número interno** ("número 4"): es el pendiente de los ids
  opacos para orientar (ya anotado en la arquitectura).
- **Tuteo:** "puedes", "buscas", "viniste".
- **Causas:**
  - Los 18 trámites sí llegan a Gemini (el extractor los ve como lista) y la
    intención también («Sacas turnos Anses»). Gemini no siguió su regla de
    listas y eligió «CONSULTAR TURNO» y «Reprogramación», que van primero en
    la lista y dicen «turno».
  - El esquema de orientar no puede preguntar: sólo sugiere hasta 4 botones.
    No hay forma de devolver "¿para qué trámite?" con los trámites como
    opciones (reinterpretar sí la tiene: `pregunta` + `opciones`).
  - «Número 4»: la regla "si nombrás algo que la página da con un número,
    decí el número" (pensada para montos) más la lista numerada.
  - Tuteo: la regla "registro neutro, sin formas regionales" da «tú»; las
    frases fijas de JEF están en voseo.
- **Resuelto (2026-09-23), con Daniel:**
  - Orientar ya no recibe la lista numerada: cada opción lleva una marca de
    dos letras ("[bc]"), así no hay número interno que decir.
  - El esquema de orientar tiene `pregunta` + `opciones`: en una página que
    es una lista de opciones parecidas, si lo pedido no dice cuál, pregunta
    ("¿Qué trámite necesitás?") y los trámites van como botones, de a cuatro,
    en el orden de la página, con "Ver más opciones". La persona puede
    escribir o elegir.
  - Medido offline (7 páginas, 5 idiomas, 21 corridas): el prompt anterior
    12 de 21, el nuevo 21 de 21 (el caso de gov.br que "fallaba" era mío: esa
    página no tenía el seguro de desempleo). "Decí cuántas hay" se queda: sin
    esa frase la pregunta sale 1 de 6; con ella, 6 de 6. La cantidad que dice
    se verifica contra los botones que ofrece.
  - Lo que la persona escribe después se busca como cualquier pedido en la
    página: Jev, y si duda, Gemini con la lista. Si no está, afuera (Daniel:
    Google llega; la lista sigue a un "Volver").
  - "Buscar" con una página abierta sigue el mismo camino que "abrir"; si
    Jev está seguro de que no está (umbral `esta_no`), sale sin Gemini.
  - Después del primer paso, JEF sigue caminando solo sólo con confianza
    0,8 (`cual_seguir`): siguió de la lista a «CONSULTAR TURNO» con 0,52.
  - En el simulador: «quiero sacar un turno» → "¿Qué trámite necesitás
    realizar?" con los trámites; «jubilación» abre Solicitud de Jubilación.
- Queda: el tuteo (deuda).

### 4. «ir a turnos» en los resultados de Google entró a Imágenes

Algunas veces, después de buscar «turno anses», al pedir «ir a turnos» JEF
abrió la pestaña Imágenes de Google en vez de un resultado.

- Pista: en la página de resultados, las pestañas del buscador (Todo,
  Imágenes, Noticias…) están entre las opciones que ve Jev o Gemini; alguno
  eligió «Imágenes». Lo que se toca en la página de un buscador tendría que
  ser un resultado.
- Dónde: `run` (abrir) → `options(of:)` en una página de resultados.
- **Causa (registro, 17:07 y 17:08):** estaba en los resultados sin
  resultados (punto 2). Gemini decidió «abrir» con la referencia «Turnos |
  ANSES», que era el epígrafe de una imagen del bloque «Imágenes». Antes de
  preguntarle a Jev, el código busca una opción con ese nombre exacto
  (`exactOption`): la imagen se llamaba así, y la abrió sin consultar a nadie.
  Después describió el visor de imágenes como una nota («Leer la nota»).
- **Resuelto (2026-09-23):** en la página del buscador, "abrir" elige sólo
  entre los resultados. En el simulador, «Turnos Anses» abre el resultado de
  anses.gob.ar.

### 5. Vistos al probar (2026-09-23), sin resolver

- **Gemini rescata y la pregunta no coincide con los botones:** en La Nación,
  "¿la sección Política y Economía o el Dólar?" con botones «Dólar oficial»,
  «Dólar blue», «Dólar tarjeta». La pregunta nombra cosas que no son sus
  opciones (`reinterpret`).
- **"Acá no hay un formulario para completar", dos veces:** con región Estados
  Unidos, "entrá a mercado libre y buscame auriculares" llega a
  mercadolibre.com, el selector de país, y el pedido que seguía no tenía dónde
  escribirse.
- **El ruteador devolvió una dirección como búsqueda:** «Sacar turno» en los
  resultados de Google terminó en "Buscando: https://www.anses.gob.ar".

## Deuda (Daniel: "no es prioridad ahora")

- **Registro del idioma.** Decidir si JEF habla según el idioma y la región
  del teléfono (el de Daniel está en región Estados Unidos: saldría «tú») o
  siempre neutro, y en ese caso cambiar también las frases fijas de JEF, hoy
  en voseo. Ver punto 3.
- **La pantalla de inicio.** Qué hay al abrir la app, sin sugerencias
  cableadas. Ver punto 1.
