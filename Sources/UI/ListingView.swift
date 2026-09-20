import SwiftUI

/// A repeated structure — product grid, article feed, result list — as one
/// collapsed, navigable stop.
///
/// The rule that shapes this view: **each item is exactly one VoiceOver stop,
/// and that stop says everything that matters in the order that matters** —
/// what it is, what it costs, then the rest. A product card left as raw DOM
/// scatters the title, the price, the rating and the image across five or six
/// stops, and the price, which is the one number the visitor came for, arrives
/// detached from the product it belongs to.
struct ListingView: View {
    let listing: Listing
    /// What Jev called it, used only when the page named nothing.
    var fallbackName: String?
    /// Open from the start when this listing IS the page.
    ///
    /// A newspaper's home page is an index, not an article: the headlines are
    /// the content. Collapsed, the whole traversal of lanacion.com.ar was four
    /// closed boxes and the legal imprint — twelve stops without a single
    /// headline, where the real site says "Masivo corte en el AMBA" by stop
    /// eighteen. Shorter is not the goal; getting there is.
    var startsExpanded = false

    var onOpenURL: (String) -> Void

    /// The page's own words beat Jev's category, which beats a bare count.
    private var displayName: String {
        if !listing.title.isEmpty { return listing.title }
        if let fallbackName, !fallbackName.isEmpty { return fallbackName }
        return "Listado de \(listing.count) elementos"
    }

    /// When the name IS the count, saying the count again underneath it —
    /// "Listado de 5 elementos, 5 elementos" — is one stop saying one thing
    /// twice.
    private var named: Bool {
        !listing.title.isEmpty || !(fallbackName ?? "").isEmpty
    }

    @Namespace private var rotorNamespace
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
                            .font(.body.weight(.medium))
                            .multilineTextAlignment(.leading)
                        if named {
                            Text(listing.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: (expanded || startsExpanded) ? "chevron.down" : "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(named ? "\(displayName), \(listing.subtitle)" : displayName)
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityValue((expanded || startsExpanded) ? "expandido" : "contraído")

            if expanded || startsExpanded {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(listing.items.enumerated()), id: \.offset) { index, item in
                        row(item, position: index + 1)
                            .id("\(listing.id)-\(index)")
                            .accessibilityRotorEntry(
                                id: "\(listing.id)-\(index)", in: rotorNamespace
                            )
                        if index < listing.items.count - 1 {
                            Divider().padding(.leading, 4)
                        }
                    }
                }
                .padding(.top, 4)
                // Long lists are where the links rotor earns its keep.
                .accessibilityRotor(.links) {
                    ForEach(Array(listing.items.enumerated()), id: \.offset) { index, item in
                        AccessibilityRotorEntry(
                            Text(item.title), id: "\(listing.id)-\(index)", in: rotorNamespace
                        )
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func row(_ item: Listing.Item, position: Int) -> some View {
        Button {
            if let href = item.href { onOpenURL(href) }
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.callout)
                    .multilineTextAlignment(.leading)

                if let price = item.price {
                    Text(price)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.tint)
                }

                if let meta = item.meta, !meta.isEmpty {
                    Text(meta)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
        .disabled(item.href == nil)
        // One element, one utterance. Position matters on a long list: it is
        // the only way to know how far in you are without counting swipes.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(position) de \(listing.items.count). \(item.spokenLabel)")
        .accessibilityHint(item.href == nil ? "" : "Abre este elemento")
        .accessibilityAddTraits(item.href == nil ? [] : [.isButton])
    }
}
