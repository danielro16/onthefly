import SwiftUI
import WebKit

@MainActor
@Observable
final class ReaderModel {
    enum State {
        case idle
        case loading(URL)
        case loaded(ExtractedPage)
        case failed(String)
    }

    /// Where the intent conversation stands. Kept apart from `State` because a
    /// page stays fully readable through every one of these — Jev refines the
    /// view, it never gates it.
    enum IntentState: Sendable {
        case unavailable
        case detecting
        case asking([Intent])
        case applied(Intent)
        case undecided
    }

    private(set) var state: State = .idle
    private(set) var intentState: IntentState = .unavailable
    /// Blocks Jev judged irrelevant, with enough confidence to act on.
    private(set) var collapsed: Set<String> = []
    /// The page's actions, sorted into goals a person recognises.
    private(set) var intentGroups: [IntentGroup] = []
    /// Names Jev picked for listings the page left unlabelled.
    private(set) var listingNames: [String: String] = [:]
    /// What the page's autocompletes are offering, per field.
    private(set) var suggestions: [String: [String]] = [:]
    /// What the page put in a field after a suggestion was picked.
    private(set) var resolvedValues: [String: String] = [:]
    /// Controls that were not there before the last tap: what the tap
    /// opened. A fare picker unfolding inside a flight card, a menu, an
    /// accordion — on a SPA the answer to a tap is whatever appeared, and
    /// buried among forty old controls it was unreachable.
    private(set) var arrivals: [Action] = []
    private(set) var arrivalCause = ""
    private var suggestionTask: Task<Void, Never>?

    var address: String = "https://es.wikipedia.org/wiki/Buenos_Aires"

    /// Whether the live page is on screen instead of the native rebuild.
    ///
    /// The escape hatch. Nothing the extractor cannot read may leave the user
    /// stuck: a captcha, an anti-bot wall, a payment iframe, a page with no
    /// prose and no actions. From here they browse the real page with
    /// VoiceOver's ordinary web navigation and come back whenever they like.
    private(set) var showingOriginal = false

    private let engine = HeadlessWebView()
    private let analyzer: PageAnalyzer?

    init() {
        analyzer = JevClient.fromEnvironment().map(PageAnalyzer.init)
        engine.onPageChanged = { [weak self] result in
            self?.pageChangedOnItsOwn(result)
        }
    }

    var page: ExtractedPage? {
        if case .loaded(let page) = state { return page }
        return nil
    }

    /// The engine's WebView, for the fallback view. Nil before the first load.
    var liveWebView: WKWebView? { engine.webView }

    func showOriginal() {
        guard engine.webView != nil else { return }
        showingOriginal = true
        UIAccessibility.post(
            notification: .screenChanged,
            argument: "Página original. Navegación web estándar."
        )
    }

    func showAccessible() {
        showingOriginal = false
        UIAccessibility.post(notification: .screenChanged, argument: "Vista accesible.")
    }

    /// Announcements that describe the native view, held back while the user
    /// is on the original page: hearing "3 grupos de opciones" over a web
    /// they are reading themselves is noise about a screen they cannot see.
    private func announce(_ text: String) {
        guard !showingOriginal else { return }
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    /// The page changed and nobody was waiting for it: the user navigated
    /// inside the visible WebView, or a site redirected, or a submit the
    /// engine already answered came back later. The native view follows.
    private func pageChangedOnItsOwn(_ result: Result<ExtractedPage, Error>) {
        switch result {
        case .success(let page):
            guard !page.isEquivalent(to: self.page) else { return }
            noteArrivals(in: page, cause: arrivalCause)
            address = page.url
            state = .loaded(page)
            collapsed = []
            announce("\(page.displayTitle). La página cambió.")
            Task { await detectIntent(for: page) }
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
        collapsed = []
        intentGroups = []
        listingNames = [:]
        suggestions = [:]
        resolvedValues = [:]
        arrivals = []
        intentState = .unavailable
        UIAccessibility.post(notification: .announcement, argument: "Cargando página")

        do {
            let page = try await engine.extract(url: url)
            address = page.url
            state = .loaded(page)
            // Screen-reader users get no visual cue that the page swapped, so
            // say it. Without this the app looks frozen to VoiceOver.
            announce("\(page.title). \(page.stats.blockCount) secciones.")
            await detectIntent(for: page)
        } catch {
            state = .failed(error.localizedDescription)
            UIAccessibility.post(notification: .announcement, argument: "No se pudo leer esta página")
        }
    }

    // MARK: - Intent

    private func detectIntent(for page: ExtractedPage) async {
        guard let analyzer else { return }
        intentState = .detecting

        do {
            let scores = try await analyzer.detectIntents(for: page)

            // Group first: the goal list IS the page for a task site, so it
            // should appear whether or not we end up asking anything.
            if !page.actions.isEmpty {
                intentGroups = await analyzer.classify(
                    actions: page.actions, site: page.siteName, scores: scores
                )
                announce("\(page.title). \(intentGroups.count) grupos de opciones.")
            }

            if !page.listings.isEmpty {
                listingNames = await analyzer.nameListings(page.listings, site: page.siteName)
            }

            let decision = scores.decide()
            switch decision {
            case .assume(let intent):
                // Reading is the default state of a reader; treating it as a
                // confirmed intent and reordering around it would be noise.
                if intent == .read {
                    intentState = .applied(.read)
                } else {
                    await apply(intent, to: page)
                }
            case .ask(let options):
                // With goal groups on screen the separate question panel would
                // be a second copy of the same list. Show it only when there is
                // nothing to group — a page of prose with no actions.
                intentState = intentGroups.isEmpty ? .asking(options) : .undecided
            case .undecided:
                intentState = .undecided
            }
        } catch {
            // Jev is an enhancement. If it fails the page still reads.
            intentState = .undecided
        }
    }

    /// Answers a blocking overlay with the choice the user picked.
    ///
    /// Only ever called from a tap: the app never resolves an overlay on its
    /// own, because consent and payment are the user's decisions.
    func resolveOverlay(_ choice: Overlay.Choice) async {
        UIAccessibility.post(notification: .announcement, argument: "Respondiendo: \(choice.label)")
        do {
            switch try await engine.activate(actionID: choice.id) {
            case .updated(let page):
                address = page.url
                state = .loaded(page)
                collapsed = []
                UIAccessibility.post(
                    notification: .announcement,
                    argument: page.overlay == nil ? "Aviso resuelto." : "La página sigue mostrando un aviso."
                )
                await detectIntent(for: page)
            case .stale:
                await go()
            }
        } catch {
            UIAccessibility.post(
                notification: .announcement, argument: "No se pudo responder el aviso"
            )
        }
    }

    /// Presses a control the page owns, then refreshes from whatever it became.
    ///
    /// Links navigate; buttons are clicked inside the live page. Either way the
    /// native view is rebuilt from the result, in the same session.
    func activate(_ action: Action) async {
        // A link with an href needs no round trip through the page.
        if action.kind == .link, let href = action.href {
            address = href
            await go()
            return
        }

        UIAccessibility.post(notification: .announcement, argument: "Activando \(action.label)")

        do {
            switch try await engine.activate(actionID: action.id) {
            case .updated(let page):
                // A control that changed nothing is not an error and must not
                // look like one. Rebuilding the view would also send VoiceOver
                // back to the top of the page for nothing.
                guard !page.isEquivalent(to: self.page) else {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: "\(action.label) no cambió la página."
                    )
                    return
                }
                noteArrivals(in: page, cause: action.label)
                address = page.url
                state = .loaded(page)
                collapsed = []
                UIAccessibility.post(
                    notification: .announcement,
                    argument: arrivals.isEmpty
                        ? "\(action.label) activado. La página cambió."
                        : "\(action.label) activado. Aparecieron \(arrivals.count) opciones."
                )
                await detectIntent(for: page)

            case .stale:
                // The node vanished between extraction and the tap — a SPA
                // re-rendered underneath us. Reloading re-stamps everything.
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "Ese control ya no está. Recargando."
                )
                await go()
            }
        } catch {
            UIAccessibility.post(
                notification: .announcement,
                argument: "No se pudo activar \(action.label)"
            )
        }
    }

    /// Carries one field edit into the live page, then asks what the page
    /// suggests for it.
    ///
    /// Fire-and-forget on purpose: typing must not wait on a round trip, and a
    /// failed write is corrected by the next keystroke. The suggestions are
    /// asked for once typing pauses — an autocomplete answers after a fetch,
    /// and asking on every keystroke would read a stale list.
    func fill(_ field: Action.Field, with value: String) {
        // The value a pick just put in the field comes back through here as
        // the text field catches up. The page already has it; writing it
        // again reopened the list that was just closed.
        if resolvedValues[field.id] == value { return }

        suggestionTask?.cancel()
        suggestionTask = Task {
            try? await engine.fill(fieldID: field.id, value: value)
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }
            let found = (try? await engine.suggestions(fieldID: field.id)) ?? []
            guard !Task.isCancelled else { return }
            suggestions[field.id] = found
            if !found.isEmpty {
                announce("\(found.count) sugerencias para \(field.name)")
            }
        }
    }

    /// Picks what the page offered. The field then holds whatever the page
    /// decided that pick means — "BUE", or the full airport name.
    func choose(_ field: Action.Field, suggestion index: Int) async {
        // Whatever typing was still pending — iOS autocorrect fires one last
        // edit as the tap lands ("Cordoba" → "Córdoba") — must not come back
        // 700 ms later and reopen the list that was just closed.
        suggestionTask?.cancel()
        do {
            let value = try await engine.choose(fieldID: field.id, index: index)
            suggestions[field.id] = []
            resolvedValues[field.id] = value
            announce("\(field.name): \(value)")
        } catch {
            announce("No se pudo elegir esa opción")
        }
    }

    /// Submits a form and refreshes from whatever the page became.
    func submit(_ action: Action) async {
        UIAccessibility.post(notification: .announcement, argument: "Enviando formulario")
        do {
            switch try await engine.submit(actionID: action.id) {
            case .updated(let page):
                guard !page.isEquivalent(to: self.page) else {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: "Formulario enviado. La página no cambió."
                    )
                    return
                }
                address = page.url
                state = .loaded(page)
                collapsed = []
                UIAccessibility.post(
                    notification: .announcement, argument: "Formulario enviado."
                )
                await detectIntent(for: page)
            case .stale:
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "El formulario ya no está. Recargando."
                )
                await go()
            }
        } catch {
            UIAccessibility.post(
                notification: .announcement, argument: "No se pudo enviar el formulario"
            )
        }
    }

    /// Called when the user picks one of the offered options.
    func choose(_ intent: Intent) async {
        guard let page else { return }
        await apply(intent, to: page)
    }

    /// Restores the untouched page. Always reachable — nothing Jev decides is
    /// one-way.
    func showEverything() {
        collapsed = []
        intentState = .undecided
        UIAccessibility.post(notification: .announcement, argument: "Mostrando la página completa")
    }

    private func apply(_ intent: Intent, to page: ExtractedPage) async {
        guard let analyzer else { return }
        intentState = .detecting

        let verdicts = await analyzer.rankBlocks(of: page, for: intent)
        collapsed = Set(verdicts.filter(\.shouldCollapse).map(\.blockID))
        intentState = .applied(intent)

        let hidden = collapsed.count
        announce(
            hidden == 0
                ? "Página lista. No se ocultó nada."
                : "Página simplificada. \(hidden) elementos agrupados al final."
        )
    }

    /// What is new in `page` compared with the one on screen: the controls
    /// a tap made appear. New by element, as the extractor marks them —
    /// a second "Comprar" inside a modal is new though its label is not.
    private func noteArrivals(in page: ExtractedPage, cause: String) {
        // A different page is a different page, not an arrival.
        guard let current = self.page, current.url == page.url else {
            arrivals = []
            return
        }
        let fresh = page.actions.filter { $0.fresh == true && $0.kind != .form }
        arrivals = Array(fresh.prefix(12))
        arrivalCause = cause
    }

    /// Accepts what people actually type: bare hosts, missing schemes.
    static func normalize(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard
            let url = URL(string: candidate),
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http",
            let host = url.host(), host.contains(".")
        else { return nil }

        return url
    }
}

struct ReaderView: View {
    @State private var model = ReaderModel()
    @FocusState private var addressFocused: Bool

    var body: some View {
        NavigationStack {
            // The WebView is always in the hierarchy, underneath. Off the
            // screen WebKit stops requestAnimationFrame, and React Helmet
            // renames the document inside one: the title stayed "Calendario
            // de vuelos" through the whole purchase. Covered by the native
            // view it keeps running; the native view stays alive on top —
            // hidden, not gone — so what the user typed is still there
            // when they come back from the original page.
            ZStack {
                if let web = model.liveWebView {
                    WebPageView(webView: web)
                        .allowsHitTesting(model.showingOriginal)
                        .accessibilityHidden(!model.showingOriginal)
                }
                content
                    .background(Color(.systemBackground))
                    .opacity(model.showingOriginal ? 0 : 1)
                    .allowsHitTesting(!model.showingOriginal)
                    .accessibilityHidden(model.showingOriginal)
            }
            // Como Safari: nada arriba. El título de la página vive en el
            // contenido y no se repite en el cromo, y la barra va abajo, donde
            // la gente ya la tiene desde iOS 15.
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                addressBar
            }
        }
    }

    /// El dominio de la página cargada, como lo escribe Safari: sin esquema y
    /// sin `www.`.
    private var displayHost: String {
        guard
            let page = model.page,
            let host = URL(string: page.url)?.host()
        else { return "" }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    /// Un solo campo que muestra dos cosas, como el de Safari: el dominio
    /// mientras se lee, la dirección entera mientras se escribe.
    private var barText: Binding<String> {
        Binding(
            get: { addressFocused || displayHost.isEmpty ? model.address : displayHost },
            set: { model.address = $0 }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle:
            EmptyStateView()
        case .loading(let url):
            LoadingView(host: url.host() ?? "")
        case .loaded(let page):
            ArticleView(
                page: page,
                intentState: model.intentState,
                collapsed: model.collapsed,
                intentGroups: model.intentGroups,
                listingNames: model.listingNames,
                onChoose: { intent in Task { await model.choose(intent) } },
                onShowEverything: { model.showEverything() },
                onOpenAction: { action in
                    Task { await model.activate(action) }
                },
                onFillField: { field, value in model.fill(field, with: value) },
                suggestions: model.suggestions,
                resolvedValues: model.resolvedValues,
                onChooseSuggestion: { field, index in
                    Task { await model.choose(field, suggestion: index) }
                },
                onSubmitForm: { action in Task { await model.submit(action) } },
                onOpenURL: { href in
                    model.address = href
                    Task { await model.go() }
                },
                onOverlayChoice: { choice in
                    Task { await model.resolveOverlay(choice) }
                },
                onOpenOriginal: { model.showOriginal() },
                arrivals: model.arrivals,
                arrivalCause: model.arrivalCause
            )
        case .failed(let message):
            FailureView(
                message: message,
                retry: { Task { await model.go() } },
                // Only once there is a page to show. A bad address never
                // loaded anything.
                openOriginal: model.liveWebView == nil ? nil : { model.showOriginal() }
            )
        }
    }

    private var addressBar: some View {
        HStack(spacing: 8) {
            // Where Safari keeps its page menu: the way out of the native
            // view, and the way back. Hidden while typing to leave room.
            if !addressFocused, model.liveWebView != nil {
                Button {
                    model.showingOriginal ? model.showAccessible() : model.showOriginal()
                } label: {
                    Image(systemName: model.showingOriginal ? "doc.plaintext" : "globe")
                        .font(.title3)
                }
                .accessibilityLabel(
                    model.showingOriginal ? "Volver a la vista accesible" : "Ver la página original"
                )
                .accessibilityHint(
                    model.showingOriginal
                        ? "La página reconstruida, con rotores y grupos"
                        : "La web tal cual, con navegación web estándar"
                )
            }

            TextField("Buscar o ingresar dirección", text: barText)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(addressFocused ? .leading : .center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .submitLabel(.go)
                .focused($addressFocused)
                .accessibilityLabel("Dirección")
                .accessibilityHint("Tocá dos veces para ir a otro sitio")
                .onSubmit {
                    addressFocused = false
                    Task { await model.go() }
                }

            // Safari no muestra ningún botón mientras se lee: la barra en
            // reposo es sólo el dominio. Al escribir sí hace falta un destino
            // que no sea la tecla "ir" del teclado.
            if addressFocused {
                Button("Ir") {
                    addressFocused = false
                    Task { await model.go() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Carga y simplifica la página")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

// MARK: - States

private struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "Nothing loaded",
            systemImage: "doc.text",
            description: Text("Enter an address below to read a page.")
        )
    }
}

private struct LoadingView: View {
    let host: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Reading \(host)…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reading \(host)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct FailureView: View {
    let message: String
    let retry: () -> Void
    /// The way out. Nil only when nothing was ever loaded.
    var openOriginal: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label("Could not read this page", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
            if let openOriginal {
                Button("Abrir la página original", action: openOriginal)
                    .accessibilityHint("La web tal cual, con navegación web estándar")
            }
        }
    }
}
