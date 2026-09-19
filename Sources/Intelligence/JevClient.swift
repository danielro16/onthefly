import Foundation

/// Client for the AI Gateway evaluation API (`typesafe-ai/jev`).
///
/// Jev is not a language model: it answers typed questions about a shared state
/// and returns calibrated probabilities. Many questions ride in one request
/// against the same state, which is the cheap path — the state is paid for once.
///
/// - Note: The API key currently ships in the app. That is fine for development
///   and wrong for release: anything in a binary is extractable. Before
///   shipping, calls must go through a backend that holds the key. Tracked in
///   README under "Deuda conocida".
actor JevClient {

    struct Configuration: Sendable {
        var apiKey: String
        var model: String = "typesafe-ai/jev"
        var endpoint = URL(string: "https://ai-gateway.vercel.sh/v1/evaluate")!
        var timeout: TimeInterval = 10
    }

    enum JevError: Error, LocalizedError {
        case missingKey
        case http(Int, String)
        case transport(String)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .missingKey: return "No AI Gateway key configured."
            case .http(let code, let body): return "Gateway returned \(code): \(body)"
            case .transport(let why): return "Network error: \(why)"
            case .decoding(let why): return "Unexpected response: \(why)"
            }
        }
    }

    private let config: Configuration
    private let session: URLSession

    init(configuration: Configuration) {
        self.config = configuration
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        self.session = URLSession(configuration: sessionConfig)
    }

    /// Reads the key from the app's Info.plist (populated by `Secrets.xcconfig`).
    /// Returns nil when no key is present, so the app runs without Jev instead
    /// of crashing — the v0 path stays fully functional.
    static func fromEnvironment() -> JevClient? {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "AIGatewayAPIKey") as? String,
            !key.isEmpty,
            key != "$(AI_GATEWAY_API_KEY)"
        else { return nil }
        return JevClient(configuration: Configuration(apiKey: key))
    }

    // MARK: - Questions

    enum Question: Encodable, Sendable {
        /// Yes/no. Returns a probability.
        case boolean(instructions: String, whenTrue: String? = nil, whenFalse: String? = nil)
        /// One option from a named set. `options` maps name to description.
        case choice(instructions: String, options: [String: String])
        /// Position on an ordered scale. `levels` runs lowest to highest.
        case score(instructions: String, levels: [String])

        private enum CodingKeys: String, CodingKey {
            case type, instructions, criteria
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .boolean(let instructions, let whenTrue, let whenFalse):
                try c.encode("boolean", forKey: .type)
                try c.encode(instructions, forKey: .instructions)
                if let whenTrue, let whenFalse {
                    try c.encode(["true": whenTrue, "false": whenFalse], forKey: .criteria)
                }
            case .choice(let instructions, let options):
                try c.encode("choice", forKey: .type)
                try c.encode(instructions, forKey: .instructions)
                try c.encode(options, forKey: .criteria)
            case .score(let instructions, let levels):
                try c.encode("score", forKey: .type)
                try c.encode(instructions, forKey: .instructions)
                try c.encode(levels, forKey: .criteria)
            }
        }
    }

    // MARK: - Answers

    /// One typed answer.
    ///
    /// `confidence` is how concentrated the distribution is — not how correct
    /// the answer is. A `choice` spread across two acceptable options scores low
    /// confidence without being wrong. Boolean answers carry no confidence: the
    /// probability already says it, and 0.5 means "equally likely", not "medium".
    enum Answer: Sendable {
        case boolean(probability: Double)
        case choice(value: String, probabilities: [String: Double], confidence: Double?)
        case score(value: Double, probabilities: [String: Double], confidence: Double?)

        var confidence: Double? {
            switch self {
            case .boolean: return nil
            case .choice(_, _, let c), .score(_, _, let c): return c
            }
        }
    }

    struct Usage: Sendable {
        let inputTokens: Int
        let outputTokens: Int
    }

    struct Result: Sendable {
        let answers: [String: Answer]
        let usage: Usage?
    }

    // MARK: - Request

    /// Evaluates `questions` against `state` in a single round trip.
    ///
    /// `state` is encoded as-is: pass a String for plain text, or a structure
    /// whose fields questions can reference with backticked paths such as
    /// `` `blocks[3].text` ``.
    func evaluate(state: some Encodable & Sendable, questions: [String: Question]) async throws -> Result {
        guard !config.apiKey.isEmpty else { throw JevError.missingKey }
        guard !questions.isEmpty else { return Result(answers: [:], usage: nil) }

        var request = URLRequest(url: config.endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            Payload(model: config.model, state: state, questions: questions)
        )

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw JevError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw JevError.transport("No HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw JevError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        return try Self.decode(data)
    }

    private struct Payload<State: Encodable>: Encodable {
        let model: String
        let state: State
        let questions: [String: Question]
    }

    // MARK: - Decoding

    /// Hand-rolled because the answer shape is a union keyed on `type`, and an
    /// unknown or malformed entry must drop that one answer rather than fail the
    /// whole page.
    private static func decode(_ data: Data) throws -> Result {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { throw JevError.decoding("Response was not an object") }

        var answers: [String: Answer] = [:]
        if let raw = root["answers"] as? [String: Any] {
            for (key, value) in raw {
                guard
                    let entry = value as? [String: Any],
                    let type = entry["type"] as? String
                else { continue }

                let confidence = entry["confidence"] as? Double
                let probabilities = (entry["probabilities"] as? [String: Any])?
                    .compactMapValues { $0 as? Double } ?? [:]

                switch type {
                case "boolean":
                    if let p = entry["probability"] as? Double {
                        answers[key] = .boolean(probability: p)
                    }
                case "choice":
                    if let choice = entry["choice"] as? String {
                        answers[key] = .choice(
                            value: choice, probabilities: probabilities, confidence: confidence
                        )
                    }
                case "score":
                    if let score = entry["score"] as? Double {
                        answers[key] = .score(
                            value: score, probabilities: probabilities, confidence: confidence
                        )
                    }
                default:
                    continue
                }
            }
        }

        var usage: Usage?
        if let raw = root["usage"] as? [String: Any] {
            usage = Usage(
                inputTokens: raw["inputTokens"] as? Int ?? 0,
                outputTokens: raw["outputTokens"] as? Int ?? 0
            )
        }

        return Result(answers: answers, usage: usage)
    }
}
