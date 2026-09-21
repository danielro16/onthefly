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
    /// Quien redacta. Jev elige, no escribe; para contestar una pregunta
    /// sobre lo que la página dice hace falta alguien que redacte, y toda
    /// afirmación suya termina en una cita que este código verifica.
    private let answerer: Answerer?
    private var counter = 0
    /// Lo que ya se tocó en este turno. Un asistente que abre un buscador, lo
    /// cierra y lo vuelve a abrir no está avanzando: está oscilando, y quien
    /// no ve sólo escucha que pasan cosas.
    private var touched: Set<String> = []

    /// Cuántos pasos puede dar sin que la persona vuelva a hablar.
    ///
    /// Corto a propósito. Un asistente que encadena diez pasos en silencio es
    /// exactamente lo que alguien que no ve no puede seguir.
    private static let maxSteps = 4

    /// Por debajo de esto no toca: ofrece y espera. Es el umbral que separa
    /// "sé a dónde ir" de "me parece" — ver la nota de arriba.
    private static let sureEnough = 0.7

    init(analyzer: PageAnalyzer?, answerer: Answerer? = Answerer.fromEnvironment()) {
        self.analyzer = analyzer
        self.answerer = answerer
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
        touched = []

        // Una dirección es una dirección. Buscarla adentro de la página —que
        // es lo que hacía— termina ofreciendo "¿querés que vaya a Inicio?"
        // cuando lo que se pidió fue google.com.
        if let url = ReaderModel.normalize(goal), goal.contains(".") , !goal.contains(" ") {
            say("Abro \(url.host() ?? goal).")
            working = true
            reader.address = goal
            await reader.go()
            working = false
            if let page = reader.page { describe(page) }
            return
        }

        // Hay pedidos que no son ni un destino ni una pregunta sobre un dato,
        // y mandarlos a decidir afuera es lo que produjo, con la página de
        // Buenos Aires abierta: "Ayudame a navegar en esta página" →
        // "¿Querés que vaya a Geografía?". Nadie pidió ir a Geografía. Se
        // pidió saber dónde se está. Eso lo sabe el código, gratis y sin red.
        if let page = reader.page, let intent = Self.intent(of: goal) {
            switch intent {
            case .orient:
                describe(page)
            case .summarize:
                working = true
                await summarize(page)
                working = false
            }
            return
        }

        await run(goal, on: reader, steps: Self.maxSteps)
    }

    /// Lo que el asistente se contesta solo.
    enum Intent { case orient, summarize }

    /// Sin tildes y sin mayúsculas, porque se escribe con dictado y el
    /// dictado acentúa cuando quiere.
    static func intent(of goal: String) -> Intent? {
        let text = goal
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let summarize = "resum|de que (se )?trata|que dice (esta|la) pagina|contame (esta|la) pagina|de que habla"
        if text.range(of: summarize, options: .regularExpression) != nil { return .summarize }

        // Deliberadamente angosto. "Ayudame a comprar un pasaje" es una
        // tarea y tiene que seguir yendo a Jev; sólo "ayudame a navegar" y
        // sus parientes son un pedido de orientación.
        let orient = "^(ayuda|ayudame|guiame|orientame|ubicame)( en| con| por)?( esta| la)?( pagina| web| pantalla)?$"
            + "|^ayudame a (navegar|moverme|orientarme|ubicarme)"
            + "|donde estoy|en que pagina estoy|que hay (aca|aqui|en esta pagina)"
            + "|que puedo hacer|que es esta pagina|describ(ime|i|ir)( esta| la)? pagina"
        if text.range(of: orient, options: .regularExpression) != nil { return .orient }
        return nil
    }

    /// De qué trata la página.
    ///
    /// No es una pregunta sobre un dato: si la página tiene texto, SIEMPRE
    /// hay respuesta. Decir "eso no lo encontré en esta página" —que es lo
    /// que decía sobre un artículo de diecisiete mil caracteres— es falso y
    /// deja a la persona sin nada.
    ///
    /// Por eso hay piso: si el modelo no está, no contesta, o su cita no se
    /// puede verificar, se leen los primeros párrafos tal cual los escribió
    /// la página. Es peor resumen y es cierto al cien por ciento.
    private func summarize(_ page: ExtractedPage) async {
        let paragraphs: [String] = page.blocks.compactMap {
            if case .paragraph(_, let text, _) = $0 { return text } else { return nil }
        }

        func readTheOpening(_ why: String) {
            guard let opening = paragraphs.first(where: { $0.count >= 80 }) else {
                describe(page)
                return
            }
            say(why)
            say(String(opening.prefix(400)))
        }

        guard let answerer else {
            readTheOpening("No tengo el modelo para resumir acá, así que te leo el principio tal cual:")
            return
        }
        let text = Self.saying(page)
        guard !text.isEmpty else {
            say("Esta página no tiene texto que pueda leer.")
            return
        }
        do {
            guard let answer = try await answerer.answer(
                "Resumí de qué trata esta página en dos o tres frases.", about: text
            ) else {
                readTheOpening("No pude resumirla sin inventar, así que te leo el principio tal cual:")
                return
            }
            say(answer.text)
            say("Lo dice así: \(answer.quote.prefix(160))")
        } catch Answerer.AnswerError.transport {
            readTheOpening("No hay conexión para resumir, pero la página ya está acá. Te leo el principio:")
        } catch {
            readTheOpening("Algo falló de mi lado al resumir. Te leo el principio tal cual:")
        }
    }

    /// La persona aceptó lo que el asistente propuso.
    func accept(_ action: Action, on reader: ReaderModel) async {
        guard let pending = offer, !working else { return }
        offer = nil
        heard(action.label)
        working = true
        defer { working = false }

        // Un campo se llena, no se toca. Sin esto, aceptar "Buscar en
        // Wikipedia" volvía a apretar la lupa y a preguntar de nuevo: la
        // persona confirmaba una y otra vez sin que nada se escribiera.
        if let page = reader.page, let field = Self.field(named: action, in: page) {
            await write(field, of: action, goal: pending.goal, on: reader)
            return
        }

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
        var first = true

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
                say("No hay conexión. Sin internet no puedo llevarte a ningún lado.")
                return
            }

            // Una pregunta no se camina, se contesta — y se contesta DONDE
            // LA PERSONA ESTÁ. Preguntar no puede moverte: enterarte de que
            // cambiaste de página sin haberlo pedido es lo más desorientador
            // que le podemos hacer a alguien que no ve.
            //
            // Se decide una sola vez, en el primer paso del turno: una vez
            // que el asistente empezó a caminar, sigue caminando.
            if first && decision.kind == .answer {
                await reply(goal, about: page)
                return
            }
            first = false

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

                // Oscilar no es avanzar.
                guard touched.insert(chosen.id).inserted else {
                    say("Estoy dando vueltas sobre lo mismo. Contame de otra forma qué buscás, o seguí vos.")
                    return
                }

                // Un campo se llena, no se toca. Y lo que se escribe sale
                // SÓLO de lo que la persona pidió: si un valor pudiera venir
                // de la página, un sitio podría hacer que JEF escriba lo que
                // se le antoje, y quien no ve no tendría cómo notarlo.
                if let field = Self.field(named: chosen, in: page) {
                    await write(field, of: chosen, goal: goal, on: reader)
                    return
                }

                say("Toco \(chosen.label).")
                await reader.activate(chosen)
            }
        }

        if let page = reader.page { describe(page) }
    }

    /// Escribe en un campo lo que la persona pidió, y para antes de enviar.
    ///
    /// **El asistente no envía formularios.** Llena y se detiene, y el botón
    /// que manda queda para la persona. No es una heurística que se pueda
    /// evadir: no existe una ruta de código por la que JEF apriete "Pagar",
    /// "Confirmar" o "Enviar". Un botón que dice "Continuar" y cobra pasa
    /// cualquier lista negra; un asistente que nunca aprieta, no.
    private func write(
        _ field: Action.Field, of form: Action, goal: String, on reader: ReaderModel
    ) async {
        guard let answerer else {
            say("Encontré el campo \(field.name), pero no puedo escribir en esta versión.")
            return
        }
        let value: String?
        do {
            value = try await answerer.value(for: field.name, from: goal)
        } catch {
            say("No pude preparar lo que hay que escribir. Probá de nuevo.")
            return
        }
        guard let value else {
            say("Encontré el campo \(field.name), pero no me dijiste qué poner. Decímelo y lo escribo.")
            return
        }

        await reader.type(value, into: field)
        say("Escribí \(value) en \(field.name).")

        // Buscar no es comprometerse: es lo que la persona pidió, no cuesta
        // nada y se deshace volviendo. Hacerla buscar el botón ella misma
        // después de pedir "busca Buenos Aires" convierte la regla de
        // seguridad en un estorbo, y una regla que estorba en lo común se
        // termina desactivando en lo importante.
        if Self.isSearch(form) {
            say("Busco.")
            await reader.submit(form)
            if let page = reader.page { describe(page) }
            return
        }

        let submit = form.submit?.isEmpty == false ? form.submit! : "el botón de enviar"
        say("Escrito. Tocá \(submit) vos: enviar esto es tu decisión, no mía.")
    }

    /// Si este formulario sólo busca.
    ///
    /// Se decide con lo que el DOM dice, nunca preguntándole a un modelo si
    /// algo es peligroso — eso ya se midió en este proyecto y no es
    /// confiable. Y se decide por la afirmativa: se envía sólo cuando se
    /// puede PROBAR que es una búsqueda, no cuando no se detecta peligro. Un
    /// botón que dice "Continuar" y cobra pasa cualquier lista negra; ninguna
    /// lista negra es la defensa acá, lo es la lista blanca.
    static func isSearch(_ form: Action) -> Bool {
        let fields = (form.fields ?? []).filter { $0.type != "hidden" }
        guard !fields.isEmpty else { return false }
        // Una contraseña nunca es una búsqueda.
        guard !fields.contains(where: \.isSecure) else { return false }

        let committing = "pagar|comprar|confirmar|enviar|suscrib|registr|crear cuenta|aceptar|continuar|siguiente|finalizar|reservar|checkout|pay|buy|submit|sign ?up|subscribe"
        let searching = "^(buscar|buscá|busca|search|filtrar|aplicar filtros|ver resultados|mostrar|consultar|go)\\b"
        let label = (form.submit ?? "").trimmingCharacters(in: .whitespaces)
        if label.range(of: committing, options: [.regularExpression, .caseInsensitive]) != nil { return false }

        // Todos sus campos son de búsqueda, o su botón dice que busca.
        let fillable = fields.filter { $0.type != "checkbox" && $0.type != "radiogroup" }
        if !fillable.isEmpty, fillable.allSatisfy(\.isSearch) { return true }
        return label.range(of: searching, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// El campo que este destino representa, si lo es.
    static func field(named action: Action, in page: ExtractedPage) -> Action.Field? {
        guard action.kind == .form else { return nil }
        let fields = action.fields ?? []
        // El primero que todavía está vacío: es donde va lo que se pidió.
        return fields.first { $0.value.isEmpty && !$0.isSecure && $0.type != "checkbox" }
            ?? fields.first { !$0.isSecure }
    }

    /// Contesta una pregunta sobre lo que la página dice.
    ///
    /// Lo que se puede contar, lo cuenta el código; lo que hay que redactar,
    /// lo redacta el modelo y lo respalda con una cita literal que se
    /// verifica contra la página. Si la cita no aparece, no se dice nada:
    /// para quien no ve, una invención sin verificar es indetectable.
    private func reply(_ question: String, about page: ExtractedPage) async {
        guard let answerer else {
            say("No puedo contestar preguntas en esta versión, pero puedo llevarte a algún lado.")
            return
        }
        let text = Self.saying(page)
        guard !text.isEmpty else {
            say("Esta página no tiene texto que pueda leer.")
            return
        }
        do {
            guard let answer = try await answerer.answer(question, about: text) else {
                say("Eso no lo encontré en esta página.")
                return
            }
            say(answer.text)
            say("Lo dice así: \(answer.quote.prefix(160))")
        } catch Answerer.AnswerError.transport {
            say("No hay conexión. Sin internet puedo leerte la página, pero no contestar preguntas.")
        } catch {
            // Un error del modelo no es un problema de red, y decir que lo es
            // manda a la persona a revisar el wifi por nada. Pasó: la
            // respuesta venía cortada y el mensaje hablaba de la conexión.
            say("Algo falló de mi lado al contestar eso. Probá de nuevo, o preguntame de otra forma.")
        }
    }

    /// Lo que la página dice, en su orden y separando el contenido del mobiliario.
    ///
    /// El orden importa y la separación más: volcando primero todas las
    /// acciones —las cotizaciones, la promo de suscripción, las redes, el
    /// menú— y después el contenido, "resumime esta página" contestaba con
    /// una descripción de los muebles: "presenta el valor de distintos tipos
    /// de dólar, ofrece una promoción de suscripción, tiene links a sus redes
    /// sociales". Todo cierto y nada de lo que la persona preguntó.
    ///
    /// Así que el contenido va primero y con su nombre, y el cromo del sitio
    /// va al final, dicho como lo que es. Nada se saca: una cotización sigue
    /// siendo un dato que alguien puede preguntar.
    static func saying(_ page: ExtractedPage) -> String {
        let chromeZones: Set<String> = [
            "header", "banner", "nav", "navigation", "search", "footer", "contentinfo",
        ]
        var content: [String] = []
        var chrome: [String] = []
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var placed = Set<String>()

        for entry in page.stream ?? [] {
            let isChrome = chromeZones.contains(entry.zone)
            switch entry.kind {
            case "action":
                guard
                    let action = entry.ref.flatMap({ id in page.actions.first { $0.id == id } }),
                    action.kind != .form, action.unnamed != true
                else { continue }
                placed.insert(action.id)
                if isChrome { chrome.append(action.label) } else { content.append(action.label) }
            case "link":
                guard let label = entry.label else { continue }
                if isChrome { chrome.append(label) } else { content.append(label) }
            case "block":
                let said = entry.block?.plainText ?? ""
                guard !said.isEmpty else { continue }
                if isChrome { chrome.append(said) } else { content.append(said) }
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                if !listing.title.isEmpty { content.append(listing.title) }
                for item in listing.items { content.append(item.spokenLabel) }
            default:
                continue
            }
        }

        // Lo que el recorrido no alcanzó a ubicar, para que nada quede fuera.
        for action in page.actions
        where action.kind != .form && action.unnamed != true && !placed.contains(action.id) {
            chrome.append(action.label)
        }
        // Un artículo no pasa por el recorrido: su texto vive en los bloques.
        if content.count < 8 {
            for block in page.blocks where !block.plainText.isEmpty { content.append(block.plainText) }
        }

        var out = "PÁGINA: \(page.displaySite) — \(page.sectionTitle)\n\n"
        out += "CONTENIDO DE LA PÁGINA (esto es a lo que la persona vino):\n"
        out += content.joined(separator: "\n").prefix(20000)
        if !chrome.isEmpty {
            out += "\n\nMENÚ, AVISOS Y DATOS AL PASO DEL SITIO (no es el contenido, pero se puede preguntar por esto):\n"
            out += chrome.joined(separator: "\n").prefix(3000)
        }
        return out
    }

    /// Dónde quedó la persona y qué hay, sin generar una palabra.
    ///
    /// Esta es la parte que más pesa cuando la página no se recorre. Si nadie
    /// va a pasarle VoiceOver por encima, esto es TODO lo que la persona va a
    /// saber del lugar donde está: no alcanza con el título. Hay que decir
    /// qué clase de página es, cuánto tiene, y qué se puede hacer desde acá.
    ///
    /// Cinco formas, porque son las cinco que encontramos midiendo: algo que
    /// tapa, una portada, una nota, una lista de resultados y un formulario.
    /// La que no cae en ninguna termina en el conteo de opciones, que es
    /// pobre pero es cierto.
    ///
    /// Ni una palabra de acá la escribe un modelo: todo es plantilla, texto
    /// literal de la página y cuentas del código. Un resumen se pide; una
    /// orientación no puede depender de que la red conteste.
    private func describe(_ page: ExtractedPage) {
        // Lo que tapa va primero: detrás de un muro de cookies no hay nada
        // que hacer, y es justo lo que la persona no puede ver que está ahí.
        if let overlay = page.overlay {
            say("Antes de nada: \(overlay.kind.title.lowercased()) tapa la página.")
            if !overlay.choices.isEmpty {
                say("Te deja: \(overlay.choices.map(\.label).prefix(3).joined(separator: ", ")). Decime cuál.")
            } else {
                say("No encontré cómo sacarlo. Podés seguir vos.")
            }
            return
        }

        say("Estás en \(page.sectionTitle), en \(page.displaySite).")

        // 1. Una portada: titulares que se abren.
        let headlines = Self.headlines(of: page)
        if !headlines.isEmpty {
            say("Hay \(headlines.count) \(headlines.count == 1 ? "nota" : "notas"). \(headlines.count == 1 ? "Dice" : "Las tres primeras"):")
            for title in headlines.prefix(3) { say(String(title.prefix(120))) }
            say("¿Te leo alguna, te resumo la página, o buscamos otra cosa?")
            return
        }

        // 2. Una nota para leer. Se pide párrafo largo y no sólo muchos
        //    caracteres: los recortes de una página de resultados suman
        //    caracteres de sobra y no son una nota.
        let paragraphs: [String] = page.blocks.compactMap {
            if case .paragraph(_, let text, _) = $0 { return text } else { return nil }
        }
        if paragraphs.count >= 3, let opening = paragraphs.prefix(3).first(where: { $0.count >= 160 }) {
            say("Es una nota de \(paragraphs.count) párrafos. Empieza así:")
            say(String(opening.prefix(220)))
            say("¿Te la leo entera, te la resumo, o preguntás algo puntual?")
            return
        }

        // 3. Una lista de resultados. Es el caso que antes salía como
        //    "Llegué. Estás en Buscar" y no decía cuántos ni cuáles.
        let lists = page.listings.filter(\.isNavigable)
        let items = lists.flatMap(\.items)
        if items.count >= 3 {
            let named = lists.count == 1 ? lists[0].title.trimmingCharacters(in: .whitespaces) : ""
            say(named.isEmpty
                ? "Hay \(items.count) resultados. Los tres primeros:"
                : "\(named): \(items.count). Los tres primeros:")
            for item in items.prefix(3) { say(String(item.title.prefix(120))) }
            say("¿Abro alguno, te leo más, o buscamos otra cosa?")
            return
        }

        // 4. Un formulario: acá no se mira, se completa.
        if let form = page.actions.first(where: { $0.kind == .form && !($0.fields ?? []).isEmpty }) {
            let fields = (form.fields ?? []).filter { $0.type != "hidden" }
            let names = fields.map(\.name).filter { !$0.isEmpty }
            say("Hay un formulario de \(fields.count) \(fields.count == 1 ? "campo" : "campos")\(names.isEmpty ? "" : ": " + names.prefix(4).joined(separator: ", ")).")
            if fields.contains(where: \.isSecure) {
                // Una contraseña no se dicta y no se manda sola.
                say("Pide una contraseña, así que esa la escribís vos.")
            } else {
                say("Decime qué poner y lo completo.")
            }
            return
        }

        // 5. Nada de lo anterior. El número igual sirve: saber que hay 40
        //    opciones es distinto de no saber si la página cargó.
        let controls = page.actions.filter { $0.kind != .form }.count
        if controls > 0 {
            say("Esta página tiene \(controls) \(controls == 1 ? "opción" : "opciones"). Pedime lo que buscás, o seguí vos.")
        } else {
            say("Esta página no me ofrece nada para tocar. Podés pedirme otra cosa.")
        }
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

        for action in page.actions where action.unnamed != true {
            // Un formulario es un destino: significa "escribí acá". Sin él,
            // "busca Buenos Aires" no tiene a dónde ir y el asistente termina
            // abriendo y cerrando la lupa.
            guard action.kind != .form || !(action.fields ?? []).isEmpty else { continue }
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
