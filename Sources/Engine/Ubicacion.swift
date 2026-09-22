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
/// Sólo el país, en dos letras. Ni la ciudad ni las coordenadas salen de
/// acá: para ordenar resultados alcanza, y es lo único que se le manda a un
/// tercero.
@MainActor
final class Ubicacion: NSObject, CLLocationManagerDelegate {
    static let shared = Ubicacion()

    private let manager = CLLocationManager()
    /// El país de la ubicación real, cuando se sabe.
    private(set) var country: String?

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
            Registro.anotar("ubicacion", ["pais": code])
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Sin ubicación queda la región de Ajustes: no hay nada que avisar.
        let reason = error.localizedDescription
        Task { @MainActor in Registro.anotar("ubicacion", ["error": reason]) }
    }
}
