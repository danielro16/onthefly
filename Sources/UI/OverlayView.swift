import SwiftUI

/// The blocking overlay, presented as the first thing on the page.
///
/// Ordering is the whole point. A cookie banner or a paywall is what a sighted
/// visitor deals with before anything else, because they can see the page
/// greyed out behind it. Left in DOM order, its buttons scatter among the
/// page's own controls and a screen-reader user works through the page for a
/// while before discovering that nothing responds.
///
/// **The app never chooses for the user.** Accepting terms, picking cookie
/// preferences or paying for a subscription are decisions that belong to the
/// person, not to a reader that happens to be in the way. This view names what
/// the overlay is, offers its real choices, and carries the original text so
/// the user can judge rather than trust our label.
struct OverlayView: View {
    let overlay: Overlay
    var onChoose: (Overlay.Choice) -> Void

    @State private var showingOriginal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(overlay.kind.title)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text(overlay.kind.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if !overlay.choices.isEmpty {
                VStack(spacing: 8) {
                    ForEach(overlay.choices) { choice in
                        Button {
                            onChoose(choice)
                        } label: {
                            Text(choice.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(.background, in: RoundedRectangle(cornerRadius: 9))
                        .accessibilityHint("Responde el aviso de la página")
                    }
                }
            }

            // The overlay's own words, verbatim. Our category is a guess; this
            // is what the page actually said, and a decision about consent
            // should not rest on our paraphrase.
            DisclosureGroup(isExpanded: $showingOriginal) {
                Text(overlay.text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            } label: {
                Text("Ver el texto original")
                    .font(.footnote)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
    }
}
