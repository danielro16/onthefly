import SwiftUI

/// Renders an extracted page as native SwiftUI.
///
/// Two things here are the reason this app is not React Native:
///
/// 1. Inline links inside a paragraph are real, individually focusable
///    accessibility elements (`AttributedString` + `.link`). React Native has
///    had this broken on iOS since 2019 (facebook/react-native#24515, #32004).
/// 2. Custom rotors let VoiceOver users jump by heading or by link, which is
///    how people actually navigate a long page. React Native exposes no API
///    for `UIAccessibilityCustomRotor` at all.
struct ArticleView: View {
    let page: ExtractedPage
    var intentState: ReaderModel.IntentState = .unavailable
    var collapsed: Set<String> = []
    var intentGroups: [IntentGroup] = []
    var listingNames: [String: String] = [:]
    var onChoose: (Intent) -> Void = { _ in }
    var onShowEverything: () -> Void = {}
    var onOpenAction: (Action) -> Void = { _ in }
    var onFillField: (Action.Field, String) -> Void = { _, _ in }
    var onSubmitForm: (Action) -> Void = { _ in }
    var onOpenURL: (String) -> Void = { _ in }
    var onOverlayChoice: (Overlay.Choice) -> Void = { _ in }

    /// Ties each block view to its rotor entries so VoiceOver can jump to it.
    @Namespace private var rotorNamespace

    private var visibleBlocks: [Block] {
        page.blocks.filter { !collapsed.contains($0.id) }
    }

    private var collapsedBlocks: [Block] {
        page.blocks.filter { collapsed.contains($0.id) }
    }

    /// One entry in a VoiceOver rotor.
    ///
    /// `id` only keeps `ForEach` rows distinct. `destination` is what the rotor
    /// actually jumps to and MUST equal the `.id()` of a view in the scroll
    /// content — several links in one paragraph share one destination.
    private struct RotorTarget: Identifiable {
        let id: String
        let destination: String
        let label: String
    }

    private var headings: [RotorTarget] {
        visibleBlocks.compactMap { block in
            guard case .heading(let id, _, let text) = block else { return nil }
            return RotorTarget(id: id, destination: id, label: text)
        }
    }

    private var linkTargets: [RotorTarget] {
        visibleBlocks.flatMap { block -> [RotorTarget] in
            let text = block.plainText
            return block.links.enumerated().compactMap { index, link in
                guard
                    let range = link.range(in: text),
                    let swiftRange = Range(range, in: text)
                else { return nil }
                return RotorTarget(
                    id: "\(block.id)#\(index)",
                    destination: block.id,
                    label: String(text[swiftRange])
                )
            }
        }
    }

    private var imageTargets: [RotorTarget] {
        visibleBlocks.compactMap { block in
            guard case .image(let id, _, let alt, let needsAlt, let caption) = block else { return nil }
            let label = alt.isEmpty ? (caption ?? "") : alt
            return RotorTarget(
                id: id,
                destination: id,
                label: label.isEmpty ? (needsAlt ? "Undescribed image" : "Image") : label
            )
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                header

                // Antes que nada: si algo tapa la página, eso es lo primero
                // que el usuario tiene que resolver.
                if let overlay = page.overlay {
                    OverlayView(overlay: overlay, onChoose: onOverlayChoice)
                }

                intentPanel
                savingsNote

                // Forms come before the goal list: a rebuilt form IS the task
                // on a check-in or booking page, and burying it under a menu
                // would undo the saving.
                ForEach(page.actions.filter { $0.kind == .form && !($0.fields ?? []).isEmpty }) { form in
                    FormView(
                        action: form,
                        onFill: onFillField,
                        onSubmit: { onSubmitForm(form) }
                    )
                }

                if !intentGroups.isEmpty {
                    ActionGroupsView(groups: intentGroups, onOpen: onOpenAction)
                }

                // Listados después de las acciones: en un catálogo el visitante
                // ya eligió qué quiere hacer; acá elige sobre qué.
                ForEach(page.listings) { listing in
                    ListingView(
                        listing: listing,
                        fallbackName: listingNames[listing.id],
                        onOpenURL: onOpenURL
                    )
                }

                ForEach(visibleBlocks) { block in
                    BlockView(block: block)
                        .id(block.id)
                        .accessibilityRotorEntry(id: block.id, in: rotorNamespace)
                }

                collapsedSection
                footer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // System rotors, not custom ones: VoiceOver users already know these,
        // they are localized by the OS, and they sit where people expect them.
        // This is the interaction React Native cannot offer at all.
        .accessibilityRotor(.headings) {
            ForEach(headings) { heading in
                AccessibilityRotorEntry(Text(heading.label), id: heading.destination, in: rotorNamespace)
            }
        }
        .accessibilityRotor(.links) {
            ForEach(linkTargets) { target in
                AccessibilityRotorEntry(Text(target.label), id: target.destination, in: rotorNamespace)
            }
        }
        .accessibilityRotor(.images) {
            ForEach(imageTargets) { target in
                AccessibilityRotorEntry(Text(target.label), id: target.destination, in: rotorNamespace)
            }
        }
        // An inline link carries a real URL, so tapping it would hand the user
        // to Safari — out of the reader and back into the page we just spent
        // the whole app rebuilding. Every link stays inside.
        .environment(\.openURL, OpenURLAction { url in
            onOpenURL(url.absoluteString)
            return .handled
        })
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(page.title)
                .font(.largeTitle.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            if !page.byline.isEmpty {
                Text(page.byline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(page.siteName)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
    }

    /// What the grouping actually saved, stated plainly.
    ///
    /// Shown because a screen-reader user cannot see that the page shrank, and
    /// because keeping the number visible keeps us honest when it stops being
    /// impressive.
    @ViewBuilder
    private var savingsNote: some View {
        let stops = page.stats.originalStops
        let now = (intentGroups.isEmpty ? page.groups.count : intentGroups.count)
            + page.listings.count + visibleBlocks.count
        if stops > 0, now < stops {
            Text("Esta página tenía \(stops) elementos para recorrer. Quedaron \(now).")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    /// The ask.
    ///
    /// This is the product's core move: when Jev's probabilities come back
    /// spread across several intents, we do not pick one — we offer them. For a
    /// screen-reader user this turns a linear hunt through two hundred elements
    /// into a choice between four. Nothing else in a reader does this.
    @ViewBuilder
    private var intentPanel: some View {
        switch intentState {
        case .unavailable, .undecided:
            EmptyView()

        case .detecting:
            HStack(spacing: 10) {
                ProgressView().controlSize(.small)
                Text("Analizando la página…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.updatesFrequently)

        case .asking(let options):
            VStack(alignment: .leading, spacing: 12) {
                Text("¿Qué querés hacer acá?")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Text("Esta página permite varias cosas. Elegí una y la ordeno para eso.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(options) { intent in
                    Button {
                        onChoose(intent)
                    } label: {
                        HStack {
                            Text(intent.label)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHint("Reordena la página para esta tarea")
                }

                Button("Mostrar la página tal cual", action: onShowEverything)
                    .font(.footnote)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .applied(let intent):
            if !collapsed.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.sparkles")
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ordenado para: \(intent.label)")
                            .font(.footnote.weight(.medium))
                        Text("\(collapsed.count) elementos agrupados al final")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Ver todo", action: onShowEverything)
                        .font(.footnote)
                }
                .padding(12)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityElement(children: .contain)
            }
        }
    }

    /// Demoted content.
    ///
    /// Collapsed, never removed. If Jev is wrong — and on an uncalibrated
    /// threshold it sometimes will be — what it demoted is still one tap away,
    /// and still in the accessibility tree.
    @ViewBuilder
    private var collapsedSection: some View {
        if !collapsedBlocks.isEmpty {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(collapsedBlocks) { block in
                        BlockView(block: block)
                            .id(block.id)
                            .accessibilityRotorEntry(id: block.id, in: rotorNamespace)
                    }
                }
                .padding(.top, 12)
            } label: {
                Text("Otros contenidos (\(collapsedBlocks.count))")
                    .font(.subheadline.weight(.medium))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHint("Contenido que no parecía relevante para la tarea elegida")
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if page.stats.truncated || page.stats.unsupported > 0 {
            VStack(alignment: .leading, spacing: 4) {
                Divider()
                if page.stats.truncated {
                    Text("This page was long and was cut short.")
                }
                if page.stats.unsupported > 0 {
                    Text("\(page.stats.unsupported) element(s) could not be simplified yet.")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 12)
        }
    }
}

// MARK: - Blocks

struct BlockView: View {
    let block: Block

    var body: some View {
        switch block {
        case .heading(_, let level, let text):
            Text(text)
                .font(headingFont(level))
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .paragraph(_, let text, let links):
            Text(Self.attributed(text, links: links))
                .font(.body)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .quote(_, let text, let links):
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(.tint)
                    .frame(width: 3)
                Text(Self.attributed(text, links: links))
                    .font(.body.italic())
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quote: \(text)")

        case .list(_, let ordered, let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(ordered ? "\(index + 1)." : "•")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        Text(Self.attributed(item.text, links: item.links))
                            .font(.body)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Item \(index + 1) of \(items.count)")
                }
            }

        case .image(_, let src, let alt, let needsAlt, let caption):
            VStack(alignment: .leading, spacing: 6) {
                AsyncImage(url: URL(string: src)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(height: 160)
                        .overlay(ProgressView())
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                if let caption, !caption.isEmpty {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(imageLabel(alt: alt, caption: caption, needsAlt: needsAlt))
            .accessibilityAddTraits(.isImage)

        case .code(_, let text):
            ScrollView(.horizontal, showsIndicators: true) {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .padding(12)
            }
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Code block")
            .accessibilityValue(text)

        case .separator:
            Divider().accessibilityHidden(true)

        case .table(_, let caption, let headers, let rows, let keyValue):
            TableBlockView(caption: caption, headers: headers, rows: rows, keyValue: keyValue)

        case .unsupported(_, let kind, let text):
            VStack(alignment: .leading, spacing: 4) {
                Label("\(kind.capitalized) — not simplified yet", systemImage: "questionmark.square.dashed")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                if !text.isEmpty {
                    Text(text).font(.callout)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .combine)
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: return .title.weight(.bold)
        case 2: return .title2.weight(.semibold)
        case 3: return .title3.weight(.semibold)
        default: return .headline
        }
    }

    private func imageLabel(alt: String, caption: String?, needsAlt: Bool) -> String {
        if !alt.isEmpty { return alt }
        if let caption, !caption.isEmpty { return caption }
        // v2 fills this in with on-device vision. Saying so is better than a
        // silent unlabeled image, which VoiceOver reads as just "image".
        return needsAlt ? "Image without a description" : "Image"
    }

    /// Builds text with real, focusable inline links.
    ///
    /// `Link.range(in:)` clamps offsets, so malformed ranges from a hostile
    /// page are dropped rather than trusted.
    static func attributed(_ text: String, links: [Link]) -> AttributedString {
        guard !links.isEmpty else { return AttributedString(text) }

        let mutable = NSMutableAttributedString(string: text)
        for link in links {
            guard
                let range = link.range(in: text),
                let url = URL(string: link.href),
                let scheme = url.scheme?.lowercased(),
                scheme == "https" || scheme == "http"
            else { continue }
            mutable.addAttribute(.link, value: url, range: range)
        }
        return AttributedString(mutable)
    }
}
