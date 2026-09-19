import SwiftUI

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

    var address: String = "https://www.lanacion.com.ar"

    private let engine = HeadlessWebView()
    private let analyzer: PageAnalyzer?

    init() {
        analyzer = JevClient.fromEnvironment().map(PageAnalyzer.init)
    }

    var page: ExtractedPage? {
        if case .loaded(let page) = state { return page }
        return nil
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
        intentState = .unavailable
        UIAccessibility.post(notification: .announcement, argument: "Cargando página")

        do {
            let page = try await engine.extract(url: url)
            state = .loaded(page)
            // Screen-reader users get no visual cue that the page swapped, so
            // say it. Without this the app looks frozen to VoiceOver.
            UIAccessibility.post(
                notification: .announcement,
                argument: "\(page.title). \(page.stats.blockCount) secciones."
            )
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
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "\(page.title). \(intentGroups.count) grupos de opciones."
                )
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

    /// Presses a control the page owns, then refreshes from whatever it became.
    ///
    /// Links navigate; buttons are clicked inside the live page. Either way the
    /// native view is rebuilt from the result, so the user never sees a WebView.
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
            case .navigated(let url):
                address = url.absoluteString
                await go()

            case .updated(let page):
                state = .loaded(page)
                collapsed = []
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "\(action.label) activado. La página cambió."
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

    /// Carries one field edit into the live page.
    ///
    /// Fire-and-forget on purpose: typing must not wait on a round trip, and a
    /// failed write is corrected by the next keystroke.
    func fill(_ field: Action.Field, with value: String) {
        Task { try? await engine.fill(fieldID: field.id, value: value) }
    }

    /// Submits a form and refreshes from whatever the page became.
    func submit(_ action: Action) async {
        UIAccessibility.post(notification: .announcement, argument: "Enviando formulario")
        do {
            switch try await engine.submit(actionID: action.id) {
            case .navigated(let url):
                address = url.absoluteString
                await go()
            case .updated(let page):
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
        UIAccessibility.post(
            notification: .announcement,
            argument: hidden == 0
                ? "Página lista. No se ocultó nada."
                : "Página simplificada. \(hidden) elementos agrupados al final."
        )
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
            Group {
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
                        onSubmitForm: { action in Task { await model.submit(action) } },
                        onOpenURL: { href in
                            model.address = href
                            Task { await model.go() }
                        }
                    )
                case .failed(let message):
                    FailureView(message: message) {
                        Task { await model.go() }
                    }
                }
            }
            .navigationTitle(model.page?.siteName ?? "Reader")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                addressBar
            }
        }
    }

    private var addressBar: some View {
        HStack(spacing: 8) {
            TextField("Address", text: $model.address)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .submitLabel(.go)
                .focused($addressFocused)
                .accessibilityLabel("Web address")
                .accessibilityHint("Enter a site to read")
                .onSubmit {
                    addressFocused = false
                    Task { await model.go() }
                }

            Button("Go") {
                addressFocused = false
                Task { await model.go() }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Loads and simplifies the page")
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
            description: Text("Enter an address above to read a page.")
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

    var body: some View {
        ContentUnavailableView {
            Label("Could not read this page", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
