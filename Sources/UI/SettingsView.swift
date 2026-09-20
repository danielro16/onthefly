import SwiftUI

/// Tamaño del texto, por encima del del sistema.
///
/// El sistema manda por defecto: quien ya configuró su iPhone no tiene que
/// volver a configurarlo acá. Pero mucha gente mayor nunca abrió Ajustes y
/// agranda la letra en cada app que se lo permite, así que la app lo permite.
enum TextSize: Int, CaseIterable, Identifiable {
    case system, large, extraLarge, huge

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .system:     return "Como el sistema"
        case .large:      return "Grande"
        case .extraLarge: return "Más grande"
        case .huge:       return "Enorme"
        }
    }

    /// Nil deja pasar el del sistema sin tocarlo.
    var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .system:     return nil
        case .large:      return .xLarge
        case .extraLarge: return .xxxLarge
        case .huge:       return .accessibility2
        }
    }
}

enum Appearance: Int, CaseIterable, Identifiable {
    case system, light, dark

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .system: return "Como el sistema"
        case .light:  return "Claro"
        case .dark:   return "Oscuro"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

/// Lo que el mockup tenía arriba —A A y contraste— vive acá.
///
/// Son ajustes de uso raro: se tocan una vez y no se vuelven a tocar. Arriba
/// de la página costaban una parada de VoiceOver en cada página, todos los
/// días, a cambio de una decisión que se toma una sola vez.
struct SettingsView: View {
    @AppStorage("jef.textSize") private var textSize = TextSize.system.rawValue
    @AppStorage("jef.appearance") private var appearance = Appearance.system.rawValue
    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tamaño del texto", selection: $textSize) {
                        ForEach(TextSize.allCases) { size in
                            Text(size.label).tag(size.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Tamaño del texto")
                } footer: {
                    Text("Se aplica a toda la app, incluido el contenido de las páginas.")
                }

                Section {
                    Picker("Apariencia", selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.label).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Apariencia")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo", action: onDone)
                }
            }
        }
    }
}
