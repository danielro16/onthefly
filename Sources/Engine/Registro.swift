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
        UIAccessibility.post(notification: .announcement, argument: text)
        Registro.anotar("voz", ["texto": text])
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
