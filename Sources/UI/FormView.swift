import SwiftUI

/// A page's form, rebuilt as native controls.
///
/// The user types into real `TextField`s — correct keyboard, Dynamic Type,
/// VoiceOver labels and hints that the original page usually lacks — and each
/// edit is written straight into the live control inside the hidden WebView.
///
/// Nothing typed here is stored, logged, or sent anywhere but the page the
/// user is already on. Password fields use `SecureField` and their text is
/// never kept in the model beyond the field itself.
struct FormView: View {
    let action: Action
    /// What the page's autocompletes are offering, per field id.
    var suggestions: [String: [String]] = [:]
    /// What the page put in a field after a suggestion was picked.
    var resolvedValues: [String: String] = [:]
    var onFill: (Action.Field, String) -> Void
    var onChooseSuggestion: (Action.Field, Int) -> Void = { _, _ in }
    /// Presses a read-only field so the page opens its list.
    var onOpenField: (Action.Field) -> Void = { _ in }
    var onSubmit: () -> Void

    @State private var values: [String: String] = [:]
    @FocusState private var focused: String?

    private var fields: [Action.Field] { action.fields ?? [] }

    private var missingRequired: [Action.Field] {
        fields.filter { field in
            guard field.required, field.type != "checkbox" else { return false }
            return (values[field.id] ?? field.value).isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(action.label)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            // The page's reply to the last submit, before the fields: why
            // it did not go through, where a sighted person sees it first.
            ForEach(action.notices ?? [], id: \.self) { notice in
                Text(notice)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Aviso del formulario: \(notice)")
            }

            ForEach(fields) { field in
                control(field)
            }

            Button {
                focused = nil
                onSubmit()
            } label: {
                Text(action.submit?.isEmpty == false ? action.submit! : "Enviar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!missingRequired.isEmpty)
            // Saying WHY a button is unavailable beats a control that is
            // simply dim and silent — a screen reader announces "dimmed" and
            // nothing else.
            .accessibilityHint(
                missingRequired.isEmpty
                    ? "Envía el formulario en la página"
                    : "Faltan campos obligatorios: "
                        + missingRequired.map(\.name).joined(separator: ", ")
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            // Seed from whatever the page already had, so a pre-filled control
            // does not look empty.
            for field in fields where !field.value.isEmpty {
                values[field.id] = field.value
            }
        }
        // A picked suggestion is the page's word on what the field holds now.
        .onChange(of: resolvedValues) { _, resolved in
            for (id, value) in resolved { values[id] = value }
        }
    }

    /// The options an autocomplete is showing for this field, as a list a
    /// screen reader can walk: position, text, and what picking it does.
    @ViewBuilder
    private func suggestionList(_ field: Action.Field) -> some View {
        if let options = suggestions[field.id], !options.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        onChooseSuggestion(field, index)
                    } label: {
                        Text(option)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 12)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(index + 1) de \(options.count). \(option)")
                    .accessibilityHint("Elige esta opción para \(field.name)")
                    if index < options.count - 1 { Divider() }
                }
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
        }
    }

    @ViewBuilder
    private func control(_ field: Action.Field) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Sighted context only. The control below carries the same name
            // as its accessibility label, so leaving this in the tree made
            // every field two stops: "Buscar con Google", then "Buscar con
            // Google, campo de texto".
            HStack(spacing: 4) {
                Text(field.name)
                    .font(.subheadline)
                if field.required {
                    Text("obligatorio")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityHidden(true)

            if field.type == "radiogroup", let options = field.options, !options.isEmpty {
                // A radio group is one decision. Rendering each option as its
                // own control makes "Pizza size" read as three unrelated
                // fields, which is what the DOM looks like and not what the
                // page means.
                Picker(field.name, selection: binding(field)) {
                    ForEach(options, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel(field.name)

            } else if field.type == "checkbox" {
                Toggle(field.name, isOn: Binding(
                    get: { (values[field.id] ?? field.value) == "on" },
                    set: { isOn in
                        let value = isOn ? "on" : ""
                        values[field.id] = value
                        onFill(field, value)
                    }
                ))
                .labelsHidden()
                .accessibilityLabel(field.name)

            } else if let options = field.options, !options.isEmpty {
                Picker(field.name, selection: binding(field)) {
                    ForEach(options, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
                // The visible label sits above; with the picker's own label
                // as well, VoiceOver said "Número de documento, Número de
                // documento".
                .labelsHidden()
                .accessibilityLabel(field.name)

            } else if field.type == "combobox" {
                // Typing filters the page's list; the button opens all of
                // it, for someone who does not know what the list holds.
                // Either way the options arrive as suggestions underneath.
                HStack(spacing: 8) {
                    TextField(field.name, text: binding(field))
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focused, equals: field.id)
                        .accessibilityLabel(field.name)
                        .accessibilityHint("Escribe para filtrar las opciones")
                    Button {
                        onOpenField(field)
                    } label: {
                        Image(systemName: "chevron.down.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Opciones de \(field.name)")
                    .accessibilityHint("Muestra todas las opciones")
                }
                suggestionList(field)

            } else if field.type == "textarea" {
                TextField(field.name, text: binding(field), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...8)
                    .focused($focused, equals: field.id)
                    .accessibilityLabel(field.name)
                suggestionList(field)

            } else if field.isSecure {
                SecureField(field.name, text: binding(field))
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: field.id)
                    .accessibilityLabel(field.name)

            } else {
                TextField(field.name, text: binding(field))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(keyboard(for: field))
                    .textContentType(contentType(for: field))
                    .textInputAutocapitalization(autocapitalization(for: field))
                    .autocorrectionDisabled(field.type == "email" || field.type == "url" || field.isSearch)
                    .focused($focused, equals: field.id)
                    .accessibilityLabel(field.name)
                    .accessibilityHint(field.required ? "Campo obligatorio" : "")
                suggestionList(field)
            }

            if let error = field.error, !error.isEmpty {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error en \(field.name): \(error)")
            }
        }
    }

    /// Writes through to the live page on every edit, so the page's own
    /// validation and reactive state stay in step with what the user sees.
    private func binding(_ field: Action.Field) -> Binding<String> {
        Binding(
            get: { values[field.id] ?? field.value },
            set: { newValue in
                values[field.id] = newValue
                onFill(field, newValue)
            }
        )
    }

    private func keyboard(for field: Action.Field) -> UIKeyboardType {
        switch field.type {
        case "email": return .emailAddress
        case "tel": return .phonePad
        case "number": return .numberPad
        case "url": return .URL
        default: return .default
        }
    }

    private func contentType(for field: Action.Field) -> UITextContentType? {
        switch field.type {
        case "email": return .emailAddress
        case "tel": return .telephoneNumber
        default: return nil
        }
    }

    private func autocapitalization(for field: Action.Field) -> TextInputAutocapitalization {
        switch field.type {
        case "email", "url": return .never
        // The phone capitalises the first letter of a sentence; a search box
        // is not a sentence. "Dni" went into a case-sensitive path and came
        // back with no results; "dni" found 2807.
        default: return field.isSearch ? .never : .sentences
        }
    }
}
