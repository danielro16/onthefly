import Foundation

/// Qué hacer con lo que la persona pidió: lo decide un modelo.
///
/// Esto reemplazó un clasificador de expresiones regulares que la medición
/// refutó: contra sesenta pedidos reales —`Tests/intenciones.json`— atrapaba
/// cinco. Entender es lo que un modelo de lenguaje hace.
///
/// Desde 2026-09-22 (Daniel: "¿por qué no inyectamos las decisiones
/// directamente al modelo?") decide con todo a la vista: el texto de la
/// página, los campos y botones de formulario numerados, dónde está la
/// persona y las reglas de `decisiones.json`. El código sólo ejecuta, y
/// verifica que el número elegido exista: el modelo nunca escribe un destino.
actor Router {

    /// Lo que el asistente sabe hacer.
    enum Action: String, Codable, Sendable {
        case ir, buscar, abrir, leer, seguir, resumir, responder
        case completar, enviar, volver, orientar, noPuedo
    }

    struct Decision: Codable, Sendable {
        let action: Action
        /// Para `ir` y `buscar`: el sitio o las palabras a buscar.
        let target: String?
        /// Para `abrir`: cómo la persona nombró lo que quiere. Se resuelve
        /// contra lo que la página ofrece; el modelo no inventa destinos.
        let reference: String?
        /// Para `responder`, la pregunta limpia. Para `buscar`, la pregunta
        /// que se contesta en el sitio que la persona elija.
        let question: String?
        /// Para `completar` y `enviar`: el número del campo o del botón en la
        /// lista de formulario que recibió el modelo, empezando en 1.
        let control: Int?
        /// Para `completar`: qué escribir, sacado de lo que dijo la persona.
        let value: String?
        /// El segundo pedido, cuando vienen dos en una frase.
        let then: Action?
        /// Lo que queda por hacer DESPUÉS de esta acción, en las palabras de
        /// la persona: se vuelve a decidir cuando esté abierta la otra página.
        let rest: String?
        /// Para `noPuedo`: qué no se puede y qué sí, dicho por el modelo.
        let message: String?
        /// Si el pedido empieza una tarea nueva o sigue la que había: lo que
        /// la persona vino a hacer lo declara ella, y viaja a Gemini hasta que
        /// pida otra cosa.
        var newTask = false
    }

    enum RouterError: Error { case http(Int), transport(String), unusable }

    private let gemini: Gemini
    private let session: URLSession

    /// El mismo modelo que responde (ver `Gemini`).
    static func fromEnvironment() -> Router? {
        Gemini.fromEnvironment().map(Router.init)
    }

    init(gemini: Gemini) {
        self.gemini = gemini
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    // Las instrucciones viven en `prompts.json` ("ruteador"): estructura fija,
    // reglas globales, respuesta por esquema. Ver `Prompts`.

    /// El estado, armado por el código. Sin una línea del texto de la página:
    /// rutear no lo necesita, y dejándolo afuera un sitio no tiene por dónde
    /// influir en la decisión.
    @MainActor
    static func state(page: ExtractedPage?, reading: (at: Int, of: Int)?, previous: String? = nil) -> String {
        // Lo que pidió antes, con sus palabras: sin esto "¿y el oficial?"
        // después de "dólar blue" no tenía de qué hablar, y "¿cuándo se
        // fundó?" se buscaba sin decir qué.
        let before = previous.map { " What they asked before: «\($0)»." } ?? ""
        guard let page else { return "No page is open yet." + before }
        var parts: [String] = ["On «\(page.sectionTitle)», at \(page.displaySite)." + before]
        let headlines = Assistant.headlines(of: page).count
        if headlines > 0 { parts.append("The page lists \(headlines) headlines that can be opened.") }
        let items = page.listings.filter(\.isNavigable).flatMap(\.items).count
        if items > 0 { parts.append("There are \(items) items in lists.") }
        let paragraphs = page.blocks.filter { if case .paragraph = $0 { return true } else { return false } }.count
        if paragraphs >= 3 { parts.append("It is a long text: \(paragraphs) paragraphs.") }
        if let form = page.actions.first(where: { $0.kind == .form && !($0.fields ?? []).isEmpty }) {
            let names = (form.fields ?? []).filter { $0.type != "hidden" }.map(\.name)
            parts.append("There is a form with these fields: \(names.prefix(8).joined(separator: ", ")).")
        }
        if let reading { parts.append("It is being read to them: at block \(reading.at) of \(reading.of).") }
        if page.overlay != nil { parts.append("A notice covers the page.") }
        return parts.joined(separator: " ")
    }

    /// `task`: lo que la persona vino a hacer. `place`: dónde está la
    /// persona. `page`: el texto de la página. `controls`: los campos y
    /// botones de formulario, en el orden en que se numeran.
    func decide(
        _ request: String, task: String? = nil, state: String, place: String? = nil,
        page: String? = nil, controls: [String] = []
    ) async throws -> Decision {
        guard let prompts = Prompts.actuales else { throw RouterError.unusable }
        let list = controls.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        let input = prompts.mensaje("ruteador", [
            "pedido": request, "tarea": task, "pagina": state, "lugar": place,
            "formulario": list.isEmpty ? nil : list, "texto": page.map { String($0.prefix(6000)) },
        ])
        let body: [String: Any] = [
            // Con el texto real de una portada razona más: 300 cortaba la
            // respuesta a la mitad ("dame los titulares" en La Nación).
            "max_tokens": 1000,
            "response_format": prompts.formato("ruteador"),
            "messages": [
                ["role": "system", "content": prompts.sistema("ruteador", idioma: Answerer.language)],
                ["role": "user", "content": input],
            ],
        ]
        // Razonando: entender qué quiere la persona es lo único que lo
        // merece (Daniel: "dejale al modelo que razone las intenciones").
        let request = try gemini.request(body, thinking: true)

        var data = Data()
        for attempt in 0..<3 {
            let response: URLResponse
            do { (data, response) = try await session.data(for: request) }
            catch { throw RouterError.transport(error.localizedDescription) }
            guard let http = response as? HTTPURLResponse else { throw RouterError.transport("Sin respuesta HTTP") }
            if (200..<300).contains(http.statusCode) { break }
            guard [429, 503, 529].contains(http.statusCode), attempt < 2 else { throw RouterError.http(http.statusCode) }
            try? await Task.sleep(for: .milliseconds(500 << attempt))
        }

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = root["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String,
            let parsed = try? JSONSerialization.jsonObject(with: Data(content.utf8)) as? [String: Any],
            let name = (parsed["action"] ?? parsed["accion"]) as? String,
            let action = Action(rawValue: name)
        else { throw RouterError.unusable }

        func text(_ key: String) -> String? {
            guard let value = parsed[key] as? String else { return nil }
            let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return clean.isEmpty || clean == "null" ? nil : clean
        }
        let number = (parsed["control"] as? Int) ?? text("control").flatMap(Int.init)
        return Decision(
            action: action,
            target: text("target"),
            reference: text("reference"),
            question: text("question"),
            control: number,
            value: text("value"),
            then: text("then").flatMap(Action.init(rawValue:)),
            rest: text("rest"),
            message: text("message"),
            newTask: text("tarea") != "sigue"
        )
    }
}
