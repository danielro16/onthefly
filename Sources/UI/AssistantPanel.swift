import SwiftUI

/// La conversación, abajo de la página.
///
/// Es la superficie más simple que existe para VoiceOver: una lista de lo
/// dicho y un campo para escribir. Sin rotores, sin grupos, sin puertas —
/// nada de lo que una página reconstruida necesita. La página se carga tal
/// como es; esto es lo único que se le agrega.
struct AssistantPanel: View {
    @Bindable var assistant: Assistant
    var onAsk: (String) -> Void
    var onAccept: (Action) -> Void
    var onClose: () -> Void

    @State private var text = ""
    @FocusState private var writing: Bool
    /// Para llevar el cursor de VoiceOver a la última respuesta: un anuncio
    /// se pierde si VoiceOver estaba hablando, una parada no.
    @AccessibilityFocusState private var focused: String?

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
            Button("Cerrar", action: onClose)
                .font(.subheadline)
                .accessibilityHint("Vuelve a la página")
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
                        Text("Decime a dónde querés ir, o preguntame sobre esta página. Por ejemplo: «llevame a deportes», «¿a cuánto está el dólar?».")
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
                    if let offer = assistant.offer {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(offer.options) { option in
                                Button {
                                    onAccept(option)
                                } label: {
                                    Text(option.label)
                                        .font(.callout)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)
                                .accessibilityHint("Va a esta opción")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: assistant.turns.count) { _, _ in
                guard let last = assistant.turns.last else { return }
                withAnimation { scroll.scrollTo(last.id, anchor: .bottom) }
                // Sólo cuando terminó de hablar: mover el cursor en medio de
                // una respuesta corta lo que se estaba diciendo.
                if !assistant.working { focused = last.id }
            }
        }
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
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("¿Qué querés hacer?", text: $text, axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.plain)
                .focused($writing)
                .submitLabel(.send)
                .onSubmit(send)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemFill), in: Capsule())
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
