import Foundation
import WebKit

/// The browsing engine.
///
/// One `WKWebView` for the life of the app. It loads the real page, runs the
/// shared `extract.js` inside it, and hands back a typed `ExtractedPage`. The
/// page is shown as it is; what the extractor reads is only what the
/// assistant sees, and the controls it can press on the person's behalf.
///
/// Two things follow from it being ONE WebView rather than one per load:
///
/// - It is a session. Cookies, logins and the state a site keeps between
///   pages survive navigation, which is what puts banks, government portals
///   and anything behind a sign-in within reach. With a fresh WebView per URL
///   none of those could ever work, whatever the extractor learned to read.
/// - What the person does on the page and what the assistant does are the
///   same thing. Solving a captcha or signing in by hand leaves the assistant
///   standing on the result.
@MainActor
final class HeadlessWebView: NSObject {

    enum ExtractionError: Error, LocalizedError {
        case scriptsMissing
        case timedOut
        case navigationFailed(String)
        case notReadable(String)
        case malformedPayload
        case noSession
        case activationFailed(String)

        var errorDescription: String? {
            switch self {
            case .scriptsMissing:
                return "Extraction scripts are missing from the bundle."
            case .timedOut:
                return "The page took too long to load."
            case .navigationFailed(let why):
                return "Could not load the page: \(why)"
            case .notReadable(let why):
                return "No readable content found (\(why))."
            case .malformedPayload:
                return "The page returned content this version cannot read."
            case .noSession:
                return "No page is loaded."
            case .activationFailed(let why):
                return "Could not activate that control: \(why)"
            }
        }
    }

    /// The live page. Nil until the first load. Exposed so the UI can put it
    /// on screen; nothing else should reach into it.
    private(set) var webView: WKWebView?
    private var blocking: Task<Void, Never>?

    /// Called when the page changed without anyone awaiting it: the user
    /// navigated inside the visible WebView, a site redirected, a form the
    /// engine submitted came back after its own re-extraction. Failures are
    /// reported too, so the assistant never keeps describing a page that is
    /// no longer the one loaded.
    var onPageChanged: ((Result<ExtractedPage, Error>) -> Void)?

    /// Una navegación arrancó desde que se apretó el último control.
    ///
    /// El WebView lo sabe antes que nadie —se entera por su delegado— y es el
    /// único que no miente: preguntárselo a la página en el mismo instante del
    /// click siempre daba que no, porque navegar es asincrónico.
    private var navigationStarted = false
    /// Cuántas navegaciones empezaron: la red de seguridad de `didFinish`
    /// sólo actúa si, cuando le toca, sigue siendo la misma.
    private var navigations = 0
    /// Cuándo empezó y terminó de cargar la página que se está leyendo, y si
    /// la tuvo que apurar la red de seguridad: para el registro, cuánto es
    /// red y cuánto es esperar a que la página se quede quieta (`deliver`).
    private var loadStart: ContinuousClock.Instant?
    private var loadEnd: ContinuousClock.Instant?
    private var hurried = false
    /// Cuánto después de terminar la carga se lee la página, si todavía no se
    /// leyó sola: la red de seguridad, o poco en los resultados de una
    /// búsqueda (`extract(url:results:)`).
    private var readAfterLoad = HeadlessWebView.safetyNet
    private static let safetyNet = Duration.seconds(3)
    private static let resultsRead = Duration.milliseconds(500)
    /// Cuántas páginas se leyeron: una falla que llega tarde no pisa una
    /// página que llegó después (ver `receive`).
    private var pagesRead = 0
    /// Cuánto se espera, después de una página sin nada que leer, a que la
    /// redirección que suele seguir empiece. En ANSES, más de medio segundo.
    private static let redirectWait = Duration.milliseconds(2500)
    private var continuation: CheckedContinuation<ExtractedPage, Error>?
    /// A page that arrived while nobody was waiting for one. The next waiter
    /// takes it instead of blocking on a load that already happened.
    private var unconsumed: ExtractedPage?
    private var timeoutTask: Task<Void, Never>?

    private let timeout: Duration

    init(timeout: Duration = .seconds(25)) {
        self.timeout = timeout
        super.init()
    }

    /// Loads `url` in the session and returns the extracted page.
    ///
    /// One extraction at a time per instance; a second call while one is in
    /// flight fails the earlier one rather than silently interleaving.
    ///
    /// `results`: es la página de resultados de una búsqueda que pidió JEF.
    /// El buscador sigue cambiando su página después de cargar y nunca se
    /// queda quieto: se esperaban 1,6–2,3 s más, con los resultados ya ahí.
    /// Se lee a `resultsRead` de terminar la carga. Sólo ahí: en los sitios la
    /// espera casi no se nota al lado de la orientación, y un sitio que arma
    /// su contenido después de cargar (Renfe) se leía a medias y había que
    /// orientarlo dos veces.
    func extract(url: URL, results: Bool = false) async throws -> ExtractedPage {
        settle(.failure(CancellationError()))
        let web = try session()
        await blocking?.value
        readAfterLoad = results ? Self.resultsRead : Self.safetyNet

        // Anything that arrived before this load belongs to the previous page.
        unconsumed = nil
        var request = URLRequest(url: url)
        request.attribution = .user
        // En el idioma del teléfono, dicho explícitamente: sin esto el
        // buscador salía en inglés ("Next Page >", "Sponsored link").
        request.setValue(Self.acceptLanguage, forHTTPHeaderField: "Accept-Language")
        web.load(request)
        return try await nextPage()
    }

    /// "es-AR, es;q=0.9": el idioma y el país del teléfono.
    static var acceptLanguage: String {
        let language = Locale.preferredLanguages.first
            .flatMap { Locale(identifier: $0).language.languageCode?.identifier } ?? "es"
        guard let region = Locale.current.region?.identifier else { return language }
        return "\(language)-\(region), \(language);q=0.9"
    }

    /// The WebView, created on first use and kept for the life of the engine.
    private func session() throws -> WKWebView {
        if let webView { return webView }

        let config = try makeConfiguration()
        let controller = config.userContentController
        blocking = Task { await Bloqueo.cargar(en: controller) }
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        // Off screen until the first page arrives, but a real size makes
        // layout-dependent sites (lazy images, responsive templates) resolve
        // as they would on screen. Once shown, SwiftUI gives it its frame.
        web.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        webView = web
        return web
    }

    enum ActivationOutcome: Sendable {
        /// The control was pressed and this is what the page became — the
        /// same document re-extracted, or the page it navigated to. The
        /// session carries over either way, so a navigation is never reloaded
        /// from scratch: the POST that just happened, the tab that just
        /// opened, the login that just succeeded all stay put.
        case updated(ExtractedPage)
        /// The element is no longer in the DOM — the page re-rendered since we
        /// extracted it.
        case stale
    }

    /// How long a page gets to decide that it is navigating.
    ///
    /// A click that leads somewhere starts its load within a frame or two; the
    /// gap is the browser's, not the network's. Measured across five sites:
    /// every navigation that was going to happen had started well inside this.
    private static let navigationGrace = Duration.milliseconds(450)

    /// Presses a control the extractor found, then re-extracts.
    ///
    /// A `<button>`'s behaviour lives in the page's own JavaScript, so the
    /// only honest way to press it is to ask the real element to click
    /// itself. On an airline home page the three main actions (VUELOS, CHECK
    /// IN, ESTADO DE VUELO) are all buttons, so without this the assistant
    /// could not move exactly where it matters most.
    ///
    /// The hard part is not the press: it is knowing what the press DID.
    /// Asking the page — which is what this used to do — cannot work, because
    /// the answer is needed in the same turn of the event loop in which the
    /// click was dispatched, and a navigation has not started by then. The
    /// answer was therefore always "it did not navigate", so the reader
    /// re-extracted the document that was already on its way out and handed
    /// the user the page they had just left. Measured on five sites: every
    /// single control that navigates reported `navigated: false`. That is the
    /// "I press it and it shows me the same thing again" everyone was hitting.
    ///
    /// So the WebView is asked instead, and it is asked after giving the page
    /// a moment to start.
    func activate(actionID: String, expecting label: String = "") async throws -> ActivationOutcome {
        guard let web = webView else { throw ExtractionError.noSession }

        // The id is ours, generated during extraction — never page-supplied —
        // so a page cannot use this path to press its own controls.
        let escaped = actionID.filter { $0.isLetter || $0.isNumber }
        // What the person heard. The page checks the control still says it
        // before pressing: an id survives a re-render, but what the node says
        // can change underneath it, and someone who cannot see has no way to
        // notice that the button moved out from under their finger.
        let expected = (try? JSONEncoder().encode([label]))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[\"\"]"
        navigationStarted = false
        let result = try await web.evaluateJavaScript(
            "window.__jefActivate('\(escaped)', \(expected)[0])"
        )

        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            let reason = (result as? [String: Any])?["reason"] as? String
            if reason == "gone" || reason == "changed" {
                return .stale
            }
            throw ExtractionError.activationFailed(
                (result as? [String: Any])?["message"] as? String ?? "unknown"
            )
        }

        // The page said so itself: a same-document route change, which a SPA
        // does synchronously. Nothing to wait for.
        if dict["navigated"] as? Bool == true {
            unconsumed = nil
            return .updated(try await nextPage())
        }

        try? await Task.sleep(for: Self.navigationGrace)

        // Another document is on its way; its own extraction will arrive when
        // it settles. Waiting for it beats reloading the URL, which would
        // replay a GET where the page just did a POST.
        if navigationStarted || web.isLoading {
            unconsumed = nil
            return .updated(try await nextPage())
        }

        // Same document, changed DOM: a menu opened, a tab switched, a panel
        // appeared. Re-extract so what the assistant sees matches the page.
        return .updated(try await reextract(web))
    }

    /// Writes a value into a form control inside the live page.
    ///
    /// Nothing is stored, logged, or sent anywhere except the page the person
    /// is already on.
    @discardableResult
    func fill(fieldID: String, value: String) async throws -> Bool {
        guard let web = webView else { throw ExtractionError.noSession }

        let safeID = fieldID.filter { $0.isLetter || $0.isNumber }
        // JSON-encode the value: it is arbitrary user text and must not be
        // able to terminate the string literal or inject script.
        guard
            let encoded = try? JSONEncoder().encode([value]),
            let array = String(data: encoded, encoding: .utf8)
        else { return false }

        let script = "window.__jefFill('\(safeID)', \(array)[0])"
        let result = try await web.evaluateJavaScript(script)
        return (result as? [String: Any])?["ok"] as? Bool == true
    }

    /// Escribe en un campo y devuelve, cuando la página ya lo recibió, lo que
    /// el campo tiene. Nil si no se pudo escribir o el campo ya no está.
    ///
    /// `fill(fieldID:value:)` está pensado para el tecleo de una persona:
    /// dispara y sigue. Un asistente que escribe y después envía necesita
    /// saber que el valor llegó antes de apretar. Y que quedó: antes se
    /// decía "Listo, escrito" sin mirar, aunque el campo ya no estuviera o
    /// la página lo hubiera borrado al reaccionar.
    func write(_ fieldID: String, _ value: String) async -> String? {
        guard (try? await fill(fieldID: fieldID, value: value)) == true, let web = webView else { return nil }
        // Lo que un sitio con autocompletado tarda en reaccionar. Medido en
        // el buscador de vuelos: menos que esto y el submit salía vacío.
        try? await Task.sleep(for: .milliseconds(700))
        let safeID = fieldID.filter { $0.isLetter || $0.isNumber }
        let now = try? await web.evaluateJavaScript("window.__jefValue('\(safeID)')") as? [String: Any]
        guard now?["ok"] as? Bool == true else { return nil }
        return now?["value"] as? String
    }

    /// Si lo que tiene el campo es lo que se escribió, sin espacios ni
    /// signos ni mayúsculas: una página que da formato ("12.345.678",
    /// "(11) 4444-5555") lo aceptó; una que lo vació o lo cortó, no.
    static func holds(_ held: String, _ written: String) -> Bool {
        func bare(_ text: String) -> String {
            String(text.lowercased().filter { $0.isLetter || $0.isNumber })
        }
        let wanted = bare(written)
        return wanted.isEmpty ? bare(held).isEmpty : bare(held).contains(wanted)
    }

    /// Arriba de todo. El extractor baja hasta el final para despertar lo
    /// que carga al scrollear y vuelve, pero no siempre queda arriba: en
    /// Clarín se veía el pie mientras el asistente hablaba de la portada.
    func scrollToTop() {
        guard let scroll = webView?.scrollView else { return }
        scroll.setContentOffset(CGPoint(x: 0, y: -scroll.adjustedContentInset.top), animated: false)
    }

    /// Brings a challenge into view — reCAPTCHA, hCaptcha, Turnstile — so the
    /// person finds it where they land.
    func scrollToChallenge() async {
        _ = try? await webView?.evaluateJavaScript("""
            (function () {
              var f = Array.prototype.find.call(document.querySelectorAll('iframe'), function (x) {
                return /recaptcha|hcaptcha|turnstile|challenges\\.cloudflare/i.test((x.src || '') + ' ' + (x.title || ''));
              });
              (f || document.body).scrollIntoView({ block: 'center' });
            })()
            """)
    }

    /// Whether there is a page to go back to.
    var canGoBack: Bool { webView?.canGoBack ?? false }

    /// Where "back" leads, so the wait can name it.
    var backURL: URL? { webView?.backForwardList.backItem?.url }

    /// Volver, con la sesión intacta: la misma pila del WebView que usaría
    /// Safari, así que la página anterior vuelve con su login y su carrito,
    /// no recargada desde cero.
    func goBack() async throws -> ExtractedPage {
        guard let web = webView, web.canGoBack else { throw ExtractionError.noSession }
        settle(.failure(CancellationError()))
        unconsumed = nil
        navigationStarted = false
        web.goBack()
        // Volver dentro de la misma página —un menú que agregó un paso al
        // historial— no carga nada, y esperar una carga era esperar hasta el
        // tiempo límite: en el Banco Nación, "Volver" terminó en "No pude
        // abrir esa página" con la página ahí. Sin navegación, se relee.
        try? await Task.sleep(for: Self.navigationGrace)
        if navigationStarted || web.isLoading { return try await nextPage() }
        return try await reextract(web)
    }

    /// Cierra lo que tapa la página con Escape (`__jefDismiss`) y la lee
    /// otra vez, como quedó.
    func dismiss() async throws -> ExtractedPage {
        guard let web = webView else { throw ExtractionError.noSession }
        _ = try? await web.evaluateJavaScript("window.__jefDismiss && window.__jefDismiss()")
        try? await Task.sleep(for: Self.navigationGrace)
        return try await reextract(web)
    }

    /// Reads the live page again, as it is now: after the person solved a
    /// challenge on the page itself, for instance.
    func reread() async throws -> ExtractedPage {
        guard let web = webView else { throw ExtractionError.noSession }
        return try await reextract(web)
    }

    /// Escribe en la página el nombre que JEF le puso a un control que el
    /// sitio dejó sin nombre, donde VoiceOver lo lee (ver `__jefName` en
    /// extract.js). False si el control ya no está o la página lo nombró.
    func name(actionID: String, label: String) async -> Bool {
        guard let web = webView,
              let encoded = try? JSONEncoder().encode([label]),
              let array = String(data: encoded, encoding: .utf8)
        else { return false }
        let safeID = actionID.filter { $0.isLetter || $0.isNumber }
        return (try? await web.evaluateJavaScript("window.__jefName('\(safeID)', \(array)[0])")) as? Bool ?? false
    }

    /// Submits the form an action belongs to, then reports what happened.
    func submit(actionID: String) async throws -> ActivationOutcome {
        guard let web = webView else { throw ExtractionError.noSession }

        let safeID = actionID.filter { $0.isLetter || $0.isNumber }
        navigationStarted = false
        let result = try await web.evaluateJavaScript("window.__jefSubmitForm('\(safeID)')")

        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            if (result as? [String: Any])?["reason"] as? String == "gone" { return .stale }
            throw ExtractionError.activationFailed(
                (result as? [String: Any])?["message"] as? String ?? "unknown"
            )
        }

        if dict["navigated"] as? Bool == true {
            unconsumed = nil
            return .updated(try await nextPage())
        }

        // Same reason as in `activate`: a submit that leaves for another page
        // has not started doing it by the time this line runs.
        try? await Task.sleep(for: Self.navigationGrace)
        if navigationStarted || web.isLoading {
            unconsumed = nil
            return .updated(try await nextPage())
        }

        return .updated(try await reextract(web))
    }

    func cancel() {
        settle(.failure(CancellationError()))
        teardown()
    }

    /// Algo que la página dijo sola: un cartel, o una zona de estado de las
    /// que VoiceOver anuncia. `asked`: era una pregunta para confirmar, y no
    /// se aceptó.
    struct Said: Sendable {
        let text: String
        let asked: Bool
    }

    /// Los carteles desde la última vez que se preguntó (`takeSaid`).
    fileprivate var alerts: [Said] = []

    /// Lo que la página dijo sola desde la última vez que se preguntó: sus
    /// carteles y sus zonas de estado (`__jefTakeSaid` en extract.js).
    /// Preguntado antes y después de apretar algo, es lo que la página
    /// contestó.
    func takeSaid() async -> [Said] {
        let live = (try? await webView?.evaluateJavaScript("window.__jefTakeSaid ? window.__jefTakeSaid() : []")) as? [String] ?? []
        defer { alerts = [] }
        return alerts + live.map { Said(text: $0, asked: false) }
    }

    /// Lo que una acción hizo tarde, hasta `limit`: la página de una
    /// navegación que recién empieza, o la que la página entregó sola. Nil si
    /// no pasó nada.
    ///
    /// Hay botones que navegan un rato después del toque —un buscador que
    /// primero consulta y después cambia de página—. A los 450 ms de
    /// `navigationGrace` la página seguía igual, se decía "Formulario enviado.
    /// La página no cambió." y los resultados llegaban un segundo después
    /// (Gob.pe). Quien llama pregunta sólo si la página quedó igual: lo que
    /// cambió ya contestó.
    func lateChange(within limit: Duration) async throws -> ExtractedPage? {
        guard let web = webView else { return nil }
        let end = ContinuousClock.now.advanced(by: limit)
        while ContinuousClock.now < end {
            if navigationStarted || web.isLoading { return try await nextPage() }
            if let page = unconsumed {
                unconsumed = nil
                return page
            }
            try? await Task.sleep(for: .milliseconds(150))
        }
        return nil
    }

    /// Re-runs extraction in the live page and waits for the result.
    private func reextract(_ web: WKWebView) async throws -> ExtractedPage {
        unconsumed = nil
        web.evaluateJavaScript("window.__jefReextract()") { _, error in
            if let error {
                self.settle(.failure(
                    ExtractionError.activationFailed(error.localizedDescription)
                ))
            }
        }
        return try await nextPage()
    }

    /// The next page the engine produces, or the one that already arrived.
    ///
    /// Only one reader waits at a time, and the newest owns the screen.
    /// Installing over a continuation that was already pending dropped it on
    /// the floor: that task never resumed, its caller waited forever, and the
    /// app went quiet with no error anywhere to say why. Two taps in quick
    /// succession were enough — the first `activate` was still waiting for its
    /// re-extraction when the second took the slot.
    ///
    /// The superseded caller is told the same way every other superseded load
    /// is told, and `ReaderModel.wasSuperseded` stays quiet about it.
    private func nextPage() async throws -> ExtractedPage {
        if let page = unconsumed {
            unconsumed = nil
            return page
        }
        settle(.failure(CancellationError()))
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            self.startTimeout()
        }
    }

    // MARK: - Configuration

    private func makeConfiguration() throws -> WKWebViewConfiguration {
        guard
            let readability = Bundle.main.url(forResource: "Readability", withExtension: "js"),
            let extractor = Bundle.main.url(forResource: "extract", withExtension: "js"),
            let readabilitySource = try? String(contentsOf: readability, encoding: .utf8),
            let extractorSource = try? String(contentsOf: extractor, encoding: .utf8)
        else {
            throw ExtractionError.scriptsMissing
        }

        let controller = WKUserContentController()

        // Readability goes in at document start so it is defined before the
        // extractor runs. `forMainFrameOnly: true` keeps both out of iframes —
        // third-party frames are ad and tracker territory and must not be able
        // to post messages to our handler.
        controller.addUserScript(WKUserScript(
            source: readabilitySource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))
        controller.addUserScript(WKUserScript(
            source: extractorSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))

        // The handler holds this object weakly; WKUserContentController retains
        // its handlers strongly, and a direct `self` here would leak the
        // WebView for the lifetime of the app.
        controller.add(WeakMessageHandler(self), name: "jefExtract")
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        // Persistent on purpose: this is a browser, and a login that vanishes
        // on the next page is not a session. Same store Safari uses.
        config.websiteDataStore = .default()
        // Say "Safari", because that is what this is: the same WebKit, on the
        // same phone. The bare WKWebView agent lacks the Version/Safari
        // tokens, and anti-bot walls read that as automation — MercadoLibre
        // served a "Seguridad" page to it before any content.
        let os = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        config.applicationNameForUserAgent = "Version/\(os).0 Mobile/15E148 Safari/604.1"
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.suppressesIncrementalRendering = true
        config.allowsInlineMediaPlayback = false
        // Nada suena ni se mueve si la persona no lo pide: los videos de
        // Clarín arrancaban solos, y con VoiceOver un video con sonido tapa
        // la voz. Es lo que hace Brave.
        config.mediaTypesRequiringUserActionForPlayback = .all
        return config
    }

    private func startTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [timeout] in
            try? await Task.sleep(for: timeout)
            guard !Task.isCancelled else { return }
            await MainActor.run { self.settle(.failure(ExtractionError.timedOut)) }
        }
    }

    /// Resolves the pending continuation exactly once, leaving the WebView
    /// alive so controls stay pressable. Safe to call from any completion path.
    private func settle(_ result: Result<ExtractedPage, Error>) {
        timeoutTask?.cancel()
        timeoutTask = nil

        guard let cont = continuation else { return }
        continuation = nil
        cont.resume(with: result)
    }

    /// Hands a page to whoever is waiting for one — or, if nobody is, reports
    /// that the page changed on its own and keeps it for the next waiter.
    private func deliver(_ result: Result<ExtractedPage, Error>) {
        if let start = loadStart, case .success(let page) = result {
            func ms(_ end: ContinuousClock.Instant) -> Int { Int((end - start) / .milliseconds(1)) }
            Registro.anotar("carga", [
                "url": page.url, "red_ms": loadEnd.map(ms) ?? -1, "leida_ms": ms(.now), "apurada": hurried,
            ])
            loadStart = nil
        }
        if continuation != nil {
            settle(result)
            return
        }
        if case .success(let page) = result { unconsumed = page }
        onPageChanged?(result)
    }

    /// Disposes of the session. Only on an explicit cancel: the WebView is the
    /// user's session, and throwing it away is what used to lose their login
    /// on every navigation.
    private func teardown() {
        webView?.stopLoading()
        webView?.configuration.userContentController
            .removeScriptMessageHandler(forName: "jefExtract")
        webView?.navigationDelegate = nil
        webView = nil
    }

    // MARK: - Message handling

    fileprivate func receive(_ body: Any) {
        guard let json = body as? String, let data = json.data(using: .utf8) else {
            settle(.failure(ExtractionError.malformedPayload))
            return
        }

        let decoder = JSONDecoder()

        if let page = try? decoder.decode(ExtractedPage.self, from: data), page.ok {
            pagesRead += 1
            deliver(.success(page))
            return
        }

        if let failure = try? decoder.decode(ExtractionFailure.self, from: data) {
            // Una página sin nada que leer puede ser el paso intermedio de
            // una redirección: si ya carga otra, o empieza a cargar dentro
            // de `redirectWait`, o la misma página llega a leerse, lo que vale
            // es eso, que llega solo. En ANSES se decía "No pude abrir esa
            // página" y la de turnos cargaba al segundo.
            let started = navigations, read = pagesRead
            Task { @MainActor [weak self] in
                let end = ContinuousClock.now.advanced(by: Self.redirectWait)
                while ContinuousClock.now < end {
                    guard let self, self.navigations == started, self.pagesRead == read,
                          self.webView?.isLoading != true else { return }
                    try? await Task.sleep(for: .milliseconds(150))
                }
                guard let self, self.navigations == started, self.pagesRead == read else { return }
                self.deliver(.failure(ExtractionError.notReadable(failure.message ?? failure.reason)))
            }
            return
        }

        deliver(.failure(ExtractionError.malformedPayload))
    }
}

// MARK: - WKNavigationDelegate

extension HeadlessWebView: WKNavigationDelegate {

    /// Async variant: the completion-handler overload does not satisfy the
    /// protocol under Swift 6 isolation, so it would silently never be called
    /// and this scheme filter would not run at all.
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard let scheme = navigationAction.request.url?.scheme?.lowercased() else {
            return .cancel
        }
        // Only web content. A page must not be able to steer the hidden engine
        // into a custom scheme and open another app behind the user's back.
        return (scheme == "https" || scheme == "http") ? .allow : .cancel
    }

    /// The only honest answer to "did that press lead somewhere". See
    /// `activate(actionID:)`.
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        navigationStarted = true
        navigations += 1
        loadStart = .now
        loadEnd = nil
        hurried = false
    }

    /// La red de seguridad: si a los 3 s de terminar la carga (medio segundo
    /// en los resultados de una búsqueda, ver `extract`) el extractor
    /// todavía no entregó la página, se le pide que la lea ya, sin esperas.
    /// Sus esperas corren con los relojes de la página, y en un WebView
    /// fuera de pantalla a veces se estiran: en Clarín, una de 6 s tardó 20,
    /// y JEF decía "no pude abrir esa página" con la página lista desde el
    /// segundo 2. Lo que la página haga después se sigue leyendo como antes.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let started = navigations
        loadEnd = .now
        let wait = readAfterLoad
        readAfterLoad = Self.safetyNet
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: wait)
            guard let self, self.navigations == started, self.continuation != nil else { return }
            self.hurried = true
            _ = try? await webView.evaluateJavaScript("window.__jefExtractNow && window.__jefExtractNow()")
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        report(error)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        report(error)
    }

    private func report(_ error: Error) {
        // A load that a newer load replaced comes back as cancelled. The newer
        // one has its own waiter; failing it for the old one's sake would
        // fail every navigation that starts while another is in flight.
        if (error as NSError).code == NSURLErrorCancelled { return }
        deliver(.failure(ExtractionError.navigationFailed(error.localizedDescription)))
    }
}

// MARK: - WKUIDelegate

extension HeadlessWebView: WKUIDelegate {

    /// Un cartel del navegador (`alert`): se cierra y se guarda lo que dice.
    /// Es cómo muchas páginas contestan —Demoblaze: "Product added."—, y
    /// antes se perdía sin que nadie lo oyera.
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async {
        guard frame.isMainFrame else { return }
        alerts.append(Said(text: message, asked: false))
    }

    /// Un cartel que pide confirmar (`confirm`): no se acepta, como antes
    /// —aceptar le toca a la persona—, pero se guarda lo que preguntó.
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        if frame.isMainFrame { alerts.append(Said(text: message, asked: true)) }
        return false
    }

    /// `target="_blank"` asks for a new window. There is one page here, so the
    /// link opens in it; without this the tap does nothing at all, silently,
    /// which on the visible page is a dead end the user cannot even hear.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - Weak bridge

/// Breaks the retain cycle between `WKUserContentController` and its handler.
private final class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var target: HeadlessWebView?

    init(_ target: HeadlessWebView) {
        self.target = target
    }

    func userContentController(
        _ controller: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        MainActor.assumeIsolated {
            target?.receive(message.body)
        }
    }
}

