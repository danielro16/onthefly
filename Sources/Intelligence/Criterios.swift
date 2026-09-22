import Foundation

/// Los criterios con que JEF juzga una página, tal como están en
/// `criterios.json`: qué es ruido, las preguntas a Jev y sus umbrales.
///
/// Lo acordó Daniel (2026-09-22): el código no lee palabras de la página ni
/// inventa umbrales. Un criterio nuevo va en el archivo, que también lee
/// Scripts/probar-jev.py: lo que se prueba es lo que corre, y los umbrales
/// salen de medir con ese banco.
struct Criterios: Decodable, Sendable {
    struct Ruido: Decodable, Sendable {
        let es: String
        let noEs: String
        /// Los tipos de ruido: cada marca tiene que decir cuál, y lo que no
        /// entra en ninguno no es ruido. Sin tipos, Gemini a veces marcaba lo
        /// que no servía para ESTE pedido —«BNA Digital» cuando se pedía el
        /// home banking— y quedaba sin sugerir en esa página para siempre.
        var tipos: [String] = []
        enum CodingKeys: String, CodingKey { case es, noEs = "no_es", tipos }

        init(es: String, noEs: String, tipos: [String] = []) {
            self.es = es
            self.noEs = noEs
            self.tipos = tipos
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            es = try c.decode(String.self, forKey: .es)
            noEs = try c.decode(String.self, forKey: .noEs)
            tipos = try c.decodeIfPresent([String].self, forKey: .tipos) ?? []
        }
    }

    struct Pregunta: Decodable, Sendable {
        let instructions: String
        let criteria: [String: String]?
    }

    /// Qué tipo es un control sin nombre: la pregunta a Jev y los tipos, con
    /// lo que significa cada uno. El nombre sale de `nombres.json`.
    struct Controles: Decodable, Sendable {
        let pregunta: String
        let tipos: [String: String]
    }

    let datos: String
    let ruido: Ruido
    let controles: Controles?
    let jev: [String: Pregunta]
    let umbrales: [String: Double]
    let esperaJevMs: Int

    enum CodingKeys: String, CodingKey {
        case datos, ruido, controles, jev, umbrales, esperaJevMs = "espera_jev_ms"
    }

    /// Los del archivo. Sin archivo, nil: quien pregunta decide qué hacer
    /// sin criterio, y lo seguro es preguntarle a la persona.
    static let actuales: Criterios? = {
        guard let url = Bundle.main.url(forResource: "criterios", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(Criterios.self, from: data)
    }()

    /// Cuánto se espera a Jev antes de seguir sin él: la carrera.
    var esperaJev: Duration { .milliseconds(esperaJevMs) }
}
