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
    static func decir(_ text: String) {
        // En cola, no encima. Un anuncio nuevo corta al que se está diciendo,
        // y el asistente dice varias cosas seguidas: medido con el registro,
        // al leer una nota los tres pedazos y "Titular 3 de 4" salían en el
        // mismo instante, y de todo eso sólo se escuchaba el final.
        let queued = NSAttributedString(
            string: text, attributes: [.accessibilitySpeechQueueAnnouncement: true]
        )
        if UIAccessibility.isVoiceOverRunning { Habla.shared.empezo() }
        UIAccessibility.post(notification: .announcement, argument: queued)
        Registro.anotar("voz", ["texto": text, "cola": true])
    }
}

/// Cuántos anuncios VoiceOver todavía no terminó de decir.
///
/// Para saber cuándo se puede mover el cursor: moverlo hace que VoiceOver
/// lea el elemento nuevo, y eso corta lo que quedaba en la cola. Con
/// VoiceOver apagado nunca sube de cero.
@MainActor
@Observable
final class Habla {
    static let shared = Habla()
    private(set) var pendientes = 0

    private init() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.announcementDidFinishNotification, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { Habla.shared.termino() }
        }
    }

    func empezo() { pendientes += 1 }
    func termino() { pendientes = max(0, pendientes - 1) }
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
