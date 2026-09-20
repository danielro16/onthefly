import SwiftUI

/// Cómo se ve una intención, y cómo se ve una tarjeta.
///
/// Vive en la capa de UI a propósito: `Intent` es una taxonomía que Jev
/// responde, y no tiene por qué saber de SwiftUI ni de colores.
///
/// El ícono y el color no son decoración gratuita. Para quien ve poco, un
/// bloque de color es lo que se encuentra antes de poder leer el texto, y
/// para alguien mayor es la diferencia entre buscar y reconocer. Para
/// VoiceOver no cuestan nada: van marcados como decorativos y la parada
/// sigue siendo una sola, la de la tarjeta.
extension Intent {
    var symbol: String {
        switch self {
        case .read:     return "newspaper"
        case .transact: return "cart"
        case .manage:   return "slider.horizontal.3"
        case .lookup:   return "magnifyingglass"
        case .account:  return "person.crop.circle"
        case .support:  return "questionmark.circle"
        case .compare:  return "square.grid.2x2"
        case .info:     return "info.circle"
        }
    }

    var color: Color {
        switch self {
        case .read:     return .blue
        case .transact: return .orange
        case .manage:   return .purple
        case .lookup:   return .indigo
        case .account:  return .teal
        case .support:  return .pink
        case .compare:  return .green
        case .info:     return .gray
        }
    }
}

/// El cuadrado de color con el ícono adentro.
///
/// Escala con el tamaño de texto: a tamaños de accesibilidad un cuadrado de
/// 44 puntos al lado de un título enorme se lee como suciedad en la pantalla.
struct IconBadge: View {
    let symbol: String
    let color: Color
    @ScaledMetric(relativeTo: .headline) private var side: CGFloat = 44

    var body: some View {
        RoundedRectangle(cornerRadius: side / 3.4, style: .continuous)
            .fill(color.gradient)
            .frame(width: side, height: side)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: side * 0.45, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}

/// La tarjeta: el único contenedor de la app.
///
/// Una sola forma repetida es lo que hace que una pantalla se entienda de un
/// vistazo, y lo que hace que el cromo de la app —que NO es una tarjeta— se
/// distinga de lo que la página ofrece.
private struct Card: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06))
            }
    }
}

extension View {
    func jefCard(padding: CGFloat = 16) -> some View { modifier(Card(padding: padding)) }
}
