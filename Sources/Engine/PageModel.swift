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
    let stats: Stats

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
    }
}

/// A cluster of related actions.
///
/// The point of the whole project in one type. On a real airline home page
/// this turns 199 VoiceOver stops into 6 — and, because every group carries a
/// title, it hands the headings rotor the destinations the page never
/// declared. That page ships exactly one heading of its own.
struct ActionGroup: Codable, Sendable, Identifiable {
    let id: String
    let region: String
    let kind: String
    /// Labels Jev can pick a title from. It cannot generate text, so the title
    /// has to already exist inside the group.
    let candidates: [String]
    let actionIds: [String]
    let size: Int

    /// Title used until Jev picks one — and whenever Jev is unavailable.
    ///
    /// Deliberately generic: a wrong specific title is worse than a vague
    /// accurate one, because a screen-reader user navigates by these.
    var fallbackTitle: String {
        switch (region, kind) {
        case ("footer", _), ("contentinfo", _): return "Pie de página"
        case ("header", _), ("banner", _):      return "Encabezado del sitio"
        case ("nav", "link"), ("navigation", "link"): return "Enlaces de navegación"
        case ("nav", _), ("navigation", _):     return "Menú"
        case ("main", "form"), ("main", _):      return "Contenido principal"
        case (_, "form"):                        return "Formulario"
        default:                                 return "Otras acciones"
        }
    }

    /// What VoiceOver announces for the collapsed group.
    func accessibilityLabel(title: String) -> String {
        "\(title), \(size) \(size == 1 ? "elemento" : "elementos")"
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

    struct Item: Codable, Sendable, Identifiable, Hashable {
        let title: String
        let href: String?
        let price: String?
        let image: String?
        let imageAlt: String?
        /// Whatever else the card said, minus title and price.
        let meta: String?

        var id: String { (href ?? "") + title }

        /// One sentence for VoiceOver, in the order that matters: what it is,
        /// what it costs, then the rest. A price read last is a price missed.
        var spokenLabel: String {
            var parts = [title]
            if let price { parts.append(price) }
            if let meta, !meta.isEmpty { parts.append(meta) }
            return parts.joined(separator: ", ")
        }
    }

    /// What the group announces. Falls back to the count rather than to a
    /// generic word: four boxes reading "Listado" are four identical stops.
    var label: String {
        title.isEmpty ? "Listado de \(count) elementos" : title
    }

    var subtitle: String { "\(count) elementos" }
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
    let region: String

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

        struct Option: Codable, Sendable, Hashable {
            let value: String
            let label: String
        }

        /// Passwords get a secure field and are never kept in app state.
        /// Nothing here is stored, logged, or sent anywhere but the page the
        /// user is already on.
        var isSecure: Bool { type == "password" }

        /// Maps the HTML type to the right keyboard, so a date field does not
        /// open a QWERTY.
        var contentHint: String { type }
    }

    /// Compact description for Jev's state. Keeping this short matters: every
    /// action competes for the same 32k context as the page text.
    var summary: String {
        var parts = ["\(kind.rawValue) in \(region): \(label)"]
        if let fields, !fields.isEmpty {
            parts.append("fields: " + fields.map(\.name).joined(separator: ", "))
        }
        if let submit, !submit.isEmpty {
            parts.append("submit: \(submit)")
        }
        return parts.joined(separator: " — ")
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
    case unsupported(id: String, kind: String, text: String)

    var id: String {
        switch self {
        case .heading(let id, _, _), .paragraph(let id, _, _),
             .list(let id, _, _), .image(let id, _, _, _, _),
             .quote(let id, _, _), .code(let id, _),
             .separator(let id), .unsupported(let id, _, _):
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
        case .separator:
            return ""
        }
    }

    /// Every inline link the block carries, in reading order.
    var links: [Link] {
        switch self {
        case .paragraph(_, _, let links), .quote(_, _, let links):
            return links
        case .list(_, _, let items):
            return items.flatMap(\.links)
        default:
            return []
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, level, text, links, ordered, items
        case src, alt, needsAlt, caption, kind
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
/// This is what lets VoiceOver focus each link inside a paragraph
/// individually, which is the whole reason this app is native.
struct Link: Codable, Sendable, Hashable {
    let start: Int
    let end: Int
    let href: String

    /// Converts to an `NSRange`, clamped to the given text so malformed
    /// offsets from a hostile page cannot crash the renderer.
    func range(in text: String) -> NSRange? {
        let total = text.utf16.count
        let lower = max(0, min(start, total))
        let upper = max(lower, min(end, total))
        guard upper > lower else { return nil }
        return NSRange(location: lower, length: upper - lower)
    }
}

struct ListItem: Codable, Sendable {
    let text: String
    let links: [Link]
}
