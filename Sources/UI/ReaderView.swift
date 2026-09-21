import SwiftUI
import WebKit

/// La sesión que maneja el asistente: un WebView, la página que muestra, y lo
/// que el extractor leyó de ella.
@MainActor
@Observable
final class ReaderModel {
    enum State {
        case idle
        case loading(URL)
        case loaded(ExtractedPage)
        case failed(String)
    }

    private(set) var state: State = .idle {
        // La pila del WebView no es observable, así que se copia acá cada vez
        // que la página cambia: es lo que decide si hay a dónde volver.
        didSet {
            canGoBack = engine.canGoBack
            #if DEBUG
            // Lo que el asistente tiene delante, tal cual se lo pasa al
            // modelo: es contra esto que una prueba verifica lo que dijo.
            switch state {
            case .loaded(let page):
                Registro.anotar("pagina", ["url": page.url, "titulo": page.title, "texto": Assistant.saying(page)])
            case .failed(let why):
                Registro.anotar("error", ["mensaje": why])
            case .idle, .loading:
                break
            }
            #endif
        }
    }
    private(set) var canGoBack = false

    var address: String = ""

    private let engine = HeadlessWebView()
    /// El asistente: la persona dice a dónde quiere ir y JEF la lleva. La
    /// página se carga tal como es; esto es lo único que se le agrega.
    let assistant: Assistant

    init() {
        let analyzer = JevClient.fromEnvironment().map(PageAnalyzer.init)
        self.assistant = Assistant(analyzer: analyzer)
        engine.onPageChanged = { [weak self] result in
            self?.pageChangedOnItsOwn(result)
        }
    }

    var page: ExtractedPage? {
        if case .loaded(let page) = state { return page }
        return nil
    }

    /// El WebView del motor, para ponerlo en pantalla. Nil antes de la
    /// primera carga.
    ///
    /// Lee `state` a propósito: el motor no es observable, y sin leer algo
    /// que sí lo sea la vista no se enteraría de que la primera página llegó.
    var liveWebView: WKWebView? {
        if case .idle = state { return nil }
        return engine.webView
    }

    /// The page changed and nobody was waiting for it: the person navigated
    /// inside the page, or a site redirected, or a submit the engine already
    /// answered came back later. What the assistant sees follows.
    private func pageChangedOnItsOwn(_ result: Result<ExtractedPage, Error>) {
        switch result {
        case .success(let page):
            guard !page.isEquivalent(to: self.page) else { return }
            address = page.url
            state = .loaded(page)
        case .failure(let error):
            state = .failed(error.localizedDescription)
        }
    }

    func go() async {
        guard let url = Self.normalize(address) else {
            state = .failed("Eso no parece una dirección web.")
            return
        }

        state = .loading(url)

        do {
            let page = try await engine.extract(url: url)
            address = page.url
            state = .loaded(page)
            engine.scrollToTop()
        } catch {
            guard !Self.wasSuperseded(error) else { return }
            state = .failed(error.localizedDescription)
        }
    }

    /// Una carga que otra más nueva reemplazó no falló: dejó de importar.
    ///
    /// El motor atiende una página por vez, y cuando llega un pedido nuevo le
    /// avisa al anterior con un `CancellationError`. Tratado como error, el
    /// pedido viejo pisaba al nuevo con "No se pudo leer esta página". Quien
    /// manda es el último pedido.
    private static func wasSuperseded(_ error: Error) -> Bool {
        error is CancellationError
    }

    /// Presses a control the page owns, then reads whatever it became.
    ///
    /// Links navigate; buttons are clicked inside the live page. Either way
    /// the page is read again from the result, in the same session.
    func activate(_ action: Action) async {
        // A link with an href needs no round trip through the page.
        if action.kind == .link, let href = action.href {
            address = href
            await go()
            return
        }

        do {
            switch try await engine.activate(actionID: action.id, expecting: action.label) {
            case .updated(let page):
                // A control that changed nothing is not an error and must not
                // look like one.
                guard !page.isEquivalent(to: self.page) else {
                    Voz.decir(
                        "\(action.label) no cambió la página."
                    )
                    return
                }
                address = page.url
                state = .loaded(page)

            case .stale:
                // The node vanished between extraction and the tap — a SPA
                // re-rendered underneath us. Reloading re-stamps everything.
                Voz.decir("Esa opción ya no está en la página. La vuelvo a cargar.")
                await go()
            }
        } catch {
            guard !Self.wasSuperseded(error) else { return }
            Voz.decir(
                "No se pudo activar \(action.label)"
            )
        }
    }

    /// Lleva un valor a un campo de la página sin esperar a que lo reciba.
    /// Quien la llama espera lo que haga falta; `type` es la que espera.
    func fill(_ field: Action.Field, with value: String) {
        Task { try? await engine.fill(fieldID: field.id, value: value) }
    }

    /// Submits a form and reads whatever the page became.
    func submit(_ action: Action) async {
        do {
            switch try await engine.submit(actionID: action.id) {
            case .updated(let page):
                // The page kept the form and marked what is missing. Said
                // out loud: the message sits under a field nobody can see.
                let complaints = page.actions.flatMap { $0.fields ?? [] }
                    .filter { !($0.error ?? "").isEmpty }
                let notices = page.actions.first { $0.id == action.id }?.notices ?? []
                let detail = complaints.first.map { "\($0.name): \($0.error ?? "")" } ?? notices.first
                if page.url == self.page?.url, let detail {
                    state = .loaded(page)
                    Voz.decir(
                        complaints.count > 1
                            ? "No se envió. \(complaints.count) campos con errores. \(detail)"
                            : "No se envió. \(detail)"
                    )
                    return
                }
                guard !page.isEquivalent(to: self.page) else {
                    Voz.decir(
                        "Formulario enviado. La página no cambió."
                    )
                    return
                }
                address = page.url
                state = .loaded(page)
            case .stale:
                Voz.decir("El formulario ya no está en la página. La vuelvo a cargar.")
                await go()
            }
        } catch {
            guard !Self.wasSuperseded(error) else { return }
            Voz.decir(
                "No se pudo enviar el formulario"
            )
        }
    }

    /// Escribe en un campo y espera a que la página lo reciba.
    ///
    /// `fill` dispara sin esperar. Un asistente que escribe y a continuación
    /// envía necesita saber que el valor llegó: acá se escribe y se espera.
    func type(_ value: String, into field: Action.Field) async {
        await engine.write(field.id, value)
        state = state
    }

    /// Volver a la página anterior, con la sesión intacta.
    ///
    /// Además de pedírselo al asistente, está atado al gesto de escape de
    /// VoiceOver —dos dedos, Z—, que es como se sale de todo lo demás en iOS.
    func back() async {
        guard engine.canGoBack else {
            Voz.decir("No hay página anterior")
            return
        }
        // Volver es una carga como cualquier otra y se tiene que ver como
        // una: sin esto el toque parecía no haber hecho nada, y el segundo
        // cancelaba al primero.
        if let url = engine.backURL { state = .loading(url) }
        do {
            let page = try await engine.goBack()
            address = page.url
            state = .loaded(page)
        } catch {
            guard !Self.wasSuperseded(error) else { return }
            state = .failed(error.localizedDescription)
        }
    }

    /// Accepts what people actually type: bare hosts, missing schemes.
    static func normalize(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let explicit = trimmed.contains("://")
        let candidate = explicit ? trimmed : "https://\(trimmed)"
        guard
            let url = URL(string: candidate),
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http",
            let host = url.host()
        else { return nil }

        // A dot is how a guess tells a domain from a search term. It is not
        // a rule about addresses: `localhost` and intranet names have none,
        // and an office or a hospital runs on those. When the person wrote
        // the scheme, they were not searching.
        guard explicit || host == "localhost" || host.contains(".") else { return nil }

        return url
    }
}

/// La app: la página tal como es, arriba, y la conversación abajo.
///
/// No hay barra de direcciones ni vista reconstruida. A todos lados se llega
/// hablando con el asistente; la página queda a la vista y sin tocar, para
/// quien ve y para lo que sólo la persona puede hacer —una contraseña, un
/// captcha, el botón de pagar—.
struct ReaderView: View {
    @State private var model = ReaderModel()

    var body: some View {
        GeometryReader { screen in
            VStack(spacing: 0) {
                // Recién cuando hubo una página. Antes no hay nada que mirar,
                // y la conversación ocupa la pantalla entera.
                if let web = model.liveWebView {
                    WebPageView(webView: web)
                    Divider()
                }
                // No es una hoja: una hoja se cierra sola cuando la página
                // cambia, que es exactamente lo que el asistente hace.
                //
                // Y con más de la mitad de la pantalla: la conversación es la
                // app. En una franja de 380 puntos las respuestas se cortaban
                // y los botones quedaban abajo, fuera de la vista.
                AssistantPanel(
                    assistant: model.assistant,
                    onAsk: { goal in Task { await model.assistant.ask(goal, on: model) } },
                    onAccept: { action in Task { await model.assistant.accept(action, on: model) } }
                )
                .frame(height: model.liveWebView == nil ? nil : max(380, screen.size.height * 0.55))
                .background(.bar)
            }
        }
        // Salir es volver. Es el gesto con el que se sale de todo lo demás
        // en iOS.
        .accessibilityAction(.escape) {
            Task { await model.assistant.goBack(on: model) }
        }
    }
}
