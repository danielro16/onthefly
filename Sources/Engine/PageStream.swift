import Foundation

/// Una parada del recorrido que `extract.js` hace de la página, de arriba
/// abajo y en el orden en que la página se muestra.
///
/// Los inventarios —`blocks`, `actions`, `listings`— dicen qué hay; esto dice
/// dónde está cada cosa respecto de las demás. Sin eso el login de un diario
/// sólo se podía apilar: todo el texto, después todos los botones, después el
/// formulario, y "ó ingresá con tu email" sonaba antes que los botones de los
/// que es alternativa.
struct StreamEntry: Codable, Sendable, Identifiable {
    let id: String
    /// "block", "action", "link" o "listing". Texto y no enum: un extractor
    /// más nuevo puede mandar un tipo que esta versión no conoce, y una
    /// parada desconocida no puede costar la página entera.
    let kind: String
    /// El landmark donde está: header, nav, main, footer…
    let zone: String
    /// No dice nada: un emoji suelto, una imagen con nombre de archivo, un
    /// botón que el sitio nunca nombró. No se descarta: va aparte.
    let noise: Bool?
    /// Para "action" y "listing": el id de lo que ocupa este lugar.
    let ref: String?
    let block: Block?
    /// Para "link": un destino que la página ofrece fuera de su navegación.
    let label: String?
    let href: String?
    /// Un titular: un link que además es encabezado.
    let level: Int?
    /// Con qué se lista una opción: las que comparten grupo son una lista;
    /// las que sólo se tocan, vecinas. Lo dice el DOM —el contenedor que
    /// repite su forma—, no una cuenta nuestra.
    let group: String?
    /// Los botones que una tarjeta lleva adentro: acciones suyas, por id.
    let extras: [String]?
}

extension Action {
    /// Un destino que la página ofrece fuera de su navegación. No tiene
    /// control detrás: se abre por su dirección.
    static func link(id: String, label: String, href: String, region: String) -> Action {
        Action(
            id: id, kind: .link, label: label, href: href, fields: nil, submit: nil,
            notices: nil, region: region, unnamed: nil, cluster: nil, primary: nil, fresh: nil
        )
    }
}
