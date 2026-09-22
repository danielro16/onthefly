import Foundation

/// Los prompts de Gemini, tal como están en `prompts.json`: rol, qué recibe,
/// reglas globales y qué devuelve.
///
/// Lo pidió Daniel (2026-09-22): un prompt es una estructura fija, inmutable
/// a un caso particular. Nunca se repara un caso agregando una frase —así se
/// vuelve una bola gigante—; se arregla en los datos, en el esquema o en el
/// código que verifica. Scripts/prompts_gemini.py los arma igual, para que
/// los tests prueben lo que corre.
struct Prompts: Sendable {
    struct Entrada: Decodable, Sendable {
        let clave: String
        let etiqueta: String
        let es: String
    }

    struct Accion: Decodable, Sendable {
        let accion: String
        let es: String
    }

    struct Prompt: Decodable, Sendable {
        let rol: String
        let paraLaPersona: Bool?
        let recibe: [Entrada]
        let reglas: [String]
        let acciones: [Accion]?
        enum CodingKeys: String, CodingKey { case rol, paraLaPersona = "para_la_persona", recibe, reglas, acciones }
    }

    struct Encabezados: Decodable, Sendable {
        let recibe: String
        let acciones: String
        let reglas: String
        let decisiones: String
    }

    private struct Archivo: Decodable {
        let encabezados: Encabezados
        let comunes: [String]
        let paraLaPersona: [String]
        let prompts: [String: Prompt]
        enum CodingKeys: String, CodingKey { case encabezados, comunes, paraLaPersona = "para_la_persona", prompts }
    }

    let encabezados: Encabezados
    let comunes: [String]
    let paraLaPersona: [String]
    let prompts: [String: Prompt]
    /// El esquema de cada respuesta, ya completo, como JSON.
    private let esquemas: [String: Data]

    static let actuales: Prompts? = {
        guard let url = Bundle.main.url(forResource: "prompts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let archivo = try? JSONDecoder().decode(Archivo.self, from: data),
              let raiz = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let crudos = raiz["prompts"] as? [String: [String: Any]]
        else { return nil }
        // Los tipos de ruido del esquema salen de `criterios.json`.
        let tipos = (try? JSONSerialization.data(withJSONObject: Criterios.actuales?.ruido.tipos ?? []))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        var esquemas: [String: Data] = [:]
        for (nombre, crudo) in crudos {
            guard let devuelve = crudo["devuelve"],
                  let data = try? JSONSerialization.data(withJSONObject: devuelve),
                  let texto = String(data: data, encoding: .utf8)
            else { continue }
            esquemas[nombre] = Data(texto.replacingOccurrences(of: "\"{ruido_tipos}\"", with: tipos).utf8)
        }
        return Prompts(encabezados: archivo.encabezados, comunes: archivo.comunes,
                       paraLaPersona: archivo.paraLaPersona, prompts: archivo.prompts, esquemas: esquemas)
    }()

    /// Rol, qué recibe, acciones si las hay, reglas (las del prompt, las de
    /// hablarle a la persona si corresponde, y las comunes) y las decisiones
    /// de `decisiones.json`.
    func sistema(_ nombre: String, idioma: String, hoy: String = "") -> String {
        guard let p = prompts[nombre] else { return "" }
        let h = encabezados
        var partes = [p.rol, h.recibe + "\n" + p.recibe.map { "- \($0.etiqueta): \($0.es)" }.joined(separator: "\n")]
        if let acciones = p.acciones, !acciones.isEmpty {
            partes.append(h.acciones + "\n" + acciones.map { "- \($0.accion): \($0.es)" }.joined(separator: "\n"))
        }
        let reglas = p.reglas + (p.paraLaPersona == true ? paraLaPersona : []) + comunes
        partes.append(h.reglas + "\n" + reglas.map { "- \($0)" }.joined(separator: "\n"))
        partes.append(h.decisiones + "\n" + Decisiones.lista.map { "- \($0)" }.joined(separator: "\n"))
        let ruido = Criterios.actuales?.ruido
        return partes.joined(separator: "\n\n")
            .replacingOccurrences(of: "{idioma}", with: idioma)
            .replacingOccurrences(of: "{hoy}", with: hoy)
            .replacingOccurrences(of: "{ruido_es}", with: ruido?.es ?? "")
            .replacingOccurrences(of: "{ruido_no_es}", with: ruido?.noEs ?? "")
            .replacingOccurrences(of: "{ruido_tipos}", with: (ruido?.tipos ?? []).joined(separator: ", "))
    }

    /// Los datos, con las etiquetas del prompt y en su orden. Lo vacío no va.
    func mensaje(_ nombre: String, _ valores: [String: String?]) -> String {
        guard let p = prompts[nombre] else { return "" }
        return p.recibe.compactMap { entrada in
            guard let valor = valores[entrada.clave] ?? nil, !valor.isEmpty else { return nil }
            return "\(entrada.etiqueta):\n\(valor)"
        }.joined(separator: "\n\n")
    }

    /// El `response_format`: la forma de la respuesta la garantiza la API, no
    /// el texto del prompt.
    func formato(_ nombre: String) -> [String: Any] {
        guard let data = esquemas[nombre],
              let esquema = try? JSONSerialization.jsonObject(with: data)
        else { return ["type": "json_object"] }
        return ["type": "json_schema", "json_schema": ["name": nombre, "strict": true, "schema": esquema]]
    }
}
