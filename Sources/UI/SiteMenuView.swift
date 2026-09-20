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
/// bottom half lands on it. A fixed bottom bar was the alternative and loses
/// on two counts: it breaks at accessibility text sizes, and a bar whose items
/// change per site gives up the predictability that makes a bar worth its
/// screen space.
struct SiteMenuView: View {
    let groups: [IntentGroup]
    var onOpen: (Action) -> Void

    @State private var open = false

    private var total: Int { groups.reduce(0) { $0 + $1.count } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { open.toggle() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Más de este sitio")
                            .font(.body.weight(.medium))
                        Text("\(total) \(total == 1 ? "opción" : "opciones")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: open ? "chevron.down" : "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Más de este sitio, \(total) \(total == 1 ? "opción" : "opciones")")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityValue(open ? "expandido" : "contraído")
            .accessibilityHint(open ? "Tocá dos veces para contraer" : "Tocá dos veces para ver el resto del sitio")

            if open {
                ActionGroupsView(groups: groups, title: nil, onOpen: onOpen)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }
}
