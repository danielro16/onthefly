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
    /// Un cajón del recorrido —el pie del sitio, lo que no dice nada—: su
    /// nombre y los ids de sus paradas. Ver `ExtractedPage.segments(only:)`.
    case entries(String, [String])
}

/// Una opción, como fila.
///
/// Compartida entre la página y las pantallas que se abren desde ella: la
/// misma cosa tiene que sonar igual en los dos lados.
struct ActionRow: View {
    let action: Action
    var uncertain = false
    /// Un titular: se toca como opción y se alcanza como encabezado.
    var isHeading = false
    /// Lo que además se puede hacer con esta opción: "Guardar", en una
    /// receta. Para VoiceOver son acciones de esta misma parada —el rotor de
    /// acciones, como en Mail—; para quien ve, un menú al costado.
    var extras: [Action] = []
    var onOpen: (Action) -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button {
                onOpen(action)
            } label: {
                Self.label(action)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(action.label)
            .accessibilityHint(Self.hint(action, uncertain: uncertain) + extrasHint)
            .accessibilityAddTraits(isHeading ? .isHeader : [])
            .accessibilityActions {
                ForEach(extras) { extra in
                    Button(extra.label) { onOpen(extra) }
                }
            }

            if !extras.isEmpty {
                Menu {
                    ForEach(extras) { extra in
                        Button(extra.label) { onOpen(extra) }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundStyle(.tint)
                        .frame(width: 36, height: 36)
                        .contentShape(.rect)
                }
                // Ya están en la fila, como acciones.
                .accessibilityHidden(true)
            }
        }
    }

    private var extrasHint: String {
        guard !extras.isEmpty else { return "" }
        return " Más acciones: " + extras.map(\.label).joined(separator: ", ") + "."
    }

    /// Cómo se ve una opción, la abra quien la abra.
    static func label(_ action: Action) -> some View {
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

    static func hint(_ action: Action, uncertain: Bool) -> String {
        // Flagging a shaky classification is honest and cheap: the user can
        // decide the label is wrong far faster than we can.
        let doubt = uncertain ? " Puede no corresponder a este grupo." : ""

        switch action.kind {
        case .link:
            // Un link sin destino propio —"Secciones", que abre el menú— se
            // aprieta adentro de la página, como un botón.
            return (action.href == nil ? "Activa este control en la página." : "Abre esta sección.") + doubt
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

/// Opciones seguidas, como lista simple: una tarjeta, una fila por opción.
struct OptionList: View {
    let options: [StreamOption]
    /// Una opción que, en vez de ir a algún lado, abre una pantalla: "Inicio"
    /// en la portada abre la portada.
    var routeFor: (Action) -> Route? = { _ in nil }
    var onOpen: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                if index > 0 { Divider() }
                if let route = routeFor(option.action) {
                    NavigationLink(value: route) {
                        ActionRow.label(option.action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.action.label)
                    .accessibilityHint("Abre la portada, por sección")
                } else {
                    ActionRow(
                        action: option.action, isHeading: option.headingLevel != nil,
                        extras: option.extras, onOpen: onOpen
                    )
                }
            }
        }
        .jefCard()
    }
}

/// Una puerta, dibujada: qué hay detrás y cuánto. Una parada.
struct DoorCard: View {
    let door: StreamDoor

    private var symbol: String {
        switch door.kind {
        case .feed, .section: return "newspaper"
        case .list: return "list.bullet"
        case .arrivals: return "sparkles"
        case .header: return "rectangle.topthird.inset.filled"
        case .menu: return "line.3.horizontal"
        case .footer, .noise: return "ellipsis"
        }
    }

    private var color: Color {
        switch door.kind {
        case .feed, .section: return .blue
        case .arrivals: return .orange
        case .menu: return .indigo
        case .list, .header, .footer, .noise: return .gray
        }
    }

    var body: some View {
        NavigationLink(value: Route.entries(door.title, door.entries)) {
            HStack(spacing: 14) {
                IconBadge(symbol: symbol, color: color)
                VStack(alignment: .leading, spacing: 3) {
                    Text(door.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(door.preview.isEmpty ? door.amount : "\(door.amount) · \(door.preview)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
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
        .accessibilityLabel("\(door.title), \(door.amount)")
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityHint(door.hint)
    }
}

/// Lo que hay detrás de una puerta, en su propia pantalla: las paradas en el
/// orden de la página. Si no entran en una pantalla y la página las trae en
/// secciones, cada sección es otra puerta.
struct EntriesScreen: View {
    let title: String
    let segments: [StreamSegment]
    var onOpen: (Action) -> Void
    var onOpenURL: (String) -> Void
    /// Aprieta el botón que una tarjeta de listado lleva en vez de un link.
    var onActivate: (String) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(segments) { segment in
                    switch segment {
                    case .block(let block):
                        BlockView(block: block)
                    case .options(_, let options):
                        OptionList(options: options, onOpen: onOpen)
                    case .door(let door):
                        DoorCard(door: door)
                    case .listing(let listing):
                        ListingView(
                            listing: listing, startsExpanded: true,
                            onOpenURL: onOpenURL, onActivate: onActivate
                        )
                    case .form:
                        // Un formulario no se guarda detrás de una puerta:
                        // se queda en la página.
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.visible, for: .navigationBar)
        // Un link adentro de un párrafo abre acá, no en Safari.
        .environment(\.openURL, OpenURLAction { url in
            onOpenURL(url.absoluteString)
            return .handled
        })
    }
}
