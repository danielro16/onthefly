import Foundation

/// Adónde van las llamadas al modelo de lenguaje del ruteador y del que responde.
///
/// Desde 2026-09-23, GLM-5.3 Flash por el AI Gateway de Vercel (Daniel:
/// "necesito ahorrar costos"). Medido en nueve sitios nuevos, cuesta la mitad
/// que Gemini 3.1 Flash-Lite por paso: US$ 0,0010 contra 0,0020. Para probar
/// otro sin recompilar, el ajuste `modelo` (en el simulador, `simctl spawn
/// <udid> defaults write ai.jef.browser modelo deepseek/deepseek-v4-flash`).
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

    static let base = "zai/glm-5.3-flash"

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
            body["reasoning"] = ["enabled": thinking]
        }
        return body
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
