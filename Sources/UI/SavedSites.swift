import SwiftUI

/// Los sitios guardados.
///
/// Lo más caro de un navegador sin vista no es leer la página: es llegar a
/// ella. Teclado, dirección, autocompletado que interrumpe, resultados de
/// buscador. Una lista de sitios con nombre borra todo eso de un toque, y es
/// la única pantalla de la app que no depende de lo que haya hecho ningún
/// sitio.
@MainActor
@Observable
final class SavedSites {
    struct Site: Codable, Identifiable, Hashable {
        var name: String
        var url: String
        var id: String { url }

        /// El dominio, como lo escribe Safari.
        var host: String {
            guard let host = URL(string: url)?.host() else { return url }
            return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        }
    }

    private(set) var sites: [Site] = []

    private let key = "jef.savedSites"
    private let store = UserDefaults.standard

    init() {
        guard
            let data = store.data(forKey: key),
            let saved = try? JSONDecoder().decode([Site].self, from: data)
        else { return }
        sites = saved
    }

    func contains(_ url: String) -> Bool { sites.contains { $0.host == Site(name: "", url: url).host } }

    /// Guarda el sitio, no la página: quien vuelve a un diario vuelve al
    /// diario. La dirección exacta se guarda igual, porque una sección
    /// —"Deportes"— es un sitio para quien la visita todos los días.
    func save(name: String, url: String) {
        let site = Site(name: name.isEmpty ? Site(name: "", url: url).host : name, url: url)
        guard !sites.contains(where: { $0.host == site.host }) else { return }
        sites.append(site)
        persist()
    }

    func remove(_ url: String) {
        let host = Site(name: "", url: url).host
        sites.removeAll { $0.host == host }
        persist()
    }

    func remove(atOffsets offsets: IndexSet) {
        sites.remove(atOffsets: offsets)
        persist()
    }

    func move(from source: IndexSet, to destination: Int) {
        sites.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sites) else { return }
        store.set(data, forKey: key)
    }
}

/// La lista de sitios, como pantalla de inicio y como hoja.
///
/// Es la misma vista en los dos lugares a propósito: la pantalla en la que
/// arranca la app tiene que ser la misma que se abre desde la barra, porque
/// aprender un lugar cuesta y aprenderlo dos veces cuesta el doble.
struct SavedSitesView: View {
    let sites: SavedSites
    var onOpen: (SavedSites.Site) -> Void
    /// Nil cuando es la pantalla de inicio: no hay nada que cerrar.
    var onDone: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mis sitios")
                        .font(.largeTitle.weight(.bold))
                        .accessibilityAddTraits(.isHeader)
                    Text(sites.sites.isEmpty
                         ? "Todavía no guardaste ninguno."
                         : "\(sites.sites.count) \(sites.sites.count == 1 ? "sitio guardado" : "sitios guardados")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 2)

                if sites.sites.isEmpty {
                    Text("Escribí una dirección en la barra de abajo y tocá Guardar. Desde acá se abre en un toque, sin volver a escribirla.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .jefCard()
                } else {
                    ForEach(sites.sites) { site in
                        Button {
                            onOpen(site)
                        } label: {
                            HStack(spacing: 14) {
                                IconBadge(symbol: "globe", color: .blue)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(site.name)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                    Text(site.host)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
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
                        .accessibilityLabel(site.name)
                        .accessibilityValue(site.host)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Abre este sitio")
                        // Borrar sin ver: la acción del rotor es el gesto que
                        // no exige encontrar un botón chico al costado.
                        .accessibilityAction(named: "Quitar de mis sitios") {
                            sites.remove(site.url)
                        }
                        .contextMenu {
                            Button("Quitar de mis sitios", systemImage: "trash", role: .destructive) {
                                sites.remove(site.url)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) {
            if let onDone {
                Button("Listo", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding()
            }
        }
    }
}
