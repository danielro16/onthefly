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
    /// The VoiceOver cursor, so a change can put it where it belongs.
    var focused: AccessibilityFocusState<String?>.Binding
    /// Se llegó tocando una opción. Ver `ReaderModel.inFlow`.
    var inFlow = false
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
        groups.reduce(0) { $0 + $1.count } <= 3
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

    /// The groups the view actually renders: what Jev decided, or — when it
    /// decided nothing — every action as one plain list.
    ///
    /// A model's silence must not delete the page's controls. Without this
    /// a page whose intent request failed, or was still in flight, rendered
    /// its text and not one of its buttons: unreachable, which is worse
    /// than ungrouped. Measured on a fixture whose six buttons vanished
    /// until a second reading arrived.
    private var groups: [IntentGroup] {
        if !intentGroups.isEmpty { return intentGroups }
        let inListings = Set(page.listings.flatMap { $0.items.flatMap(\.pressableIds) })
        let rest = page.actions.filter { $0.kind != .form && !inListings.contains($0.id) }
        guard !rest.isEmpty else { return [] }
        return [IntentGroup(
            intent: .info, actions: rest, uncertain: [], title: "Opciones de la página"
        )]
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
        return groups.first { $0.intent == dominant }
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
            return groups.compactMap { group in
                let rest = group.actions.filter { !taken.contains($0.id) }
                return rest.isEmpty ? nil : IntentGroup(intent: group.intent, actions: rest, uncertain: group.uncertain)
            }
        }
        guard let leadGroup, !contentFirst else { return contentFirst ? groups : [] }
        return groups.filter { $0.id != leadGroup.id }
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
        Array(groups.flatMap(\.actions)
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
            .accessibilityFocused(focused, equals: ReaderModel.arrivalsAnchor)
        }
    }

    /// Everything else the site offers. One stop at the end.
    private var menuGroups: [IntentGroup] {
        // En una página simple no hay cajón: todo se mostró arriba, abierto.
        if isSimple { return [] }
        // En una portada las categorías están arriba, todas: lo único que
        // baja al cajón es el bucket de sobras.
        return isIndex
            ? withoutSections(withoutNextSteps(groups)).filter { $0.intent.isCatchAll }
            : withoutNextSteps(demoted)
    }

    /// Una página que ya era simple.
    ///
    /// El login de La Nación tiene dieciséis paradas. No hay nada que
    /// ahorrar, y todo lo que la app hace para ahorrar —categorías, cajas,
    /// un menú al final— ahí sólo agrega: los tres botones de "ingresar con"
    /// terminaron a tres toques de profundidad, dentro de "Más de este
    /// sitio", dentro de "Mi cuenta". Una página que se recorre en dieciséis
    /// pasos se muestra entera, en orden, sin cajas.
    ///
    /// Es lo que UX.md llama "cuándo no intervenir", medido sobre el DOM y
    /// no sobre lo que Jev opine.
    private var isSimple: Bool {
        // Una portada de sección sigue siendo una portada, y una nota sigue
        // siendo una nota: haber llegado tocando no las convierte en tareas.
        guard !isIndex, !isArticle else { return false }
        return inFlow || (page.stats.originalStops > 0 && page.stats.originalStops <= 30)
    }

    /// Una portada: listas de enlaces y poca prosa.
    ///
    /// No es un texto para leer, es un índice para elegir — y ésa es la
    /// diferencia que la app no hacía. Un diario y una nota de Wikipedia
    /// caían los dos en "leer contenido", así que la portada se volcaba
    /// entera sobre la página. Una tienda y una página de resultados también
    /// son listas, pero ahí el volcado es correcto: la persona ya eligió, y
    /// los resultados son la respuesta.
    private var isIndex: Bool {
        leadsWithContent && !isArticle && !isCatalog && !hasResults
            && page.listings.contains { $0.isNavigable && $0.items.count >= 4 }
    }

    /// Las secciones del sitio: los enlaces de su navegación.
    ///
    /// En un diario esto es "Política, Economía, Deportes" — la respuesta a
    /// "quiero ver esto ordenado". Hoy vivían repartidos entre las categorías
    /// de Jev y el cajón del final, junto al login y los legales.
    private var sectionActions: [Action] {
        var seen = Set<String>()
        return page.actions.filter { action in
            guard action.kind == .link, action.region == "nav" || action.region == "navigation"
            else { return false }
            let key = action.label.lowercased()
            guard !key.isEmpty, !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }
    }

    private func withoutSections(_ groups: [IntentGroup]) -> [IntentGroup] {
        let taken = Set(sectionActions.map(\.id))
        return groups.compactMap { group in
            let rest = group.actions.filter { !taken.contains($0.id) }
            return rest.isEmpty ? nil : IntentGroup(
                intent: group.intent, actions: rest, uncertain: group.uncertain, title: group.title
            )
        }
    }

    /// Las categorías de una portada: sin las secciones (que van en su propia
    /// caja) y sin el bucket de sobras (que va al cajón del final).
    private var indexGroups: [IntentGroup] {
        withoutSections(withoutNextSteps(groups)).filter { !$0.intent.isCatchAll }
    }

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

                // The order of the page is the answer to what the page is for,
                // not a fixed sequence of sections. A newspaper opens with the
                // news; a search engine opens with the box. Putting eleven
                // actions — dollar quotes among them — above the headlines is
                // what made the reader read as more confusing than the site.
                if isSimple {
                    // La intención ya está clara: acá no se pregunta nada ni
                    // se categoriza nada. Lo que dice la página, lo que
                    // ofrece —como lista, en su orden— y lo que pide. El
                    // ruido en una sola caja al final.
                    blocksSection
                    plainOptions
                    formsSection(searchOnly: nil)
                    listingsSection
                    asideListingsSection
                    otherOptions
                } else if isIndex {
                    // Una portada ofrece; no vuelca. El usuario decide si se
                    // entera de lo que el sitio recomienda o va por su
                    // sección, y las dos cosas están a una parada.
                    indexOptions
                    formsSection(searchOnly: nil)
                    // La prosa suelta de una portada son los legales y las
                    // fichas técnicas. No se pierde: va detrás de todo.
                    blocksSection
                    asideListingsSection
                } else if contentFirst {
                    // A search box is the page's first tool wherever it is;
                    // a newsletter signup waits behind the content.
                    formsSection(searchOnly: true)
                    // En un artículo el texto va primero y las listas
                    // —notas, "leé también"— detrás. En una portada las
                    // listas son las noticias, y el orden se invierte.
                    if isArticle {
                        blocksSection
                        listingsSection
                    } else {
                        listingsSection
                        blocksSection
                    }
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
                    } else if !groups.isEmpty, !isDetecting {
                        // Jev found no dominant goal. Then the categories are
                        // the honest answer and they stay where they were.
                        //
                        // `!isDetecting` es la diferencia entre ofrecer y
                        // adivinar. Los grupos llegan antes que la decisión, y
                        // dibujarlos ahí ponía "¿Qué querés hacer?" con cuatro
                        // cajas sobre un diario para borrarlas un segundo
                        // después: para quien mira, parpadea; para quien
                        // escucha, el cursor se cae de lo que estaba leyendo.
                        ActionGroupsView(
                            groups: withoutNextSteps(groups),
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

                // En una portada ya se mostró arriba, con las demás opciones.
                if !menuGroups.isEmpty, !isIndex {
                    SiteMenuView(groups: menuGroups, onOpen: onOpenAction)
                        .id(Self.menuDestination)
                        .accessibilityRotorEntry(id: Self.menuDestination, in: rotorNamespace)
                }

                collapsedSection
                // Lo que la app tiene para decir sobre sí misma va al final,
                // detrás de todo lo que la página tenía para decir.
                savingsNote
                footer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // El fondo agrupado de iOS: las tarjetas se despegan de él sin
        // necesidad de bordes ni sombras.
        .background(Color(.systemBackground))
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

    /// Las opciones de una página cuya intención ya está clara, como lista.
    ///
    /// "Ingresar con correo. Ingresar con Google. Ingresar con Facebook."
    /// Sin categorías encima y en el orden en que la página las puso: cuando
    /// ya entraste a hacer una cosa, nombrar la categoría de lo que estás
    /// haciendo es decirte lo que ya sabés, y ordenarlo distinto de como
    /// estaba es hacerte buscar.
    private var taskActions: [Action] {
        let aside = Set(asideActions.map(\.id))
        let promoted = Set(nextSteps.map(\.id))
        let inListings = Set(page.listings.flatMap { $0.items.flatMap(\.pressableIds) })
        return page.actions.filter { action in
            guard action.kind != .form || (action.fields ?? []).isEmpty else { return false }
            return !aside.contains(action.id)
                && !promoted.contains(action.id)
                && !inListings.contains(action.id)
        }
    }

    /// Lo que no es a lo que viniste: recuperar la contraseña, el pie, las
    /// redes. No se descarta —nada se descarta— pero va detrás de una puerta
    /// con su nombre.
    private var asideActions: [Action] {
        let leftovers = groups.filter { $0.intent.isCatchAll }.flatMap(\.actions)
        let noise = page.actions.filter { action in
            action.unnamed == true
                || action.label.trimmingCharacters(in: .whitespaces)
                    .range(of: Self.plumbing, options: [.regularExpression, .caseInsensitive]) != nil
        }
        var seen = Set<String>()
        return (leftovers + noise).filter { seen.insert($0.id).inserted }
    }

    /// Controles que existen para moverse por la página, no para hacer algo
    /// en ella. No se pierden: van a "Otras opciones".
    private static let plumbing =
        "^(volver|atr[aá]s|back|cerrar|close|men[uú]|abrir el men[uú]|bot[oó]n sin nombre)$"

    @ViewBuilder
    private var plainOptions: some View {
        if !taskActions.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(taskActions.enumerated()), id: \.element.id) { index, action in
                    if index > 0 { Divider() }
                    ActionRow(action: action, onOpen: onOpenAction)
                }
            }
            .jefCard()
        }
    }

    @ViewBuilder
    private var otherOptions: some View {
        let others = asideActions
        if !others.isEmpty {
            NavigationLink(value: Route.options("Otras opciones", others)) {
                optionLabel(
                    symbol: "ellipsis", color: .gray, title: "Otras opciones",
                    subtitle: "\(others.count) \(others.count == 1 ? "opción" : "opciones")"
                )
            }
            .buttonStyle(.plain)
            .jefCard()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Otras opciones, \(others.count) \(others.count == 1 ? "opción" : "opciones")")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityHint("Abre el resto de esta página en otra pantalla")
        }
    }

    /// El tramo 3 de una portada: qué querés hacer, con las palabras del
    /// sitio y con el conteo de lo que hay detrás de cada puerta.
    @ViewBuilder
    private var indexOptions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Qué querés hacer?")
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 4)

            headlinesCard
            sectionsCard

            if !indexGroups.isEmpty {
                ActionGroupsView(groups: indexGroups, title: nil, onOpen: onOpenAction)
            }

            // El resto del sitio es una opción más, la última. Apartada al
            // final de la página quedaba detrás de los legales: para llegar
            // al menú había que escuchar el ISSN y el domicilio legal.
            if !menuGroups.isEmpty {
                SiteMenuView(groups: menuGroups, onOpen: onOpenAction)
                    .id(Self.menuDestination)
                    .accessibilityRotorEntry(id: Self.menuDestination, in: rotorNamespace)
            }
        }
    }

    @ViewBuilder
    private var headlinesCard: some View {
        let total = HeadlinesScreen.total(of: page)
        if total > 0 {
            let preview = HeadlinesScreen.preview(of: page)
            NavigationLink(value: Route.headlines) {
                optionLabel(
                    symbol: "newspaper", color: .blue, title: "Leer los titulares",
                    // El conteo es la diferencia entre una puerta con cartel y
                    // una puerta cerrada: sin él, quien no ve no sabe si detrás
                    // hay tres cosas o doscientas.
                    subtitle: preview.isEmpty
                        ? "\(total) \(total == 1 ? "noticia" : "noticias")"
                        : "\(total) noticias · \(preview)"
                )
            }
            .buttonStyle(.plain)
            .jefCard()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Leer los titulares, \(total) \(total == 1 ? "noticia" : "noticias")")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityHint("Abre todas las noticias de la portada, en orden")
        }
    }

    @ViewBuilder
    private var sectionsCard: some View {
        let sections = sectionActions
        if sections.count >= 3 {
            let names = sections.prefix(4).map(\.label).joined(separator: ", ")
            NavigationLink(value: Route.options("Secciones", sections)) {
                optionLabel(
                    symbol: "square.grid.2x2", color: .green, title: "Ir a una sección",
                    subtitle: "\(sections.count) secciones · \(names)"
                )
            }
            .buttonStyle(.plain)
            .jefCard()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ir a una sección, \(sections.count) secciones")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityHint("Abre las secciones del sitio en otra pantalla")
        }
    }

    private func optionLabel(
        symbol: String, color: Color, title: String, subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            IconBadge(symbol: symbol, color: color)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
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
                voiceOverFocus: focused,
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
                // Abierta o cerrada se decide con lo que dice el DOM, no con
                // lo que va a decir Jev: atado a `contentFirst`, la misma
                // lista arrancaba cerrada y se abría sola al llegar la
                // respuesta. Una lista abierta dentro de un artículo sí tapa
                // el artículo — las 297 notas al pie de Wikipedia antes de la
                // primera línea del texto — y eso el DOM ya lo sabe.
                startsExpanded: isContent(listing) && !isArticle,
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

    /// Tramo 1 — dónde estoy. Siempre, dos paradas.
    ///
    /// El sitio primero y la página después, sin el separador ni los sufijos:
    /// `Inicio | Braille Perú` se dice "Braille Perú. Inicio.". Y una línea de
    /// qué es esto. Es el ancla: si entraste mal, esto es lo único que te lo
    /// dice, y por eso nada va antes — ni siquiera lo que la app tenga para
    /// contar sobre sí misma.
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(page.displaySite)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(page.sectionTitle)
                    .font(.largeTitle.weight(.bold))
            }
            // Las dos líneas son una parada: "Braille Perú. Inicio.". Leerlas
            // por separado son dos paradas para decir un solo lugar.
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(page.displaySite). \(page.sectionTitle).")
            .accessibilityAddTraits(.isHeader)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 2)
    }

    /// Qué es esto: la descripción del sitio, o de quién es la nota.
    ///
    /// Una firma que repite el nombre del sitio no es una firma:
    /// "Colaboradores de los proyectos Wikimedia" no le dice a nadie qué es
    /// esta página, y ocupa la única línea que sí podía decirlo.
    private var subtitle: String {
        let summary = page.summary
        if !summary.isEmpty { return summary }

        let byline = page.byline.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !byline.isEmpty else { return "" }
        let flat = byline.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        let echoesSite = page.siteName
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .split(separator: " ")
            .contains { $0.count > 3 && flat.contains($0) }
        return echoesSite ? "" : byline
    }

    /// Prosa de verdad: un artículo, no una portada.
    ///
    /// Decide el orden. Wikipedia tiene 297 notas al pie agrupadas en una
    /// lista, y una lista antes del texto es 297 elementos antes de la
    /// primera línea de la nota. Una portada no tiene este problema porque
    /// sus listas SON el contenido.
    private var isArticle: Bool {
        visibleBlocks.reduce(0) { $0 + $1.plainText.count } >= 1200
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
        let stops = isSimple ? 0 : page.stats.originalStops
        let now = (groups.isEmpty ? page.groups.count : groups.count)
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
            // En una página simple no se agrupó nada, así que no hay nada
            // que explicar ni que deshacer: "Ordenado para Mi cuenta. Ver
            // todo." sobre un login era una parada que no quería decir nada.
            if !collapsed.isEmpty, !isSimple {
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
