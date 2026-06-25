import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.verticalSizeClass) private var vSizeClass
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    private var isLandscape: Bool { vSizeClass == .compact }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: hamburger (left) + bell (right)
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            appState.isDrawerOpen = true
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24))
                            .foregroundStyle(colors.iconDefault)
                    }
                    Spacer()
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.iconDefault)
                }
                .padding(.horizontal, spacing.m)
                .padding(.vertical, spacing.m)

                // Central content
                VStack(spacing: 0) {
                    Spacer()

                    if !isLandscape {
                        VStack(spacing: spacing.xs) {
                            Text("wod")
                                .font(.system(size: 64, weight: .black, design: .monospaced))
                                .foregroundStyle(colors.textPrimary)
                            Text("TIMER")
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundStyle(colors.textPrimary)
                        }
                        Spacer().frame(height: spacing.l)
                    }

                    if isLandscape {
                        landscapeGrid
                    } else {
                        portraitGrid
                    }

                    Spacer().frame(height: spacing.l)

                    // Diary link
                    Button {
                        appState.path.append(.diary)
                    } label: {
                        Text("DIARIO DEL WORKOUT")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(spacing.m)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, spacing.l)
                .padding(.vertical, isLandscape ? spacing.s : spacing.xl)
            }
        }
        .navigationBarHidden(true)
    }

    // Portrait: [AMRAP|FOR TIME] / [EMOM|TABATA] / [CUSTOM|I MIEI WOD]
    private var portraitGrid: some View {
        VStack(spacing: spacing.m) {
            HStack(spacing: spacing.m) {
                HomeButton(label: "AMRAP",    color: colors.accentAmrap)   { appState.path.append(.config(.amrap)) }
                HomeButton(label: "FOR TIME", color: colors.accentForTime) { appState.path.append(.config(.forTime)) }
            }
            HStack(spacing: spacing.m) {
                HomeButton(label: "EMOM",   color: colors.accentEmom)   { appState.path.append(.config(.emom)) }
                HomeButton(label: "TABATA", color: colors.accentTabata) { appState.path.append(.config(.tabata)) }
            }
            HStack(spacing: spacing.m) {
                HomeButton(label: "CUSTOM",     color: colors.accentCustom) { appState.path.append(.config(.custom)) }
                HomeButton(label: "I MIEI WOD", color: colors.accentMix)   { appState.path.append(.library) }
            }
        }
    }

    // Landscape: [AMRAP|FOR TIME|EMOM|TABATA] / [CUSTOM|I MIEI WOD]
    private var landscapeGrid: some View {
        VStack(spacing: spacing.m) {
            HStack(spacing: spacing.m) {
                HomeButton(label: "AMRAP",    color: colors.accentAmrap)   { appState.path.append(.config(.amrap)) }
                HomeButton(label: "FOR TIME", color: colors.accentForTime) { appState.path.append(.config(.forTime)) }
                HomeButton(label: "EMOM",     color: colors.accentEmom)    { appState.path.append(.config(.emom)) }
                HomeButton(label: "TABATA",   color: colors.accentTabata)  { appState.path.append(.config(.tabata)) }
            }
            HStack(spacing: spacing.m) {
                HomeButton(label: "CUSTOM",     color: colors.accentCustom) { appState.path.append(.config(.custom)) }
                HomeButton(label: "I MIEI WOD", color: colors.accentMix)   { appState.path.append(.library) }
            }
        }
    }
}

private struct HomeButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(color, in: Capsule())
        }
    }
}
