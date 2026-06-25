import SwiftUI

struct SaveWodSheet: View {
    let config: TimerConfig
    let onDismiss: () -> Void

    @Environment(AppState.self) private var appState
    @State private var name = ""
    @State private var description = ""

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    var body: some View {
        NavigationStack {
            ZStack {
                colors.bgSurface.ignoresSafeArea()
                VStack(spacing: spacing.l) {
                    VStack(alignment: .leading, spacing: spacing.s) {
                        Text("Nome *")
                            .font(.caption)
                            .foregroundStyle(colors.textSecondary)
                        TextField("es. Cindy, Fran, DT…", text: $name)
                            .foregroundStyle(colors.textPrimary)
                            .tint(colors.accentTabata)
                            .padding()
                            .background(colors.bgElevated, in: RoundedRectangle(cornerRadius: 10))
                    }
                    VStack(alignment: .leading, spacing: spacing.s) {
                        Text("Descrizione (opzionale)")
                            .font(.caption)
                            .foregroundStyle(colors.textSecondary)
                        TextField("Note, strategia, target…", text: $description, axis: .vertical)
                            .foregroundStyle(colors.textPrimary)
                            .tint(colors.accentTabata)
                            .lineLimit(3...6)
                            .padding()
                            .background(colors.bgElevated, in: RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                }
                .padding(spacing.m)
            }
            .navigationTitle("Salva come WOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.bgSurface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { onDismiss() }
                        .foregroundStyle(colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        appState.saveWod(name: name.trimmingCharacters(in: .whitespaces),
                                         description: description.trimmingCharacters(in: .whitespaces),
                                         config: config)
                        onDismiss()
                    }
                    .foregroundStyle(colors.accentTabata)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
