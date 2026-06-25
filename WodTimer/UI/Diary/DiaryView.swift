import SwiftUI

struct DiaryView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                Divider().background(colors.divider)
                content
            }
        }
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        HStack {
            Button { appState.path.removeLast() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.textPrimary)
            }
            Text("Diario del workout")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, spacing.m)
        .padding(.vertical, spacing.s)
    }

    @ViewBuilder
    private var content: some View {
        let logs = appState.logStore.logs
        if logs.isEmpty {
            VStack(spacing: spacing.m) {
                Spacer()
                Image(systemName: "dumbbell")
                    .font(.system(size: 56))
                    .foregroundStyle(colors.textDisabled)
                Text("Nessun allenamento\nregistrato")
                    .font(.system(size: 17))
                    .foregroundStyle(colors.textSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: spacing.s) {
                    ForEach(logs) { log in
                        WorkoutLogCard(log: log)
                            .onTapGesture {
                                appState.path.append(.diaryDetail(log.id))
                            }
                    }
                }
                .padding(spacing.m)
            }
        }
    }
}

// MARK: – WorkoutLogCard

struct WorkoutLogCard: View {
    let log: WorkoutLog
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    var body: some View {
        let accent = colors.accent(for: log.type)

        HStack(spacing: spacing.m) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: spacing.s) {
                    Text(log.type.displayName)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                    Spacer()
                    Text(log.formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.textDisabled)
                }

                HStack(alignment: .firstTextBaseline, spacing: spacing.s) {
                    Text(log.formattedDuration)
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundStyle(colors.textPrimary)
                    if !log.notes.isEmpty {
                        Text(log.notes)
                            .font(.system(size: 13))
                            .foregroundStyle(colors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colors.textDisabled)
        }
        .padding(spacing.m)
        .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 12))
    }
}
