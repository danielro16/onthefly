import Foundation

/// Adónde van las llamadas al modelo de lenguaje del ruteador y del que responde.
///
/// Desde 2026-09-24, GPT-6 Luna por el AI Gateway de Vercel (Daniel). En los
/// mismos nueve sitios, contra GLM-5.3 Flash (el base desde el 23/9): el
/// ruteador razonando acierta 49 de 60 contra 47, sin JSON roto, y un paso
/// cuesta ~US$ 0,00076 contra 0,00108. Sin razonar, el ruteador de Luna a veces
/// deja texto después del JSON: por eso `razonar` sigue prendido. OpenAI
/// rechaza el esquema si un objeto no trae `additionalProperties: false`
/// (prompts.json). Para probar otro sin recompilar, el ajuste `modelo` (en el
/// simulador, `simctl spawn <udid> defaults write ai.jef.browser modelo
/// zai/glm-5.3-flash`).
/// Un nombre que empieza con "gemini-" va directo a Google con su clave. Jev va
/// siempre por el gateway.
struct Gemini: Sendable {
    let endpoint: URL
    let key: String
    let model: String
    /// Directo a Google: el razonamiento se apaga con otro parámetro.
    let direct: Bool
    /// Si el ruteador puede razonar. El ajuste `razonar` en falso lo apaga:
    /// Qwen 3.8 Flash razonando tardaba 18 s por decisión, y sin razonar
    /// acertaba más (52 de 60 contra 40).
    var reasons = UserDefaults.standard.object(forKey: "razonar") as? Bool ?? true

    static let base = "openai/gpt-6-luna"

    /// Cuánto texto de la página ven los que deciden: el ruteador, la
    /// orientación y reinterpretar, el mismo para todos. La orientación veía
    /// la página entera (hasta 23.000 letras en Clarín) y el ruteador 6.000:
    /// el que entiende a la persona veía menos que el que describe. Con el
    /// mapa de la página aparte, alcanza; en una portada grande ahorra la
    /// mitad de la orientación. Contestar y resumir leen la página entera: la
    /// respuesta puede estar al final.
    static let pageLimit = 6000

    static func fromEnvironment() -> Gemini? {
        let chosen = UserDefaults.standard.string(forKey: "modelo") ?? base
        if chosen.hasPrefix("gemini-"), let key = value("GeminiAPIKey", unset: "$(GEMINI_API_KEY)") {
            return Gemini(
                endpoint: URL(string: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions")!,
                key: key, model: chosen, direct: true
            )
        }
        guard let key = value("AIGatewayAPIKey", unset: "$(AI_GATEWAY_API_KEY)") else { return nil }
        return Gemini(
            endpoint: URL(string: "https://ai-gateway.vercel.sh/v1/chat/completions")!,
            key: key, model: chosen, direct: false
        )
    }

    private static func value(_ name: String, unset: String) -> String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: name) as? String,
              !key.isEmpty, key != unset
        else { return nil }
        return key
    }

    /// El pedido con el modelo y con razonamiento o sin él.
    ///
    /// `thinking` sólo para entender qué quiere la persona, que es donde
    /// Daniel lo pidió: medido, cuesta 0,4 s más (1,0 contra 1,4 s) y decide
    /// igual o mejor. Para redactar una respuesta no se usa: se midió con
    /// Flash que gastaba 481 de 500 tokens pensando y devolvía el JSON
    /// cortado.
    func body(_ body: [String: Any], thinking: Bool = false) -> [String: Any] {
        var body = body
        body["model"] = model
        let thinking = thinking && reasons
        if direct {
            body["reasoning_effort"] = thinking ? "low" : "none"
        } else {
            // Poco, como directo a Google. Prendido sin más, Luna razonaba
            // hasta gastar los 1.000 tokens del ruteador y no contestaba nada
            // (Trenitalia: 2 de 5, hasta 12,7 s); con "low", 5 de 5 en 3,6–5,5
            // s y la misma decisión.
            body["reasoning"] = thinking ? ["effort": "low"] : ["enabled": false]
        }
        return body
    }

    /// Si un pedido que falló es falta de red. Un modelo que tarda más de lo
    /// que se lo espera también corta el pedido, y eso no es la red: el
    /// ruteador, razonando, pasó los 15 s en 3 de 111 pedidos medidos, y la
    /// persona oía «Sin conexión» con internet andando.
    static func offline(_ error: Error) -> Bool {
        guard let error = error as? URLError else { return false }
        let network: [URLError.Code] = [
            .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost,
            .dnsLookupFailed, .dataNotAllowed, .internationalRoamingOff, .callIsActive,
        ]
        return network.contains(error.code)
    }

    /// El objeto JSON de una respuesta: el primero completo. GPT-6 Luna, sin
    /// razonar, a veces deja texto después del objeto (medido al cambiar de
    /// modelo), y leído entero no era JSON: la orientación se descartaba y
    /// quedaba la plantilla (tres veces en La Vanguardia).
    static func object(in content: String) -> [String: Any]? {
        if let whole = try? JSONSerialization.jsonObject(with: Data(content.utf8)) as? [String: Any] { return whole }
        guard let start = content.firstIndex(of: "{") else { return nil }
        var depth = 0, inString = false, escaped = false
        for index in content[start...].indices {
            let character = content[index]
            if inString {
                if escaped { escaped = false } else if character == "\\" { escaped = true } else if character == "\"" { inString = false }
                continue
            }
            if character == "\"" { inString = true }
            else if character == "{" { depth += 1 }
            else if character == "}" {
                depth -= 1
                if depth == 0 { return try? JSONSerialization.jsonObject(with: Data(content[start...index].utf8)) as? [String: Any] }
            }
        }
        return nil
    }

    func request(_ body: [String: Any], thinking: Bool = false) throws -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: self.body(body, thinking: thinking))
        return request
    }
}
