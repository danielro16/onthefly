import SwiftUI

/// A data table, as a list of records.
///
/// A grid on a phone forces horizontal scrolling and, worse, separates each
/// value from the column it belongs to — a screen reader lands on "-5.000"
/// with no way to know it is an amount. Native banking apps solve this by
/// dropping the grid and pairing every value with its header, and so does this.
///
/// Each row is **one** VoiceOver stop that speaks the whole record:
/// "Fecha: 12/03, Concepto: Transferencia, Monto: -5.000". That pairing is
/// what a sighted reader gets for free from the grid's geometry.
struct TableBlockView: View {
    let caption: String
    let headers: [String]
    let rows: [[String]]
    /// The table labels its rows in the first column — an infobox, a spec
    /// sheet, an account summary. Renders as one line per field instead of
    /// a record list.
    var keyValue: Bool = false

    @Namespace private var rotorNamespace
    @State private var showingGrid = false

    private var title: String {
        caption.isEmpty ? "Tabla de \(rows.count) filas" : caption
    }

    /// Pairs each cell with its column header. Falls back to a position when
    /// the table never declared headers.
    private func record(_ row: [String]) -> [(header: String, value: String)] {
        row.enumerated().compactMap { index, value in
            guard !value.isEmpty else { return nil }
            let header = index < headers.count && !headers[index].isEmpty
                ? headers[index]
                : "Columna \(index + 1)"
            return (header, value)
        }
    }

    private func spoken(_ row: [String]) -> String {
        if keyValue {
            let name = row.first ?? ""
            return "\(name): \(row.dropFirst().joined(separator: " "))"
        }
        return record(row).map { "\($0.header): \($0.value)" }.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .accessibilityAddTraits(.isHeader)
                    Text(keyValue
                     ? "\(rows.count) datos"
                     : "\(rows.count) filas, \(max(headers.count, rows.first?.count ?? 0)) columnas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // The grid stays available: for a small table, or for someone
                // using a braille display, the original shape can be easier.
                Button(showingGrid ? "Ver como lista" : (keyValue ? "Ver como tabla" : "Ver como tabla")) {
                    withAnimation(.easeInOut(duration: 0.15)) { showingGrid.toggle() }
                }
                .font(.caption)
            }

            if showingGrid {
                gridLayout
            } else if keyValue {
                fieldLayout
            } else {
                recordLayout
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        // The tables rotor is how VoiceOver users find tabular data on a long
        // page — worth wiring even when the layout is a record list.
        .accessibilityRotor(.tables) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                AccessibilityRotorEntry(
                    Text(spoken(row)), id: "row\(index)", in: rotorNamespace
                )
            }
        }
    }

    /// One line per field: the first cell names, the rest is the value.
    private var fieldLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                let name = row.first ?? ""
                let value = row.dropFirst().joined(separator: " ")

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.callout)
                }
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id("row\(index)")
                .accessibilityRotorEntry(id: "row\(index)", in: rotorNamespace)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(name): \(value)")

                if index < rows.count - 1 { Divider() }
            }
        }
    }

    private var recordLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(record(row).enumerated()), id: \.offset) { _, pair in
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(pair.header)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 70, alignment: .leading)
                            Text(pair.value)
                                .font(.callout)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id("row\(index)")
                .accessibilityRotorEntry(id: "row\(index)", in: rotorNamespace)
                // One stop per record, not one per cell.
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Fila \(index + 1) de \(rows.count). \(spoken(row))")

                if index < rows.count - 1 {
                    Divider()
                }
            }
        }
    }

    private var gridLayout: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                if !headers.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(headers.enumerated()), id: \.offset) { _, header in
                            Text(header)
                                .font(.caption.weight(.semibold))
                                .frame(width: 130, alignment: .leading)
                                .padding(.vertical, 6)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Encabezados: " + headers.joined(separator: ", "))
                    Divider()
                }
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.caption)
                                .frame(width: 130, alignment: .leading)
                                .padding(.vertical, 6)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Fila \(index + 1). \(spoken(row))")
                    if index < rows.count - 1 { Divider() }
                }
            }
        }
    }
}
