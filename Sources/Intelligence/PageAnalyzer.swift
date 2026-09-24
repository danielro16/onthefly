import Foundation

/// Lo que el asistente le pregunta a Jev sobre una página: a dónde ir.
///
/// Jev elige entre opciones enumeradas —lo único que se midió que hace de
/// forma confiable— y nunca redacta. Las opciones las pone la página; la
/// frase que se dice la pone el código.
actor PageAnalyzer {

    private let jev: JevClient

    init(jev: JevClient) {
        self.jev = jev
    }

    // MARK: - ¿Compromete?

    private struct CommitState: Encodable, Sendable {
        let button: String
        let fields: [String]
        let site: String
        let title: String
    }

    /// Qué tan probable es que apretar este botón comprometa a la persona:
    /// pagar, confirmar, mandar datos, darse de baja. Lo juzga Jev con la
    /// pregunta de `criterios.json`, en cualquier idioma, con los campos del
    /// formulario como contexto ("Continuar" junto a un número de tarjeta).
    /// `control`: un formulario, o un botón o link, que no tiene campos.
    ///
    /// Nil si no hay criterio, si Jev falla o si no contesta a tiempo: la
    /// carrera de la arquitectura. Quien llama trata nil como "compromete":
    /// ante la duda, el botón lo toca la mano.
    func commits(button: String, control: Action, page: ExtractedPage) async -> Double? {
        guard let criterios = Criterios.actuales, let pregunta = criterios.jev["compromete"] else { return nil }
        let fields = (control.fields ?? []).filter { $0.type != "hidden" }.map { field in
            "\(field.name) (\(field.type)\(field.autocomplete.map { ", \($0)" } ?? ""))"
        }
        let state = CommitState(button: button, fields: fields, site: page.displaySite, title: page.title)
        let question = JevClient.Question.boolean(
            instructions: pregunta.instructions,
            whenTrue: pregunta.criteria?["true"], whenFalse: pregunta.criteria?["false"])
        let jev = self.jev
        return await withTaskGroup(of: Double?.self) { group in
            group.addTask {
                let result = try? await jev.evaluate(state: state, questions: ["compromete": question])
                guard case .boolean(let probability)? = result?.answers["compromete"] else { return nil }
                return probability
            }
            group.addTask {
                try? await Task.sleep(for: criterios.esperaJev)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
    }

    // MARK: - Anuncios en los resultados

    private struct ResultsState: Encodable, Sendable {
        struct Result: Encodable, Sendable {
            let result: String
            let before: String
            let after: String
        }
        let results: [Result]
    }

    /// Qué tan probable es que cada resultado del buscador sea un anuncio
    /// (índice → probabilidad). Jev lo juzga con lo que el buscador muestra
    /// antes y después de cada uno —"Resultados patrocinados", "¿Por qué
    /// este anuncio?", "Sponsored"—, en cualquier idioma y de cualquier
    /// buscador. El filtro anterior miraba las direcciones de los anuncios de
    /// Google, y dejó de andar cuando Google las cambió: en Boca, los tres
    /// primeros botones eran reventa paga.
    ///
    /// Un solo pedido con todos los resultados: medio segundo. Un pedido por
    /// resultado separaba mejor (en Boca, un anuncio dio 0,58 juntos y 0,92
    /// solo), pero Daniel eligió el rápido: si se cuela un anuncio, se ofrece
    /// como un resultado más. Nil si Jev no contestó a tiempo: los resultados
    /// se ofrecen como vinieron.
    func adProbabilities(_ results: [(result: String, before: String, after: String)]) async -> [Int: Double]? {
        guard let criterios = Criterios.actuales, let pregunta = criterios.jev["anuncio"], !results.isEmpty else { return nil }
        let items = Array(results.prefix(20))
        let state = ResultsState(results: items.map { .init(result: $0.result, before: $0.before, after: $0.after) })
        var questions: [String: JevClient.Question] = [:]
        for index in items.indices {
            questions["r\(index)"] = .boolean(
                instructions: pregunta.instructions.replacingOccurrences(of: "{i}", with: "\(index)"),
                whenTrue: pregunta.criteria?["true"], whenFalse: pregunta.criteria?["false"])
        }
        let jev = self.jev
        let asked = questions
        let answers: [String: JevClient.Answer]? = await withTaskGroup(of: [String: JevClient.Answer]?.self) { group in
            group.addTask { try? await jev.evaluate(state: state, questions: asked).answers }
            group.addTask {
                try? await Task.sleep(for: criterios.esperaJev)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
        guard let answers else { return nil }
        var out: [Int: Double] = [:]
        for index in items.indices {
            if case .boolean(let probability)? = answers["r\(index)"] { out[index] = probability }
        }
        return out
    }

    // MARK: - Qué sitio es, qué página es

    private struct KindState: Encodable, Sendable {
        struct Item: Encodable, Sendable {
            let text: String
            let kind: String
            let region: String
        }
        struct Notice: Encodable, Sendable {
            let text: String
            let choices: [String]
            let links: [String]
        }
        let domain: String
        let title: String
        let headings: [String]
        let text: String
        let items: [Item]
        /// El aviso que tapa la página, si hay: el extractor sabe que está
        /// por su forma; qué pide, lo dice Jev.
        let notice: Notice?
    }

    /// Lo que Jev dijo de una página: qué tipo de sitio y qué tipo de página,
    /// cada uno con su seguridad.
    struct Kinds: Sendable {
        let site: String
        let siteConfidence: Double
        let page: String
        let pageConfidence: Double
        /// Qué pide el aviso que tapa la página, si hay uno.
        var notice: String? = nil
        var noticeConfidence: Double = 0
    }

    /// Las preguntas "sitio" y "pagina" de `criterios.json`, en un solo
    /// pedido: con las opciones y sus definiciones en el archivo, un tipo
    /// nuevo es una línea, no código. Medido en 27 páginas de 9 países: con
    /// seguridad de 0,7 o más acertó 48 de 48 sitios y 45 de 45 páginas, en
    /// medio segundo. Lo que no llega a esa seguridad lo decide el modelo.
    /// Con un aviso encima, también qué pide ("aviso"): medido en 8 avisos, 8
    /// bien, y la promoción de Foodit, que el extractor no reconocía por sus
    /// palabras. Nil si Jev no contesta a tiempo.
    func kinds(domain: String, title: String, headings: [String], text: String,
               items: [(text: String, kind: String, region: String)], overlay: Overlay? = nil) async -> Kinds? {
        guard let criterios = Criterios.actuales, let sitio = criterios.jev["sitio"], let pagina = criterios.jev["pagina"]
        else { return nil }
        let aviso = overlay == nil ? nil : criterios.jev["aviso"]
        let state = KindState(
            domain: domain, title: String(title.prefix(120)), headings: headings.prefix(12).map { String($0.prefix(100)) },
            text: String(text.prefix(1200)),
            items: items.prefix(30).map { .init(text: String($0.text.prefix(80)), kind: $0.kind, region: $0.region) },
            notice: overlay.map { .init(text: String($0.text.prefix(600)), choices: $0.choices.map(\.label),
                                        links: ($0.links ?? []).map(\.label)) })
        var questions: [String: JevClient.Question] = [
            "sitio": .choice(instructions: sitio.instructions, options: (sitio.criteria ?? [:]).mapValues { $0 }),
            "pagina": .choice(instructions: pagina.instructions, options: (pagina.criteria ?? [:]).mapValues { $0 }),
        ]
        if let aviso {
            questions["aviso"] = .choice(instructions: aviso.instructions, options: (aviso.criteria ?? [:]).mapValues { $0 })
        }
        let asked = questions
        let jev = self.jev
        let answers: [String: JevClient.Answer]? = await withTaskGroup(of: [String: JevClient.Answer]?.self) { group in
            group.addTask { try? await jev.evaluate(state: state, questions: asked).answers }
            group.addTask {
                try? await Task.sleep(for: criterios.esperaJev)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
        guard case .choice(let site, let siteP, let siteC)? = answers?["sitio"],
              case .choice(let page, let pageP, let pageC)? = answers?["pagina"] else { return nil }
        var found = Kinds(site: site, siteConfidence: siteC ?? siteP[site] ?? 0,
                          page: page, pageConfidence: pageC ?? pageP[page] ?? 0)
        if case .choice(let notice, let noticeP, let noticeC)? = answers?["aviso"] {
            found.notice = notice
            found.noticeConfidence = noticeC ?? noticeP[notice] ?? 0
        }
        return found
    }

    // MARK: - Controles sin nombre

    private struct ControlsState: Encodable, Sendable {
        struct Control: Encodable, Sendable {
            let hints: String
            let region: String
        }
        let controls: [Control]
    }

    /// Lo ya decidido, por pistas y región: el mismo botón, en cada lectura
    /// de la página, no se vuelve a preguntar. `.some(nil)`: Jev no supo.
    private var knownKinds: [String: String?] = [:]

    /// El tipo de cada control sin nombre —índice → tipo de `criterios.json`—,
    /// sólo los que Jev eligió con la confianza del umbral y que no son
    /// "other". Con la carrera: si Jev no contesta a tiempo, esos quedan sin
    /// nombre y se vuelven a intentar en otra lectura.
    ///
    /// Medido con 30 controles en castellano, inglés, francés, alemán,
    /// japonés y ruso: 28 bien, y los dos errores con confianza baja (0,35 y
    /// 0,39), así que con el umbral no se nombran mal: quedan sin nombre.
    func kinds(ofUnnamed controls: [(hints: String, region: String)]) async -> [Int: String] {
        guard let criterios = Criterios.actuales, let preguntas = criterios.controles else { return [:] }
        let limit = criterios.umbrales["nombre_control"] ?? 1
        var result: [Int: String] = [:]
        var pending: [Int] = []
        for (index, control) in controls.enumerated() {
            if let known = knownKinds[control.hints + "|" + control.region] {
                if let kind = known { result[index] = kind }
            } else {
                pending.append(index)
            }
        }
        guard !pending.isEmpty else { return result }
        let batch = Array(pending.prefix(35))
        let state = ControlsState(controls: batch.map { .init(hints: controls[$0].hints, region: controls[$0].region) })
        var questions: [String: JevClient.Question] = [:]
        for position in batch.indices {
            questions["c\(position)"] = .choice(
                instructions: preguntas.pregunta.replacingOccurrences(of: "{i}", with: "\(position)"),
                options: preguntas.tipos)
        }
        let jev = self.jev
        let asked = questions
        let answers: [String: JevClient.Answer]? = await withTaskGroup(of: [String: JevClient.Answer]?.self) { group in
            group.addTask { try? await jev.evaluate(state: state, questions: asked).answers }
            group.addTask {
                try? await Task.sleep(for: criterios.esperaJev)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
        guard let answers else { return result }
        for (position, index) in batch.enumerated() {
            guard case .choice(let value, let probabilities, _)? = answers["c\(position)"] else { continue }
            let sure = (probabilities[value] ?? 0) >= limit && value != "other"
            knownKinds[controls[index].hints + "|" + controls[index].region] = .some(sure ? value : nil)
            if sure { result[index] = value }
        }
        return result
    }

    // MARK: - ¿Cuál lleva a lo pedido?

    private struct ItemsState: Encodable, Sendable {
        struct Item: Encodable, Sendable {
            let text: String
            let kind: String
            let region: String
            let domain: String
            let external: Bool
        }
        let request: String
        let items: [Item]
    }

    /// Lo que Jev encontró en la página para un pedido.
    struct Found: Sendable {
        /// El índice, en las opciones, del que lleva a lo pedido. Nil: ninguno.
        let choice: Int?
        /// Qué tan seguro está Jev de esa elección, también si es "ninguno".
        let confidence: Double
        /// Qué tan probable es que lo pedido se consiga en esta página,
        /// leyéndola o tocando algo.
        let here: Double?
    }

    /// Cuál de las opciones de la página lleva a lo pedido, o ninguna, y si
    /// está en esta página: las preguntas "cual" y "esta" de `criterios.json`,
    /// armadas como las mide `Scripts/probar-jev.py`. Reemplaza a las cabezas
    /// "kind" y "move": qué quiere la persona lo decide Gemini; Jev mira la
    /// página.
    ///
    /// En dos rondas de estados chicos: la página en tandas de 35, en
    /// paralelo, y una final entre los dos mejores de cada tanda. Con la
    /// página entera como estado el proveedor rechazaba (429/503), y la
    /// documentación de Jev avisa que el contexto de más le quita precisión.
    /// Cada ronda corre la carrera: nil si Jev no contesta a tiempo, y
    /// decide Gemini.
    func find(_ request: String, among options: [Action], site: String) async -> Found? {
        guard let criterios = Criterios.actuales, let cual = criterios.jev["cual"], let esta = criterios.jev["esta"],
              !options.isEmpty else { return nil }
        func domain(_ url: String?) -> String {
            guard let url, let host = URL(string: url)?.host()?.lowercased() else { return "" }
            return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        }
        let own = domain(site)
        let items: [ItemsState.Item] = options.map { action in
            var text = action.label
            if action.kind == .form {
                let fields = (action.fields ?? []).filter { $0.type != "hidden" }.map(\.name)
                text += " [\(fields.joined(separator: ", "))] \(action.submit ?? "")"
            }
            let target = domain(action.href)
            let external = !target.isEmpty && !(target == own || target.hasSuffix("." + own) || own.hasSuffix("." + target))
            return .init(
                text: String(text.split(whereSeparator: \.isWhitespace).joined(separator: " ").prefix(120)),
                kind: action.kind.rawValue, region: action.region.isEmpty ? "main" : action.region,
                domain: target, external: external)
        }
        func questions(_ count: Int) -> [String: JevClient.Question] {
            var choices: [String: String?] = [:]
            for index in 0..<count { choices.updateValue(nil, forKey: String(index)) }
            for (key, text) in cual.criteria ?? [:] { choices[key] = text }
            return [
                "cual": .choice(instructions: cual.instructions + " " + criterios.datos, options: choices),
                "esta": .boolean(
                    instructions: esta.instructions + " " + criterios.datos,
                    whenTrue: esta.criteria?["true"], whenFalse: esta.criteria?["false"]),
            ]
        }
        let jev = self.jev
        let wait = criterios.esperaJev
        /// Una ronda: un pedido por grupo, todos a la vez, con la carrera.
        func round(_ groups: [[Int]]) async -> [[String: JevClient.Answer]?]? {
            let asked = groups.map { (ItemsState(request: request, items: $0.map { items[$0] }), questions($0.count)) }
            return await withTaskGroup(of: [[String: JevClient.Answer]?]?.self) { race in
                race.addTask {
                    await withTaskGroup(of: (Int, [String: JevClient.Answer]?).self) { each in
                        for (n, (state, questions)) in asked.enumerated() {
                            each.addTask { (n, try? await jev.evaluate(state: state, questions: questions).answers) }
                        }
                        var out = [[String: JevClient.Answer]?](repeating: nil, count: asked.count)
                        for await (n, answers) in each { out[n] = answers }
                        return out
                    }
                }
                race.addTask {
                    try? await Task.sleep(for: wait)
                    return nil
                }
                let first = await race.next() ?? nil
                race.cancelAll()
                return first
            }
        }

        let groups = stride(from: 0, to: items.count, by: 35).map { Array($0..<min($0 + 35, items.count)) }
        guard let first = await round(groups) else { return nil }
        var candidates: [Int] = []
        var here: [Double] = []
        for (group, answers) in zip(groups, first) {
            guard let answers else { continue }
            if case .boolean(let probability)? = answers["esta"] { here.append(probability) }
            guard case .choice(_, let probabilities, _)? = answers["cual"] else { continue }
            // Los dos mejores de cada tanda, si valen algo: la final decide.
            candidates += probabilities.filter { $0.key != "none" && $0.value >= 0.1 }
                .sorted { $0.value > $1.value }.prefix(2)
                .compactMap { Int($0.key) }.filter { group.indices.contains($0) }.map { group[$0] }
        }
        guard !candidates.isEmpty else {
            // Ninguna tanda tuvo un candidato: ninguno, si contestaron todas.
            guard first.allSatisfy({ $0 != nil }) else { return nil }
            return Found(choice: nil, confidence: 1, here: here.max())
        }
        guard let final = await round([candidates])?.first ?? nil,
              case .choice(let value, let probabilities, let confidence)? = final["cual"]
        else { return nil }
        var sure: Double? = here.max()
        if case .boolean(let probability)? = final["esta"] { sure = probability }
        return Found(
            choice: Int(value).flatMap { candidates.indices.contains($0) ? candidates[$0] : nil },
            confidence: confidence ?? probabilities[value] ?? 0,
            here: sure)
    }
}
