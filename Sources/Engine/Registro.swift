import Foundation
import UIKit

/// Lo que se dice en voz alta.
///
/// Para VoiceOver es exactamente `UIAccessibility.post(.announcement)`. Pasa
/// por acá para que las pruebas sepan qué se habría escuchado: el simulador no
/// corre VoiceOver, y sin esto no hay forma de saber qué oyó alguien ni si un
/// anuncio le cortó la palabra a otro.
@MainActor
enum Voz {
    /// `interrumpir`: corta lo que se esté diciendo en vez de esperar. Para lo
    /// primero que responde a un pedido nuevo: lo anterior ya no importa.
    static func decir(_ text: String, interrumpir: Bool = false) {
        // En cola, no encima. Un anuncio nuevo corta al que se está diciendo,
        // y el asistente dice varias cosas seguidas: medido con el registro,
        // al leer una nota los tres pedazos y "Titular 3 de 4" salían en el
        // mismo instante, y de todo eso sólo se escuchaba el final.
        let queued = NSAttributedString(
            string: text, attributes: [.accessibilitySpeechQueueAnnouncement: !interrumpir]
        )
        if UIAccessibility.isVoiceOverRunning { Habla.shared.empezo(text, cortando: interrumpir) }
        UIAccessibility.post(notification: .announcement, argument: queued)
        Registro.anotar("voz", ["texto": text, "cola": !interrumpir])
    }
}

/// Cuántos anuncios de JEF VoiceOver todavía no terminó de decir.
///
/// Para saber cuándo se puede mover el cursor: moverlo hace que VoiceOver
/// lea el elemento nuevo, y eso corta lo que quedaba en la cola. Con
/// VoiceOver apagado nunca sube de cero.
///
/// Se cuentan sólo los de JEF, por su texto: iOS avisa qué anuncio terminó.
/// Antes se restaba con cualquier aviso de "terminó", la cuenta llegaba a
/// cero con la descripción de la página todavía sonando, el cursor saltaba a
/// los botones y la cortaba (Daniel, en su iPhone).
@MainActor
@Observable
final class Habla {
    static let shared = Habla()
    private(set) var pendientes = 0
    private var sonando: [(id: Int, texto: String)] = []
    private var siguiente = 0

    private init() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.announcementDidFinishNotification, object: nil, queue: .main
        ) { nota in
            let texto = nota.userInfo?[UIAccessibility.announcementStringValueUserInfoKey] as? String
            let completo = nota.userInfo?[UIAccessibility.announcementWasSuccessfulUserInfoKey] as? Bool
            MainActor.assumeIsolated { Habla.shared.termino(texto, completo: completo) }
        }
    }

    /// `cortando`: lo que estaba en cola lo descarta VoiceOver, y no siempre
    /// avisa; se da por terminado.
    func empezo(_ texto: String, cortando: Bool) {
        if cortando { sonando.removeAll() }
        siguiente += 1
        let id = siguiente
        sonando.append((id, texto))
        pendientes = sonando.count
        // Por si iOS nunca avisa: lo que dura dicho, con margen. Sin esto un
        // aviso perdido dejaba el cursor sin moverse nunca.
        let limite = Double(texto.count) / 10 + 5
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(limite))
            Habla.shared.vencio(id)
        }
    }

    func termino(_ texto: String?, completo: Bool?) {
        guard let texto, let indice = sonando.firstIndex(where: { $0.texto == texto }) else { return }
        sonando.remove(at: indice)
        pendientes = sonando.count
        // Si VoiceOver lo dijo entero o lo cortó: es lo que hay que saber.
        Registro.anotar("voz_fin", ["texto": String(texto.prefix(80)), "completo": completo ?? true])
    }

    private func vencio(_ id: Int) {
        guard let indice = sonando.firstIndex(where: { $0.id == id }) else { return }
        sonando.remove(at: indice)
        pendientes = sonando.count
    }
}

/// El registro de una prueba: lo que se dijo, lo que se mostró y lo que se vio.
///
/// Sólo existe en las compilaciones de prueba (DEBUG); en la app que se
/// publica cada llamada es vacía. Escribe una línea JSON por cosa en
/// `Documents/registro.jsonl` del contenedor de la app, que
/// `Scripts/probar-escenarios.py` lee desde la Mac.
@MainActor
enum Registro {
    static func anotar(_ tipo: String, _ datos: [String: Any]) {
        #if DEBUG
        var linea = datos
        linea["tipo"] = tipo
        linea["t"] = Date().timeIntervalSince1970
        guard
            let data = try? JSONSerialization.data(withJSONObject: linea),
            let carpeta = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        let archivo = carpeta.appending(path: "registro.jsonl")
        if !FileManager.default.fileExists(atPath: archivo.path()) {
            FileManager.default.createFile(atPath: archivo.path(), contents: nil)
        }
        guard let handle = try? FileHandle(forWritingTo: archivo) else { return }
        defer { try? handle.close() }
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: data + Data("\n".utf8))
        #endif
    }
}
