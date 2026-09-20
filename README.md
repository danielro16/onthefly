# JEF Browser

Navegador móvil que transforma cualquier web en algo accesible y nativo.

No muestra una web arreglada: extrae el contenido y lo **renderiza como app
nativa**. Por eso VoiceOver se comporta como en una app, no como en una página.

## Arquitectura

```
┌─────────────────────────────────────────────┐
│  WebView OCULTO — nunca se ve               │
│  · carga la URL real                        │
│  · corre Readability + extract.js           │
│  · devuelve bloques tipados por postMessage │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  Cascada de decisión                         │
│  0. código      filtros, landmarks   ~0ms   │  ✅ v0
│  1. heurísticas Readability          ~ms    │  ✅ v0
│  2. Jev         orden + intención    ~760ms │  ✅ v1
│  3. FM visión   alt-text             local  │  ⬜ v2
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  UI 100% NATIVA — SwiftUI                    │
│  rotores de sistema · links enfocables      │
└─────────────────────────────────────────────┘
```

## Por qué Swift y no React Native

La decisión se tomó con datos, no por preferencia:

- **facebook/react-native#24515** — VoiceOver no enfoca elementos anidados en
  iOS. Abierto desde abril 2019, sin resolver.
- **facebook/react-native#32004** — accesibilidad de texto anidado. Abierto
  desde agosto 2021, actividad en julio 2026, 33 comentarios.

Una página web es *texto con links adentro*. Si VoiceOver no puede enfocar cada
link dentro de un párrafo, no hay producto. Y RN no expone ninguna API para
`UIAccessibilityCustomRotor`, que es cómo la gente navega una página larga.

Ver [ANDROID.md](ANDROID.md) para el port futuro: el core de extracción se
comparte sin cambios.

## Estado

**v0 funcionando.** Sin IA todavía.

- [x] Extracción con Readability en WebView oculto
- [x] Bloques tipados: heading, paragraph, list, image, quote, code, table
- [x] Links inline enfocables individualmente (`AttributedString` + `.link`)
- [x] Rotores de sistema: encabezados, links, imágenes
- [x] Dynamic Type, anuncios a VoiceOver, estados de error
- [x] Inventario de acciones (forms, botones, nav) — lo que Readability tira
- [x] Detección de intención con Jev + pregunta al usuario si es ambiguo
- [x] Colapsado por relevancia, con la confianza como freno
- [x] Activar botones de la página desde la vista nativa
- [x] Formularios reconstruidos: texto, tel, email, radio, checkbox, select, textarea
- [x] Un solo WebView con sesión persistente: cookies y login sobreviven la navegación
- [x] Fallback a la página original cuando la reconstrucción falla o el usuario lo pide
- [ ] Probar con VoiceOver real end-to-end
- [ ] Calibrar umbrales contra páginas reales
- [x] Formularios de facto: grupos de inputs sin `<form>` (el buscador de vuelos)
- [x] Autocompletados: las sugerencias de la página como lista nativa
- [x] Navegación SPA (`pushState`) y páginas que cambian después de leídas
- [x] Captcha detectado y dicho, con la salida a la página original al lado
- [ ] Foundation Models: alt-text de imágenes sin descripción
- [ ] Caché por template

## El modelo de intención

Jev **no adivina qué quiere el usuario**. Detecta qué *ofrece* la página, y la
app decide qué hacer con esa distribución:

| Caso | Jev devuelve | Decisión |
|---|---|---|
| Artículo de Wikipedia | `read` 0.87, resto < 0.15 | asume, no molesta |
| Home de aerolínea | 5 tareas entre 0.85 y 0.93 | **pregunta** |
| Todo bajo el umbral | nada domina | no toca nada |

La regla que dispara la pregunta no es la probabilidad sola sino **el gap con
la segunda**: dos intenciones en 0.9 cada una es una página ambigua, no una
página confiable. Medido: Wikipedia gap 0.73 → asume; aerolínea gap 0.06 →
pregunta.

### Presencia no es prominencia

Se hacen **dos preguntas**, no una, y la distinción salió de medir contra el DOM
real de aerolineas.com.ar:

- `boolean` × 7 — *¿la página ofrece esto?*
- `choice` — *¿para qué está hecha principalmente?*

Solo con los booleans, "entrar a mi cuenta" salía primera (0.93) por encima de
"comprar o reservar" (0.85): la home tiene muchos botones de login y Plus, así
que la respuesta era correcta y el orden inútil. El `choice` contesta
`transact` con confianza 0.90 y promueve esa opción al frente del panel.

Panel resultante, contra el DOM real:

```
1. Comprar o reservar          ← primary choice, conf 0.90
2. Entrar a mi cuenta
3. Modificar algo que ya tengo ← check-in
4. Pedir ayuda o reclamar
5. Buscar un dato puntual      ← estado de vuelo
```

### Ruido del DOM real

El extractor filtra chrome que nunca es una tarea. En la home de la aerolínea
sacó **11 de 40 acciones**: banner de cookies, puntos de carrusel (`1`…`5`),
steppers de pasajeros, skip links. Sin ese filtro esas 11 ocupaban slots y
empujaban tareas reales más allá del límite de 40.

Guardarraíles, todos en `PageIntent.swift` y `PageAnalyzer.swift`:

- El contenido narrativo **nunca** se reordena; solo se colapsa lo irrelevante
- Headings y separadores están excluidos del ranking por diseño
- Un bloque se colapsa solo con confianza ≥ 0.6 — la duda deja todo como está
- Nada se borra: va a "Otros contenidos", siempre alcanzable y en el a11y tree
- Si Jev falla o no hay key, la app funciona como v0

## Correr

```bash
./Scripts/make-secrets.sh     # genera Secrets.xcconfig desde .env
xcodegen generate && open JEFBrowser.xcodeproj
```

Requiere Xcode 26+, iOS 26+. El proyecto se genera desde `project.yml` — no
commitear `JEFBrowser.xcodeproj`.

## Estructura

```
Sources/
├── Extraction/     ← compartido con Android, sin APIs de plataforma
│   ├── Readability.js     (Mozilla, Apache 2.0)
│   └── extract.js         DOM → bloques tipados
├── Engine/
│   ├── HeadlessWebView.swift   WKWebView invisible
│   └── PageModel.swift         contrato JSON
├── UI/
│   ├── ReaderView.swift        barra de direcciones y estados
│   └── ArticleView.swift       render nativo + rotores
└── Cache/          ← vacío, v1
```

## Notas

- `Link.start/end` son offsets **UTF-16** para mapear directo a `NSRange` (y a
  Kotlin después). No cambiar a code points.
- El contenido de una página es **hostil por definición**: `extract.js` parsea
  con `DOMParser` (inerte), el WebView filtra esquemas no-web, y los rangos de
  links se clampean antes de usarse.
- Jev no resiste inyección adversarial. Cuando entre en v1, sus decisiones no
  pueden ser la única barrera para nada que importe.

## Sesión y salida de emergencia

Hay **un solo WebView** para toda la vida de la app, con el `websiteDataStore`
por defecto — el mismo que usa Safari. Antes se creaba uno nuevo, sin
persistencia, por cada URL: eso hacía imposible cualquier cosa detrás de un
login, que es justamente donde están las tablas de un banco y los trámites de
ARCA. Ahora una navegación es una navegación, no una recarga: el POST que
acaba de ocurrir, la pestaña que se abrió, la sesión que se inició, todo sigue
ahí.

También se presenta como Safari (`Version/x Mobile Safari/604.1`), porque lo
es: mismo WebKit, mismo teléfono. El user agent pelado de WKWebView es lo que
MercadoLibre leyó como bot.

Y cuando la reconstrucción no alcanza —captcha, muro anti-bot, iframe de pago,
una página sin prosa ni acciones— el usuario **ve la página real**, dentro de
la app, con la navegación web normal de VoiceOver. Es el mismo WebView, así que
lo que haga ahí (resolver el captcha, iniciar sesión) sigue vigente al volver, y
lo que navegue se extrae solo y lo espera del lado nativo. Nadie queda en un
callejón sin salida: peor que la vista nativa, infinitamente mejor que "no se
pudo leer esta página".

## Interacción: el WebView como ejecutor

El WebView no solo extrae, también ejecuta. Sigue invisible, pero es
bidireccional.

Al extraer, cada control queda marcado con `data-jef-id` / `data-jef-field`.
Para activarlo, Swift le pide al elemento real que se haga click a sí mismo. Un
selector CSS se rompería en cualquier re-render; el atributo aguanta, y si el
nodo igual desapareció, la app lo detecta (`.stale`) y recarga.

**Por qué no alcanza con asignar `.value`:** React mantiene su propio value
tracker sobre el nodo e ignora una asignación directa, así que el estado del
componente nunca se entera y el campo se revierte en el próximo render. Hay que
llamar al setter del prototipo nativo y después disparar `input` y `change`, que
es lo que React, Angular y Vue realmente escuchan. Sin eso los campos se ven
llenos y se envían vacíos — peor que no ofrecerlos.

Radios y checkboxes no se llenan: se clickean, que es lo que hace una persona.

Verificado contra `httpbin.org/forms/post` leyendo el `FormData` del form —
lo que literalmente viaja en el POST: texto, teléfono, radio, checkbox y
textarea llegan correctos.

## Tres bugs que solo aparecieron ejecutando

**`isHidden` no medía el tamaño.** El buscador de Wikipedia es un `<input>`
real colapsado a 0×0 bajo un componente Vue. Pasaba el filtro, se extraía como
campo llenable, y la app escribía en un control que la página no lee. Ahora
cualquier elemento de menos de 2×2 se descarta.

**Los campos mostraban el atributo `name`.** "custname", "custtel" en vez de
"Customer name", "Telephone". `controlLabel` ahora resuelve el `<label>` como
lo hace un lector de pantalla — `for=`, label ancestro, `aria-label` — y deja
`name` como último recurso. Es exactamente el fallo que esta app existe para
arreglar.

**Los radios salían como N campos de texto.** "Pizza size: small / medium /
large" eran tres campos sueltos. Ahora se agrupan por `name` y se renderizan
como un solo control segmentado, que es lo que la página significa.

## Cobertura por patrón

Lo que rompe no es el rubro — es el patrón estructural. Un banco y un sitio de
gobierno fallan por lo mismo: tablas y trámites de varios pasos.

| Patrón | Dónde aparece | Estado |
|---|---|---|
| Artículo de prosa | noticias, wiki, blogs | ✅ |
| Menú de tareas | aerolíneas, gobierno | ✅ |
| Formulario simple | contacto, login, búsqueda | ✅ |
| **Listado repetido** | e-commerce, feeds, resultados | ✅ |
| Tabla de datos | bancos, gobierno, salud | ❌ marcada como hueco |
| Formulario sin `<form>` | toda SPA (buscador de vuelos) | ✅ |
| Autocompletado | aerolínea, e-commerce, direcciones | ✅ |
| Grilla de opciones (calendario de precios) | aerolínea | ✅ como "Elegí una opción, 34" |
| Navegación SPA / resultados que llegan tarde | toda SPA | ✅ |
| Trámite multi-paso | gobierno, checkout | ⚠️ la sesión aguanta; sin probar |
| Contenido tras login | bancos, salud | ⚠️ la sesión aguanta; sin probar |
| Scroll infinito | feeds, catálogos | ❌ sin probar |
| Modal / paywall | diarios | ❌ sin probar |
| iframe | pasarelas de pago | ⛔ cerrado por diseño → página original |
| Captcha / anti-bot | e-commerce | ✅ se dice y se ofrece la página original |

### Medido sobre sitios reales

| Sitio | Tipo | Paradas | Headings propios | Listados |
|---|---|---|---|---|
| httpbin/forms | formulario | 13 | — | — |
| ARCA (AFIP) | gobierno SPA | 71 | 12 | 8, 4, 4 |
| Banco Galicia | banco | 169 | 44 | 17, 9, 7 |
| aerolineas.com.ar | transporte SPA | 194 | **1** | — |
| MercadoLibre | e-commerce | 222 | 21 | *anti-bot* |
| Amazon | e-commerce | 307 | 55 | — |
| La Nación | diario | **432** | **192** | 13, 7, 4, 4 |
| Wikipedia | referencia | 4.087 | muchos | — |

**Los headings van de 1 a 192, y los dos extremos rompen igual.** Aerolíneas
tiene uno: el rotor no tiene a dónde ir. La Nación tiene 192: nadie navega 192
opciones. Agrupar sirve para los dos casos, por razones opuestas.

**MercadoLibre bloquea por anti-bot.** Nos devolvió una página "Seguridad". En
el teléfono del usuario, con su sesión y su user agent, probablemente no pase
— pero hay que verificarlo en dispositivo, no asumirlo.

**Las tablas están detrás del login.** En banco y AFIP no hay ninguna tabla en
la parte pública. El patrón más crítico no se puede medir sin credenciales, así
que habrá que implementarlo contra un caso sintético y validarlo con un usuario
real.

## Listados

Un catálogo es el mismo markup estampado N veces, y esa repetición ya está en
el DOM: detectarla no necesita modelo. Apareció en **todos** los sitios
muestreados, lo que la hace el patrón más universal medido.

Cada ítem es **una** parada de VoiceOver que dice lo que importa en el orden que
importa: qué es, cuánto cuesta, y después el resto. Sin esto el precio —el único
número por el que alguien entró— llega separado del producto al que pertenece.

El nombre del listado sale, por orden: del heading que la página pone antes, de
un `choice` de Jev entre seis tipos (noticias, productos, trámites, categorías,
resultados, enlaces) con confianza ≥ 0.5, y recién al final del conteo. Medido
en La Nación: 2 de 4 listados tenían heading propio, Jev nombró los otros.

## El enfoque de intenciones, medido a ciegas

Después de usar la app sin mirar la pantalla —leyendo sólo el árbol de
accesibilidad con `Scripts/voiceover-walk.py` y tocando por etiqueta con
`Scripts/voiceover-tap.py`— en Google, Wikipedia, La Nación, Aerolíneas (home
y resultados) y MercadoLibre, esto es lo que aguanta y lo que no.

**Lo que aguanta.** "¿Para qué está hecha esta página?" es la pregunta
correcta como *primera* decisión, porque decide el orden, y el orden es todo
para quien navega linealmente: en Google el buscador va primero (`lookup`), en
La Nación los titulares (`read`) con las acciones al final, en Aerolíneas el
formulario de vuelos (`transact`). En los cuatro Jev acertó la intención
principal con confianza alta (0.74 a 1.00), y con el orden correcto las
paradas caen de 182 a 16 y de 336 a 40 sin perder ningún titular.

**Lo que no aguanta: clasificar acción por acción.** Los 34 botones de un
calendario de precios son *un* control para una persona. Juzgados uno por uno,
Jev los repartió entre "Comparar", "Comprar" y "Consultar" según lo que dijera
cada etiqueta, y en la corrida siguiente los mandó enteros a "Gestionar lo que
ya tengo", contraídos detrás de "¿Qué querés hacer?". No es un problema de
calibración: la etiqueta "10 de octubre de 2026, 112935 ARS" no contiene la
información de que hay 33 hermanas iguales. Esa información está en el DOM, y
el DOM la da gratis. Por eso los hermanos de igual forma viajan como un
`cluster`, se juzgan una vez, y cuando un cluster es la mayoría de la página
lidera como lo que es —"Elegí una opción, 34 opciones"— sin que nadie pregunte.

**La regla que sale de esto.** Jev decide *intención* (qué quiere hacer alguien
acá) y elige entre nombres que ya existen. La *estructura* —qué es un
formulario, qué es una grilla, qué es el paso siguiente, qué es un aviso que
bloquea— se decide en código, antes, porque el DOM la declara y un modelo sólo
puede perderla. Cada vez que el código sabe la respuesta, preguntar es ruido:
la pregunta con cuatro categorías contraídas sobre un calendario fue la peor
pantalla de la sesión.

**Lo que la intención no resuelve.** Las llamadas a la acción: para Jev
"Continuar" es una transacción, pero en la pantalla de resultados es *el paso
siguiente*, y filado bajo "Más de este sitio" quedaba a tres niveles del día
que el usuario acababa de elegir. Un CTA vive en el flujo, no en una categoría.
Y la variabilidad: la misma página dio `assume(compare)` a 0.94 y `ask` en
corridas consecutivas. Los umbrales siguen sin calibrar; el sesgo elegido
(preguntar antes que ordenar mal) es correcto, pero la pregunta tiene que ser
la excepción, no la salida por defecto.

**Sobre "proponer según el tipo de sitio".** No hace falta un catálogo de tipos
de sitio. Lo que rompe es estructural y se repite entre rubros: el formulario
sin `<form>` (aerolínea, pero cualquier SPA), el autocompletado (aerolínea,
e-commerce, direcciones), la navegación por `pushState` (todas las SPA), el
captcha (e-commerce, bancos), los listados (todos). Cada patrón se resolvió una
vez y sirve para todos. La intención elige el *orden* entre esos patrones; no
los reemplaza.

## Deuda conocida

**La API key viaja en el binario.** `Secrets.xcconfig` la inyecta en el
Info.plist, lo cual está bien para desarrollar y mal para publicar: cualquiera
puede extraerla de un `.ipa`. Antes de ship, las llamadas a Jev tienen que pasar
por un backend propio que guarde la key. No es refactor grande — `JevClient`
solo cambia de endpoint — pero no puede olvidarse.

**Los umbrales no están calibrados.** `dominant: 0.75`, `plausible: 0.45`,
`confidence ≥ 0.6` son puntos de partida conservadores, no medidos. La guía de
TypeSafe es calibrarlos contra datos etiquetados del dominio. El sesgo elegido
es preguntar de más antes que reordenar mal.

**El buscador de vuelos no se detecta como formulario.** En aerolineas.com.ar
`collectActions` encontró 0 `<form>`: el buscador es un div con botones, como
en casi toda SPA moderna. Se rescata por los botones ("VUELOS", "Buscar
vuelos") pero se pierden los campos (origen, destino, fechas), que es
justamente lo que haría falta para guiar a alguien a completarlo. Falta
detectar formularios de facto — grupos de inputs sin `<form>`.

**La página tenía un solo heading.** Las SPA modernas casi no usan headings
semánticos, así que la navegación por encabezados —la más usada en VoiceOver—
tiene poco a qué agarrarse. Inferir jerarquía donde el DOM no la declara es
trabajo pendiente, y probablemente otro uso de Jev.

Ver [JEV.md](JEV.md) para la referencia de Jev y AI Gateway.
