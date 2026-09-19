# Stack Android — para abordar a futuro

Notas para cuando toque portar. **No hay código Android todavía.** Esto es la
decisión tomada de antemano para que el port no obligue a rediseñar nada.

## Regla de oro

`Sources/Extraction/` se copia **sin modificar** a `app/src/main/assets/`.

`extract.js` y `Readability.js` son el core compartido y no pueden tocar APIs de
plataforma. Si alguna vez necesitás una rama `if (iOS)` dentro de esos archivos,
está mal diseñado: el dato que te falta tiene que salir por el JSON y decidirse
del lado nativo.

`extract.js` ya sale preparado — el envío tiene los dos caminos:

```js
try {
  window.webkit.messageHandlers.jefExtract.postMessage(json);  // iOS
} catch (e) {
  if (window.jefExtract && window.jefExtract.postMessage) {
    window.jefExtract.postMessage(json);                        // Android
  }
}
```

## Qué se comparte y qué no

| Capa | iOS | Android | ¿Compartido? |
|---|---|---|---|
| Extracción | `extract.js` + `Readability.js` | idénticos | **sí, tal cual** |
| Contrato JSON | `PageModel.swift` | `PageModel.kt` | mismo shape, se reescribe |
| Motor | `WKWebView` | `android.webkit.WebView` | no |
| Bridge | `WKScriptMessageHandler` | `@JavascriptInterface` | no |
| UI | SwiftUI | Jetpack Compose | no |
| Llamada a Jev | URLSession | OkHttp / Ktor | HTTP plano, ~50 líneas |
| Caché | SQLite | Room | no |

Lo caro es la extracción, y esa se comparte entera.

## Stack

- **Kotlin** + **Jetpack Compose**
- **androidx.webkit** (`WebViewCompat`) — no el `WebView` pelado
- **Coil** para imágenes
- **Room** para el caché de templates
- **Ktor client** o **OkHttp** para Jev

## Los tres puntos donde Android difiere de verdad

### 1. Inyectar al inicio del documento

iOS tiene `WKUserScript(injectionTime: .atDocumentStart)`. El `WebView` pelado de
Android no tiene equivalente — `onPageFinished` llega tarde y deja correr scripts
de la página antes que los tuyos.

Usar `androidx.webkit`:

```kotlin
if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
    WebViewCompat.addDocumentStartJavaScript(
        webView,
        readabilitySource,
        setOf("*")          // acotar a los orígenes que cargás
    )
}
```

Si el feature no está soportado en ese dispositivo, el fallback es
`evaluateJavascript()` en `onPageStarted`. Es peor pero funciona.

### 2. El bridge es una superficie de ataque

`addJavascriptInterface` expone un objeto Java al JS de la página. Cualquier
frame que corra puede llamarlo.

```kotlin
class ExtractBridge(private val onResult: (String) -> Unit) {
    @JavascriptInterface
    fun postMessage(json: String) = onResult(json)
}
webView.addJavascriptInterface(ExtractBridge(::handle), "jefExtract")
```

Reglas, no sugerencias:
- **Solo** el método `postMessage`, nada más anotado con `@JavascriptInterface`
- Validar el JSON entrante igual que en iOS — el contenido es hostil
- `setAllowFileAccess(false)`, `setAllowFileAccessFromFileURLs(false)`,
  `setAllowUniversalAccessFromFileURLs(false)`
- Considerar quitar el interface tras la extracción

En iOS esto se resuelve con `forMainFrameOnly: true`. En Android hay que hacerlo
a mano.

### 3. TalkBack no es VoiceOver

No hay rotor. TalkBack usa **reading controls**: el usuario cambia la
granularidad de navegación (swipe arriba/abajo) entre caracteres, palabras,
párrafos, **encabezados**, links y controles.

Equivalencias:

| iOS | Android |
|---|---|
| `.accessibilityAddTraits(.isHeader)` | `Modifier.semantics { heading() }` |
| `.accessibilityRotor(.headings)` | sale gratis de `heading()` |
| `.accessibilityRotor(.links)` | `LinkAnnotation` en `AnnotatedString` |
| `.accessibilityLabel` | `contentDescription` |
| `UIAccessibility.post(.announcement)` | `View.announceForAccessibility()` |
| `.accessibilityElement(children: .combine)` | `Modifier.semantics(mergeDescendants = true)` |

**La buena noticia:** marcando bien los headings con `heading()`, la navegación
por encabezados de TalkBack funciona sin escribir un rotor. El modelo de Android
es más automático y menos configurable.

**Links inline:** Compose 1.7+ tiene `LinkAnnotation` dentro de `AnnotatedString`,
que sí produce links accesibles individualmente. El equivalente directo del
`AttributedString` + `.link` de iOS. Los offsets UTF-16 del JSON sirven igual —
Kotlin también usa UTF-16.

## El hueco real: visión on-device

iOS tiene Foundation Models con visión, gratis y en todos los dispositivos con
Apple Intelligence. Android no tiene equivalente parejo:

| Opción | Estado |
|---|---|
| **ML Kit Image Labeling** | on-device, gratis, universal — pero etiquetas sueltas, no descripciones |
| **Gemini Nano / AICore** | buena calidad, pero solo en gama alta (Pixel, Galaxy S) |
| **LLM en la nube** | universal, pero cuesta y sale del dispositivo |

Probable resolución: ML Kit como piso universal, Gemini Nano donde exista, nube
como último recurso y opt-in. **Decidir con datos de dispositivos reales, no
antes.**

## Cuándo abordarlo

Después de validar en iOS. El orden importa: si el producto cambia de forma
durante la validación, `extract.js` cambia con él — y conviene que eso pase una
vez, no dos.

Cuando llegue el momento, el trabajo real es la UI en Compose y el bridge. La
extracción ya va a estar probada contra páginas reales.
