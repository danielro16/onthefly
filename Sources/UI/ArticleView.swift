import SwiftUI

/// Renders an extracted page as native SwiftUI.
///
/// Two things here are the reason this app is not React Native:
///
/// 1. Inline links inside a paragraph are real, individually focusable
///    accessibility elements (`AttributedString` + `.link`). React Native has
///    had this broken on iOS since 2019 (facebook/react-native#24515, #32004).
/// 2. Custom rotors let VoiceOver users jump by heading or by link, which is
///    how people actually navigate a long page. React Native exposes no API
///    for `UIAccessibilityCustomRotor` at all.
struct ArticleView: View {
    let page: ExtractedPage
    var intentState: ReaderModel.IntentState = .unavailable
    var collapsed: Set<String> = []
    var intentGroups: [IntentGroup] = []
    var listingNames: [String: String] = [:]
    var onChoose: (Intent) -> Void = { _ in }
    var onShowEverything: () -> Void = {}
    var onOpenAction: (Action) -> Void = { _ in }
    var onFillField: (Action.Field, String) -> Void = { _, _ in }
    var suggestions: [String: [String]] = [:]
    var resolvedValues: [String: String] = [:]
    var onChooseSuggestion: (Action.Field, Int) -> Void = { _, _ in }
    var onOpenField: (Action.Field) -> Void = { _ in }
    var onSubmitForm: (Action) -> Void = { _ in }
    var onOpenURL: (String) -> Void = { _ in }
    var onOverlayChoice: (Overlay.Choice) -> Void = { _ in }
    var onOpenOriginal: () -> Void = {}
    /// What the last tap made appear. See `ReaderModel.arrivals`.
    var arrivals: [Action] = []
    var arrivalCause = ""

    /// Ties each block view to its rotor entries so VoiceOver can jump to it.
    @Namespace private var rotorNamespace

    private var visibleBlocks: [Block] {
        page.blocks.filter { !collapsed.contains($0.id) }
    }

    private var collapsedBlocks: [Block] {
        page.blocks.filter { collapsed.contains($0.id) }
    }

    /// What Jev decided the page is for, once it decided.
    private var dominant: Intent? {
        if case .applied(let intent) = intentState { return intent }
        return nil
    }

    /// Reading is what a newspaper or an article is for, and there the
    /// listings and the prose ARE the page. Nothing may sit above them.
    private var leadsWithContent: Bool { dominant == .read }

    private var isDetecting: Bool {
        if case .detecting = intentState { return true }
        return false
    }

    /// No goal, no grid, no article: a portal. Its listings are what it has
    /// to offer — argentina.gob.ar is "Más temas" and little else — and
    /// collapsed they were two closed boxes over one paragraph.
    private var nothingLeads: Bool {
        !isDetecting && !leadsWithContent && leadGroup == nil && leadCluster == nil
    }

    /// Two lone links are not a question. "¿Qué querés hacer?" over
    /// "Consultar un dato, 1 opción" and "Información del sitio, 1 opción"
    /// is a menu of one item each, dressed as a decision.
    private var fewActions: Bool {
        intentGroups.reduce(0) { $0 + $1.count } <= 3
    }

    /// A shop. Listings that carry prices are what the visitor came for;
    /// Jev read fravega.com's home as "Ayuda" — two phone numbers on top,
    /// seventy priced products folded away underneath.
    private var isCatalog: Bool {
        page.listings.contains { isPriced($0) }
    }

    private func isPriced(_ listing: Listing) -> Bool {
        let priced = listing.items.filter { $0.price != nil }.count
        return priced >= 3 && priced * 2 >= listing.items.count
    }

    /// The content opens the page: an article, a newspaper, a shop, or a
    /// portal with nothing leading — where four goal categories over "Más
    /// temas" were a question before the answer. The site's actions go to
    /// the menu.
    /// A results page. Whatever the query was for, the results are the
    /// answer; on Google Jev led with "Comparar opciones" and the seven
    /// results sat collapsed beneath it.
    private var hasResults: Bool {
        page.listings.contains { listing in
            listing.title.range(of: "resultados|results", options: [.regularExpression, .caseInsensitive]) != nil
                || listingNames[listing.id] == "Resultados"
        }
    }

    private var contentFirst: Bool {
        leadsWithContent || isCatalog || hasResults
            || (nothingLeads && (!page.listings.isEmpty || !visibleBlocks.isEmpty))
    }

    /// The one goal that answers the dominant intent. It leads instead of
    /// sitting as one category among four.
    private var leadGroup: IntentGroup? {
        guard let dominant, !leadsWithContent else { return nil }
        // The catch-all never leads. A bank's marketing home came out as
        // "Información del sitio, 28 opciones" on top: the leftovers bucket,
        // presented as the point of the page.
        guard !dominant.isCatchAll else { return nil }
        return intentGroups.first { $0.intent == dominant }
    }

    /// The page as one control set, when it is one. See `dominantCluster`.
    private var leadCluster: IntentGroup? {
        let members = page.dominantCluster
        guard !members.isEmpty, !leadsWithContent else { return nil }
        return IntentGroup(
            intent: dominant ?? .compare, actions: members, uncertain: [],
            title: "Elegí una opción"
        )
    }

    /// Everything that did not lead.
    ///
    /// On a page that leads with content there is no lead group, but the
    /// site's actions do not stop existing: a newspaper's sign-in and its
    /// sections went nowhere at all, which made them unreachable rather
    /// than demoted.
    private var demoted: [IntentGroup] {
        if let leadCluster {
            let taken = Set(leadCluster.actions.map(\.id))
            return intentGroups.compactMap { group in
                let rest = group.actions.filter { !taken.contains($0.id) }
                return rest.isEmpty ? nil : IntentGroup(intent: group.intent, actions: rest, uncertain: group.uncertain)
            }
        }
        guard let leadGroup, !contentFirst else { return contentFirst ? intentGroups : [] }
        return intentGroups.filter { $0.id != leadGroup.id }
    }

    /// The button that moves the task forward, wherever Jev filed it.
    ///
    /// On the flight calendar the page is "compare" and leads with the
    /// prices, so "Continuar" — a transaction — went into the site menu,
    /// three levels down from the day the user had just picked. A call to
    /// action is the next step of the screen, not one more thing the site
    /// offers; it stays in the flow, right after the content. Buttons only:
    /// a nav link that happens to say "Reservar" is navigation.
    private static let callToAction =
        "\\b(continuar|siguiente|comprar|pagar|confirmar|reservar|finalizar|checkout|continue|next|buy|pay|confirm)\\b"

    /// The door in. On a bank's home "Online Banking" is the reason most
    /// people came, and it sat fortieth in the site menu. A link counts here
    /// too: sign-in is a link on nearly every site.
    private static let entrance =
        "^(ingres[aá]r?|iniciar sesi[oó]n|acceder|acced[eé]|entrar|login|log in|sign in|online banking|home banking|mi cuenta|abrir men[uú]|men[uú]|open menu|abrir el men[uú])$"

    private var nextSteps: [Action] {
        Array(intentGroups.flatMap(\.actions)
            .filter {
                $0.primary == true
                || ($0.kind == .button
                    && $0.label.range(of: Self.callToAction, options: [.regularExpression, .caseInsensitive]) != nil)
                || $0.label.trimmingCharacters(in: .whitespaces)
                    .range(of: Self.entrance, options: [.regularExpression, .caseInsensitive]) != nil
            }
            .prefix(3))
    }

    /// The groups as shown: the calls to action live in the flow instead,
    /// a button a listing row already presses — "Desde 81.987 ARS" on its
    /// flight — is not listed a second time on its own, and what the last
    /// tap opened is shown where it opened.
    private func withoutNextSteps(_ groups: [IntentGroup]) -> [IntentGroup] {
        let promoted = Set(nextSteps.map(\.id))
        let inListings = Set(page.listings.flatMap { $0.items.flatMap(\.pressableIds) })
        let arrived = Set(arrivals.map(\.id))
        return groups.compactMap { group in
            let rest = group.actions.filter {
                !promoted.contains($0.id) && !inListings.contains($0.id) && !arrived.contains($0.id)
            }
            return rest.isEmpty ? nil : IntentGroup(intent: group.intent, actions: rest, uncertain: group.uncertain)
        }
    }

    /// What the last tap made appear — minus what a listing row already
    /// says: the return flights' price buttons are the return flights.
    private var shownArrivals: [Action] {
        let inListings = Set(page.listings.flatMap { $0.items.flatMap(\.pressableIds) })
        return arrivals.filter { !inListings.contains($0.id) }
    }

    /// What the last tap made appear, first, open, named after the tap.
    @ViewBuilder
    private var arrivalsSection: some View {
        if !shownArrivals.isEmpty {
            ActionGroupsView(
                groups: [IntentGroup(
                    intent: dominant ?? .transact, actions: shownArrivals, uncertain: [],
                    title: arrivalCause.isEmpty ? "Apareció en la página" : "Apareció al tocar \(arrivalCause)"
                )],
                title: nil, expandedByDefault: true, onOpen: onOpenAction
            )
        }
    }

    /// Everything else the site offers. One stop at the end.
    private var menuGroups: [IntentGroup] { withoutNextSteps(demoted) }

    private static let menuDestination = "jef-site-menu"

    /// One entry in a VoiceOver rotor.
    ///
    /// `id` only keeps `ForEach` rows distinct. `destination` is what the rotor
    /// actually jumps to and MUST equal the `.id()` of a view in the scroll
    /// content — several links in one paragraph share one destination.
    private struct RotorTarget: Identifiable {
        let id: String
        let destination: String
        let label: String
    }

    private var headings: [RotorTarget] {
        visibleBlocks.compactMap { block in
            guard case .heading(let id, _, let text) = block else { return nil }
            return RotorTarget(id: id, destination: id, label: text)
        }
    }

    private var linkTargets: [RotorTarget] {
        visibleBlocks.flatMap { block -> [RotorTarget] in
            let text = block.plainText
            return block.links.enumerated().compactMap { index, link in
                guard
                    let range = link.range(in: text),
                    let swiftRange = Range(range, in: text)
                else { return nil }
                return RotorTarget(
                    id: "\(block.id)#\(index)",
                    destination: block.id,
                    label: String(text[swiftRange])
                )
            }
        }
    }

    private var imageTargets: [RotorTarget] {
        visibleBlocks.compactMap { block in
            guard case .image(let id, _, let alt, let needsAlt, let caption) = block else { return nil }
            let label = alt.isEmpty ? (caption ?? "") : alt
            return RotorTarget(
                id: id,
                destination: id,
                label: label.isEmpty ? (needsAlt ? "Imagen sin descripción" : "Imagen") : label
            )
        }
    }

    var body: some View {
        ScrollView {
            // Not lazy, on purpose. A LazyVStack kept showing the first
            // render after Jev answered: listings stayed collapsed and
            // unnamed on lanacion.com.ar while the body had already been
            // re-evaluated with the names in hand. And a lazy stack only
            // puts the visible part of the page in the accessibility tree,
            // so a heading further down is not there for the rotor to reach.
            VStack(alignment: .leading, spacing: 20) {
                header

                // Antes que nada: si algo tapa la página, eso es lo primero
                // que el usuario tiene que resolver.
                if let overlay = page.overlay {
                    OverlayView(
                        overlay: overlay, onChoose: onOverlayChoice,
                        onOpenLink: onOpenURL, onOpenOriginal: onOpenOriginal
                    )
                }

                intentPanel
                arrivalsSection
                savingsNote

                // The order of the page is the answer to what the page is for,
                // not a fixed sequence of sections. A newspaper opens with the
                // news; a search engine opens with the box. Putting eleven
                // actions — dollar quotes among them — above the headlines is
                // what made the reader read as more confusing than the site.
                if contentFirst {
                    // A search box is the page's first tool wherever it is;
                    // a newsletter signup waits behind the content.
                    formsSection(searchOnly: true)
                    listingsSection
                    blocksSection
                    asideListingsSection
                    formsSection(searchOnly: false)
                } else {
                    // A rebuilt form IS the task on a check-in, booking or
                    // search page, so nothing goes above it.
                    formsSection(searchOnly: nil)

                    if let leadCluster {
                        ActionGroupsView(
                            groups: [leadCluster], title: nil, expandedByDefault: true,
                            onOpen: onOpenAction
                        )
                    } else if let leadGroup {
                        if let shown = withoutNextSteps([leadGroup]).first {
                            ActionGroupsView(
                                groups: [shown], title: nil, expandedByDefault: true,
                                onOpen: onOpenAction
                            )
                        }
                    } else if !intentGroups.isEmpty {
                        // Jev found no dominant goal. Then the categories are
                        // the honest answer and they stay where they were.
                        ActionGroupsView(
                            groups: withoutNextSteps(intentGroups),
                            title: fewActions ? nil : "¿Qué querés hacer?",
                            expandedByDefault: fewActions,
                            onOpen: onOpenAction
                        )
                    }

                    listingsSection
                    blocksSection
                    asideListingsSection
                }

                nextStepSection

                if !menuGroups.isEmpty {
                    SiteMenuView(groups: menuGroups, onOpen: onOpenAction)
                        .id(Self.menuDestination)
                        .accessibilityRotorEntry(id: Self.menuDestination, in: rotorNamespace)
                }

                collapsedSection
                footer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // System rotors, not custom ones: VoiceOver users already know these,
        // they are localized by the OS, and they sit where people expect them.
        // This is the interaction React Native cannot offer at all.
        .accessibilityRotor(.headings) {
            ForEach(headings) { heading in
                AccessibilityRotorEntry(Text(heading.label), id: heading.destination, in: rotorNamespace)
            }
            // This rotor REPLACES the system one, so a heading missing here is
            // a heading VoiceOver cannot reach by rotor at all.
            if !menuGroups.isEmpty {
                AccessibilityRotorEntry(
                    Text("Más de este sitio"), id: Self.menuDestination, in: rotorNamespace
                )
            }
        }
        .accessibilityRotor(.links) {
            ForEach(linkTargets) { target in
                AccessibilityRotorEntry(Text(target.label), id: target.destination, in: rotorNamespace)
            }
        }
        .accessibilityRotor(.images) {
            ForEach(imageTargets) { target in
                AccessibilityRotorEntry(Text(target.label), id: target.destination, in: rotorNamespace)
            }
        }
        // An inline link carries a real URL, so tapping it would hand the user
        // to Safari — out of the reader and back into the page we just spent
        // the whole app rebuilding. Every link stays inside.
        .environment(\.openURL, OpenURLAction { url in
            onOpenURL(url.absoluteString)
            return .handled
        })
    }

    @ViewBuilder
    private var nextStepSection: some View {
        if !nextSteps.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(nextSteps) { action in
                    Button {
                        onOpenAction(action)
                    } label: {
                        Text(action.label)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("El paso siguiente de esta pantalla. Activa este control en la página.")
                }
            }
        }
    }

    /// The page's forms. `searchOnly` true: just the search boxes; false:
    /// everything but; nil: all of them.
    @ViewBuilder
    private func formsSection(searchOnly: Bool?) -> some View {
        ForEach(page.actions.filter { form in
            guard form.kind == .form, let fields = form.fields, !fields.isEmpty else { return false }
            guard let searchOnly else { return true }
            return fields.contains { $0.isSearch } == searchOnly
        }) { form in
            FormView(
                action: form,
                suggestions: suggestions,
                resolvedValues: resolvedValues,
                onFill: onFillField,
                onChooseSuggestion: onChooseSuggestion,
                onOpenField: onOpenField,
                onSubmit: { onSubmitForm(form) }
            )
        }
    }

    /// A listing worth opening on a content-first page is one that IS
    /// content: the page named it, or Jev saw news, products, services or
    /// results in it. A footer's seventeen links, opened, are seventeen
    /// stops of nothing before the page.
    private func isContent(_ listing: Listing) -> Bool {
        // Having a name is not enough: "Entidades que confían en Braille
        // Perú" names a logo wall.
        if !listing.isNavigable { return false }
        if !listing.title.isEmpty || isPriced(listing) { return true }
        if listingNames[listing.id] == "Resultados" { return true }
        guard let kind = listingNames[listing.id] else { return false }
        return ["Noticias", "Productos", "Trámites y servicios", "Resultados"].contains(kind)
    }

    /// Lists that lead somewhere, and lists that only say things. The
    /// second kind waits behind the content, collapsed.
    private var contentListings: [Listing] { page.listings.filter(\.isNavigable) }
    private var asideListings: [Listing] { page.listings.filter { !$0.isNavigable } }

    @ViewBuilder
    private var listingsSection: some View {
        listingRows(contentListings)
    }

    @ViewBuilder
    private var asideListingsSection: some View {
        listingRows(asideListings)
    }

    @ViewBuilder
    private func listingRows(_ listings: [Listing]) -> some View {
        ForEach(listings) { listing in
            ListingView(
                listing: listing,
                fallbackName: listingNames[listing.id],
                startsExpanded: contentFirst && isContent(listing),
                onOpenURL: onOpenURL,
                onActivate: { id in
                    if let action = page.actions.first(where: { $0.id == id }) { onOpenAction(action) }
                }
            )
        }
    }

    @ViewBuilder
    private var blocksSection: some View {
        ForEach(visibleBlocks) { block in
            BlockView(block: block)
                .id(block.id)
                .accessibilityRotorEntry(id: block.id, in: rotorNamespace)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(page.displayTitle)
                .font(.largeTitle.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            // El sitio no se repite acá: ya está en la barra de direcciones,
            // visible y sin gastar una parada de VoiceOver.
            if !page.byline.isEmpty {
                Text(page.byline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
    }

    private var collapsedNote: String {
        collapsed.count == 1
            ? "1 elemento agrupado al final"
            : "\(collapsed.count) elementos agrupados al final"
    }

    /// What the grouping actually saved, stated plainly.
    ///
    /// Shown because a screen-reader user cannot see that the page shrank, and
    /// because keeping the number visible keeps us honest when it stops being
    /// impressive.
    @ViewBuilder
    private var savingsNote: some View {
        let stops = page.stats.originalStops
        let now = (intentGroups.isEmpty ? page.groups.count : intentGroups.count)
            + page.listings.count + visibleBlocks.count
        if stops > 0, now < stops {
            Text("Esta página tenía \(stops) elementos para recorrer. Quedaron \(now).")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    /// The ask.
    ///
    /// This is the product's core move: when Jev's probabilities come back
    /// spread across several intents, we do not pick one — we offer them. For a
    /// screen-reader user this turns a linear hunt through two hundred elements
    /// into a choice between four. Nothing else in a reader does this.
    @ViewBuilder
    private var intentPanel: some View {
        switch intentState {
        case .unavailable, .undecided:
            EmptyView()

        case .detecting:
            HStack(spacing: 10) {
                ProgressView().controlSize(.small)
                Text("Analizando la página…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.updatesFrequently)

        case .asking(let options):
            VStack(alignment: .leading, spacing: 12) {
                Text("¿Qué querés hacer acá?")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Text("Esta página permite varias cosas. Elegí una y la ordeno para eso.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(options) { intent in
                    Button {
                        onChoose(intent)
                    } label: {
                        HStack {
                            Text(intent.label)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHint("Reordena la página para esta tarea")
                }

                Button("Mostrar la página tal cual", action: onShowEverything)
                    .font(.footnote)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .applied(let intent):
            if !collapsed.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.sparkles")
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ordenado para: \(intent.label)")
                            .font(.footnote.weight(.medium))
                        Text(collapsedNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    // One stop for the note, one for the button. As three
                    // stops this read "Ordenado para…", "Ver todo", "1
                    // elementos agrupados al final" — the button before the
                    // sentence it undoes.
                    .accessibilityElement(children: .combine)
                    Spacer()
                    Button("Ver todo", action: onShowEverything)
                        .font(.footnote)
                        .accessibilityHint("Muestra la página sin agrupar")
                }
                .padding(12)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityElement(children: .contain)
            }
        }
    }

    /// Demoted content.
    ///
    /// Collapsed, never removed. If Jev is wrong — and on an uncalibrated
    /// threshold it sometimes will be — what it demoted is still one tap away,
    /// and still in the accessibility tree.
    @ViewBuilder
    private var collapsedSection: some View {
        if !collapsedBlocks.isEmpty {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(collapsedBlocks) { block in
                        BlockView(block: block)
                            .id(block.id)
                            .accessibilityRotorEntry(id: block.id, in: rotorNamespace)
                    }
                }
                .padding(.top, 12)
            } label: {
                Text("Otros contenidos (\(collapsedBlocks.count))")
                    .font(.subheadline.weight(.medium))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHint("Contenido que no parecía relevante para la tarea elegida")
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if page.stats.truncated || page.stats.unsupported > 0 {
            VStack(alignment: .leading, spacing: 4) {
                Divider()
                if page.stats.truncated {
                    Text("This page was long and was cut short.")
                }
                if page.stats.unsupported > 0 {
                    Text("\(page.stats.unsupported) element(s) could not be simplified yet.")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 12)
        }
    }
}

// MARK: - Blocks

struct BlockView: View {
    let block: Block

    @Environment(\.openURL) private var openURL

    var body: some View {
        switch block {
        case .heading(_, let level, let text):
            Text(text)
                .font(headingFont(level))
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .paragraph(_, let text, let links):
            Text(Self.attributed(text, links: links))
                .font(.body)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityActions { linkActions(text, links) }

        case .quote(_, let text, let links):
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(.tint)
                    .frame(width: 3)
                Text(Self.attributed(text, links: links))
                    .accessibilityActions { linkActions(text, links) }
                    .font(.body.italic())
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quote: \(text)")

        case .list(_, let ordered, let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        // The number is part of what an ordered item says; a
                        // bullet is not.
                        Text(ordered ? "\(index + 1)." : "•")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(!ordered)
                        Text(Self.attributed(item.text, links: item.links))
                            .font(.body)
                    }
                    // One stop that says the item. An earlier version labelled
                    // the container "Item 1 of 7" and nothing else — a list of
                    // seven things read as seven positions.
                    .accessibilityElement(children: .combine)
                    .accessibilityActions { linkActions(item.text, item.links) }
                }
            }

        case .image(_, let src, let alt, let needsAlt, let caption):
            VStack(alignment: .leading, spacing: 6) {
                AsyncImage(url: URL(string: src)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(height: 160)
                        .overlay(ProgressView())
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                if let caption, !caption.isEmpty {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(imageLabel(alt: alt, caption: caption, needsAlt: needsAlt))
            .accessibilityAddTraits(.isImage)

        case .code(_, let text):
            ScrollView(.horizontal, showsIndicators: true) {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .padding(12)
            }
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Code block")
            .accessibilityValue(text)

        case .separator:
            Divider().accessibilityHidden(true)

        case .table(_, let caption, let headers, let rows, let keyValue):
            TableBlockView(caption: caption, headers: headers, rows: rows, keyValue: keyValue)

        case .unsupported(_, let kind, let text):
            VStack(alignment: .leading, spacing: 4) {
                Label("\(kind.capitalized) — not simplified yet", systemImage: "questionmark.square.dashed")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                if !text.isEmpty {
                    Text(text).font(.callout)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .combine)
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: return .title.weight(.bold)
        case 2: return .title2.weight(.semibold)
        case 3: return .title3.weight(.semibold)
        default: return .headline
        }
    }

    private func imageLabel(alt: String, caption: String?, needsAlt: Bool) -> String {
        if !alt.isEmpty { return alt }
        if let caption, !caption.isEmpty { return caption }
        // v2 fills this in with on-device vision. Saying so is better than a
        // silent unlabeled image, which VoiceOver reads as just "image".
        return needsAlt ? "Imagen sin descripción" : "Imagen"
    }

    /// Builds text with real, focusable inline links.
    ///
    /// `Link.range(in:)` clamps offsets, so malformed ranges from a hostile
    /// page are dropped rather than trusted.
    /// Every link in a block, as a VoiceOver custom action.
    ///
    /// A paragraph is one stop and stays one stop — that is the point of
    /// grouping. But a stop with links inside must still let the user follow
    /// them, and the way VoiceOver users do that on native apps is the
    /// actions rotor: swipe up or down on the element, hear "Abrir: X",
    /// double-tap. Safari instead makes every link its own stop, which is
    /// exactly the 224-element traversal this app exists to shrink.
    ///
    /// Verified in the accessibility tree: without this, a Wikipedia
    /// paragraph with a dozen links exposed zero of them — one static text,
    /// no children, no actions.
    @ViewBuilder
    private func linkActions(_ text: String, _ links: [Link]) -> some View {
        // Reversed because the system lists actions last-added first; the
        // user should hear them in the order they appear in the text.
        ForEach(Array(links.reversed().enumerated()), id: \.offset) { _, link in
            if let range = link.range(in: text),
               let swiftRange = Range(range, in: text),
               let url = URL(string: link.href),
               let scheme = url.scheme?.lowercased(),
               scheme == "https" || scheme == "http",
               // A footnote mark — "[9]" — is a link, but "Abrir: [9]" five
               // times over is noise, not navigation.
               !Self.isFootnote(text[swiftRange]) {
                Button("Abrir: \(text[swiftRange])") { openURL(url) }
            }
        }
    }

    static func isFootnote(_ label: Substring) -> Bool {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("[") && trimmed.hasSuffix("]") &&
               trimmed.dropFirst().dropLast().allSatisfy { $0.isNumber || $0 == "," || $0 == " " }
    }

    static func attributed(_ text: String, links: [Link]) -> AttributedString {
        guard !links.isEmpty else { return AttributedString(text) }

        let mutable = NSMutableAttributedString(string: text)
        for link in links {
            guard
                let range = link.range(in: text),
                let url = URL(string: link.href),
                let scheme = url.scheme?.lowercased(),
                scheme == "https" || scheme == "http"
            else { continue }
            mutable.addAttribute(.link, value: url, range: range)
        }
        return AttributedString(mutable)
    }
}
