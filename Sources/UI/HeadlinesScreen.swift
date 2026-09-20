import SwiftUI

/// Todo lo que la portada publica, en el orden del sitio.
///
/// Una portada no es un texto: es un índice. Volcarla entera sobre la página
/// obliga a pasar por treinta y seis noticias para llegar a "Deportes"; no
/// ofrecerla es esconder aquello por lo que la mayoría entró. La salida es que
/// sea **una parada que abre una pantalla**: al que viene a leer le cuesta un
/// toque, y al que viene por una sección le ahorra treinta y seis.
///
/// Acá adentro no se agrupa ni se plega nada. Es el diario.
struct HeadlinesScreen: View {
    let page: ExtractedPage
    var listingNames: [String: String] = [:]
    var onOpenURL: (String) -> Void
    var onActivate: (String) -> Void = { _ in }

    private var listings: [Listing] { page.listings.filter(\.isNavigable) }

    static func total(of page: ExtractedPage) -> Int {
        page.listings.filter(\.isNavigable).reduce(0) { $0 + $1.items.count }
    }

    /// De qué habla hoy: las primeras, para que la caja que abre esta
    /// pantalla no sea una puerta sin cartel.
    static func preview(of page: ExtractedPage) -> String {
        let titles = page.listings.filter(\.isNavigable)
            .flatMap(\.items).prefix(3)
            .map { $0.title.split(separator: ".").first.map(String.init) ?? $0.title }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return titles.joined(separator: ", ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(listings) { listing in
                    ListingView(
                        listing: listing,
                        fallbackName: listingNames[listing.id],
                        startsExpanded: true,
                        onOpenURL: onOpenURL,
                        onActivate: onActivate
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Titulares")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.visible, for: .navigationBar)
    }
}
