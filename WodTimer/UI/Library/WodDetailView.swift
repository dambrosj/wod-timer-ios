import SwiftUI

struct WodDetailView: View {
    let wodId: String
    @Environment(AppState.self) private var appState

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    private var wod: SavedWod? {
        appState.store.wods.first { $0.id == wodId }
    }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            if let wod {
                let accent = colors.accent(for: wod.type)

                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Button { appState.path.removeLast() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colors.textPrimary)
                        }
                        Text(wod.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(colors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, spacing.m)
                    .padding(.vertical, spacing.s)

                    Divider().background(colors.divider)

                    ScrollView {
                        VStack(alignment: .leading, spacing: spacing.m) {

                            // Type badge
                            Text(wod.type.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(accent)
                                .padding(.horizontal, 14).padding(.vertical, 5)
                                .background(accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 999))

                            if !wod.description.isEmpty {
                                Text(wod.description)
                                    .font(.system(size: 16))
                                    .foregroundStyle(colors.textSecondary)
                            }

                            if wod.timesUsed > 0 {
                                let lastUsed = wod.lastUsedAt.map { formatDate($0) } ?? "—"
                                Text("Usato \(wod.timesUsed)× · Ultimo uso: \(lastUsed)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(colors.textDisabled)
                            }

                            // AVVIA CTA
                            Button {
                                appState.path.removeLast()
                                appState.startWod(wod)
                            } label: {
                                HStack(spacing: spacing.s) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 18))
                                    Text("AVVIA")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                }
                                .foregroundStyle(colors.bgPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(accent, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(spacing.m)
                    }
                }
            } else {
                Color.clear.onAppear { appState.path.removeLast() }
            }
        }
        .navigationBarHidden(true)
    }

    private func formatDate(_ ms: Double) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: ms / 1000))
    }
}
