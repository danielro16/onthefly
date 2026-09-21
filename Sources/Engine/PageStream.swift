import Foundation

/// Una parada del recorrido que `extract.js` hace de la página, de arriba
/// abajo y en el orden en que la página se muestra.
///
/// Los inventarios —`blocks`, `actions`, `listings`— dicen qué hay; esto dice
/// dónde está cada cosa respecto de las demás. Sin eso el login de un diario
/// sólo se podía apilar: todo el texto, después todos los botones, después el
/// formulario, y "ó ingresá con tu email" sonaba antes que los botones de los
/// que es alternativa.
struct StreamEntry: Codable, Sendable, Identifiable {
    let id: String
    /// "block", "action", "link" o "listing". Texto y no enum: un extractor
    /// más nuevo puede mandar un tipo que esta versión no conoce, y una
    /// parada desconocida no puede costar la página entera.
    let kind: String
    /// El landmark donde está: header, nav, main, footer…
    let zone: String
    /// No dice nada: un emoji suelto, una imagen con nombre de archivo, un
    /// botón que el sitio nunca nombró. No se descarta: va aparte.
    let noise: Bool?
    /// Para "action" y "listing": el id de lo que ocupa este lugar.
    let ref: String?
    let block: Block?
    /// Para "link": un destino que la página ofrece fuera de su navegación.
    let label: String?
    let href: String?
    /// Un titular: un link que además es encabezado.
    let level: Int?
    /// Con qué se lista una opción: las que comparten grupo son una lista;
    /// las que sólo se tocan, vecinas. Lo dice el DOM —el contenedor que
    /// repite su forma—, no una cuenta nuestra.
    let group: String?
    /// Los botones que una tarjeta lleva adentro: acciones suyas, por id.
    let extras: [String]?
}

/// Cuántas paradas son muchas. En un solo lugar, para calibrarlo con uso real.
///
/// No hay una cifra oficial. Hay dos cosas que sí se saben: una lista hablada
/// no se puede releer de un vistazo —los menús telefónicos se diseñan con
/// cuatro o cinco opciones, y siete es el techo de lo que se retiene—, y cada
/// parada cuesta unos dos o tres segundos entre el gesto y la escucha. Ocho
/// paradas son veinte segundos; veinticinco, un minuto; las 359 de la portada
/// de un diario, un cuarto de hora.
enum StopBudget {
    /// Opciones seguidas que se escuchan enteras. Más que esto va detrás de
    /// una puerta con nombre, a un toque.
    static let openList = 7

    /// Lo que entra en una pantalla: alrededor de un minuto de escucha. Una
    /// pantalla que lo pasa y tiene secciones propias las ofrece como cajas,
    /// en vez de obligar a recorrer una para llegar a la siguiente.
    static let screen = 25

    /// Titulares que hacen de una página una portada.
    static let feed = 20

    /// Andamio, no regla de diseño: hasta que el recorrido cubra artículos y
    /// páginas de tarea grandes, de ésas sólo lo usan las de hasta tantas
    /// paradas. Las reglas de adentro no miran este número.
    static let inOrderPageLimit = 30
}

/// Una opción de una lista: algo que se toca.
struct StreamOption: Identifiable, Sendable {
    let action: Action
    /// Un titular es una opción y además un encabezado, para el rotor.
    let headingLevel: Int?
    /// Lo que además se puede hacer con ella: "Guardar", en una receta. Una
    /// parada con sus acciones, no una parada por botón.
    var extras: [Action] = []

    var id: String { action.id }
}

/// Una puerta: una parada que dice qué hay detrás y cuánto, y abre una
/// pantalla con eso. Nunca se despliega en el lugar: desplegar obliga a
/// recorrer una sección entera para llegar a la siguiente.
struct StreamDoor: Identifiable, Sendable, Hashable {
    enum Kind: String, Sendable {
        /// La portada: todo lo que la página publica, por sección.
        case feed
        /// Una sección de la página, con el nombre que la página le puso.
        case section
        /// Opciones seguidas que eran demasiadas para escucharlas de corrido.
        case list
        /// Lo que el último toque hizo aparecer.
        case arrivals
        case footer
        case noise
    }

    let id: String
    let kind: Kind
    let title: String
    /// Cuánto hay detrás, dicho y escrito: "8 titulares".
    let amount: String
    /// Lo primero que hay detrás, para quien ve. VoiceOver no lo dice: la
    /// parada tiene que seguir siendo corta.
    let preview: String
    let hint: String
    /// Las paradas que guarda. Ver `ExtractedPage.segments(only:title:)`.
    let entries: [String]
}

/// Un tramo de la página, listo para dibujar. El orden es el de la página.
enum StreamSegment: Identifiable, Sendable {
    case block(Block)
    case form(Action)
    /// Sólo el listado cuyas tarjetas se eligen de varias formas —un plan de
    /// cuotas con un botón por tarjeta—. Los demás son opciones, como todo.
    case listing(Listing)
    /// Opciones seguidas, abiertas: una lista simple.
    case options(id: String, [StreamOption])
    case door(StreamDoor)

    var id: String {
        switch self {
        case .block(let block): return block.id
        case .form(let action): return action.id
        case .listing(let listing): return listing.id
        case .options(let id, _): return id
        case .door(let door): return door.id
        }
    }
}

extension ExtractedPage {
    private static let chrome: Set<String> = ["header", "banner", "nav", "navigation", "search", "footer", "contentinfo"]

    /// Si esta página se muestra en su propio orden.
    ///
    /// Una portada sí, tenga el tamaño que tenga. Un artículo todavía no: su
    /// texto sale del recorte de Readability, que no tiene lugar en el
    /// recorrido.
    var readsInOrder: Bool {
        guard let stream, !stream.isEmpty else { return false }
        if isFeed { return true }
        guard blocks.reduce(0, { $0 + $1.plainText.count }) < 1200 else { return false }
        return stats.originalStops > 0 && stats.originalStops <= StopBudget.inOrderPageLimit
    }

    /// Una portada: la página es, sobre todo, titulares. Lo dice el DOM —
    /// links que además son encabezado, tarjetas repetidas— y no un modelo.
    var isFeed: Bool { feedEntries.count >= 2 && headlineCount(in: feedEntries) >= StopBudget.feed }

    /// Las paradas de la portada: desde el primer titular hasta el último,
    /// sin el encabezado, el menú ni el pie del sitio.
    private var feedEntries: [StreamEntry] {
        guard let stream else { return [] }
        func isHeadline(_ entry: StreamEntry) -> Bool {
            guard !Self.chrome.contains(entry.zone), entry.noise != true else { return false }
            return entry.kind == "listing" || (entry.kind == "link" && entry.level != nil)
        }
        guard
            let first = stream.firstIndex(where: isHeadline),
            let last = stream.lastIndex(where: isHeadline)
        else { return [] }
        return stream[first...last].filter { !Self.chrome.contains($0.zone) && $0.noise != true }
    }

    private func headlineCount(in entries: [StreamEntry]) -> Int {
        let sizes = Dictionary(listings.map { ($0.id, $0.items.count) }, uniquingKeysWith: { first, _ in first })
        return entries.reduce(0) { total, entry in
            switch entry.kind {
            case "link": return total + (entry.level != nil ? 1 : 0)
            case "listing": return total + (entry.ref.flatMap { sizes[$0] } ?? 0)
            default: return total
            }
        }
    }

    /// Un link a la página en la que ya se está: "Inicio", en la portada. No
    /// lleva a ningún lado — recargar es volver al mismo lugar —, así que abre
    /// lo que esta página es.
    func isSelfLink(_ action: Action) -> Bool {
        guard action.kind == .link, let href = action.href else { return false }
        func bare(_ address: String) -> String {
            var text = address.components(separatedBy: "#")[0].lowercased()
            while text.hasSuffix("/") { text.removeLast() }
            return text
        }
        return bare(href) == bare(url)
    }

    /// El recorrido, en tramos.
    ///
    /// Nada se reordena. Lo único que pasa acá es lo que la vista le da gratis
    /// a quien ve: opciones vecinas se leen como una lista, una lista larga se
    /// reconoce sin leerla entera, el pie se saltea, y lo que no dice nada no
    /// se mira.
    ///
    /// Con `ids` arma la pantalla que abre una puerta: sólo esas paradas. Si
    /// entran en una pantalla van todas, abiertas; si no, y la página las
    /// trae en secciones, cada sección es una caja.
    ///
    /// `arrivals` son los controles que el último toque hizo aparecer: van
    /// primero y con el nombre de lo que se tocó.
    func segments(
        only ids: Set<String>? = nil,
        title screenTitle: String = "",
        arrivals: Set<String> = [],
        cause: String = ""
    ) -> [StreamSegment] {
        guard let stream else { return [] }
        let nested = ids != nil
        let actionsByID = Dictionary(actions.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let listingsByID = Dictionary(listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        func isForm(_ entry: StreamEntry) -> Bool {
            entry.kind == "action" && entry.ref.flatMap { actionsByID[$0] }?.kind == .form
        }

        var flow = stream.filter { ids?.contains($0.id) ?? true }

        if nested {
            if let boxes = sectionDoors(of: flow, listingsByID: listingsByID) { return boxes }
        }

        var leading: [StreamSegment] = []
        var trailing: [StreamSegment] = []
        var feedDoor: StreamDoor?
        var feedIDs: Set<String> = []

        if !nested {
            // Lo que el toque abrió, primero: es la respuesta al toque.
            let arrived = flow.filter { entry in
                entry.kind == "action" && entry.noise != true && entry.ref.map(arrivals.contains) == true && !isForm(entry)
            }
            if !arrived.isEmpty {
                let taken = Set(arrived.map(\.id))
                flow.removeAll { taken.contains($0.id) }
                let name = cause.isEmpty ? "Apareció en la página" : cause
                if arrived.count > StopBudget.openList {
                    leading.append(.door(StreamDoor(
                        id: Self.arrivalsID, kind: .arrivals, title: name,
                        amount: Self.amount(arrived.count, "opción", "opciones"),
                        preview: arrived.prefix(3).compactMap { $0.ref.flatMap { actionsByID[$0] }?.label }.joined(separator: ", "),
                        hint: "Lo que apareció al tocar. Abre sus opciones en otra pantalla",
                        entries: arrived.map(\.id)
                    )))
                } else {
                    leading.append(.block(.heading(
                        id: "jef-arrivals-title", level: 2,
                        text: cause.isEmpty ? name : "Apareció al tocar \(cause)"
                    )))
                    leading.append(.options(id: Self.arrivalsID, arrived.compactMap { entry in
                        entry.ref.flatMap { actionsByID[$0] }.map { StreamOption(action: $0, headingLevel: nil) }
                    }))
                }
            }

            // El pie: legales, redes, el mapa del sitio. Corto, se lee donde
            // está; largo, es una parada y no quince. Un formulario o un
            // listado que viva ahí se queda en la página.
            let foot = flow.filter { entry in
                ["footer", "contentinfo"].contains(entry.zone)
                    && entry.noise != true && entry.kind != "listing" && !isForm(entry)
            }
            if foot.count > StopBudget.openList {
                let taken = Set(foot.map(\.id))
                flow.removeAll { taken.contains($0.id) }
                trailing.append(.door(StreamDoor(
                    id: "jef-footer", kind: .footer, title: "Resto del sitio",
                    amount: Self.amount(foot.count, "elemento", "elementos"), preview: "",
                    hint: "Abre el pie del sitio en otra pantalla",
                    entries: foot.map(\.id)
                )))
            }

            let noise = flow.filter { $0.noise == true }
            if !noise.isEmpty {
                flow.removeAll { $0.noise == true }
                trailing.append(.door(StreamDoor(
                    id: "jef-noise", kind: .noise, title: "Símbolos y elementos sin nombre",
                    amount: Self.amount(noise.count, "elemento", "elementos"), preview: "",
                    hint: "Botones, imágenes y símbolos que la página no describe",
                    entries: noise.map(\.id)
                )))
            }

            // La portada: ciento treinta titulares no son una pantalla. Una
            // puerta, donde la portada empieza; detrás, las secciones que el
            // diario ya tenía, cada una en su caja.
            if isFeed {
                let inFlow = Set(flow.map(\.id))
                let feed = feedEntries.filter { inFlow.contains($0.id) }
                feedIDs = Set(feed.map(\.id))
                let first = feed.first { $0.kind == "link" && $0.level != nil }?.label
                    ?? feed.first { $0.kind == "listing" }?.ref.flatMap { listingsByID[$0] }?.items.first?.title
                    ?? ""
                feedDoor = StreamDoor(
                    id: "jef-feed", kind: .feed, title: "Portada",
                    amount: Self.amount(headlineCount(in: feed), "titular", "titulares"),
                    preview: first,
                    hint: "Abre la portada, por sección",
                    entries: feed.map(\.id)
                )
            }
        }

        var segments: [StreamSegment] = []
        var run: [(option: StreamOption, entry: String)] = []
        var runGroup: String?

        func closeRun() {
            guard let first = run.first else { return }
            defer { run = [] }
            let options = run.map(\.option)
            guard !nested, options.count > StopBudget.openList else {
                segments.append(.options(id: "run-\(first.option.id)", options))
                return
            }
            // El nombre de la puerta es el que la página le puso —el
            // encabezado que tenía justo arriba— y, si no le puso ninguno,
            // lo que hay adentro. Nunca una categoría nuestra.
            let names = options.prefix(3).map(\.action.label).joined(separator: ", ")
            var title = "\(names) y \(options.count - 3) más"
            if case .block(.heading(_, _, let text))? = segments.last {
                title = text
                segments.removeLast()
            }
            var seen = Set<String>()
            segments.append(.door(StreamDoor(
                id: "fold-\(first.option.id)", kind: .list, title: title,
                amount: Self.amount(options.count, "opción", "opciones"),
                preview: title.hasPrefix(names) ? "" : names,
                hint: "Abre sus opciones en otra pantalla",
                entries: run.map(\.entry).filter { seen.insert($0).inserted }
            )))
        }

        let pageTitle = Self.plain(sectionTitle)
        let ownTitle = Self.plain(screenTitle)

        for entry in flow {
            if feedIDs.contains(entry.id) {
                if let door = feedDoor {
                    closeRun()
                    segments.append(.door(door))
                    feedDoor = nil
                }
                continue
            }

            var option: StreamOption?
            var group = entry.group

            switch entry.kind {
            case "action":
                guard let action = entry.ref.flatMap({ actionsByID[$0] }) else { continue }
                if action.kind == .form {
                    closeRun()
                    segments.append(.form(action))
                    continue
                }
                option = StreamOption(action: action, headingLevel: nil)
            case "link":
                guard let label = entry.label, let href = entry.href else { continue }
                option = StreamOption(
                    action: .link(id: entry.id, label: label, href: href, region: entry.zone),
                    headingLevel: entry.level,
                    extras: (entry.extras ?? []).compactMap { actionsByID[$0] }
                )
            case "listing":
                guard let listing = entry.ref.flatMap({ listingsByID[$0] }) else { continue }
                guard listing.items.allSatisfy({ ($0.choices ?? []).isEmpty }) else {
                    closeRun()
                    segments.append(.listing(listing))
                    continue
                }
                // Un listado es una lista de opciones con nombre: corta, va
                // abierta; larga, es una caja. No un desplegable.
                closeRun()
                if !listing.title.isEmpty, Self.plain(listing.title) != ownTitle {
                    segments.append(.block(.heading(id: "\(listing.id)-title", level: 2, text: listing.title)))
                }
                for (index, item) in listing.items.enumerated() {
                    let id = "\(listing.id)-\(index)"
                    if let href = item.href {
                        run.append((StreamOption(
                            action: .link(id: id, label: item.spokenLabel, href: href, region: entry.zone),
                            headingLevel: nil,
                            extras: (item.extras ?? []).compactMap { actionsByID[$0.id] }
                        ), entry.id))
                    } else if let action = item.actionId.flatMap({ actionsByID[$0] }) {
                        run.append((StreamOption(action: action, headingLevel: nil), entry.id))
                    } else {
                        closeRun()
                        segments.append(.block(.paragraph(id: id, text: item.spokenLabel, links: [])))
                    }
                }
                closeRun()
                continue
            case "block":
                guard let block = entry.block else { continue }
                // El título ya se dijo —en "dónde estoy", o en el nombre de
                // esta pantalla—. Repetido es una parada que no informa.
                if case .heading(_, let level, let text) = block {
                    if level == 1, Self.plain(text) == pageTitle { continue }
                    if nested, Self.plain(text) == ownTitle { continue }
                }
                closeRun()
                segments.append(.block(block))
            default:
                continue
            }

            if let option {
                // Dos opciones que se tocan sin compartir grupo no son una
                // lista: la tarjeta de abajo de ocho áreas no es la novena.
                // Adentro de una pantalla sí: la pantalla entera es la lista.
                if nested { group = "screen" }
                if group == nil || group != runGroup { closeRun() }
                runGroup = group
                run.append((option, entry.id))
            }
        }
        closeRun()

        return leading + segments + trailing
    }

    /// Las secciones de un tramo, como cajas — o nil si el tramo entra en una
    /// pantalla o la página no lo trae en secciones.
    ///
    /// Los nombres son los de la página: sus encabezados ("Análisis",
    /// "Actualidad"), los títulos cortos que además llevan a la sección
    /// ("Deportes", "El Mundo") y los de sus listados. Lo que viene antes del
    /// primero es lo que el diario puso arriba de todo.
    private func sectionDoors(of flow: [StreamEntry], listingsByID: [String: Listing]) -> [StreamSegment]? {
        struct Part {
            var title: String
            var titleEntry: String?
            var ids: [String] = []
            var count = 0
            var preview = ""
        }

        func isSectionLink(_ entry: StreamEntry) -> Bool {
            guard entry.kind == "link", entry.level != nil, let label = entry.label else { return false }
            return label.count <= 32 && !label.contains(",") && !label.contains(".")
                && label.split(separator: " ").count <= 4
        }

        var stops = 0
        var parts: [Part] = []
        var current = Part(title: "")

        func close() {
            guard !current.ids.isEmpty || current.titleEntry != nil else { return }
            // Una sección sin nada que abrir —un encabezado sobre una foto—
            // no es una caja: se queda con la anterior, entera.
            if current.count == 0, var previous = parts.popLast() {
                previous.ids += [current.titleEntry].compactMap { $0 } + current.ids
                parts.append(previous)
            } else {
                parts.append(current)
            }
        }

        for entry in flow {
            switch entry.kind {
            case "block":
                guard let block = entry.block else { continue }
                if case .heading(_, _, let text) = block {
                    close()
                    current = Part(title: text, titleEntry: entry.id)
                    continue
                }
                if case .separator = block { continue }
                current.ids.append(entry.id)
                stops += 1
            case "listing":
                guard let listing = entry.ref.flatMap({ listingsByID[$0] }) else { continue }
                // Un título de listado largo es un titular que quedó arriba
                // del contenedor, no el nombre de una sección.
                let name = listing.title
                if !name.isEmpty, name.count <= 40, Self.plain(name) != Self.plain(current.title) {
                    close()
                    current = Part(title: name)
                }
                current.ids.append(entry.id)
                current.count += listing.items.count
                stops += listing.items.count
                if current.preview.isEmpty { current.preview = listing.items.first?.title ?? "" }
            default:
                if isSectionLink(entry) {
                    close()
                    // El link del título queda adentro, primero: lleva a la
                    // sección entera.
                    current = Part(title: entry.label ?? "", ids: [entry.id])
                    stops += 1
                    continue
                }
                current.ids.append(entry.id)
                current.count += 1
                stops += 1
                if current.preview.isEmpty, entry.kind == "link" { current.preview = entry.label ?? "" }
            }
        }
        close()

        guard stops > StopBudget.screen, parts.count >= 2 else { return nil }

        return parts.map { part in
            let title = part.title.isEmpty ? "Lo principal" : part.title
            return .door(StreamDoor(
                id: "sec-\(part.ids.first ?? title)", kind: .section, title: title,
                amount: Self.amount(part.count, "titular", "titulares"),
                preview: part.preview,
                hint: "Abre sus titulares en otra pantalla",
                entries: part.ids
            ))
        }
    }

    /// Cuántas paradas es de verdad este recorrido, contadas como las cuenta
    /// VoiceOver: una por fila, no una por tramo.
    ///
    /// Existe porque el número que la app venía diciendo estaba mal. Sumaba
    /// grupos más listados más bloques —cosas que no son paradas— y en
    /// Wikipedia anunciaba "quedaron 20" cuando el recorrido real eran 52.
    /// Decirle a alguien que no puede contar por sí mismo un número inventado
    /// es peor que no decirle nada.
    func stopCount(of segments: [StreamSegment]) -> Int {
        segments.reduce(0) { total, segment in
            switch segment {
            case .block, .door:
                return total + 1
            case .form(let action):
                // El título, un campo por fila, y el botón de enviar.
                return total + 2 + (action.fields ?? []).count
            case .options(_, let options):
                return total + options.count
            case .listing(let listing):
                let open = listing.items.count <= StopBudget.openList
                return total + 1 + (open ? listing.items.count : 0)
            }
        }
    }

    /// El id de lo que el último toque hizo aparecer, para llevar ahí el
    /// cursor de VoiceOver.
    static let arrivalsID = "jef.arrivals"

    private static func amount(_ count: Int, _ one: String, _ many: String) -> String {
        "\(count) \(count == 1 ? one : many)"
    }

    private static func plain(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Action {
    /// Un destino que la página ofrece fuera de su navegación. No tiene
    /// control detrás: se abre por su dirección.
    static func link(id: String, label: String, href: String, region: String) -> Action {
        Action(
            id: id, kind: .link, label: label, href: href, fields: nil, submit: nil,
            notices: nil, region: region, unnamed: nil, cluster: nil, primary: nil, fresh: nil
        )
    }
}
