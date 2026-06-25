import SwiftUI

/// Collapsible exercises block for TABATA and EMOM config screens.
/// Two modes: "Stesso per tutte" (single field) and "Per serie" (one per series).
struct ExercisesBlockView: View {
    @Binding var exercises: [String]
    let seriesCount: Int

    @State private var expanded = false
    @State private var isPerSeries = false
    @State private var singleValue = ""
    @State private var perSeriesValues: [String] = []

    private let colors = WodTheme.colors

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(colors.divider)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Text("Esercizi")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colors.textPrimary)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Mode toggle chips
                    HStack(spacing: 8) {
                        modeChip("Stesso per tutte", selected: !isPerSeries) {
                            isPerSeries = false
                            pushSingle()
                        }
                        modeChip("Per serie", selected: isPerSeries) {
                            isPerSeries = true
                            syncSize()
                            if !singleValue.isBlank && perSeriesValues.allSatisfy(\.isBlank) {
                                perSeriesValues = Array(repeating: singleValue, count: perSeriesValues.count)
                            }
                            pushPerSeries()
                        }
                    }

                    if !isPerSeries {
                        exField(value: $singleValue, placeholder: "Esercizio (tutte le serie)")
                            .onChange(of: singleValue) { _, _ in pushSingle() }
                    } else {
                        ForEach(perSeriesValues.indices, id: \.self) { i in
                            exField(
                                value: Binding(
                                    get: { perSeriesValues[i] },
                                    set: { perSeriesValues[i] = $0; pushPerSeries() }
                                ),
                                placeholder: "Serie \(i + 1)"
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.bgSurface)
            }

            Divider().background(colors.divider)
        }
        .onAppear { syncSize() }
        .onChange(of: seriesCount) { _, _ in
            syncSize()
            if isPerSeries { pushPerSeries() }
        }
    }

    // MARK: – Helpers

    private func syncSize() {
        while perSeriesValues.count < seriesCount { perSeriesValues.append("") }
        if perSeriesValues.count > seriesCount {
            perSeriesValues = Array(perSeriesValues.prefix(seriesCount))
        }
    }

    private func pushSingle() {
        let v = singleValue.trimmed
        exercises = v.isEmpty ? [] : [v]
    }

    private func pushPerSeries() {
        var result = perSeriesValues
        while result.last?.isBlank == true { result.removeLast() }
        exercises = result
    }

    private func modeChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(selected ? .white : colors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selected ? colors.accentTabata : colors.bgElevated,
                    in: RoundedRectangle(cornerRadius: 999)
                )
        }
    }

    private func exField(value: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: value)
            .font(.system(size: 15))
            .foregroundStyle(colors.textPrimary)
            .tint(colors.accentTabata)
            .padding(10)
            .background(colors.bgPrimary)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider, lineWidth: 1))
    }
}

private extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespaces).isEmpty }
    var trimmed: String { trimmingCharacters(in: .whitespaces) }
}
