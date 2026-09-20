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

    private(set) var state: State = .idle {
        // La pila del WebView no es observable, así que se copia acá cada vez
        // que la página cambia: es lo que decide si "Volver" está activo.
        didSet { canGoBack = engine.canGoBack }
    }
    private(set) var canGoBack = false
    /// Llegamos a esta página tocando una opción, no escribiendo una
    /// dirección.
    ///
    /// Entonces la intención ya está clara y no se vuelve a preguntar: quien
    /// tocó "Ingresar" no necesita que le ofrezcan ingresar. UX.md lo llama
    /// "el tipo se pega al flujo"; acá el flujo es el toque que trajo.
    private(set) var inFlow = false
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
    /// Where VoiceOver should land after the page changed under someone's
    /// feet. Rebuilding the view destroys the element the cursor was on,
    /// and the cursor falls back to the top — which is complaint number
    /// four on every list of what screen-reader users hate. Announcing the
    /// change is not enough: the focus has to go somewhere deliberate.
    /// `nil` leaves it where it is.
    private(set) var focusTarget: String?
    private var suggestionTask: Task<Void, Never>?
    /// Puente entre `activate` y `go`: la dirección que sigue vino de un
    /// toque, no del teclado.
    private var openedByTap = false

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
            // Fields the form did not have a moment ago: say which, not
            // that "the page changed" — the person is in the middle of it.
            let known = Set((self.page?.fields ?? []).map(\.name))
            let added = page.url == self.page?.url
                ? page.fields.filter { !known.contains($0.name) }
                : []
            noteArrivals(in: page, cause: arrivalCause)
            address = page.url
            state = .loaded(page)
            collapsed = []
            if added.isEmpty {
                announce("\(page.displayTitle). La página cambió.")
            } else {
                let names = added.map(\.name)
                announce(names.count == 1
                    ? "Apareció un campo: \(names[0])"
                    : "Aparecieron \(names.count) campos: \(names.joined(separator: ", "))")
                // The person was filling this form. Put them on what
                // appeared, not back at the title.
                focusTarget = added.first?.id
            }
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
        focusTarget = nil
        // Sólo cuando la dirección la escribió una persona. Un link abierto
        // desde la página pasa por acá también, y ése sí viene de un toque.
        inFlow = openedByTap
        openedByTap = false
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
        // Una página que se lee en su orden no se agrupa por intención: no
        // hay nada que preguntarle a Jev, y su forma no puede depender de
        // que la red conteste.
        guard !page.readsInOrder else {
            intentState = .unavailable
            return
        }
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
            openedByTap = true
            await go()
            return
        }
        openedByTap = false
        inFlow = true

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
                focusTarget = arrivals.isEmpty ? nil : ReaderModel.arrivalsAnchor
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

    /// Opens a combobox's list without typing, then reads the list as
    /// suggestions for that field: the whole list, for someone who does
    /// not know what it holds.
    func openField(_ field: Action.Field) async {
        suggestionTask?.cancel()
        try? await engine.open(fieldID: field.id)
        try? await Task.sleep(for: .milliseconds(500))
        let found = (try? await engine.suggestions(fieldID: field.id)) ?? []
        suggestions[field.id] = found
        announce(found.isEmpty ? "No aparecieron opciones" : "\(found.count) opciones para \(field.name)")
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
                // The page kept the form and marked what is missing. Said
                // out loud here; each message also sits under its field.
                let complaints = page.actions.flatMap { $0.fields ?? [] }
                    .filter { !($0.error ?? "").isEmpty }
                let notices = page.actions.first { $0.id == action.id }?.notices ?? []
                let detail = complaints.first.map { "\($0.name): \($0.error ?? "")" } ?? notices.first
                if page.url == self.page?.url, let detail {
                    arrivals = []
                    suggestions = [:]
                    state = .loaded(page)
                    focusTarget = complaints.first?.id
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: complaints.count > 1
                            ? "No se envió. \(complaints.count) campos con errores. \(detail)"
                            : "No se envió. \(detail)"
                    )
                    return
                }
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
                suggestions = [:]
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

    /// Volver a la página anterior.
    ///
    /// En un navegador sin vista, volver es el gesto más usado de todos: se
    /// entra a algo, no era, se sale. Por eso está en un lugar fijo de la
    /// barra y además atado al gesto de escape de VoiceOver — dos dedos, Z —
    /// que es como se sale de todo lo demás en iOS.
    func back() async {
        guard engine.canGoBack else {
            UIAccessibility.post(notification: .announcement, argument: "No hay página anterior")
            return
        }
        UIAccessibility.post(notification: .announcement, argument: "Volviendo")
        do {
            let page = try await engine.goBack()
            inFlow = false
            address = page.url
            state = .loaded(page)
            collapsed = []
            intentGroups = []
            listingNames = [:]
            arrivals = []
            intentState = .unavailable
            announce("\(page.displayTitle). \(page.stats.blockCount) secciones.")
            await detectIntent(for: page)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Reads the page again, as it is now. For when the native view fell
    /// behind the page — a form that rendered after the last look.
    func reread() async {
        UIAccessibility.post(notification: .announcement, argument: "Leyendo la página de nuevo")
        do {
            let page = try await engine.reread()
            noteArrivals(in: page, cause: "leer de nuevo")
            address = page.url
            state = .loaded(page)
            collapsed = []
            UIAccessibility.post(
                notification: .announcement,
                argument: "\(page.displayTitle). \(page.stats.blockCount) secciones."
            )
            await detectIntent(for: page)
        } catch {
            UIAccessibility.post(notification: .announcement, argument: "No se pudo leer la página")
        }
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
        // A different page is a different page, not an arrival — and what
        // it shows later is not what the last tap on the old one opened.
        guard let current = self.page, current.url == page.url else {
            arrivals = []
            arrivalCause = ""
            return
        }
        let fresh = page.actions.filter { $0.fresh == true && $0.kind != .form }
        // Most of the page being new means the page arrived, not that a
        // tap opened something: the checkout rendered its accordion a
        // minute after its route, and read as seven arrivals.
        //
        // Salvo en una página que se lee en su orden, donde lo que llegó va
        // detrás de una sola puerta con el nombre de lo que se tocó: el menú
        // de "Secciones" de un diario son treinta links sobre veinte, y son
        // exactamente la respuesta al toque.
        if page.readsInOrder {
            arrivals = fresh.count < page.actions.count ? fresh : []
        } else {
            guard fresh.count * 2 < page.actions.count else {
                arrivals = []
                return
            }
            arrivals = Array(fresh.prefix(12))
        }
        arrivalCause = cause
    }

    /// The id of the "what just appeared" box, for moving focus there.
    static let arrivalsAnchor = "jef.arrivals"

    /// Consumed by the view once the cursor has been placed.
    func clearFocusTarget() { focusTarget = nil }

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

struct ReaderView: View {
    @State private var model = ReaderModel()
    /// Las pantallas abiertas sobre la página.
    ///
    /// Se vacía apenas se toca algo que navega: la página nueva se carga
    /// debajo, y quedarse en la lista de opciones de la página anterior se
    /// siente —y suena— como que el toque no hizo nada.
    @State private var path = NavigationPath()
    @State private var sites = SavedSites()
    @State private var showingSites = false
    @State private var showingSettings = false
    @AppStorage("jef.textSize") private var textSize = TextSize.system.rawValue
    @AppStorage("jef.appearance") private var appearance = Appearance.system.rawValue
    @Environment(\.dynamicTypeSize) private var systemTypeSize
    @FocusState private var addressFocused: Bool
    /// Where the VoiceOver cursor is. Moved deliberately when the page
    /// changes under someone, so they do not get dropped back at the top.
    @AccessibilityFocusState private var focused: String?

    /// El tamaño que manda: el de Ajustes si se eligió uno, el del sistema si
    /// no. Se calcula acá porque leer el entorno en la misma vista que lo
    /// escribe devuelve el valor de entrada, no el elegido.
    private var typeSize: DynamicTypeSize {
        TextSize(rawValue: textSize)?.dynamicTypeSize ?? systemTypeSize
    }

    var body: some View {
        NavigationStack(path: $path) {
            // The native view stays alive underneath the original page —
            // hidden, not gone — so what the user typed into a form is still
            // there when they come back. The WebView itself stays out of the
            // hierarchy until shown: inside it, in any window, the keyboard
            // stopped reaching the native fields.
            ZStack {
                content
                    .opacity(model.showingOriginal ? 0 : 1)
                    .allowsHitTesting(!model.showingOriginal)
                    .accessibilityHidden(model.showingOriginal)
                if model.showingOriginal, let web = model.liveWebView {
                    WebPageView(webView: web)
                }
            }
            // Como Safari: nada arriba. El título de la página vive en el
            // contenido y no se repite en el cromo, y la barra va abajo, donde
            // la gente ya la tiene desde iOS 15.
            //
            // Abajo también por una razón que Safari no tuvo que pensar:
            // VoiceOver lee el cromo DESPUÉS del contenido, así que la app no
            // gasta ninguna parada antes de que la página diga su nombre. El
            // toque de cuatro dedos abajo cae directo acá.
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                chrome
            }
            // Salir es volver. Es el gesto con el que se sale de todo lo demás
            // en iOS, y acá no estaba atado a nada.
            .accessibilityAction(.escape) {
                Task { await model.back() }
            }
            // Una categoría abre una pantalla, no se despliega. Ver [Route].
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .options(let title, let actions):
                    OptionsScreen(title: title, actions: actions) { action in
                        open(action)
                    }
                case .groups(let title, let groups):
                    GroupsScreen(title: title, groups: groups) { action in
                        open(action)
                    }
                case .entries(let title, let ids):
                    if let page = model.page {
                        EntriesScreen(
                            title: title,
                            segments: page.segments(only: Set(ids), title: title),
                            onOpen: { action in open(action) },
                            onOpenURL: { href in
                                path = NavigationPath()
                                model.address = href
                                Task { await model.go() }
                            },
                            onActivate: { id in
                                guard let action = page.actions.first(where: { $0.id == id })
                                else { return }
                                open(action)
                            }
                        )
                    }
                case .headlines:
                    if let page = model.page {
                        HeadlinesScreen(
                            page: page,
                            listingNames: model.listingNames,
                            onOpenURL: { href in
                                path = NavigationPath()
                                model.address = href
                                Task { await model.go() }
                            },
                            onActivate: { id in
                                guard let action = page.actions.first(where: { $0.id == id })
                                else { return }
                                open(action)
                            }
                        )
                    }
                }
            }
            .sheet(isPresented: $showingSites) {
                SavedSitesView(
                    sites: sites,
                    onOpen: { open($0) },
                    onDone: { showingSites = false }
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView { showingSettings = false }
            }
            // After the view is rebuilt, not before: the element to focus
            // has to exist, and the announcement that says why should be
            // heard first rather than cut off by the cursor landing.
            .onChange(of: model.focusTarget) { _, target in
                guard let target else { return }
                Task {
                    try? await Task.sleep(for: .milliseconds(900))
                    focused = target
                    model.clearFocusTarget()
                }
            }
        }
        .dynamicTypeSize(typeSize)
        .preferredColorScheme(Appearance(rawValue: appearance)?.colorScheme)
    }

    /// Abre una opción desde una pantalla: cierra la pantalla y activa el
    /// control en la página.
    private func open(_ action: Action) {
        path = NavigationPath()
        Task { await model.activate(action) }
    }

    private func open(_ site: SavedSites.Site) {
        showingSites = false
        addressFocused = false
        model.address = site.url
        Task { await model.go() }
    }

    private var isSaved: Bool {
        guard let page = model.page else { return false }
        return sites.contains(page.url)
    }

    private func toggleSaved() {
        guard let page = model.page else { return }
        if sites.contains(page.url) {
            sites.remove(page.url)
            UIAccessibility.post(notification: .announcement, argument: "Quitado de mis sitios")
        } else {
            sites.save(name: page.displaySite, url: page.url)
            UIAccessibility.post(notification: .announcement, argument: "Guardado en mis sitios")
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
            // La app abre en la lista de sitios. Para quien no ve, escribir
            // una dirección es lo más caro de un navegador, y una pantalla de
            // inicio vacía obliga a hacerlo todas las veces.
            SavedSitesView(sites: sites, onOpen: { open($0) })
        case .loading(let url):
            LoadingView(host: url.host() ?? "")
        case .loaded(let page):
            ArticleView(
                page: page,
                focused: $focused,
                inFlow: model.inFlow,
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
                onOpenField: { field in Task { await model.openField(field) } },
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

    /// El cromo: la dirección y cinco destinos fijos.
    ///
    /// Fijos es la palabra. Una barra que cambia según el sitio no se puede
    /// aprender de memoria, y aprenderla de memoria es exactamente para lo
    /// que sirve. Lo que ofrece cada sitio vive adentro de la página, en
    /// "Más de este sitio", y nunca acá.
    private var chrome: some View {
        VStack(spacing: 10) {
            addressField
            if !addressFocused { toolbar }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(.bar)
    }

    /// Un solo campo que muestra dos cosas, como el de Safari: el dominio
    /// mientras se lee, la dirección entera mientras se escribe.
    private var addressField: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                TextField("Buscar o ingresar dirección", text: barText)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(addressFocused ? .leading : .center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .focused($addressFocused)
                    .accessibilityLabel("Dirección")
                    .accessibilityValue(displayHost)
                    .accessibilityHint("Tocá dos veces para ir a otro sitio")
                    .onSubmit {
                        addressFocused = false
                        Task { await model.go() }
                    }

                // Where Safari keeps reload. Reads the page again as it is
                // now, for when the native view fell behind it.
                if !addressFocused, model.liveWebView != nil, !model.showingOriginal {
                    Button {
                        Task { await model.reread() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Leer de nuevo")
                    .accessibilityHint("Vuelve a leer la página tal como está ahora")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color(.tertiarySystemFill), in: Capsule())

            // Safari no muestra ningún botón mientras se lee: la barra en
            // reposo es sólo el dominio. Al escribir sí hace falta un destino
            // que no sea la tecla "ir" del teclado.
            if addressFocused {
                Button("Ir") {
                    addressFocused = false
                    Task { await model.go() }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .accessibilityHint("Carga y simplifica la página")
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 0) {
            toolbarButton(
                symbol: "chevron.left", label: "Volver", enabled: model.canGoBack,
                hint: "Vuelve a la página anterior"
            ) {
                Task { await model.back() }
            }

            toolbarButton(symbol: "book", label: "Mis sitios", hint: "Tus sitios guardados") {
                addressFocused = false
                showingSites = true
            }

            toolbarButton(
                symbol: isSaved ? "bookmark.fill" : "bookmark",
                label: isSaved ? "Guardado" : "Guardar",
                enabled: model.page != nil,
                hint: isSaved ? "Lo quita de tus sitios" : "Lo agrega a tus sitios"
            ) {
                toggleSaved()
            }

            toolbarButton(
                symbol: model.showingOriginal ? "doc.plaintext" : "globe",
                label: model.showingOriginal ? "Accesible" : "Original",
                enabled: model.liveWebView != nil,
                hint: model.showingOriginal
                    ? "La página reconstruida, con rotores y grupos"
                    : "La web tal cual, con navegación web estándar"
            ) {
                model.showingOriginal ? model.showAccessible() : model.showOriginal()
            }

            toolbarButton(symbol: "gearshape", label: "Ajustes", hint: "Tamaño del texto y apariencia") {
                addressFocused = false
                showingSettings = true
            }
        }
    }

    /// Un destino de la barra.
    ///
    /// Con su palabra debajo: un ícono solo es un acertijo para quien ve poco
    /// y para quien nunca usó la app. A tamaños de accesibilidad la palabra se
    /// va —ahí sí rompería la fila— y el ícono crece; VoiceOver la dice igual,
    /// porque nunca dependió de que estuviera dibujada.
    @ViewBuilder
    private func toolbarButton(
        symbol: String,
        label: String,
        enabled: Bool = true,
        hint: String,
        action: @escaping () -> Void
    ) -> some View {
        let big = typeSize.isAccessibilitySize

        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: big ? 26 : 20, weight: .regular))
                    .frame(height: big ? 30 : 22)
                if !big {
                    Text(label)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(enabled ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
        .disabled(!enabled)
        .accessibilityLabel(label)
        .accessibilityHint(hint)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - States

private struct LoadingView: View {
    let host: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Leyendo \(host)…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Leyendo \(host)")
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
            Label("No se pudo leer esta página", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Intentar de nuevo", action: retry)
                .buttonStyle(.borderedProminent)
            if let openOriginal {
                Button("Abrir la página original", action: openOriginal)
                    .accessibilityHint("La web tal cual, con navegación web estándar")
            }
        }
        .background(Color(.systemBackground))
    }
}
