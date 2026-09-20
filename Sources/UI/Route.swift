import SwiftUI

/// A dónde lleva tocar una caja.
///
/// Una categoría no se despliega dentro de la página: **abre una pantalla**.
/// Desplegar deja al usuario en el mismo lugar con la página crecida debajo
/// —y con VoiceOver, con el cursor en el medio de algo que cambió de tamaño—;
/// abrir es el gesto que iOS ya enseñó, con su "atrás" en el lugar de
/// siempre. Además una pantalla puede decir su nombre, y un desplegable no.
enum Route: Hashable {
    /// Las opciones de un grupo, con el nombre del grupo por título.
    case options(String, [Action])
    /// Varias categorías juntas, cada una con su propia pantalla detrás.
    case groups(String, [IntentGroup])
    /// Todo lo que la portada lista, en el orden del sitio.
    case headlines
}

/// Una opción, como fila.
///
/// Compartida entre la página y las pantallas que se abren desde ella: la
/// misma cosa tiene que sonar igual en los dos lados.
struct ActionRow: View {
    let action: Action
    var uncertain = false
    var onOpen: (Action) -> Void

    var body: some View {
        Button {
            onOpen(action)
        } label: {
            HStack(spacing: 10) {
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
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.label)
        .accessibilityHint(Self.hint(action, uncertain: uncertain))
    }

    static func hint(_ action: Action, uncertain: Bool) -> String {
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

/// Varias categorías, en su propia pantalla.
///
/// **Una pantalla nunca muestra otra caja.** Abrir una tarjeta para encontrar
/// otra tarjeta, que hay que abrir para recién ver las opciones, es ruido que
/// ponemos nosotros: tres toques para llegar a una lista que entraba entera
/// en la primera. Acá las categorías son encabezados —que el rotor de
/// VoiceOver sabe recorrer— y debajo de cada uno están sus opciones.
struct GroupsScreen: View {
    let title: String
    let groups: [IntentGroup]
    var onOpen: (Action) -> Void

    @Namespace private var rotorNamespace

    private func options(_ group: IntentGroup) -> [Action] {
        group.actions.filter { $0.kind != .form || ($0.fields ?? []).isEmpty }
    }

    /// Con una sola categoría, su nombre ya es el título de la pantalla.
    private var named: Bool { groups.count > 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(groups) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        if named {
                            Text(group.label)
                                .font(.title3.weight(.semibold))
                                .accessibilityAddTraits(.isHeader)
                                .id(group.id)
                                .accessibilityRotorEntry(id: group.id, in: rotorNamespace)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(options(group).enumerated()), id: \.element.id) { index, action in
                                if index > 0 { Divider() }
                                ActionRow(action: action, onOpen: onOpen)
                            }
                        }
                        .jefCard()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .accessibilityRotor(.headings) {
            ForEach(groups) { group in
                AccessibilityRotorEntry(Text(group.label), id: group.id, in: rotorNamespace)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.visible, for: .navigationBar)
    }
}

/// Las opciones de una categoría, en su propia pantalla.
struct OptionsScreen: View {
    let title: String
    let actions: [Action]
    var onOpen: (Action) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    if index > 0 { Divider() }
                    ActionRow(action: action, onOpen: onOpen)
                }
            }
            .jefCard()
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.visible, for: .navigationBar)
    }
}
