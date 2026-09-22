import Foundation

/// Adónde van las llamadas a Gemini del ruteador y del que responde.
///
/// Con la clave de Google (`GEMINI_API_KEY`), directo a Google con 3.1
/// Flash-Lite: lo decidió Daniel (2026-09-22) — más nuevo que 2.5 y más
/// barato que 2.5 Flash para responder. Sin esa clave, por el AI Gateway de
/// Vercel con los modelos de antes. Jev va siempre por el gateway.
struct Gemini: Sendable {
    let endpoint: URL
    let key: String
    let model: String
    /// Directo a Google: el razonamiento se apaga con otro parámetro.
    let direct: Bool

    /// `gateway`: el modelo que se usa por el gateway si no hay clave de Google.
    static func fromEnvironment(gateway model: String) -> Gemini? {
        if let key = value("GeminiAPIKey", unset: "$(GEMINI_API_KEY)") {
            return Gemini(
                endpoint: URL(string: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions")!,
                key: key, model: "gemini-3.1-flash-lite", direct: true
            )
        }
        if let key = value("AIGatewayAPIKey", unset: "$(AI_GATEWAY_API_KEY)") {
            return Gemini(
                endpoint: URL(string: "https://ai-gateway.vercel.sh/v1/chat/completions")!,
                key: key, model: model, direct: false
            )
        }
        return nil
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
