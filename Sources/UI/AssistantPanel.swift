import SwiftUI

/// La conversación. Es la app: al abrirla ocupa la pantalla entera, y con
/// una página cargada queda abajo de ella.
///
/// Es la superficie más simple que existe para VoiceOver: una lista de lo
/// dicho y un campo para escribir. La página se carga tal como es; esto es
/// lo único que se le agrega.
struct AssistantPanel: View {
    @Bindable var assistant: Assistant
    var onAsk: (String) -> Void
    var onAccept: (Action) -> Void

    @State private var text = ""
    @FocusState private var writing: Bool
    /// Para llevar el cursor de VoiceOver a lo que sigue cuando terminó de
    /// hablar. Ver `placeFocus`.
    @AccessibilityFocusState private var focused: String?
    /// La cantidad de líneas cuando se puso el cursor por última vez: una
    /// vez por respuesta, no cada vez que algo se mueve.
    @State private var placedAt = 0
    /// Los "Otra cosa" ya atendidos.
    @State private var inputsHandled = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            conversation
            Divider()
            composer
        }
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack {
            Text("Asistente")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if assistant.working {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityLabel("Buscando")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var conversation: some View {
        ScrollViewReader { scroll in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if assistant.turns.isEmpty {
                        Text("JEF es un asistente para usar internet sin ver la pantalla: abre sitios, busca, lee, resume y contesta lo que dicen. Se le puede escribir o dictar un pedido, o tocar uno de estos ejemplos.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(assistant.turns) { turn in
                        line(turn)
                            .id(turn.id)
                            .accessibilityFocused($focused, equals: turn.id)
                    }
                    // Lo que propuso cuando no estuvo seguro: se toca, no se
                    // contesta por voz. Una radio o la página leída en voz
                    // alta pueden decir "sí"; la mano no se confunde.
                    //
                    // Justo debajo de lo que las presenta, y con forma de
                    // fila: con `.bordered` se veían como texto azul
                    // centrado, sueltas, lejos de la frase que las nombraba.
                    if let offer = assistant.offer {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(offer.options) { option in
                                Button {
                                    onAccept(option)
                                } label: {
                                    // Texto oscuro con borde de color, y no
                                    // celeste sobre celeste: con poca vista
                                    // no se leía, y se confundía con los
                                    // globos de la conversación.
                                    HStack(spacing: 10) {
                                        Text(option.label)
                                            .font(.callout.weight(.medium))
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer(minLength: 0)
                                        Image(systemName: "chevron.right")
                                            .font(.footnote.weight(.bold))
                                            .foregroundStyle(.tint)
                                            .accessibilityHidden(true)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(.tint, lineWidth: 1.5)
                                    )
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                // Sin pista: el nombre ya dice qué hace, y
                                // "Va a esta opción" después de cada botón
                                // era una frase más por botón.
                                .accessibilityFocused($focused, equals: "opcion-\(option.id)")
                                // Sólo la primera dice cuántas hay: saber que
                                // hay opciones y cuántas, sin que cada botón
                                // agregue una frase.
                                .accessibilityHint(option.id == offer.options.first?.id && offer.options.count > 1
                                    ? "Primera de \(offer.options.count) opciones." : "")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // "Otra cosa": el cursor va al campo, con el teclado abierto.
            .onChange(of: assistant.inputRequests) { _, _ in
                writing = true
            }
            .onChange(of: assistant.turns.count) { _, _ in
                guard !assistant.turns.isEmpty else { return }
                // La respuesta, desde su comienzo, con los botones debajo.
                // Anclando la ÚLTIMA línea abajo, los botones —que vienen
                // después— quedaban escondidos detrás del campo de escribir:
                // en una portada de La Nación había cuatro y no se veía
                // ninguno. Con VoiceOver se llegaba igual; con poca vista, no.
                if let start = responseStart {
                    withAnimation { scroll.scrollTo(start, anchor: .top) }
                }
            }
            // El cursor, cuando todo se dijo: en la primera opción, que es lo
            // que sigue. Antes iba a la última línea apenas aparecía: cortaba
            // lo que quedaba por decir, y la releía —se escuchaba dos veces—.
            .onChange(of: settled) { _, now in
                guard now else { return }
                Task {
                    // Las opciones se ponen al cerrar el turno, un instante
                    // después de la última línea.
                    try? await Task.sleep(for: .milliseconds(400))
                    placeFocus()
                }
            }
        }
    }

    /// La respuesta terminó y VoiceOver ya dijo todo.
    private var settled: Bool {
        !assistant.inTurn && Habla.shared.pendientes == 0 && !assistant.turns.isEmpty
    }

    private func placeFocus() {
        guard settled, placedAt != assistant.turns.count else { return }
        placedAt = assistant.turns.count
        // "Otra cosa": al campo, a escribir. Con el teclado sólo no alcanzaba:
        // el cursor de VoiceOver se quedaba en la conversación.
        if assistant.inputRequests != inputsHandled {
            inputsHandled = assistant.inputRequests
            focused = "campo"
            return
        }
        if let first = assistant.offer?.options.first {
            focused = "opcion-\(first.id)"
        } else if let last = assistant.turns.last {
            focused = last.id
        }
    }

    /// Dónde empieza la última respuesta: la primera línea de JEF después
    /// de lo último que dijo la persona.
    private var responseStart: String? {
        let turns = assistant.turns
        guard let asked = turns.lastIndex(where: { $0.who == .person }) else { return turns.first?.id }
        return turns.indices.contains(asked + 1) ? turns[asked + 1].id : turns[asked].id
    }

    private func line(_ turn: Assistant.Turn) -> some View {
        let mine = turn.who == .person
        return HStack {
            if mine { Spacer(minLength: 40) }
            Text(turn.text)
                .font(.callout)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    mine ? AnyShapeStyle(.tint.opacity(0.15)) : AnyShapeStyle(Color(.secondarySystemBackground)),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .frame(maxWidth: .infinity, alignment: mine ? .trailing : .leading)
            if !mine { Spacer(minLength: 40) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mine ? "Vos: \(turn.text)" : turn.text)
        // Cada pedido es un encabezado: con el rotor se salta de un pedido al
        // siguiente, en vez de recorrer cada línea de cada respuesta.
        .accessibilityAddTraits(mine ? .isHeader : [])
    }

    private var composer: some View {
        HStack(spacing: 10) {
            // El texto de ayuda más oscuro que el gris de siempre: con poca
            // vista, el gris claro parecía un campo desactivado.
            TextField("Pedido", text: $text, prompt: Text(assistant.awaiting.map { "Escribir: \($0)" } ?? "¿Qué querés hacer?").foregroundStyle(.secondary), axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.plain)
                .focused($writing)
                .accessibilityFocused($focused, equals: "campo")
                .submitLabel(.send)
                .onSubmit(send)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemFill), in: Capsule())
                // Con borde: sin él, con poca vista el campo no se distinguía.
                .overlay(Capsule().strokeBorder(Color.secondary, lineWidth: 1))
                .accessibilityLabel("Pedido")
                .accessibilityHint("Escribí a dónde querés ir. Con el dictado del teclado también se puede hablar.")

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || assistant.working)
            .accessibilityLabel("Enviar")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func send() {
        let goal = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty else { return }
        text = ""
        writing = false
        onAsk(goal)
    }
}
