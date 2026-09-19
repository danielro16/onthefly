import Foundation
import WebKit

/// The extraction engine.
///
/// A `WKWebView` that is never shown. It loads the real page, runs the shared
/// `extract.js` inside it, and hands back a typed `ExtractedPage`. The user
/// never sees this view — the app renders native SwiftUI from its output.
///
/// That split is the whole architecture: the web engine parses, native code
/// renders. It is also why VoiceOver behaves like a native app here rather
/// than like a web page in a wrapper.
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

    private var webView: WKWebView?
    private var continuation: CheckedContinuation<ExtractedPage, Error>?
    private var timeoutTask: Task<Void, Never>?

    private let timeout: Duration

    init(timeout: Duration = .seconds(25)) {
        self.timeout = timeout
        super.init()
    }

    /// Loads `url`, extracts it, and returns the typed page.
    ///
    /// The WebView stays alive afterwards so `activate(_:)` can press controls
    /// the native UI rebuilt. One extraction at a time per instance; a second
    /// call while one is in flight fails the earlier one rather than silently
    /// interleaving.
    func extract(url: URL) async throws -> ExtractedPage {
        settle(.failure(CancellationError()))
        teardown()

        let config = try makeConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        // Never rendered, but a non-zero size makes layout-dependent sites
        // (lazy images, responsive templates) resolve as they would on screen.
        web.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        webView = web

        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            self.startTimeout()
            var request = URLRequest(url: url)
            request.attribution = .user
            web.load(request)
        }
    }

    enum ActivationOutcome: Sendable {
        /// The control was pressed and the page re-extracted.
        case updated(ExtractedPage)
        /// The control was pressed and the page navigated elsewhere.
        case navigated(URL)
        /// The element is no longer in the DOM — the page re-rendered since we
        /// extracted it.
        case stale
    }

    /// Presses a control the UI rebuilt, then re-extracts.
    ///
    /// A `<button>`'s behaviour lives in the page's own JavaScript, so a native
    /// view cannot reproduce it — the only honest way to offer that button is
    /// to ask the real element to click itself. On an airline home page the
    /// three main actions (VUELOS, CHECK IN, ESTADO DE VUELO) are all buttons,
    /// so without this the reader is read-only exactly where it matters most.
    func activate(actionID: String) async throws -> ActivationOutcome {
        guard let web = webView else { throw ExtractionError.noSession }

        // The id is ours, generated during extraction — never page-supplied —
        // so a page cannot use this path to press its own controls.
        let escaped = actionID.filter { $0.isLetter || $0.isNumber }
        let result = try await web.evaluateJavaScript("window.__jefActivate('\(escaped)')")

        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            if let dict = result as? [String: Any], dict["reason"] as? String == "gone" {
                return .stale
            }
            throw ExtractionError.activationFailed(
                (result as? [String: Any])?["message"] as? String ?? "unknown"
            )
        }

        if dict["navigated"] as? Bool == true,
           let href = dict["href"] as? String, let url = URL(string: href) {
            return .navigated(url)
        }

        // Same URL, changed DOM: a menu opened, a tab switched, a panel
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

    /// Submits the form an action belongs to, then reports what happened.
    func submit(actionID: String) async throws -> ActivationOutcome {
        guard let web = webView else { throw ExtractionError.noSession }

        let safeID = actionID.filter { $0.isLetter || $0.isNumber }
        let result = try await web.evaluateJavaScript("window.__jefSubmitForm('\(safeID)')")

        guard let dict = result as? [String: Any], dict["ok"] as? Bool == true else {
            if (result as? [String: Any])?["reason"] as? String == "gone" { return .stale }
            throw ExtractionError.activationFailed(
                (result as? [String: Any])?["message"] as? String ?? "unknown"
            )
        }

        if dict["navigated"] as? Bool == true,
           let href = dict["href"] as? String, let url = URL(string: href) {
            return .navigated(url)
        }

        return .updated(try await reextract(web))
    }

    func cancel() {
        settle(.failure(CancellationError()))
        teardown()
    }

    /// Re-runs extraction in the live page and waits for the result.
    private func reextract(_ web: WKWebView) async throws -> ExtractedPage {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            self.startTimeout()
            web.evaluateJavaScript("window.__jefReextract()") { _, error in
                if let error {
                    self.settle(.failure(
                        ExtractionError.activationFailed(error.localizedDescription)
                    ))
                }
            }
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
        config.websiteDataStore = .nonPersistent()
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

    /// Disposes of the session. Only on a new load or an explicit cancel —
    /// tearing down after every extraction is what used to make buttons
    /// unpressable.
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
            settle(.success(page))
            return
        }

        if let failure = try? decoder.decode(ExtractionFailure.self, from: data) {
            settle(.failure(ExtractionError.notReadable(failure.message ?? failure.reason)))
            return
        }

        settle(.failure(ExtractionError.malformedPayload))
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

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        settle(.failure(ExtractionError.navigationFailed(error.localizedDescription)))
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        settle(.failure(ExtractionError.navigationFailed(error.localizedDescription)))
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
