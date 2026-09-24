import Foundation

/// The typed page that `extract.js` produces.
///
/// Mirrors the JSON contract exactly. If you change a field here, change it in
/// `Sources/Extraction/extract.js` too — that file is also the Android core.
struct ExtractedPage: Codable, Sendable {
    let ok: Bool
    let url: String
    let title: String
    let byline: String
    let siteName: String
    let excerpt: String
    let lang: String
    let blocks: [Block]
    /// What the page lets you DO. Empty on a plain article; on a task site
    /// (airline, bank, government) this is the page.
    let actions: [Action]
    /// Actions clustered into navigable groups. One VoiceOver stop each,
    /// instead of one per action.
    let groups: [ActionGroup]
    /// Repeated structures: product grids, article feeds, result lists.
    let listings: [Listing]
    /// La página en su orden: lo que dice, lo que deja hacer y lo que lista,
    /// cada cosa donde la página la muestra. Ver `PageStream.swift`.
    ///
    /// Opcional porque un extractor anterior no lo manda.
    let stream: [StreamEntry]?
    /// Something blocking the page: cookie banner, paywall, login wall.
    let overlay: Overlay?
    let stats: Stats

    /// Whether a re-extraction produced the same page.
    ///
    /// Pressing a control that turns out to change nothing is common: a tab
    /// that was already selected, a menu that reopens the same items. Better
    /// to say it did nothing than to report the same page as a new one.
    func isEquivalent(to other: ExtractedPage?) -> Bool {
        guard let other else { return false }
        return title == other.title
            && url == other.url
            && blocks.count == other.blocks.count
            && listings.count == other.listings.count
            && actions.map(\.shape) == other.actions.map(\.shape)
            && streamShape == other.streamShape
            && overlay?.text == other.overlay?.text
    }

    /// Si otra lectura de la misma página trae lo mismo: los mismos bloques,
    /// listas, recorrido y aviso, y los mismos controles. Los controles por
    /// su marca, que sobrevive a otra lectura, y no por su nombre: el que
    /// JEF le pone a uno que no tenía no es otra página. Un carrito que carga
    /// sus productos después de la página, sí: en Demoblaze se contaba
    /// "no veo ningún producto" con los productos ahí.
    func sameContent(as other: ExtractedPage) -> Bool {
        title == other.title
            && blocks.count == other.blocks.count
            && listings.count == other.listings.count
            && actions.map(\.id) == other.actions.map(\.id)
            && streamShape == other.streamShape
            && overlay?.text == other.overlay?.text
    }

    /// La FORMA del recorrido, para distinguir dos lecturas.
    ///
    /// Sin mirarlo, un toque que abrió un panel sin traer controles nuevos —o
    /// que expandió una sección— se leía como "la página no cambió", y la app
    /// se lo decía a la persona en voz alta.
    ///
    /// La forma, y no el texto: un reloj, un ticker o un aviso que rota
    /// cambian el texto solos, y si eso contara como página nueva la página
    /// cambiaría sin que nadie tocara nada. Un bloque cuenta por estar, no por
    /// lo que diga; un link, por su dirección, que es lo que hace que sea otro
    /// link.
    private var streamShape: [String] {
        (stream ?? []).map { entry in
            entry.kind + "|" + (entry.ref ?? entry.href ?? "")
        }
    }

    /// Every field on the page, in order.
    var fields: [Action.Field] { actions.flatMap { $0.fields ?? [] } }

    /// El nombre del sitio, o el dominio cuando la página no lo declara.
    ///
    /// Un `og:site_name` que no se parece en nada al dominio es el nombre de
    /// la organización, no el del sitio: "Wikimedia Foundation, Inc." sobre
    /// es.wikipedia.org. El dominio es lo que la persona tipeó y lo que
    /// reconoce, así que gana.
    var displaySite: String {
        // Con sus letras: "tiempomañana.net", no "xn--tiempomaana-8db.net".
        let host = (URL(string: url)?.host()).map(Assistant.unicode).map {
            $0.hasPrefix("www.") ? String($0.dropFirst(4)) : $0
        } ?? ""
        let siteName = Assistant.unicode(self.siteName)
        guard !siteName.isEmpty else { return host }
        guard !host.isEmpty else { return siteName }

        func letters(_ text: String) -> String {
            text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                .filter(\.isLetter)
        }
        let name = letters(siteName)
        let domain = letters(host)
        guard !name.isEmpty else { return host }
        return domain.contains(name) || name.contains(domain) ? siteName : host
    }

    /// El nombre de ESTA página, sin el del sitio.
    ///
    /// Un `<title>` está escrito para una pestaña: "Inicio | Braille Perú",
    /// "Buenos Aires - Wikipedia, la enciclopedia libre". El sitio se dice
    /// antes y aparte, así que repetirlo acá es una parada que no informa.
    /// Cuando no queda nada, la página es la portada.
    var sectionTitle: String {
        let raw = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "Inicio" }

        // Un guión sólo separa cuando tiene aire a los costados: "Check-in"
        // es una palabra.
        let normalized = raw
            .replacingOccurrences(of: " - ", with: "|")
            .replacingOccurrences(of: " : ", with: "|")
        let parts = normalized
            .components(separatedBy: CharacterSet(charactersIn: "|–—·»"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard parts.count > 1 else { return parts.first ?? "Inicio" }

        let site = displaySite.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        let kept = parts.filter { part in
            let candidate = part.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            guard !site.isEmpty else { return true }
            return !candidate.contains(site) && !site.contains(candidate)
        }
        // Sin nombre de sitio que descartar, el título de la página es lo
        // primero: el sitio se firma al final en casi toda la web.
        return kept.first ?? "Inicio"
    }

    struct Stats: Codable, Sendable {
        let blockCount: Int
        let actionCount: Int
        let groupCount: Int
        let listingCount: Int
        /// What a screen reader would have stopped on without this app.
        /// Measured on the live DOM, so the saving we claim stays honest.
        let originalStops: Int
        /// Headings the page itself declared. On aerolineas.com.ar: one.
        let originalHeadings: Int
        let charCount: Int
        let truncated: Bool
        let imagesWithoutAlt: Int
        let unsupported: Int
        /// Controles que el tope dejó afuera. Se dicen: un número con el que
        /// la persona puede hacer algo vale más que un silencio.
        let droppedActions: Int?
    }
}

extension ExtractedPage {
    /// La misma página, con nombre para los controles que no lo tenían: los
    /// que JEF nombró (id → nombre). La próxima lectura los trae de la página
    /// misma, donde quedaron escritos; esto es para no esperarla.
    func naming(_ labels: [String: String]) -> ExtractedPage {
        ExtractedPage(ok: ok, url: url, title: title, byline: byline, siteName: siteName, excerpt: excerpt, lang: lang,
                      blocks: blocks, actions: actions.map { $0.named(labels[$0.id]) }, groups: groups,
                      listings: listings, stream: stream, overlay: overlay, stats: stats)
    }
}

extension Action {
    /// Este control con el nombre que le puso JEF, si no tenía.
    func named(_ label: String?) -> Action {
        guard let label, unnamed == true else { return self }
        return Action(id: id, kind: kind, label: label, href: href, fields: fields, submit: submit, notices: notices,
                      region: region, unnamed: nil, hints: hints, cluster: cluster, primary: primary, fresh: fresh)
    }
}

/// A cluster of related actions, as the extractor groups them.
struct ActionGroup: Codable, Sendable, Identifiable {
    let id: String
    let region: String
    let kind: String
    /// Labels Jev can pick a title from. It cannot generate text, so the title
    /// has to already exist inside the group.
    let candidates: [String]
    let actionIds: [String]
    let size: Int
}

/// Something covering the page that has to be dealt with first.
///
/// A sighted visitor sees the page dimmed behind a box and knows the box comes
/// first. With a screen reader the overlay's controls arrive mixed into the
/// page's, with no cue that nothing else will work until it is resolved.
///
/// The app never resolves one on the user's behalf. Accepting terms or picking
/// cookie preferences is their decision; this only makes it reachable, names
/// what it is, and carries the original text so they can judge for themselves.
struct Overlay: Codable, Sendable {
    let kind: Kind
    let text: String
    /// The check offers an audio alternative. It lives inside the widget's
    /// own iframe, so the app cannot press it — but saying it exists is
    /// the difference between a wall and a door.
    let audioChallenge: Bool?
    let choices: [Choice]
    /// Links out of the overlay — the privacy policy, the terms. Kept apart
    /// from `choices` because following one abandons the page instead of
    /// answering anything, and offering it as a third button beside "Aceptar"
    /// misrepresents what it does.
    let links: [Reference]?

    enum Kind: String, Codable, Sendable {
        case cookies, paywall, newsletter, login, age, captcha, other

        var title: String {
            switch self {
            case .cookies:    return "Aviso de cookies"
            case .paywall:    return "Contenido para suscriptores"
            case .newsletter: return "Invitación a suscribirte"
            case .login:      return "Hay que iniciar sesión"
            case .age:        return "Verificación de edad"
            case .captcha:    return "Verificación de seguridad"
            case .other:      return "Aviso de la página"
            }
        }

        var explanation: String {
            switch self {
            case .cookies:
                return "Esta página pide una decisión sobre cookies antes de seguir."
            case .paywall:
                return "El contenido está detrás de una suscripción."
            case .newsletter:
                return "La página ofrece suscribirte a novedades. Podés ignorarlo."
            case .login:
                return "Hace falta una cuenta para ver esto."
            case .age:
                return "La página pide confirmar tu edad."
            case .captcha:
                return "La página pide comprobar que sos una persona. Eso no se puede resolver desde esta vista: abrí la página original, completalo ahí y volvé."
            case .other:
                return "La página muestra un aviso encima del contenido."
            }
        }
    }

    struct Choice: Codable, Sendable, Identifiable, Hashable {
        let id: String
        let label: String
    }

    struct Reference: Codable, Sendable, Identifiable, Hashable {
        let label: String
        let href: String

        var id: String { href }
    }
}

/// A repeated structure the page stamps N times.
///
/// Found in every site sampled — ARCA 8 items, Banco Galicia 17, La Nación 13
/// — which makes it the most universal pattern measured, not an e-commerce
/// special case. Detected purely from DOM repetition: no model involved.
///
/// Collapsing one into a single stop is what makes a catalogue usable. Fifty
/// products used to read as fifty unrelated links with their prices lost in
/// the surrounding text.
struct Listing: Codable, Sendable, Identifiable {
    let id: String
    /// Taken from the heading the page puts before the list. Empty when the
    /// page never named it.
    let title: String
    let count: Int
    let items: [Item]

    /// Whether its items lead anywhere. A wall of logos — braille.pe lists
    /// twenty-three institutions that trust it — is prose laid out in a
    /// grid: twenty-three stops that go nowhere, and they were arriving
    /// before the page said what it does. Worth one stop, not twenty-three.
    var isNavigable: Bool {
        items.contains { $0.href != nil || $0.actionId != nil || !($0.choices ?? []).isEmpty }
    }

    struct Item: Codable, Sendable, Identifiable, Hashable {
        let title: String
        /// The button inside the card, when the card has no link of its own.
        let actionId: String?
        /// Several buttons and no single one that is the card: the ways to
        /// pick it, each pressable on its own.
        let choices: [Choice]?
        let href: String?
        let price: String?
        let image: String?
        let imageAlt: String?
        /// Whatever else the card said, minus title and price.
        let meta: String?
        /// The web address the card's link shows, when it shows one: Google
        /// writes "ANSES https://www.anses.gob.ar" inside each result's link,
        /// and the link itself goes through a redirect of its own, so this
        /// is where the result's site is.
        let shown: String?
        /// Buttons the card holds besides the link that opens it — "Guardar"
        /// on every recipe. They are the card's own actions, not stops of
        /// their own: fifteen rows reading "Guardar" say nothing about what
        /// each one saves.
        let extras: [Choice]?

        var id: String { (href ?? "") + title }

        struct Choice: Codable, Sendable, Hashable, Identifiable {
            let id: String
            let label: String
        }

        /// Every action this card already offers, so nothing lists it twice.
        var pressableIds: [String] {
            (actionId.map { [$0] } ?? []) + (choices ?? []).map(\.id) + (extras ?? []).map(\.id)
        }

        /// One sentence for VoiceOver, in the order that matters: what it is,
        /// what it costs, then the rest. A price read last is a price missed.
        var spokenLabel: String {
            var parts = [title]
            if let price { parts.append(price) }
            if let meta, !meta.isEmpty { parts.append(meta) }
            return parts.joined(separator: ", ")
        }
    }
}

/// Something the user can do on the page.
///
/// Readability discards all of these, which is why a reader built only on it
/// shows an empty shell on the sites where a screen-reader user most needs
/// help. `region` carries the landmark it came from — "Search" in a header
/// means something different from "Search" in main content, and that
/// distinction is what lets Jev group actions into tasks.
struct Action: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let kind: Kind
    let label: String
    let href: String?
    let fields: [Field]?
    let submit: String?
    /// What the page wrote back after this form's last submit: texts that
    /// appeared inside it, usually why it did not go through.
    let notices: [String]?
    let region: String
    /// El sitio no le puso nombre y tuvimos que inventarle uno.
    ///
    /// No se descarta —cerrar un modal suele ser uno de éstos— pero no puede
    /// encabezar una lista: "Botón sin nombre" como opción de login es ruido
    /// nuestro encima del ruido del sitio.
    let unnamed: Bool?
    /// Lo que el HTML dice de un control sin nombre —el símbolo que dibuja,
    /// su clase, su id, los nombres de su ícono—: las pistas con que Jev
    /// elige qué tipo de control es. Ver `ReaderModel.nameUnnamed`.
    var hints: String?

    /// What makes this action the same action on a later reading: its
    /// label, and for a form, its fields. Picking "DNI" added three date
    /// fields to the checkout, and the reading that carried them was
    /// dropped as the same page because the label had not changed.
    var shape: String {
        label + (fields ?? []).map { "|\($0.name):\($0.type)" }.joined() + (notices ?? []).joined()
    }
    /// Shared by sibling buttons of the same shape — the 34 cells of a
    /// calendar, the 12 tiles of a grid. One control set, judged once.
    let cluster: String?
    /// Sits in the bar pinned to the bottom of the screen: the page's own
    /// next step, whatever it is called.
    let primary: Bool?
    /// First seen by this extraction: what the last tap made appear.
    let fresh: Bool?

    enum Kind: String, Codable, Sendable {
        case form, button, link
    }

    struct Field: Codable, Sendable, Hashable, Identifiable {
        let id: String
        let name: String
        let type: String
        let required: Bool
        /// Whatever the page already had in the control.
        let value: String
        /// Present for `<select>`: a native picker cannot offer choices it
        /// does not know about.
        let options: [Option]?
        /// What the page holds against the field, when it says so
        /// (aria-invalid plus the message it points at).
        let error: String?

        struct Option: Codable, Sendable, Hashable {
            let value: String
            let label: String
        }

        /// The WHATWG autofill token the page declared, if any.
        var autocomplete: String?
        /// A password, a one-time code or a card, by the HTML standard (see
        /// `isSecret` in extract.js). Its value never comes out of the page.
        var secret: Bool?
        /// A search box, by the HTML standard: `type=search`, a search
        /// keyboard, or inside the search landmark (see extract.js).
        var search: Bool?

        /// Written from the chat like any other field, but never shown,
        /// logged, or sent to a model.
        var isSecure: Bool { type == "password" || secret == true }

        /// Typed as-is: no capital letter the page did not ask for, no
        /// autocorrected city. Decided by the standard, never by the name:
        /// a name is words, in whatever language the site speaks.
        var isSearch: Bool { type == "search" || search == true }
    }

}

/// A failed extraction. Kept separate so callers must handle it explicitly
/// rather than reading an empty `ExtractedPage` as a valid one.
struct ExtractionFailure: Codable, Sendable, Error {
    let ok: Bool
    let reason: String
    let url: String
    let message: String?
}

/// One renderable unit of the page.
///
/// Decoded from a tagged union keyed on `type`. Unknown types decode to
/// `.unsupported` rather than throwing, so one odd node cannot lose the page.
enum Block: Codable, Sendable, Identifiable {
    case heading(id: String, level: Int, text: String)
    case paragraph(id: String, text: String, links: [Link])
    case list(id: String, ordered: Bool, items: [ListItem])
    case image(id: String, src: String, alt: String, needsAlt: Bool, caption: String?)
    case quote(id: String, text: String, links: [Link])
    case code(id: String, text: String)
    case separator(id: String)
    case table(id: String, caption: String, headers: [String], rows: [[String]], keyValue: Bool)
    case unsupported(id: String, kind: String, text: String)

    var id: String {
        switch self {
        case .heading(let id, _, _), .paragraph(let id, _, _),
             .list(let id, _, _), .image(let id, _, _, _, _),
             .quote(let id, _, _), .code(let id, _),
             .separator(let id), .unsupported(let id, _, _),
             .table(let id, _, _, _, _):
            return id
        }
    }

    /// Plain text of the block, for rotor labels and search.
    var plainText: String {
        switch self {
        case .heading(_, _, let text), .paragraph(_, let text, _),
             .quote(_, let text, _), .code(_, let text),
             .unsupported(_, _, let text):
            return text
        case .list(_, _, let items):
            return items.map(\.text).joined(separator: ", ")
        case .image(_, _, let alt, _, let caption):
            return caption ?? alt
        case .table(_, let caption, let headers, let rows, let keyValue):
            // Con sus datos: es lo que lee el asistente. "Tabla de 12 filas"
            // era un anuncio de la vista reconstruida, y el asistente no podía
            // contestar nada de un extracto, una tabla de precios o de
            // cotizaciones — llegó a decir "la página indica la existencia de
            // una tabla con 36 filas". Cada celda con el nombre de su columna,
            // que es lo que alguien que ve saca de la grilla.
            let shown = rows.prefix(60).map { row -> String in
                if keyValue, row.count >= 2 { return "\(row[0]): \(row.dropFirst().joined(separator: " "))" }
                return row.enumerated().compactMap { index, cell -> String? in
                    guard !cell.isEmpty else { return nil }
                    return headers.indices.contains(index) && !headers[index].isEmpty
                        ? "\(headers[index]): \(cell)" : cell
                }.joined(separator: "; ")
            }.filter { !$0.isEmpty }
            let more = rows.count > 60 ? "\n(y \(rows.count - 60) filas más)" : ""
            return (caption.isEmpty ? "" : "\(caption)\n") + shown.joined(separator: "\n") + more
        case .separator:
            return ""
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, level, text, links, ordered, items
        case src, alt, needsAlt, caption, kind
        case headers, rows, keyValue
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let id = try c.decode(String.self, forKey: .id)
        let type = try c.decode(String.self, forKey: .type)

        switch type {
        case "heading":
            self = .heading(
                id: id,
                level: try c.decodeIfPresent(Int.self, forKey: .level) ?? 2,
                text: try c.decode(String.self, forKey: .text)
            )
        case "paragraph":
            self = .paragraph(
                id: id,
                text: try c.decode(String.self, forKey: .text),
                links: try c.decodeIfPresent([Link].self, forKey: .links) ?? []
            )
        case "list":
            self = .list(
                id: id,
                ordered: try c.decodeIfPresent(Bool.self, forKey: .ordered) ?? false,
                items: try c.decodeIfPresent([ListItem].self, forKey: .items) ?? []
            )
        case "image":
            self = .image(
                id: id,
                src: try c.decode(String.self, forKey: .src),
                alt: try c.decodeIfPresent(String.self, forKey: .alt) ?? "",
                needsAlt: try c.decodeIfPresent(Bool.self, forKey: .needsAlt) ?? false,
                caption: try c.decodeIfPresent(String.self, forKey: .caption)
            )
        case "quote":
            self = .quote(
                id: id,
                text: try c.decode(String.self, forKey: .text),
                links: try c.decodeIfPresent([Link].self, forKey: .links) ?? []
            )
        case "code":
            self = .code(id: id, text: try c.decode(String.self, forKey: .text))
        case "separator":
            self = .separator(id: id)
        case "table":
            self = .table(
                id: id,
                caption: try c.decodeIfPresent(String.self, forKey: .caption) ?? "",
                headers: try c.decodeIfPresent([String].self, forKey: .headers) ?? [],
                rows: try c.decodeIfPresent([[String]].self, forKey: .rows) ?? [],
                keyValue: try c.decodeIfPresent(Bool.self, forKey: .keyValue) ?? false
            )
        default:
            self = .unsupported(
                id: id,
                kind: try c.decodeIfPresent(String.self, forKey: .kind) ?? type,
                text: try c.decodeIfPresent(String.self, forKey: .text) ?? ""
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        switch self {
        case .heading(_, let level, let text):
            try c.encode("heading", forKey: .type)
            try c.encode(level, forKey: .level)
            try c.encode(text, forKey: .text)
        case .paragraph(_, let text, let links):
            try c.encode("paragraph", forKey: .type)
            try c.encode(text, forKey: .text)
            try c.encode(links, forKey: .links)
        case .list(_, let ordered, let items):
            try c.encode("list", forKey: .type)
            try c.encode(ordered, forKey: .ordered)
            try c.encode(items, forKey: .items)
        case .image(_, let src, let alt, let needsAlt, let caption):
            try c.encode("image", forKey: .type)
            try c.encode(src, forKey: .src)
            try c.encode(alt, forKey: .alt)
            try c.encode(needsAlt, forKey: .needsAlt)
            try c.encodeIfPresent(caption, forKey: .caption)
        case .quote(_, let text, let links):
            try c.encode("quote", forKey: .type)
            try c.encode(text, forKey: .text)
            try c.encode(links, forKey: .links)
        case .code(_, let text):
            try c.encode("code", forKey: .type)
            try c.encode(text, forKey: .text)
        case .separator:
            try c.encode("separator", forKey: .type)
        case .table(_, let caption, let headers, let rows, let keyValue):
            try c.encode("table", forKey: .type)
            try c.encode(caption, forKey: .caption)
            try c.encode(headers, forKey: .headers)
            try c.encode(rows, forKey: .rows)
            try c.encode(keyValue, forKey: .keyValue)
        case .unsupported(_, let kind, let text):
            try c.encode("unsupported", forKey: .type)
            try c.encode(kind, forKey: .kind)
            try c.encode(text, forKey: .text)
        }
    }
}

/// An inline link inside a text block.
///
/// `start` and `end` are UTF-16 code-unit offsets into the block's text —
/// the same units `NSRange` uses, so they convert without re-measuring.
struct Link: Codable, Sendable, Hashable {
    let start: Int
    let end: Int
    let href: String
}

struct ListItem: Codable, Sendable {
    let text: String
    let links: [Link]
}
