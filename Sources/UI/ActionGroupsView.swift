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
/// Cada caja **abre una pantalla**; no se despliega. Ver [Route].
///
/// Each title carries `.isHeader`, so every goal is a stop in VoiceOver's
/// headings rotor. aerolineas.com.ar declares one heading of its own.
struct ActionGroupsView: View {
    let groups: [IntentGroup]
    /// Nil when the surrounding view already says what this list is. Asking
    /// "¿Qué querés hacer?" above a single group that Jev already chose is a
    /// question with one answer.
    var title: String? = "¿Qué querés hacer?"
    /// The goal that leads the page opens by itself: it is the answer, not one
    /// option among several. Entonces se muestra acá mismo, abierto, en vez de
    /// esconderse detrás de una pantalla más.
    var expandedByDefault = false
    var onOpen: (Action) -> Void

    @Namespace private var rotorNamespace

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 4)
            }

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

    /// Lo que hay adentro, con las palabras del sitio.
    ///
    /// Sólo visual: la parada de VoiceOver sigue siendo "el grupo, N
    /// opciones", que es corta y dice lo mismo. Para quien ve, esta línea es
    /// el vistazo que la lectura lineal no da — y es información que la
    /// página ya tenía, no una etiqueta nuestra.
    private func preview(_ group: IntentGroup) -> String {
        let count = "\(group.count) \(group.count == 1 ? "opción" : "opciones")"
        let names = group.actions.prefix(3)
            .map { $0.label.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !names.isEmpty else { return count }
        return "\(count) · \(names.joined(separator: ", "))"
    }

    /// Forms render as real forms above; listing them here too would be the
    /// same task twice.
    private func options(_ group: IntentGroup) -> [Action] {
        group.actions.filter { $0.kind != .form || ($0.fields ?? []).isEmpty }
    }

    @ViewBuilder
    private func section(_ group: IntentGroup) -> some View {
        if expandedByDefault {
            // Lo que lidera la página ya es la respuesta: mostrarlo detrás de
            // un toque sería esconder aquello a lo que la persona vino.
            VStack(alignment: .leading, spacing: 6) {
                heading(group, opens: false)
                Divider().padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(options(group)) { action in
                        ActionRow(
                            action: action,
                            uncertain: group.uncertain.contains(action.id),
                            onOpen: onOpen
                        )
                    }
                }
            }
            .jefCard()
        } else {
            NavigationLink(value: Route.options(group.label, options(group))) {
                heading(group, opens: true)
            }
            .buttonStyle(.plain)
            .jefCard()
            // The collapsed goal is ONE stop. That is where the saving comes
            // from: 194 stops become one per goal.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(group.label), \(group.count) \(group.count == 1 ? "opción" : "opciones")")
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityHint("Abre sus opciones en otra pantalla")
        }
    }

    private func heading(_ group: IntentGroup, opens: Bool) -> some View {
        HStack(spacing: 14) {
            IconBadge(symbol: group.intent.symbol, color: group.intent.color)
            VStack(alignment: .leading, spacing: 3) {
                Text(group.label)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(preview(group))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            if opens {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .contentShape(.rect)
    }
}
