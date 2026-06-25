import SwiftUI

struct DiaryDetailView: View {
    let logId: String
    @Environment(AppState.self) private var appState
    @State private var notes = ""
    @State private var showDeleteConfirm = false

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    private var log: WorkoutLog? {
        appState.logStore.logs.first { $0.id == logId }
    }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            if let log {
                let accent = colors.accent(for: log.type)

                ScrollView {
                    VStack(alignment: .leading, spacing: spacing.l) {

                        // Top bar
                        HStack {
                            Button { appState.path.removeLast() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(colors.textPrimary)
                            }
                            Text(log.type.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(accent)
                            Spacer()
                            Button {
                                showDeleteConfirm = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                    .foregroundStyle(colors.error)
                            }
                        }
                        .padding(.horizontal, spacing.m)
                        .padding(.top, spacing.s)

                        Divider().background(colors.divider)

                        VStack(alignment: .leading, spacing: spacing.s) {
                            // Duration
                            Text(log.formattedDuration)
                                .font(.system(size: 52, weight: .black, design: .monospaced))
                                .foregroundStyle(colors.textPrimary)
                            Text(log.formattedDate)
                                .font(.system(size: 15))
                                .foregroundStyle(colors.textSecondary)
                        }
                        .padding(.horizontal, spacing.m)

                        Divider().background(colors.divider)

                        // Notes
                        VStack(alignment: .leading, spacing: spacing.s) {
                            Text("Note")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(colors.textSecondary)

                            TextField("Aggiungi una nota…", text: $notes, axis: .vertical)
                                .lineLimit(1...8)
                                .font(.system(size: 15))
                                .foregroundStyle(colors.textPrimary)
                                .tint(colors.accentTabata)
                                .padding(12)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider, lineWidth: 1))

                            Button {
                                appState.logStore.updateNotes(id: logId, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
                                appState.path.removeLast()
                            } label: {
                                Text("Salva note")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(colors.accentTabata)
                            }
                        }
                        .padding(.horizontal, spacing.m)

                        Spacer()
                    }
                    .padding(.vertical, spacing.s)
                }
                .onAppear { notes = log.notes }
            } else {
                // Log was deleted — go back
                Color.clear.onAppear { appState.path.removeLast() }
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog(
            "Sei sicuro di voler eliminare questo allenamento?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Elimina", role: .destructive) {
                if let log { appState.logStore.delete(log) }
                appState.path.removeLast()
            }
            Button("Annulla", role: .cancel) {}
        }
    }
}
