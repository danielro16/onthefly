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
    /// Cerrar el asistente y dejar la página entera a la vista. Nil sin
    /// página: antes de la primera carga no hay nada que mirar.
    var onClose: (() -> Void)?
    /// Arrastrar la parte de arriba sube, baja o cierra el panel. Nil a
    /// pantalla completa, sin página detrás.
    var onDrag: ((DragGesture.Value, _ ended: Bool) -> Void)?
    /// Cerrado sigue armado, invisible: la conversación y hasta dónde se
    /// leyó quedan como estaban para cuando se vuelva a abrir.
    var isOpen = true

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
    /// Los "Ir a la prueba" ya atendidos.
    @State private var pageFocusHandled = 0

    var body: some View {
        // Cerrado, VoiceOver no lo recorre. Por partes y no sobre el panel
        // entero: puesto ahí, abierto valía `false` y destapaba la manija,
        // que VoiceOver no tiene que tocar.
        VStack(spacing: 0) {
            header
            // Se desvanece en los bordes en vez de cortarse en seco. No pasa
            // por debajo del título ni del campo: detrás de ellos, borroso,
            // era ruido, y VoiceOver leía el campo antes que la conversación.
            conversation
                .mask {
                    VStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom).frame(height: 14)
                        Color.black
                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom).frame(height: 14)
                    }
                }
                .accessibilityHidden(!isOpen)
            composer
                .accessibilityHidden(!isOpen)
        }
        // Reabierto, el cursor va a lo último que se dijo: es lo que la
        // persona vino a buscar.
        .onChange(of: isOpen) { _, open in
            guard open else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                if let first = assistant.offer?.options.first {
                    focused = "opcion-\(first.id)"
                } else if let last = assistant.turns.last {
                    focused = last.id
                }
            }
        }
    }

    private var header: some View {
        HStack {
            // Cerrado, oculto pieza por pieza: sobre la fila entera, el
            // título tomaba el ancho de la fila.
            Text("Asistente")
                .font(.headline)
                .allowsHitTesting(false)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHidden(!isOpen)
            Spacer()
            if assistant.working {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityLabel("Buscando")
                    .accessibilityHidden(!isOpen)
            }
            // Volvió: sin él no había cómo usar la página misma —resolver una
            // prueba anti-robot, escribir una contraseña—. Lo marcó Daniel.
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                        // Sin forma, un botón liso sólo se toca sobre el
                        // dibujo: la cruz, no el círculo. Así no andaba.
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel("Cerrar el asistente")
                .accessibilityHint("Deja la página entera a la vista. Para volver, «Abrir el asistente», abajo.")
                .accessibilityHidden(!isOpen)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, onDrag == nil ? 12 : 19)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        // La manija y el arrastre van detrás, en toda la franja. Puesto
        // sobre la franja misma, VoiceOver le daba su tamaño al título y a
        // la X. Y VoiceOver no para en la manija: una hoja del sistema le
        // cobraba una parada de "Sheet Grabber" antes de todo. Para cerrar
        // está la X.
        .background(alignment: .top) {
            if onDrag != nil {
                ZStack(alignment: .top) {
                    Color.clear
                    Capsule()
                        .fill(.secondary.opacity(0.5))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                }
                .contentShape(.rect)
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onChanged { onDrag?($0, false) }
                        .onEnded { onDrag?($0, true) }
                )
                .accessibilityElement(children: .ignore)
                .accessibilityHidden(true)
            }
        }
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
        guard isOpen, settled, placedAt != assistant.turns.count else { return }
        placedAt = assistant.turns.count
        // "Otra cosa": al campo, a escribir. Con el teclado sólo no alcanzaba:
        // el cursor de VoiceOver se quedaba en la conversación.
        if assistant.inputRequests != inputsHandled {
            inputsHandled = assistant.inputRequests
            focused = "campo"
            return
        }
        // "Ir a la prueba": el cursor quedó en la página, y ahí se queda.
        // Traerlo de vuelta a las opciones deshacía el salto.
        if assistant.pageFocusRequests != pageFocusHandled {
            pageFocusHandled = assistant.pageFocusRequests
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
                // Sólido debajo: sobre el vidrio, el celeste translúcido
                // dejaba ver la página a través del texto.
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        // Una sola cápsula, con Enviar adentro, como en Mensajes: el campo
        // blanco al lado de un botón gris suelto se veía como dos cosas sin
        // relación.
        HStack(alignment: .bottom, spacing: 6) {
            // El texto de ayuda más oscuro que el gris de siempre: con poca
            // vista, el gris claro parecía un campo desactivado. Y fijo, no
            // `.secondary`: sobre el vidrio ese gris se aclara todavía más.
            Group {
                // Una contraseña pedida se escribe tapada: ni en pantalla ni
                // letra por letra en voz alta.
                if assistant.awaitingSecret {
                    SecureField("Pedido", text: $text, prompt: Text(assistant.awaiting.map { "Escribir: \($0)" } ?? "").foregroundStyle(Color(.secondaryLabel)))
                } else {
                    TextField("Pedido", text: $text, prompt: Text(assistant.awaiting.map { "Escribir: \($0)" } ?? "¿Qué querés hacer?").foregroundStyle(Color(.secondaryLabel)), axis: .vertical)
                        .lineLimit(1...3)
                }
            }
                .textFieldStyle(.plain)
                .focused($writing)
                .accessibilityFocused($focused, equals: "campo")
                .submitLabel(.send)
                .onSubmit(send)
                .padding(.vertical, 11)
                .accessibilityLabel("Pedido")
                // La pista dice lo que va a pasar con lo escrito: con un dato
                // pedido, que va directo al campo de la página.
                .accessibilityHint(assistant.awaiting.map { "Va directo al campo «\($0)» de la página." }
                    ?? "Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.")

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || assistant.working)
            .padding(.bottom, 5)
            .accessibilityLabel("Enviar")
        }
        .padding(.leading, 18)
        .padding(.trailing, 6)
        // Sólido: sobre el vidrio, un relleno translúcido se perdía.
        .background(Color(.systemBackground), in: Capsule())
        // Con borde: sin él, con poca vista el campo no se distinguía.
        .overlay(Capsule().strokeBorder(Color(.systemGray3), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func send() {
        let goal = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty else { return }
        text = ""
        writing = false
        onAsk(goal)
    }
}
