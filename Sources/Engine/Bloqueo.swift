import Foundation
import WebKit

/// Las listas de anuncios y rastreadores de la comunidad —EasyList y
/// EasyPrivacy, las mismas que usan Brave y los bloqueadores de Safari—,
/// cargadas en el navegador de JEF.
///
/// Lo pidió Daniel (2026-09-24): identificar los anuncios como lo hace Brave,
/// sin llamar a ningún modelo. No son reglas nuestras: las mantiene una
/// comunidad para millones de sitios, y WebKit las aplica solo, antes de que
/// la página cargue. Lo bloqueado no llega ni a la persona ni al extractor ni
/// al modelo. Atribución y licencia en `Bloqueo/LICENCIA.md`.
@MainActor
enum Bloqueo {
    static let listas = ["easylist", "easyprivacy"]

    /// Compila cada lista la primera vez —WebKit la guarda compilada— o la
    /// trae ya compilada, y la agrega al navegador. En Clarín, con las listas
    /// la página hace la mitad de los pedidos (55 contra 118). Rompían Clarín
    /// por una debilidad nuestra, no de ellas: las esperas del extractor
    /// corren con el reloj de la página, y fuera de pantalla a veces se
    /// estiraban; lo resuelve la red de seguridad de `HeadlessWebView`
    /// (`didFinish`). El ajuste de prueba `bloqueo` en falso las apaga.
    static func cargar(en controller: WKUserContentController) async {
        guard UserDefaults.standard.object(forKey: "bloqueo") as? Bool ?? true,
              let store = WKContentRuleListStore.default() else { return }
        for nombre in listas {
            guard let url = Bundle.main.url(forResource: nombre, withExtension: "json") else { continue }
            // El tamaño identifica la versión: una lista nueva se compila de nuevo.
            let tamaño = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
            let id = "\(nombre)-\(tamaño)"
            if let lista = try? await store.contentRuleList(forIdentifier: id) {
                controller.add(lista)
                continue
            }
            do {
                let json = try String(contentsOf: url, encoding: .utf8)
                if let lista = try await store.compileContentRuleList(forIdentifier: id, encodedContentRuleList: json) {
                    controller.add(lista)
                }
            } catch {
                Registro.anotar("error", ["donde": "bloqueo", "lista": nombre, "detalle": String(describing: error)])
            }
        }
    }
}
