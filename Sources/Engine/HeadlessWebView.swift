import Foundation
import WebKit

/// The browsing engine.
///
/// One `WKWebView` for the life of the app. It loads the real page, runs the
/// shared `extract.js` inside it, and hands back a typed `ExtractedPage`; the
/// app renders native SwiftUI from that output and the WebView stays off
/// screen. That split is the whole architecture: the web engine parses,
/// native code renders, and VoiceOver behaves like a native app rather than
/// like a web page in a wrapper.
///
/// Two things follow from it being ONE WebView rather than one per load:
///
/// - It is a session. Cookies, logins and the state a site keeps between
///   pages survive navigation, which is what puts banks, government portals
///   and anything behind a sign-in within reach. With a fresh WebView per URL
///   none of those could ever work, whatever the extractor learned to read.
/// - It can be shown. When the native rebuild fails — a captcha, an anti-bot
///   wall, a payment iframe, a page that simply did not extract — the user is
///   handed the live page itself instead of a dead end, and whatever they do
///   there (solve the captcha, sign in) is still there when they switch back.
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
    /// on screen as the fallback; nothing else should reach into it.
    private(set) var webView: WKWebView?

    /// Called when the page changed without anyone awaiting it: the user
    /// navigated inside the visible WebView, a site redirected, a form the
    /// engine submitted came back after its own re-extraction. Failures are
    /// reported too, so the native view never keeps showing a page that is
    /// no longer the one loaded.
    var onPageChanged: ((Result<ExtractedPage, Error>) -> Void)?

    /// Una navegación arrancó desde que se apretó el último control.
    ///
    /// El WebView lo sabe antes que nadie —se entera por su delegado— y es el
    /// único que no miente: preguntárselo a la página en el mismo instante del
    /// click siempre daba que no, porque navegar es asincrónico.
    private var navigationStarted = false
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
    func extract(url: URL) async throws -> ExtractedPage {
        settle(.failure(CancellationError()))
        let web = try session()

        // Anything that arrived before this load belongs to the previous page.
        unconsumed = nil
        var request = URLRequest(url: url)
        request.attribution = .user
        web.load(request)
        return try await nextPage()
    }

    /// The WebView, created on first use and kept for the life of the engine.
    private func session() throws -> WKWebView {
        if let webView { return webView }

        let config = try makeConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        // Off screen most of the time, but a real size makes layout-dependent
        // sites (lazy images, responsive templates) resolve as they would on
        // screen. When shown, SwiftUI gives it the screen's frame instead.
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

    /// Presses a control the UI rebuilt, then re-extracts.
    ///
    /// A `<button>`'s behaviour lives in the page's own JavaScript, so a native
    /// view cannot reproduce it — the only honest way to offer that button is
    /// to ask the real element to click itself. On an airline home page the
    /// three main actions (VUELOS, CHECK IN, ESTADO DE VUELO) are all buttons,
    /// so without this the reader is read-only exactly where it matters most.
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
    func activate(actionID: String) async throws -> ActivationOutcome {
        guard let web = webView else { throw ExtractionError.noSession }

        // The id is ours, generated during extraction — never page-supplied —
        // so a page cannot use this path to press its own controls.
        let escaped = actionID.filter { $0.isLetter || $0.isNumber }
        navigationStarted = false
        let result = try await web.evaluateJavaScript("window.__jefActivate('\(escaped)')")

        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            if let dict = result as? [String: Any], dict["reason"] as? String == "gone" {
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
        // appeared. Re-extract so the native view matches what the page now is.
        return .updated(try await reextract(web))
    }

    /// Writes a value into a form control inside the live page.
    ///
    /// The user types into a native `TextField`; this carries what they typed
    /// to the real control. Nothing is stored, logged, or sent anywhere except
    /// the page they are already on — including passwords, which the UI keeps
    /// in a secure field and never holds in app state.
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
        web.goBack()
        return try await nextPage()
    }

    /// Reads the live page again, on request. The safety valve: every
    /// heuristic about when a page has finished changing is a guess, and
    /// the person can always ask.
    func reread() async throws -> ExtractedPage {
        guard let web = webView else { throw ExtractionError.noSession }
        return try await reextract(web)
    }

    /// Opens a combobox's list without typing into it, so `suggestions`
    /// can read everything it offers.
    func open(fieldID: String) async throws {
        guard let web = webView else { throw ExtractionError.noSession }
        let safeID = fieldID.filter { $0.isLetter || $0.isNumber }
        _ = try await web.evaluateJavaScript("window.__jefOpen('\(safeID)')")
    }

    /// What an autocomplete under `fieldID` is offering right now.
    func suggestions(fieldID: String) async throws -> [String] {
        guard let web = webView else { throw ExtractionError.noSession }
        let safeID = fieldID.filter { $0.isLetter || $0.isNumber }
        let result = try await web.evaluateJavaScript("window.__jefSuggestions('\(safeID)')")
        let list = (result as? [String: Any])?["suggestions"] as? [[String: Any]] ?? []
        return list.compactMap { $0["label"] as? String }
    }

    /// Picks one of them, and returns what the page put in the field.
    func choose(fieldID: String, index: Int) async throws -> String {
        guard let web = webView else { throw ExtractionError.noSession }
        let safeID = fieldID.filter { $0.isLetter || $0.isNumber }
        let result = try await web.evaluateJavaScript("window.__jefChoose('\(safeID)', \(index))")
        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            throw ExtractionError.activationFailed(
                (result as? [String: Any])?["message"] as? String ?? "gone"
            )
        }
        return dict["value"] as? String ?? ""
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
            deliver(.success(page))
            return
        }

        if let failure = try? decoder.decode(ExtractionFailure.self, from: data) {
            deliver(.failure(ExtractionError.notReadable(failure.message ?? failure.reason)))
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
