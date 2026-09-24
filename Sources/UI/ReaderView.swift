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
            if case .loaded(let page) = state { nameUnnamed(in: page) }
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

    /// Jev, también para nombrar los controles que la página dejó sin nombre.
    private let analyzer: PageAnalyzer?

    init() {
        let analyzer = JevClient.fromEnvironment().map(PageAnalyzer.init)
        self.analyzer = analyzer
        self.assistant = Assistant(analyzer: analyzer)
        engine.onPageChanged = { [weak self] result in
            self?.pageChangedOnItsOwn(result)
        }
        assistant.onChallenge = { [weak self] in self?.watchChallenge() }
    }

    private var watching: Task<Void, Never>?

    /// Los controles sin nombre que ya se intentaron nombrar en esta
    /// dirección: otra lectura de la misma página no vuelve a preguntar.
    private var namingTried: (url: String, ids: Set<String>) = ("", [])

    /// Nombra los controles que la página dejó sin nombre.
    ///
    /// Jev elige el tipo por las pistas del HTML (`criterios.json`), el
    /// nombre sale de `nombres.json` en el idioma de la persona, y se escribe
    /// en la página, donde VoiceOver lo lee. Desde ahí el control tiene
    /// nombre para todos —la persona, las opciones, Jev al navegar—. Lo que
    /// Jev no sabe con confianza queda sin
    /// nombre. Los nombres se ponen en la página que la app ya tiene; la
    /// próxima lectura los trae de la página misma, donde quedaron escritos.
    private func nameUnnamed(in page: ExtractedPage) {
        if namingTried.url != page.url { namingTried = (page.url, []) }
        let pending = page.actions.filter {
            $0.unnamed == true && !($0.hints ?? "").isEmpty && !namingTried.ids.contains($0.id)
        }
        guard let analyzer, !pending.isEmpty else { return }
        namingTried.ids.formUnion(pending.map(\.id))
        Task {
            let kinds = await analyzer.kinds(ofUnnamed: pending.map { (hints: $0.hints ?? "", region: $0.region) })
            var labels: [String: String] = [:]
            for (index, kind) in kinds {
                guard let label = Nombres.de(kind, idioma: Answerer.phoneLanguage) else { continue }
                if await engine.name(actionID: pending[index].id, label: label) { labels[pending[index].id] = label }
            }
            Registro.anotar("nombres", ["url": page.url, "nombres": labels.values.sorted(), "sin_nombre": pending.count])
            // En la página que la app ya tiene, sin releer: releer competía
            // con una carga en curso y se salteaba en medio de un turno.
            guard !labels.isEmpty, case .loaded(let current) = state, current.url == page.url else { return }
            state = .loaded(current.naming(labels))
        }
    }

    /// Mientras hay una prueba anti-robot pendiente, la página se vuelve a
    /// mirar cada dos segundos.
    ///
    /// El aviso de cambios del extractor no alcanza: cambiar la prueba por el
    /// listado en la misma dirección movió 16 nodos, menos que su umbral, y
    /// JEF tardó veinte segundos en enterarse —hasta que la persona tocó "Ya
    /// la resolví"—. Y su ventana es de noventa segundos: resolver una
    /// prueba con audio puede llevar más.
    func watchChallenge() {
        guard watching == nil else { return }
        watching = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard let self, self.assistant.waitsForChallenge else { break }
                // Con la persona hablando con el asistente, no se relee: el
                // turno en curso es el que manda.
                guard !self.assistant.inTurn, !self.assistant.working,
                      let page = try? await self.engine.reread(),
                      !Assistant.hasChallenge(page) else { continue }
                self.address = page.url
                self.state = .loaded(page)
                await self.assistant.pageChanged(page, on: self)
            }
            self?.watching = nil
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
            Task { await assistant.pageChanged(page, on: self) }
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

    /// Cuánto más se espera, después de un toque o un envío que dejó la
    /// página igual, a que haga algo. En Gob.pe la búsqueda navegaba un
    /// segundo y medio después de enviarla.
    static let lateLimit = Duration.milliseconds(2500)

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
            case .updated(var page):
                // Igual todavía: puede estar por navegar (`lateChange`).
                if page.isEquivalent(to: self.page), let late = try await engine.lateChange(within: Self.lateLimit) {
                    page = late
                }
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

    /// Lleva a la prueba anti-robot: la página se desplaza hasta ella y el
    /// cursor de VoiceOver pasa a la página.
    func showChallenge() {
        Task {
            await engine.scrollToChallenge()
            if let web = engine.webView {
                UIAccessibility.post(notification: .layoutChanged, argument: web)
            }
        }
    }

    /// A dónde lleva "Volver": el título y la dirección de la página anterior.
    var backPlace: (title: String, url: String)? {
        guard let item = engine.webView?.backForwardList.backItem else { return nil }
        return (item.title ?? "", item.url.absoluteString)
    }

    /// Vuelve a leer la página tal como está ahora.
    func reread() async {
        guard let page = try? await engine.reread() else { return }
        address = page.url
        state = .loaded(page)
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
                // Igual todavía: puede estar por navegar (`lateChange`).
                var page = page
                if page.isEquivalent(to: self.page), let late = try await engine.lateChange(within: Self.lateLimit) {
                    page = late
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
            // Si la carga no terminó pero la página está, se cuenta la que
            // está en vez de decir que no se pudo.
            if let page = try? await engine.reread() {
                address = page.url
                state = .loaded(page)
                return
            }
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

/// La app: la página tal como es, a pantalla completa, y la conversación
/// encima.
///
/// No hay barra de direcciones ni vista reconstruida. A todos lados se llega
/// hablando con el asistente; la página queda a la vista y sin tocar, para
/// quien ve y para lo que sólo la persona puede hacer —una contraseña, un
/// captcha, el botón de pagar—.
///
/// Como Safari: abajo flotan Volver y el buscador. Tocar el buscador levanta
/// la conversación.
struct ReaderView: View {
    @State private var model = ReaderModel()
    /// El asistente a la vista. Cerrado, la página ocupa la pantalla entera
    /// y queda la barra de abajo para volver.
    @State private var panelOpen = true
    /// Las dos alturas del panel: un poco más de media pantalla, o entera.
    private enum Detent { case medium, large }
    @State private var detent = Detent.medium
    /// Lo que se lleva arrastrada la manija, hacia abajo en positivo.
    @State private var drag: CGFloat = 0
    /// Cerrado a mano, el cursor de VoiceOver va a la barra: es lo que
    /// queda en pantalla y lo que lo vuelve a abrir.
    @AccessibilityFocusState private var barFocused: Bool
    @State private var barHeight: CGFloat = 0
    /// El buscador y el panel son la misma superficie: al abrir, el buscador
    /// se estira hasta ser el panel; al cerrar, el panel se encoge hasta ser
    /// el buscador. Lo pidió Daniel: que se entienda de dónde sale y a dónde
    /// vuelve.
    @Namespace private var morph
    @Environment(\.colorScheme) private var scheme

    private var hasPage: Bool { model.liveWebView != nil }
    private var open: Bool { panelOpen || !hasPage }

    private static let motion = Animation.spring(duration: 0.45, bounce: 0.14)

    var body: some View {
        GeometryReader { screen in
            ZStack(alignment: .bottom) {
                if let web = model.liveWebView {
                    // Por debajo de la barra, como en Safari. Lo que la barra
                    // o el panel tapan se le dice al WebView: lo fijo al pie
                    // de la página —un aviso de cookies, un botón de pagar—
                    // se acomoda arriba de ellos en vez de quedar debajo.
                    WebPageView(webView: web, coveredBottom: covered(in: screen))
                        .ignoresSafeArea(edges: .bottom)
                }
                if hasPage {
                    panelFrame(in: screen)
                    // Una sola superficie, siempre puesta: con el chat abierto
                    // tiene el marco del panel; cerrado, el del buscador. Al
                    // cambiar, va de uno al otro. Con dos —una que se iba y
                    // otra que llegaba— el fondo del panel desaparecía de
                    // golpe y el texto se apagaba sin nada detrás.
                    surface(surfaceShape)
                        .matchedGeometryEffect(id: open ? "panel" : "buscador", in: morph, isSource: false)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    // Siempre armada, apagada con el chat abierto: el marco
                    // del buscador tiene que estar para que la superficie
                    // vuelva a él.
                    bar
                        .opacity(panelOpen ? 0 : 1)
                        .animation(panelOpen ? .easeOut(duration: 0.1) : .easeOut(duration: 0.2).delay(0.18), value: panelOpen)
                        .allowsHitTesting(!panelOpen)
                        .accessibilityHidden(panelOpen)
                }
                panel(in: screen)
            }
            .animation(Self.motion, value: hasPage)
        }
        // El país para buscar: la ubicación, con el permiso que el sistema
        // pide una vez; sin permiso, la región de Ajustes.
        .task { Ubicacion.shared.start() }
        // "Ir a la prueba": la página entera, para poder resolverla.
        .onChange(of: model.assistant.pageFocusRequests) { _, _ in
            withAnimation(Self.motion) { panelOpen = false }
        }
        // Resuelta, el asistente vuelve: lo que sigue lo cuenta él.
        .onChange(of: model.assistant.panelRequests) { _, _ in
            withAnimation(Self.motion) { panelOpen = true }
        }
        // Salir es cerrar lo que está abierto, como en todo iOS: con el
        // asistente a la vista lo cierra; con la página sola, vuelve.
        .accessibilityAction(.escape) {
            if hasPage, panelOpen {
                close()
            } else {
                Task { await model.assistant.goBack(on: model) }
            }
        }
    }

    // MARK: - El panel

    /// La conversación. Sin página es la pantalla entera; con página, un
    /// panel que flota sobre ella.
    ///
    /// No es una hoja del sistema: una hoja se cierra sola cuando la página
    /// cambia, que es exactamente lo que el asistente hace, y le cobra a
    /// VoiceOver una parada de "Sheet Grabber" antes de todo.
    ///
    /// Cerrado sigue armado, invisible: la conversación y hasta dónde se
    /// leyó quedan como estaban para cuando se vuelva a abrir.
    private func panel(in screen: GeometryProxy) -> some View {
        AssistantPanel(
            assistant: model.assistant,
            onAsk: { goal in Task { await model.assistant.ask(goal, on: model) } },
            onAccept: { action in Task { await model.assistant.accept(action, on: model) } },
            onClose: hasPage ? { close() } : nil,
            onDrag: hasPage ? { value, ended in dragged(value, ended: ended, in: screen) } : nil,
            isOpen: open
        )
        .frame(maxWidth: .infinity)
        .frame(height: hasPage ? panelHeight(in: screen) : screen.size.height)
        .clipShape(.rect(topLeadingRadius: hasPage ? 34 : 0, topTrailingRadius: hasPage ? 34 : 0, style: .continuous))
        // Al cerrar, lo de adentro se apaga enseguida y el fondo se encoge
        // solo hasta el buscador; al abrir, aparece cuando el fondo ya se
        // estiró. Apagándose al mismo ritmo, el texto quedaba flotando sobre
        // la página, sin fondo detrás.
        .opacity(open ? 1 : 0)
        .scaleEffect(open ? 1 : 0.9, anchor: .bottom)
        .animation(open ? .easeOut(duration: 0.22).delay(0.12) : .easeOut(duration: 0.1), value: open)
        .background {
            if !hasPage { Color(.systemBackground).ignoresSafeArea() }
        }
        .padding(.horizontal, hasPage ? 8 : 0)
        .offset(y: dragOffset(in: screen))
        .allowsHitTesting(open)
    }

    /// El marco del panel, sin nada dibujado: es a donde va la superficie
    /// con el chat abierto. El de la conversación, más lo que baja hacia el
    /// borde de la pantalla.
    private func panelFrame(in screen: GeometryProxy) -> some View {
        // Con el teclado arriba el fondo termina en él; sin teclado, baja
        // hasta casi el borde de la pantalla.
        let keyboardUp = screen.safeAreaInsets.bottom > 100
        return Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: panelHeight(in: screen))
            .background {
                Color.clear
                    .matchedGeometryEffect(id: "panel", in: morph)
                    .padding(.bottom, keyboardUp ? 0 : 8)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .padding(.horizontal, 8)
            .offset(y: dragOffset(in: screen))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    /// Abierto, arriba redondeado y abajo siguiendo la curva de la pantalla,
    /// como las hojas de iOS; cerrado, la cápsula del buscador.
    private var surfaceShape: ConcentricRectangle {
        open
            ? ConcentricRectangle(
                topLeadingCorner: .fixed(34), topTrailingCorner: .fixed(34),
                bottomLeadingCorner: .concentric(minimum: .fixed(34)), bottomTrailingCorner: .concentric(minimum: .fixed(34)))
            : ConcentricRectangle(corners: .fixed(27))
    }

    /// La superficie de la barra y del panel, la misma en los dos, como la
    /// de Safari: blanca en claro, gris muy oscuro en oscuro, con una sombra
    /// suave que la despega de la página.
    ///
    /// Primero fue vidrio, y no sirvió: dejaba leer la página debajo del
    /// texto —con poca vista, ruido— y cambiaba de claro a oscuro según lo
    /// que tuviera detrás. Daniel: "si es blanco todo blanco, si es negro
    /// todo negro".
    private func surface(_ shape: some Shape) -> some View {
        shape
            .fill(Color(.secondarySystemGroupedBackground))
            // Un borde apenas marcado: en claro, blanco sobre una página
            // blanca, sólo la sombra no alcanzaba para ver dónde termina; en
            // oscuro la sombra no se ve.
            .overlay(shape.stroke(scheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.08), lineWidth: 1))
            .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.2), radius: 10, y: 2)
    }

    /// Arrastrado más allá de su altura mínima, el panel entero baja.
    private func dragOffset(in screen: GeometryProxy) -> CGFloat {
        open ? max(0, drag - (restingHeight(in: screen) - 200)) : 0
    }

    /// Sin arrastrar: 55 % de la pantalla, o entera. Y con más de la mitad a
    /// propósito: la conversación es la app. En una franja de 380 puntos las
    /// respuestas se cortaban y los botones quedaban abajo, fuera de la vista.
    private func restingHeight(in screen: GeometryProxy) -> CGFloat {
        let full = screen.size.height
        switch detent {
        case .medium: return min(full, max(380, full * 0.55))
        case .large: return full
        }
    }

    /// La altura mientras se arrastra: sigue al dedo, hasta la pantalla
    /// entera para arriba y hasta 200 puntos para abajo. Pasado eso, el
    /// panel entero baja.
    private func panelHeight(in screen: GeometryProxy) -> CGFloat {
        let resting = restingHeight(in: screen)
        return min(screen.size.height, max(200, resting - drag))
    }

    private func dragged(_ value: DragGesture.Value, ended: Bool, in screen: GeometryProxy) {
        guard ended else {
            drag = value.translation.height
            return
        }
        let flung = value.predictedEndTranslation.height
        switch detent {
        case .medium where flung > 140, .large where flung > 420:
            close()
            return
        default:
            break
        }
        withAnimation(Self.motion) {
            drag = 0
            switch detent {
            case .medium where flung < -120: detent = .large
            case .large where flung > 120: detent = .medium
            default: break
            }
        }
    }

    private func openPanel() {
        withAnimation(Self.motion) { panelOpen = true }
    }

    private func close() {
        withAnimation(Self.motion) {
            panelOpen = false
            detent = .medium
            drag = 0
        }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            barFocused = true
        }
    }

    /// Lo que la barra o el panel tapan de la página, desde el pie de la
    /// pantalla. Con el teclado de un campo de la página, la barra queda
    /// detrás de él, y del teclado se ocupa el WebView.
    private func covered(in screen: GeometryProxy) -> CGFloat {
        let bottom = screen.safeAreaInsets.bottom
        if open { return panelHeight(in: screen) + bottom }
        return bottom > 100 ? 0 : barHeight + bottom
    }

    // MARK: - La barra

    /// Volver y el buscador, flotando sobre la página como en Safari.
    ///
    /// El buscador no es un campo: levanta la conversación, con la última
    /// respuesta y sus botones a la vista. El teclado los taparía, y los
    /// botones son el camino; para escribir está el campo de abajo del
    /// panel.
    private var bar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await model.assistant.goBack(on: model) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(model.canGoBack ? .primary : .tertiary)
                    .frame(width: 54, height: 54)
                    // Sin forma, un botón liso sólo se toca sobre el
                    // dibujo: la flecha, no el círculo.
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .background { surface(Circle()) }
            .disabled(!model.canGoBack)
            .accessibilityLabel("Volver")

            Button(action: openPanel) {
                HStack(spacing: 10) {
                    if model.assistant.working {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.body.weight(.semibold))
                    }
                    Text(place ?? "¿Qué querés hacer?")
                        .font(.body)
                        .foregroundStyle(place == nil ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18)
                .frame(height: 54)
                .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            // La superficie la pone el ReaderView: es la misma del panel.
            .background {
                Color.clear.matchedGeometryEffect(id: "buscador", in: morph)
            }
            .accessibilityLabel("Abrir el asistente")
            .accessibilityValue(model.assistant.working ? "Buscando" : (place ?? ""))
            .accessibilityFocused($barFocused)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { barHeight = $0 + 4 }
        // Con el teclado de un campo de la página, la barra queda detrás de
        // él, como en Safari: no sube y baja con el teclado.
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    /// Dónde se está, como lo muestra Safari: el dominio, sin "www.".
    private var place: String? {
        let url: URL? = switch model.state {
        case .loading(let url): url
        case .loaded(let page): URL(string: page.url)
        case .idle, .failed: URL(string: model.address)
        }
        guard let host = url?.host(), !host.isEmpty else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
