import Foundation
import UIKit

/// El asistente: la persona dice a dónde quiere ir y JEF la lleva.
///
/// La web se carga tal como es. No se reordena, no se agrupa, no se dibuja de
/// nuevo: lo único que se agrega es esta conversación. Recorrer una página con
/// VoiceOver cuesta decenas de gestos aunque esté bien armada; decir "quiero
/// ver deportes" cuesta una frase.
///
/// **Ni una palabra de lo que el asistente dice la escribe un modelo.** Todo
/// sale del texto literal de la página o de un número que contó este código.
/// Jev elige entre opciones enumeradas —lo único que hace de forma confiable,
/// medido: 500 ms y acierta— y nunca redacta. Así lo peor que puede pasar es
/// que el asistente cite algo que no servía; nunca que invente algo que no
/// estaba.
///
/// Y cuando duda, pregunta. Medido sobre aerolineas.com.ar con un objetivo
/// vago: Jev pone el destino correcto primero (0,63) pero no sabe si
/// corresponde actuar (0,47 contra 0,53). Navegando sola, esa duda es un
/// fracaso silencioso; conversando, es un turno más.
@MainActor
@Observable
final class Assistant {

    struct Turn: Identifiable, Sendable {
        enum Who: Sendable { case person, jef }
        let id: String
        let who: Who
        let text: String
    }

    /// Lo que el asistente propuso cuando no estuvo seguro, esperando un sí.
    struct Offer: Sendable {
        let goal: String
        let options: [Action]
    }

    private(set) var turns: [Turn] = []
    private(set) var working = false
    private(set) var offer: Offer?
    /// Lo último que dijo, para anunciarlo y para que la pantalla lo muestre
    /// aunque VoiceOver se haya comido el anuncio.
    private(set) var latest = ""

    private let analyzer: PageAnalyzer?
    private var counter = 0

    /// Cuántos pasos puede dar sin que la persona vuelva a hablar.
    ///
    /// Corto a propósito. Un asistente que encadena diez pasos en silencio es
    /// exactamente lo que alguien que no ve no puede seguir.
    private static let maxSteps = 4

    /// Por debajo de esto no toca: ofrece y espera. Es el umbral que separa
    /// "sé a dónde ir" de "me parece" — ver la nota de arriba.
    private static let sureEnough = 0.7

    init(analyzer: PageAnalyzer?) {
        self.analyzer = analyzer
    }

    var isAvailable: Bool { analyzer != nil }

    private func say(_ text: String) {
        counter += 1
        turns.append(Turn(id: "t\(counter)", who: .jef, text: text))
        latest = text
        // Dicho en voz alta. Es la única manera de que alguien que no ve se
        // entere de lo que el asistente hizo mientras lo hace.
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    private func heard(_ text: String) {
        counter += 1
        turns.append(Turn(id: "t\(counter)", who: .person, text: text))
    }

    func clear() {
        turns = []
        offer = nil
        latest = ""
    }

    /// Lo que la persona pidió.
    func ask(_ goal: String, on reader: ReaderModel) async {
        let goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty, !working else { return }
        heard(goal)
        offer = nil
        await run(goal, on: reader, steps: Self.maxSteps)
    }

    /// La persona aceptó lo que el asistente propuso.
    func accept(_ action: Action, on reader: ReaderModel) async {
        guard let pending = offer, !working else { return }
        offer = nil
        heard(action.label)
        working = true
        say("Toco \(action.label).")
        await reader.activate(action)
        working = false
        await run(pending.goal, on: reader, steps: 1)
    }

    private func run(_ goal: String, on reader: ReaderModel, steps: Int) async {
        guard let analyzer else {
            say("El asistente no está configurado en esta versión.")
            return
        }
        working = true
        defer { working = false }

        for _ in 0..<max(steps, 1) {
            guard let page = reader.page else {
                say("Todavía no hay una página cargada.")
                return
            }
            let options = Self.options(of: page)
            guard !options.isEmpty else {
                say("Esta página no ofrece nada que pueda tocar.")
                return
            }

            let decision: PageAnalyzer.Step
            do {
                decision = try await analyzer.nextStep(goal: goal, page: page, options: options)
            } catch {
                // Sin red no hay asistente, y eso se dice — no se disimula
                // con un "no encontré nada".
                say("No pude consultar. Revisá la conexión y probá de nuevo.")
                return
            }

            switch decision.move {
            case .done:
                describe(page)
                return

            case .ask, .go where decision.confidence < Self.sureEnough:
                let candidates = decision.ranked.prefix(2).compactMap { index in
                    options.indices.contains(index) ? options[index] : nil
                }
                guard let first = candidates.first else {
                    say("No encontré por dónde seguir para eso.")
                    return
                }
                offer = Offer(goal: goal, options: Array(candidates))
                if candidates.count > 1 {
                    say("No estoy seguro. ¿Querés que vaya a \(first.label)? También veo \(candidates[1].label).")
                } else {
                    say("No estoy seguro. ¿Querés que vaya a \(first.label)?")
                }
                return

            case .go:
                guard
                    let index = decision.ranked.first,
                    options.indices.contains(index)
                else {
                    say("No encontré por dónde seguir para eso.")
                    return
                }
                let chosen = options[index]
                say("Toco \(chosen.label).")
                await reader.activate(chosen)
            }
        }

        if let page = reader.page { describe(page) }
    }

    /// Dónde quedó la persona y qué hay, sin generar una palabra.
    private func describe(_ page: ExtractedPage) {
        say("Llegué. Estás en \(page.sectionTitle).")

        let headlines = Self.headlines(of: page)
        guard !headlines.isEmpty else {
            let controls = page.actions.filter { $0.kind != .form }.count
            if controls > 0 {
                say("Esta página tiene \(controls) \(controls == 1 ? "opción" : "opciones"). Pedime lo que buscás, o seguí vos.")
            } else {
                say("Seguí vos cuando quieras.")
            }
            return
        }

        say("Hay \(headlines.count) \(headlines.count == 1 ? "nota" : "notas"). \(headlines.count == 1 ? "Dice" : "Las tres primeras"):")
        for title in headlines.prefix(3) {
            say(String(title.prefix(120)))
        }
        say("¿Te leo alguna, seguís vos, o buscamos otra cosa?")
    }

    // MARK: - La tabla

    /// Todo lo que la página deja tocar o abrir, esté o no en la pantalla.
    ///
    /// Es la ventaja que JEF tiene y que un agente genérico no: su inventario
    /// mira la página entera. Medido contra el de browser-use en
    /// aerolineas.com.ar: el suyo ve 35 controles, los de arriba de todo, y
    /// "MI RESERVA" no está entre ellos; el nuestro ve 57 y sí lo tiene.
    static func options(of page: ExtractedPage) -> [Action] {
        var out: [Action] = []
        var seen = Set<String>()

        func add(_ action: Action) {
            let key = action.href ?? action.id
            guard seen.insert(key).inserted, !action.label.isEmpty else { return }
            out.append(action)
        }

        for action in page.actions where action.kind != .form && action.unnamed != true {
            add(action)
        }
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            switch entry.kind {
            case "link":
                guard let label = entry.label, let href = entry.href else { continue }
                add(.link(id: entry.id, label: label, href: href, region: entry.zone))
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for (index, item) in listing.items.enumerated() {
                    guard let href = item.href else { continue }
                    add(.link(id: "\(listing.id)-\(index)", label: item.title, href: href, region: entry.zone))
                }
            default:
                continue
            }
        }
        // Jev admite 255 opciones por pregunta. Medido, no documentado.
        return Array(out.prefix(240))
    }

    /// Los titulares de esta página: un link que además es encabezado, o un
    /// ítem de listado con nombre largo que abre otra página. La misma regla
    /// que decide si algo es una portada.
    static func headlines(of page: ExtractedPage) -> [String] {
        var out: [String] = []
        var seen = Set<String>()
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            if entry.kind == "link", entry.level != nil, entry.href != nil, let label = entry.label {
                if seen.insert(label).inserted { out.append(label) }
            }
            if entry.kind == "listing", let listing = entry.ref.flatMap({ byID[$0] }) {
                for item in listing.items where item.href != nil && item.title.count >= 25 {
                    if seen.insert(item.title).inserted { out.append(item.title) }
                }
            }
        }
        return out
    }
}
