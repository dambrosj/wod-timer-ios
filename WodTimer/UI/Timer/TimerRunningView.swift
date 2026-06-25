import SwiftUI
import UIKit

struct TimerRunningView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.verticalSizeClass) private var vSizeClass

    private let colors = WodTheme.colors

    // Exercise list page state
    @State private var currentPage = 0
    @State private var exerciseRepsDone: [Int] = []
    @State private var exerciseChecked: [Bool] = []

    private var engine: BaseIntervalEngine? { appState.activeEngine }

    private var hasExercisePage: Bool {
        guard let cfg = appState.pendingConfig else { return false }
        switch cfg {
        case .amrap(let c):   return !c.exercises.isEmpty
        case .forTime(let c): return !c.exercises.isEmpty
        default:              return false
        }
    }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            if let engine, let phase = engine.currentPhase {
                let ringColor = phaseColor(phase)

                if hasExercisePage {
                    TabView(selection: $currentPage) {
                        timerPage(phase: phase, ringColor: ringColor, engine: engine)
                            .tag(0)
                        exerciseListPage(phase: phase, ringColor: ringColor)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()

                    // Page dots
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<2) { i in
                                Circle()
                                    .fill(currentPage == i ? ringColor : colors.textDisabled)
                                    .frame(width: currentPage == i ? 8 : 6, height: currentPage == i ? 8 : 6)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                } else {
                    timerPage(phase: phase, ringColor: ringColor, engine: engine)
                }

                // Back button
                VStack {
                    HStack {
                        Button { appState.goHome() } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(colors.iconDefault)
                                .frame(width: 44, height: 44)
                        }
                        .padding(4)
                        Spacer()
                    }
                    Spacer()
                }

            } else {
                ProgressView().tint(colors.phaseWork)
            }
        }
        .navigationBarHidden(true)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .onChange(of: engine?.isCompleted ?? false) { _, completed in
            if completed { appState.onTimerCompleted() }
        }
    }

    // MARK: – Timer ring page

    @ViewBuilder
    private func timerPage(phase: TimerPhase, ringColor: Color, engine: BaseIntervalEngine) -> some View {
        let isLandscape = vSizeClass == .compact

        ZStack {
            colors.bgPrimary.ignoresSafeArea()

            if isLandscape {
                landscapeLayout(phase: phase, ringColor: ringColor, engine: engine)
            } else {
                portraitLayout(phase: phase, ringColor: ringColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard currentPage == 0 else { return }
            if phase.isPaused { engine.resume() } else { engine.pause() }
        }
        .onLongPressGesture(minimumDuration: 0.4) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            engine.skip()
        }
    }

    // MARK: – Portrait

    private func portraitLayout(phase: TimerPhase, ringColor: Color) -> some View {
        let isCustomWork = phase.phase == .work && phase.currentExercise == nil
        return VStack(spacing: 0) {
            Spacer().frame(height: 56)

            Text(isCustomWork ? phase.label.uppercased() : phase.label)
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundStyle(isCustomWork ? .white : ringColor)

            if phase.totalRounds > 1 {
                Text("\(phase.currentRound)/\(phase.totalRounds)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(colors.textSecondary)
            }

            if phase.totalWodRounds > 1 {
                Text("Round WOD \(phase.currentWodRound)/\(phase.totalWodRounds)")
                    .font(.system(size: 15))
                    .foregroundStyle(colors.textSecondary)
            }

            Spacer().frame(height: 12)

            exerciseLabel(phase: phase)

            CircularTimerView(phase: phase, ringColor: ringColor)
                .padding(.horizontal, 32)

            Spacer().frame(height: 16)

            if let sub = buildSubLabel(phase) {
                Text(sub).font(.system(size: 15)).foregroundStyle(colors.textSecondary)
            }

            Spacer().frame(height: 20)

            Text(phase.isPaused ? "Tocca per riprendere · tieni per saltare" : "Tocca per pausa · tieni per saltare")
                .font(.caption).foregroundStyle(colors.textDisabled)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: – Landscape

    private func landscapeLayout(phase: TimerPhase, ringColor: Color, engine: BaseIntervalEngine) -> some View {
        let isCustomWork = phase.phase == .work && phase.currentExercise == nil
        return HStack(spacing: 0) {
            CircularTimerView(phase: phase, ringColor: ringColor)
                .padding(16)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text(isCustomWork ? phase.label.uppercased() : phase.label)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(isCustomWork ? .white : ringColor)

                if phase.totalRounds > 1 {
                    Text("\(phase.currentRound)/\(phase.totalRounds)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(colors.textSecondary)
                }

                if phase.totalWodRounds > 1 {
                    Text("Round WOD \(phase.currentWodRound)/\(phase.totalWodRounds)")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.textSecondary)
                }

                exerciseLabel(phase: phase)

                if let sub = buildSubLabel(phase) {
                    Text(sub)
                        .font(.system(size: 14))
                        .foregroundStyle(colors.textSecondary)
                }

                Spacer().frame(height: 16)

                HStack(spacing: 12) {
                    Button {
                        if phase.isPaused { engine.resume() } else { engine.pause() }
                    } label: {
                        Text(phase.isPaused ? "RIPRENDI" : "PAUSA")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(colors.textPrimary)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider))
                    }
                    Button { engine.skip() } label: {
                        Text("SALTA")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(colors.textPrimary)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider))
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: – Exercise label

    private func exerciseToShow(_ phase: TimerPhase) -> String? {
        switch phase.phase {
        case .work:      return phase.currentExercise ?? phase.nextExercise
        case .countdown: return phase.currentExercise
        case .rest:      return phase.nextExercise
        case .wodRest:   return phase.nextExercise
        }
    }

    @ViewBuilder
    private func exerciseLabel(phase: TimerPhase) -> some View {
        let toShow = exerciseToShow(phase)
        let isCurrent = phase.phase == .work && phase.currentExercise != nil

        if let ex = toShow {
            Text(ex.uppercased())
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(isCurrent ? colors.textPrimary : colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
        }
    }

    // MARK: – Exercise list page

    private var exerciseListData: (exercises: [String], reps: [Int], minReps: [Int]) {
        switch appState.pendingConfig {
        case .amrap(let c):
            return (c.exercises, c.exerciseReps, c.exerciseMinReps)
        case .forTime(let c):
            return (c.exercises, c.exerciseReps, c.exerciseMinReps)
        default:
            return ([], [], [])
        }
    }

    @ViewBuilder
    private func exerciseListPage(phase: TimerPhase, ringColor: Color) -> some View {
        let data = exerciseListData
        let exercises = data.exercises
        let reps = data.reps
        let minReps = data.minReps

        VStack(spacing: 0) {
            // Mini timer bar
            miniTimerBar(phase: phase, ringColor: ringColor)
            Divider().background(colors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(exercises.indices, id: \.self) { i in
                        let isDone = exerciseChecked.getOrFalse(i)
                        let done = exerciseRepsDone.getOrZero(i)
                        let target = reps.getOrZero(i)
                        let minR = minReps.getOrZero(i)

                        HStack(spacing: 12) {
                            Button {
                                exerciseChecked.setOrAppend(i, !isDone)
                            } label: {
                                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(isDone ? colors.phaseWork : colors.textSecondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercises[i].ifBlank("Esercizio \(i + 1)"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(isDone ? colors.textDisabled : colors.textPrimary)
                                    .strikethrough(isDone)
                                if minR > 0 && !isDone {
                                    Text("Min: \(minR) rep")
                                        .font(.caption).foregroundStyle(colors.textSecondary)
                                }
                            }

                            Spacer()

                            if target > 0 {
                                Text("× \(target)")
                                    .font(.system(size: 15)).foregroundStyle(colors.textSecondary)
                            }

                            // Done counter
                            HStack(spacing: 0) {
                                Button {
                                    if done > 0 { exerciseRepsDone.setOrAppend(i, done - 1) }
                                } label: {
                                    Text("−").font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(done > 0 && !isDone ? colors.textSecondary : colors.textDisabled)
                                        .frame(width: 28, height: 36)
                                }
                                Text("\(done)")
                                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(isDone ? colors.textDisabled : colors.textPrimary)
                                    .frame(width: 32, alignment: .center)
                                Button {
                                    if !isDone { exerciseRepsDone.setOrAppend(i, done + 1) }
                                } label: {
                                    Text("+").font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(!isDone ? colors.textSecondary : colors.textDisabled)
                                        .frame(width: 28, height: 36)
                                }
                            }
                            .background(colors.bgElevated, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider, lineWidth: 1))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .opacity(isDone ? 0.5 : 1)

                        if i < exercises.count - 1 {
                            Divider().padding(.leading, 60).background(colors.divider)
                        }
                    }
                }
            }
        }
        .background(colors.bgPrimary)
    }

    private func miniTimerBar(phase: TimerPhase, ringColor: Color) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Circle()
                    .fill(phase.isPaused ? colors.textDisabled : ringColor)
                    .frame(width: 8, height: 8)
                Text(phase.isPaused ? "IN PAUSA" : phase.label.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(phase.isPaused ? colors.textDisabled : ringColor)
                Spacer()
                Text(phase.formattedTime)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ProgressView(value: phase.progress)
                .tint(phase.isPaused ? colors.textDisabled : ringColor)
                .scaleEffect(x: 1, y: 1.5)
        }
    }

    // MARK: – Helpers

    private func phaseColor(_ phase: TimerPhase) -> Color {
        if phase.isPaused { return colors.textSecondary }
        switch phase.phase {
        case .countdown: return colors.textPrimary
        case .work:      return colors.phaseWork
        case .rest:      return colors.phaseRest
        case .wodRest:   return colors.phaseWodRest
        }
    }

    private func buildSubLabel(_ phase: TimerPhase) -> String? {
        if phase.phase == .wodRest && phase.totalWodRounds > 1 {
            return "Prossimo: Round \(phase.currentWodRound + 1)/\(phase.totalWodRounds)"
        }
        return nil
    }
}

// MARK: – Array helpers

private extension Array where Element == Bool {
    func getOrFalse(_ i: Int) -> Bool { indices.contains(i) ? self[i] : false }
    mutating func setOrAppend(_ i: Int, _ v: Bool) {
        while count <= i { append(false) }
        self[i] = v
    }
}

private extension Array where Element == Int {
    func getOrZero(_ i: Int) -> Int { indices.contains(i) ? self[i] : 0 }
    mutating func setOrAppend(_ i: Int, _ v: Int) {
        while count <= i { append(0) }
        self[i] = v
    }
}

private extension String {
    func ifBlank(_ fallback: String) -> String { trimmingCharacters(in: .whitespaces).isEmpty ? fallback : self }
}
