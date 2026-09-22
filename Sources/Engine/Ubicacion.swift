import CoreLocation
import Foundation
import MapKit

/// El país desde donde se usa JEF, para que el buscador dé resultados de ahí.
///
/// Es lo que hace cualquier buscador: busca desde donde estás. Daniel lo
/// decidió así (2026-09-22): primero la ubicación real, con el permiso que el
/// sistema pide una sola vez; si la persona no lo da, la región de Ajustes.
/// Sin modelo y sin listas: quien quiere algo de otro país lo escribe —"banco
/// galicia argentina"—, como en cualquier buscador.
///
/// El país, en dos letras, va al buscador. La ciudad la recibe el modelo que
/// decide qué hacer, para las búsquedas que dependen del lugar: con "tiempo
/// mañana" y sólo el país, desde Miami salía el clima de España. Las
/// coordenadas no salen de acá.
@MainActor
final class Ubicacion: NSObject, CLLocationManagerDelegate {
    static let shared = Ubicacion()

    private let manager = CLLocationManager()
    /// El país de la ubicación real, cuando se sabe.
    private(set) var country: String?
    /// Dónde está la persona, dicho como un lugar: "Miami, Florida, Estados
    /// Unidos". Nil sin permiso de ubicación.
    private(set) var place: String?

    /// El país para buscar: el de la ubicación, o el de Ajustes.
    static var countryForSearch: String? {
        shared.country ?? Locale.current.region?.identifier
    }

    override private init() {
        super.init()
        manager.delegate = self
        // Para saber el país sobra con una ubicación gruesa: gasta menos
        // batería y no hace falta precisión.
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    /// Pide el permiso si todavía no se pidió, y la ubicación si hay permiso.
    func start() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default: break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.start() }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            guard let request = MKReverseGeocodingRequest(location: location),
                  let places = try? await request.mapItems,
                  let code = places.first?.addressRepresentations?.region?.identifier
            else {
                Registro.anotar("ubicacion", ["pais": "sin resultado"])
                return
            }
            self.country = code
            let address = places.first?.addressRepresentations
            self.place = [address?.cityWithContext, address?.regionName]
                .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
            Registro.anotar("ubicacion", ["pais": code])
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Sin ubicación queda la región de Ajustes: no hay nada que avisar.
        let reason = error.localizedDescription
        Task { @MainActor in Registro.anotar("ubicacion", ["error": reason]) }
    }
}
