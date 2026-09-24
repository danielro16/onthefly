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
    /// trae ya compilada, y la agrega al navegador.
    ///
    /// Apagadas hasta saber por qué rompen Clarín: con cualquiera de las dos,
    /// Clarín falló o tardó más de 20 s en 5 de 6 cargas, y sin ellas cargó
    /// en 4,5 s todas las veces. El ajuste de prueba `bloqueo` las prende.
    /// Medido en 6 páginas: en los diarios lo que lee el modelo casi no
    /// cambia (sus anuncios viven en marcos que el extractor ya no leía); en
    /// Google sacan 2 de 3 anuncios y el texto se achica un tercio.
    static func cargar(en controller: WKUserContentController) async {
        guard UserDefaults.standard.object(forKey: "bloqueo") as? Bool ?? false,
              let store = WKContentRuleListStore.default() else { return }
        // En las pruebas, `bloqueo_solo` carga una sola lista: para saber cuál
        // rompe un sitio.
        let solo = UserDefaults.standard.string(forKey: "bloqueo_solo")
        for nombre in listas where solo == nil || solo == nombre {
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
