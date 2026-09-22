import Foundation

/// Las decisiones de Daniel, tal como están en `decisiones.json`. Van en
/// todos los prompts de Gemini: ver `Prompts.sistema`.
///
/// Lo pidió él (2026-09-22): las reglas no van en el código, van en un
/// archivo que se le inyecta al modelo. El código lee la página y hace lo que
/// se decide; decidir es del modelo, con estas reglas.
enum Decisiones {
    static let lista: [String] = {
        guard let url = Bundle.main.url(forResource: "decisiones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = root["decisiones"] as? [String]
        else { return [] }
        return list
    }()

}
