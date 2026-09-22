import Foundation

/// Los nombres que JEF les pone a los controles que la página dejó sin
/// nombre, por tipo y por idioma, tal como están en `nombres.json`.
///
/// Es la voz de JEF, no la del sitio: lo que la página nombra se respeta tal
/// cual ("Login" es "Login"); lo que no nombra, lo nombra JEF en el idioma de
/// la persona. Un idioma que falta usa el inglés.
enum Nombres {
    private static let catalogo: [String: [String: String]] = {
        guard let url = Bundle.main.url(forResource: "nombres", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let nombres = root["nombres"] as? [String: [String: String]]
        else { return [:] }
        return nombres
    }()

    /// El nombre de un tipo de control (`criterios.json` → controles) en ese
    /// idioma, o en inglés si el catálogo no lo tiene.
    static func de(_ tipo: String, idioma: String) -> String? {
        guard let porIdioma = catalogo[tipo] else { return nil }
        return porIdioma[idioma] ?? porIdioma["en"]
    }
}
