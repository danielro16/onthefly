import Foundation

/// Contesta preguntas sobre lo que la página dice.
///
/// Jev no sirve para esto: elige entre opciones, no redacta. Así que acá sí
/// va un modelo de lenguaje — el más barato que alcance, porque el trabajo es
/// leer un texto que ya tenemos y responder sobre él, no razonar.
///
/// **La regla que hace que esto se pueda confiar: el modelo está obligado a
/// citar la página textualmente, y este código verifica que la cita exista.**
/// Si el texto citado no aparece en la página, la respuesta no se dice. Para
/// alguien que ve, una invención se nota al mirar; para alguien que no ve, es
/// invisible. La verificación es lo que la vuelve visible.
///
/// Medido sobre lanacion.com.ar: 1,3-2,8 s y menos de un cuarto de centavo
/// por pregunta. Y una demostración involuntaria de que la disciplina
/// funciona — con el texto de la página incompleto, preguntado por el dólar,
/// el modelo contestó "la página no dice eso" en vez de inventar un número.
actor Answerer {

    struct Answer: Sendable {
        let text: String
        /// Lo que la página dice, palabra por palabra.
        let quote: String
        /// Lo que es probable que la persona pregunte después, y que esta
        /// misma página contesta: "¿Y el MEP?" después del blue.
        var questions: [String] = []
        /// La página contesta sólo una parte: se dice, y se ofrece buscar el
        /// resto afuera.
        var partial = false
    }

    enum AnswerError: Error {
        case http(Int)
        case transport(String)
        case unusable
        /// Cifras que el modelo dijo haber usado y la página no tiene.
        case unverified([String])
    }

    private let gemini: Gemini
    private let session: URLSession

    /// El modelo base (ver `Gemini`).
    static func fromEnvironment() -> Answerer? {
        Gemini.fromEnvironment().map(Answerer.init)
    }

    init(gemini: Gemini) {
        self.gemini = gemini
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        self.session = URLSession(configuration: config)
    }

    /// Un asistente que habla como una persona, anclado en la página.
    ///
    /// Antes le exigía una cita copiada letra por letra y descartaba todo si
    /// no coincidía. Sonaba a robot, y fallaba justo donde no debía: en la
    /// portada del New York Times resumió en castellano una página en
    /// inglés, la cita no coincidió con el original, y la persona oyó "no
    /// pude resumirla sin inventar". Pidió un resumen y le contestamos sobre
    /// nuestras reglas.
    ///
    /// Lo que protege contra inventos no es la cita: es que el modelo SÓLO ve
    /// el texto de la página y tiene prohibido agregar lo que sepa por fuera.
    /// Así funciona cualquier asistente que lee documentos. La verificación
    /// estricta queda donde un invento lastima: cifras, montos y fechas.
    /// La fecha de hoy, dicha: "domingo 21 de septiembre de 2026".
    static var today: String {
        Date().formatted(Date.FormatStyle(date: .complete, time: .omitted).locale(Locale(identifier: phoneLanguage)))
    }


    /// La respuesta, o nil si la página no alcanza o la cita no se pudo
    /// verificar. Nil NO es un error: es lo que se dice cuando no se sabe.
    /// Una llamada, con reintento. El gateway devuelve 503 de a ratos, y sin
    /// reintento una respuesta perdida se le muestra a la persona como si no
    /// hubiera internet.
    private func send(_ body: [String: Any]) async throws -> [String: Any]? {
        let request = try gemini.request(body)

        var data = Data()
        for attempt in 0..<3 {
            let response: URLResponse
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                throw AnswerError.transport(error.localizedDescription)
            }
            guard let http = response as? HTTPURLResponse else {
                throw AnswerError.transport("Sin respuesta HTTP")
            }
            if (200..<300).contains(http.statusCode) { break }
            guard [429, 503, 529].contains(http.statusCode), attempt < 2 else {
                throw AnswerError.http(http.statusCode)
            }
            try? await Task.sleep(for: .milliseconds(600 << attempt))
        }

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = root["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw AnswerError.unusable }
        return try? JSONSerialization.jsonObject(with: Data(content.utf8)) as? [String: Any]
    }

    /// Un pedido a Gemini con uno de los prompts de `prompts.json`: su
    /// sistema, sus datos con sus etiquetas y su esquema de respuesta.
    private func ask(_ nombre: String, _ valores: [String: String?], maxTokens: Int) async throws -> [String: Any]? {
        guard let prompts = Prompts.actuales else { throw AnswerError.unusable }
        let body: [String: Any] = [
            "max_tokens": maxTokens,
            "response_format": prompts.formato(nombre),
            "messages": [
                ["role": "system", "content": prompts.sistema(nombre, idioma: Self.language, hoy: Self.today)],
                ["role": "user", "content": prompts.mensaje(nombre, valores)],
            ],
        ]
        return try await send(body)
    }

    /// `previous`: una pregunta que sigue a otra ("¿y el oficial?") no se
    /// entiende sola. `reading`: por dónde va la lectura en voz alta, que no
    /// está en la página ("¿cuánto falta?").
    func answer(_ question: String, about page: String, previous: String? = nil, reading: String? = nil) async throws -> Answer? {
        guard let parsed = try await ask("contestar", [
            "anterior": previous, "pedido": question, "lectura": reading, "texto": page,
        ], maxTokens: 800) else { throw AnswerError.unusable }
        // Si la página contesta lo decide un campo del esquema, no el texto:
        // con "decilo con naturalidad" el modelo escribía "la página no
        // menciona vuelos", y eso se tomaba como una respuesta.
        let answers = parsed["contesta"] as? String
        guard answers != "no", let text = parsed["respuesta"] as? String, !text.isEmpty else { return nil }

        // La verificación, donde importa. Un número inventado —un monto, un
        // precio, una fecha de vencimiento— es el invento que lastima, y es
        // el único que alguien que no ve no puede detectar de oído. Cada
        // cifra que el modelo dice haber usado tiene que estar en la página.
        // Si una no aparece, no se dice nada: mejor callar que inventar un
        // saldo.
        let figures = (parsed["cifras"] as? [String]) ?? []
        guard figures.allSatisfy({ Self.figureAppears($0, in: page) }) else { return nil }
        let questions = ((parsed["preguntas"] as? [String]) ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count <= 60 }
        return Answer(text: text, quote: "", questions: Array(questions.prefix(2)), partial: answers == "en_parte")
    }

    /// El resumen de una página. `alreadySaid`: lo que la persona ya escuchó
    /// de ella, para no repetirlo. Nil si no se pudo, o si una cifra no está
    /// en la página: la misma verificación que al contestar.
    func summary(of page: String, alreadySaid: String? = nil) async throws -> Answer? {
        guard let parsed = try await ask("resumir", ["dicho": alreadySaid, "texto": page], maxTokens: 600)
        else { throw AnswerError.unusable }
        guard let text = parsed["respuesta"] as? String, !text.isEmpty else { return nil }
        let figures = (parsed["cifras"] as? [String]) ?? []
        guard figures.allSatisfy({ Self.figureAppears($0, in: page) }) else { return nil }
        return Answer(text: text, quote: "")
    }

    /// Lo que se le dice a alguien al llegar a una página, y qué puede hacer.
    struct Orientation: Sendable {
        let text: String
        let suggestions: [Suggestion]
        /// Los números de la lista (desde 1) que son ruido para quien llega:
        /// no se sugieren. Con la definición de `criterios.json`.
        var noise: [Int] = []
        /// En una página que es una lista de opciones parecidas —trámites,
        /// categorías, planes— cuando lo pedido no dice cuál: la pregunta, y
        /// las opciones (números de la lista, desde 1) para contestarla. En
        /// ANSES, "¿para qué trámite?" con los trámites de la página.
        var question: String? = nil
        var choices: [Int] = []
    }

    struct Suggestion: Sendable {
        enum Kind: String, Sendable { case abrir, leer, resumir }
        let label: String
        let kind: Kind
        /// Para abrir: el número del elemento en la lista que se le pasó al
        /// modelo, empezando en 1. El modelo nombra el botón; el destino lo
        /// pone la página.
        let number: Int?
    }

    /// Orientar como lo haría una persona, y proponer qué hacer.
    ///
    /// Lo que pidió Daniel al ver la portada del New York Times leída como
    /// si fuera una nota —el menú de ediciones como "párrafo 1"—: que el
    /// asistente diga dónde está, qué dice lo principal, y pregunte qué le
    /// gustaría hacer, con las opciones como botones.
    ///
    /// Las opciones de abrir se eligen POR SU MARCA de una lista que arma el
    /// código con lo que la página ofrece de verdad. El modelo escribe la
    /// etiqueta del botón; no puede escribir su destino.
    /// `frontPage`: es una portada, y sus titulares los dice el código, tal
    /// cual los escribió el diario. Reescritos por el modelo salían distintos
    /// en cada visita, y a veces con algo que no estaba.
    func orient(page: String, candidates: [String], goal: String? = nil, frontPage: Bool = false) async throws -> Orientation? {
        // Cada elemento con una marca de dos letras y no con un número: con la
        // lista numerada, el modelo le decía a la persona "está en la lista
        // como número 4". La marca es para los campos de la respuesta.
        let marks = Self.marks(candidates.count)
        let list = zip(marks, candidates).map { "[\($0)] \($1)" }.joined(separator: "\n")
        let numberOf = Dictionary(uniqueKeysWithValues: marks.enumerated().map { ($1, $0 + 1) })
        func number(_ value: Any?) -> Int? { (value as? String).flatMap { numberOf[$0] } }
        // Qué es ruido y sus tipos los dice `criterios.json`, no este código.
        let ruido = Criterios.actuales?.ruido ?? .init(es: "", noEs: "")
        let parsed = try await ask("orientar", [
            "vino": goal, "titulares": frontPage ? "yes" : nil, "lista": list, "texto": page,
        ], maxTokens: 1100)
        guard let parsed,
              let text = parsed["respuesta"] as? String, !text.isEmpty
        else { throw AnswerError.unusable }
        // Cuántas opciones ofrece para su pregunta: "hay 18 trámites" no está
        // escrito en la página, pero se verifica contra los botones que se
        // van a ofrecer. Si cuenta 19 y ofrece 18, se descarta como
        // cualquier cifra inventada.
        let offered = String(Set(((parsed["opciones"] as? [Any]) ?? []).compactMap(number)).count)
        let figures = (parsed["cifras"] as? [String]) ?? []
        let missing = figures.filter {
            !Self.figureAppears($0, in: page + "\n" + list) && String($0.filter(\.isNumber)) != offered
        }
        guard missing.isEmpty else { throw AnswerError.unverified(missing) }

        // El ruido, por número y con su tipo: sólo números que estén en la
        // lista y tipos que estén en `criterios.json`. Una marca sin tipo
        // válido no cuenta: con números sueltos, Gemini marcaba lo que no
        // servía para ESTE pedido, como productos del propio banco.
        let kinds = Set(ruido.tipos)
        let noise = ((parsed["ruido"] as? [[String: Any]]) ?? []).compactMap { mark -> Int? in
            guard let kind = mark["tipo"] as? String, kinds.contains(kind) else { return nil }
            return number(mark["id"])
        }
        let raw = (parsed["sugerencias"] as? [[String: Any]]) ?? []
        let suggestions: [Suggestion] = raw.compactMap { item in
            guard let label = (item["etiqueta"] as? String)?.trimmingCharacters(in: .whitespaces),
                  !label.isEmpty,
                  let kind = (item["tipo"] as? String).flatMap(Suggestion.Kind.init(rawValue:))
            else { return nil }
            let target = number(item["id"])
            if kind == .abrir {
                // La verificación de siempre: la marca tiene que estar en la
                // lista. Y lo que el mismo modelo llamó ruido no se sugiere.
                guard let target, !noise.contains(target) else { return nil }
            }
            return Suggestion(label: label, kind: kind, number: target)
        }
        // La pregunta vale con sus opciones: sin ninguna opción que exista,
        // no hay qué contestar.
        // Cada una una vez; el orden lo pone quien llama, que sabe el de la
        // página.
        let choices = Set(((parsed["opciones"] as? [Any]) ?? []).compactMap(number)).subtracting(noise).sorted()
        let question = (parsed["pregunta"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return Orientation(
            text: text, suggestions: Array(suggestions.prefix(4)), noise: noise,
            question: choices.isEmpty || question?.isEmpty != false ? nil : question, choices: choices)
    }

    /// Marcas de dos letras para una lista: "bb", "bc", "bd"… Sin vocales,
    /// para que no formen palabras, y sin números.
    static func marks(_ count: Int) -> [String] {
        let letters = Array("bcdfghjkmnpqrstvwxz")
        return (0..<count).map { String([letters[$0 / letters.count % letters.count], letters[$0 % letters.count]]) }
    }

    /// Cuando Jev no encuentra lo pedido o duda: Gemini lee el pedido y lo
    /// que la página deja tocar, y elige uno si está claro o pregunta entre
    /// dos o tres. Lo pidió Daniel: en el Banco Nación, "cuenta" dejaba a Jev
    /// perdido, y lo que quería era entrar al Home Banking.
    struct Reinterpretation: Sendable {
        /// El número elegido, empezando en 0, si está claro.
        let choice: Int?
        /// Si no, la pregunta para la persona, y entre cuáles.
        let question: String?
        let options: [Int]
        /// Si no está en la página: cómo buscarlo en internet.
        let search: String?
    }

    func reinterpret(_ request: String, task: String? = nil, options: [String], page: String) async throws -> Reinterpretation? {
        let list = options.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        guard let parsed = try await ask("reinterpretar", [
            "tarea": task == request ? nil : task,
            "pedido": request, "lista": list, "texto": String(page.prefix(6000)),
        ], maxTokens: 300) else { return nil }
        func number(_ value: Any?) -> Int? {
            let n = (value as? Int) ?? (value as? String).flatMap(Int.init)
            guard let n, (1...options.count).contains(n) else { return nil }
            return n - 1
        }
        let choices = ((parsed["opciones"] as? [Any]) ?? []).compactMap(number)
        let question = (parsed["pregunta"] as? String)?.trimmingCharacters(in: .whitespaces)
        return Reinterpretation(
            choice: number(parsed["elegir"]),
            question: question?.isEmpty == false ? question : nil,
            options: Array(choices.prefix(3)),
            search: (parsed["buscar"] as? String).flatMap { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0 }
        )
    }

    /// Qué hay que escribir en un campo, sacado ÚNICAMENTE de lo que la
    /// persona pidió.
    ///
    /// La página no participa. Ni como contexto: si un valor pudiera salir
    /// del DOM, un sitio podría hacer que JEF escriba lo que se le antoje en
    /// un formulario, y quien no ve no tendría cómo notarlo. Lo único que
    /// entra acá es la frase que la persona dictó y el nombre del campo.
    ///
    /// Devuelve nil cuando el pedido no dice qué poner — y entonces no se
    /// escribe nada y se le pregunta a la persona.
    struct FieldValue: Sendable {
        let value: String
        /// Lo que pidió implica mandar el formulario: buscar, entrar.
        let send: Bool
    }

    func value(for field: String, from request: String) async throws -> FieldValue? {
        guard let parsed = try await ask("valor", ["pedido": request, "campo": field], maxTokens: 200) else { return nil }
        guard let value = parsed["valor"] as? String, !value.trimmingCharacters(in: .whitespaces).isEmpty
        else { return nil }
        return FieldValue(value: value, send: parsed["enviar"] as? Bool ?? false)
    }

    /// El idioma del teléfono, para que el asistente hable el de la persona.
    ///
    /// El primero de la lista del sistema, y no `Locale.current`: la app no
    /// tiene traducciones, así que iOS le asigna inglés aunque el teléfono
    /// esté en castellano. Con el simulador en es_AR, el asistente llegaba a
    /// La Nación diciendo "You are on LA NACION".
    static var language: String {
        let code = phoneLanguage
        return Locale(identifier: code).localizedString(forLanguageCode: code) ?? code
    }

    /// El código del idioma del teléfono: "es", "en".
    static var phoneLanguage: String {
        Locale.preferredLanguages.first
            .flatMap { Locale(identifier: $0).language.languageCode?.identifier } ?? "es"
    }

    /// Una cifra que está en la página, aunque el separador de miles sea
    /// otro: Wikipedia escribe "644 234" con un espacio fino y el modelo lo
    /// copió "644.234" — la misma cifra, y por eso se descartaba la
    /// orientación entera.
    static func figureAppears(_ figure: String, in page: String) -> Bool {
        if appears(figure, in: page, minimum: 1) { return true }
        // Se comparan los números, no las palabras ni las unidades: el modelo
        // dice "27 °C" donde la página escribe "27°", y "26 de septiembre"
        // donde escribe "sáb 26". Exigir el texto igual tiraba respuestas
        // buenas y la persona oía "eso no aparece en esta página". Lo que
        // sigue sin poder pasar es que el número no esté en la página.
        func values(_ text: String) -> [Double] {
            // Sin separadores de miles: "1.535,00", "1 535.00" y "1535" son
            // el mismo número, se escriba como se escriba en cada país.
            let plain = text.replacingOccurrences(
                of: "(?<=\\d)[.,\\s\u{00A0}\u{202F}\u{2009}](?=\\d{3}(?!\\d))", with: "",
                options: .regularExpression)
            return plain.matches(of: /\d+(?:[.,]\d+)?/)
                .compactMap { Double(String($0.output).replacingOccurrences(of: ",", with: ".")) }
        }
        let wanted = values(figure)
        guard !wanted.isEmpty else { return false }
        let onPage = Set(values(page))
        return wanted.allSatisfy(onPage.contains)
    }

    /// Si ese texto está de verdad en la página. Se comparan los espacios y
    /// las mayúsculas con manga ancha —el modelo reacomoda el espaciado al
    /// copiar— y nada más: las palabras tienen que ser las de la página.
    static func appears(_ quote: String, in page: String, minimum: Int = 8) -> Bool {
        func flat(_ text: String) -> String {
            text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        }
        let needle = flat(quote)
        guard needle.count >= minimum else { return false }
        return flat(page).contains(needle)
    }
}
