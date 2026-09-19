import SwiftUI

/// The page, presented as goals.
///
/// One list, ordered by how likely each goal is what the user came for. There
/// is no separate "what do you want to do?" panel any more: asking and showing
/// were two shapes for the same thing, and merging them means a person hears
/// one structure instead of two.
///
/// Group titles are goals a person would recognise — "Comprar o reservar",
/// "Gestionar lo que ya tengo" — never DOM categories. An earlier version
/// grouped by landmark and produced "Pie de página", which is a fact about the
/// HTML and not about anything the user wants.
///
/// Each title carries `.isHeader`, so every goal is a stop in VoiceOver's
/// headings rotor. aerolineas.com.ar declares one heading of its own.
struct ActionGroupsView: View {
    let groups: [IntentGroup]
    var onOpen: (Action) -> Void

    @Namespace private var rotorNamespace
    @State private var expanded: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Qué querés hacer?")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            ForEach(groups) { group in
                section(group)
                    .id(group.id)
                    .accessibilityRotorEntry(id: group.id, in: rotorNamespace)
            }
        }
        .accessibilityRotor(.headings) {
            ForEach(groups) { group in
                AccessibilityRotorEntry(Text(group.label), id: group.id, in: rotorNamespace)
            }
        }
    }

    @ViewBuilder
    private func section(_ group: IntentGroup) -> some View {
        let isOpen = expanded.contains(group.id)

        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isOpen { expanded.remove(group.id) } else { expanded.insert(group.id) }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.label)
                            .font(.body.weight(.medium))
                        Text("\(group.count) \(group.count == 1 ? "opción" : "opciones")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            // The collapsed goal is ONE stop. That is where the saving comes
            // from: 194 stops become one per goal.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(group.label), \(group.count) \(group.count == 1 ? "opción" : "opciones")")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityValue(isOpen ? "expandido" : "contraído")
            .accessibilityHint(isOpen ? "Tocá dos veces para contraer" : "Tocá dos veces para ver las opciones")

            if isOpen {
                VStack(alignment: .leading, spacing: 2) {
                    // Forms render as real forms above; listing them here too
                    // would be the same task twice.
                    ForEach(group.actions.filter { $0.kind != .form || ($0.fields ?? []).isEmpty }) { action in
                        row(action, uncertain: group.uncertain.contains(action.id))
                    }
                }
                .padding(.leading, 10)
                .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func row(_ action: Action, uncertain: Bool) -> some View {
        Button {
            onOpen(action)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: action.kind == .link ? "arrow.up.right" : "hand.tap")
                    .font(.caption)
                    .foregroundStyle(.tint)
                    .frame(width: 16)
                    .accessibilityHidden(true)
                Text(action.label)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.label)
        .accessibilityHint(hint(action, uncertain: uncertain))
    }

    private func hint(_ action: Action, uncertain: Bool) -> String {
        // Flagging a shaky classification is honest and cheap: the user can
        // decide the label is wrong far faster than we can.
        let doubt = uncertain ? " Puede no corresponder a este grupo." : ""

        switch action.kind {
        case .link:
            return "Abre esta sección." + doubt
        case .form:
            guard let fields = action.fields, !fields.isEmpty else {
                return "Abre el formulario." + doubt
            }
            return "Formulario con \(fields.count) campos: "
                + fields.map(\.name).joined(separator: ", ") + "." + doubt
        case .button:
            // Pressed inside the live page, which is the only way a rebuilt
            // view can honour a control whose behaviour is the page's own
            // JavaScript.
            return "Activa este control en la página." + doubt
        }
    }
}
