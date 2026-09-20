import SwiftUI

/// Everything the site also offers, as one stop at the end.
///
/// The earlier shape put four goal categories above the page and asked which
/// one you wanted. On a newspaper that is four questions before the news, and
/// on a search engine it is four categories over a box that was already the
/// answer. Categorising a page that was simple makes it worse: google.com has
/// twenty stops to begin with, so there is nothing there to save.
///
/// So the dominant intent decides what leads, and the rest collapses to here.
/// Last in reading order is where "everything else" belongs, and it is one
/// swipe away from the end of the page — VoiceOver's four-finger tap on the
/// bottom half lands on it.
///
/// Esto no es la barra de abajo, y la diferencia es la regla: **lo del sitio
/// va en la página, lo de JEF va en el cromo, y no comparten forma visual.**
/// Una barra fija cuyos ítems cambian en cada sitio no se puede aprender; la
/// de abajo tiene siempre los mismos cinco y por eso puede ser fija.
struct SiteMenuView: View {
    let groups: [IntentGroup]
    var onOpen: (Action) -> Void

    private var total: Int { groups.reduce(0) { $0 + $1.count } }

    var body: some View {
        NavigationLink(value: Route.groups("Más de este sitio", groups)) {
            HStack(spacing: 14) {
                IconBadge(symbol: "ellipsis", color: .gray)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Más de este sitio")
                        .font(.headline)
                    Text("\(total) \(total == 1 ? "opción" : "opciones")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .jefCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Más de este sitio, \(total) \(total == 1 ? "opción" : "opciones")")
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityHint("Abre el resto del sitio en otra pantalla")
    }
}
