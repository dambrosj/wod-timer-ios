import SwiftUI

/// Collapsible block for building a free-form exercise sequence (AMRAP / FOR TIME).
struct ExerciseSequenceView: View {
    @Binding var exercises: [String]
    @Binding var exerciseReps: [Int]
    @Binding var exerciseMinReps: [Int]

    @State private var expanded = false
    @State private var pickerTarget: PickerTarget?

    private let colors = WodTheme.colors
    private let pickerItems = (0...99).map { $0 == 0 ? "—" : "\($0)" }

    struct PickerTarget: Identifiable {
        let id = UUID()
        let exerciseIndex: Int
        let isReps: Bool
        var value: Int
    }

    private var subtitle: String {
        switch exercises.count {
        case 0: return "Nessun esercizio"
        case 1: return "1 esercizio"
        default: return "\(exercises.count) esercizi"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(colors.divider)

            // Header
            Button { withAnimation { expanded.toggle() } } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sequenza esercizi")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colors.textPrimary)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(colors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            if expanded {
                VStack(spacing: 0) {
                    if !exercises.isEmpty {
                        // Column headers
                        HStack {
                            Spacer()
                            Text("Reps").font(.caption).foregroundStyle(colors.textSecondary).frame(width: 52, alignment: .center)
                            Spacer().frame(width: 6)
                            Text("Min").font(.caption).foregroundStyle(colors.textSecondary).frame(width: 52, alignment: .center)
                            Spacer().frame(width: 36)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    ForEach(exercises.indices, id: \.self) { i in
                        ExerciseRow(
                            index: i,
                            name: binding(exercises, i),
                            reps: exerciseReps.getOrDefault(i, 0),
                            minReps: exerciseMinReps.getOrDefault(i, 0),
                            onRepsTap: {
                                pickerTarget = PickerTarget(exerciseIndex: i, isReps: true, value: exerciseReps.getOrDefault(i, 0))
                            },
                            onMinRepsTap: {
                                pickerTarget = PickerTarget(exerciseIndex: i, isReps: false, value: exerciseMinReps.getOrDefault(i, 0))
                            },
                            onDelete: { removeAt(i) }
                        )
                    }

                    // Add button
                    Button { addExercise() } label: {
                        Label("Aggiungi esercizio", systemImage: "plus")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(colors.accentTabata)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .background(colors.bgSurface)
            }

            Divider().background(colors.divider)
        }
        .sheet(item: $pickerTarget) { target in
            repPickerSheet(target)
                .presentationDetents([.medium])
                .presentationBackground(colors.bgPrimary)
        }
    }

    private func repPickerSheet(_ target: PickerTarget) -> some View {
        let exName = exercises.getOrDefault(target.exerciseIndex, "").ifEmpty("Esercizio \(target.exerciseIndex + 1)")
        let label = target.isReps ? "Ripetizioni obiettivo" : "Ripetizioni minime"
        @State var tempIdx = target.value

        return VStack(spacing: 0) {
            Text("\(exName) — \(label)")
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)
                .padding(.top, 16)

            WheelPickerView(items: pickerItems, selectedIndex: $tempIdx)
                .padding(.horizontal)

            Button {
                if target.isReps {
                    exerciseReps.setOrAppend(target.exerciseIndex, tempIdx)
                } else {
                    exerciseMinReps.setOrAppend(target.exerciseIndex, tempIdx)
                }
                pickerTarget = nil
            } label: {
                Text("Conferma")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(colors.accentTabata, in: RoundedRectangle(cornerRadius: 999))
            }
            .padding(.horizontal, 24).padding(.bottom, 32)
        }
    }

    private func binding(_ arr: [String], _ i: Int) -> Binding<String> {
        Binding(get: { arr.getOrDefault(i, "") },
                set: { exercises.setOrAppend(i, $0) })
    }

    private func addExercise() {
        exercises.append("")
        exerciseReps.append(0)
        exerciseMinReps.append(0)
    }

    private func removeAt(_ i: Int) {
        if exercises.indices.contains(i)    { exercises.remove(at: i) }
        if exerciseReps.indices.contains(i) { exerciseReps.remove(at: i) }
        if exerciseMinReps.indices.contains(i) { exerciseMinReps.remove(at: i) }
    }
}

private struct ExerciseRow: View {
    let index: Int
    @Binding var name: String
    let reps: Int
    let minReps: Int
    let onRepsTap: () -> Void
    let onMinRepsTap: () -> Void
    let onDelete: () -> Void

    private let colors = WodTheme.colors

    var body: some View {
        HStack(spacing: 6) {
            Text("\(index + 1).")
                .font(.caption).foregroundStyle(colors.textDisabled).frame(width: 22, alignment: .trailing)

            TextField("Esercizio \(index + 1)", text: $name)
                .font(.system(size: 15))
                .foregroundStyle(colors.textPrimary)
                .tint(colors.accentTabata)

            SmallRepsBadge(value: reps, onTap: onRepsTap)
            Spacer().frame(width: 6)
            SmallRepsBadge(value: minReps, onTap: onMinRepsTap)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 13))
                    .foregroundStyle(colors.textDisabled)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

private struct SmallRepsBadge: View {
    let value: Int
    let onTap: () -> Void
    private let colors = WodTheme.colors

    var body: some View {
        Button(action: onTap) {
            Text(value == 0 ? "—" : "\(value)")
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(value > 0 ? colors.textPrimary : colors.textDisabled)
                .frame(width: 52, height: 44)
                .background(colors.bgSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(value > 0 ? colors.accentTabata : colors.divider,
                                lineWidth: value > 0 ? 2 : 1)
                )
        }
    }
}

// MARK: – Array helpers

private extension Array where Element == String {
    func getOrDefault(_ i: Int, _ def: String) -> String { indices.contains(i) ? self[i] : def }
    mutating func setOrAppend(_ i: Int, _ v: String) {
        while count <= i { append("") }
        self[i] = v
    }
}

private extension Array where Element == Int {
    func getOrDefault(_ i: Int, _ def: Int) -> Int { indices.contains(i) ? self[i] : def }
    mutating func setOrAppend(_ i: Int, _ v: Int) {
        while count <= i { append(0) }
        self[i] = v
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
