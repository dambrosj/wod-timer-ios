import SwiftUI

struct CompletionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.verticalSizeClass) private var vSizeClass
    @State private var notes = ""

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing
    private var isLandscape: Bool { vSizeClass == .compact }

    private var log: WorkoutLog? { appState.pendingWorkoutLog }

    private var accentColor: Color {
        guard let cfg = appState.pendingConfig else { return colors.success }
        return colors.accent(for: cfg.timerType)
    }

    private var typeName: String {
        appState.pendingConfig?.timerType.displayName ?? "WOD"
    }

    private var shareText: String {
        let dur = log?.formattedDuration ?? ""
        return "Ho appena completato un allenamento \(typeName)\(dur.isEmpty ? "" : " di \(dur)") con WOD Timer! 💪"
    }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: – Portrait

    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: spacing.l) {
                Spacer().frame(height: spacing.l)
                checkmarkCircle
                VStack(spacing: spacing.s) {
                    completedText
                    typeBadge
                }
                statsSummary
                notesField
                actionButtons
                Spacer().frame(height: spacing.l)
            }
            .padding(.horizontal, spacing.m)
        }
    }

    // MARK: – Landscape (two columns, mirrors Android)

    private var landscapeLayout: some View {
        HStack(spacing: spacing.l) {
            // Left: checkmark + COMPLETATO! + type badge
            VStack(spacing: spacing.m) {
                Spacer()
                checkmarkCircle
                completedText
                typeBadge
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Right: stats + notes + buttons (scrollable)
            ScrollView {
                VStack(spacing: spacing.s) {
                    statsSummary
                    Spacer().frame(height: spacing.s)
                    notesField
                    Spacer().frame(height: spacing.s)
                    actionButtons
                }
                .padding(.vertical, spacing.m)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(spacing.m)
    }

    // MARK: – Subviews

    private var checkmarkCircle: some View {
        ZStack {
            Circle()
                .fill(colors.success)
                .frame(width: 120, height: 120)
            Image(systemName: "checkmark")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(colors.bgPrimary)
        }
    }

    private var completedText: some View {
        Text("COMPLETATO!")
            .font(.system(size: 32, weight: .black, design: .monospaced))
            .foregroundStyle(colors.textPrimary)
            .multilineTextAlignment(.center)
    }

    private var typeBadge: some View {
        Text(typeName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 999))
    }

    private var statsSummary: some View {
        VStack(spacing: 4) {
            if let l = log {
                Text(l.formattedDuration)
                    .font(.system(size: 52, weight: .black, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                Text(l.formattedDate)
                    .font(.system(size: 14))
                    .foregroundStyle(colors.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: spacing.s) {
            Text("Note")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(colors.textSecondary)
            TextField("Aggiungi una nota sull'allenamento…", text: $notes, axis: .vertical)
                .lineLimit(1...5)
                .font(.system(size: 15))
                .foregroundStyle(colors.textPrimary)
                .tint(colors.accentTabata)
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        HStack(spacing: spacing.m) {
            ShareLink(item: shareText) {
                Label("Condividi", systemImage: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(colors.textPrimary)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(colors.divider, lineWidth: 1))
            }

            Button {
                saveAndGoHome()
            } label: {
                Text("Salva")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(colors.bgPrimary)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(colors.success, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: – Actions

    private func saveAndGoHome() {
        if var l = log {
            l.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            appState.logStore.log(l)
        }
        appState.pendingWorkoutLog = nil
        appState.goHome()
    }
}
