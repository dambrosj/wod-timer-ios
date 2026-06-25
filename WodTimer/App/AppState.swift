import SwiftUI

enum AppRoute: Hashable {
    case config(TimerType)
    case timer
    case completion
    case library
    case wodDetail(String)     // SavedWod id
    case diary
    case diaryDetail(String)   // WorkoutLog id
    case settings
}

@MainActor
@Observable
final class AppState {
    var path: [AppRoute] = []
    var pendingConfig: TimerConfig?
    var activeEngine: BaseIntervalEngine?
    var isDrawerOpen: Bool = false
    var store = SavedWodStore()
    var settings = SettingsStore()
    var logStore = WorkoutLogStore()

    /// Set just before navigating to CompletionView; consumed (saved or discarded) there.
    var pendingWorkoutLog: WorkoutLog?

    // MARK: – Timer

    func startTimer(config: TimerConfig) {
        pendingConfig = config
        pendingWorkoutLog = nil
        let engine: BaseIntervalEngine
        switch config {
        case .amrap(let c):   engine = AmrapEngine(config: c)
        case .forTime(let c): engine = ForTimeEngine(config: c)
        case .emom(let c):    engine = EmomEngine(config: c)
        case .tabata(let c):  engine = TabataEngine(config: c)
        case .custom(let c):  engine = CustomEngine(config: c)
        }
        activeEngine = engine
        path.append(.timer)
        engine.start()
    }

    func startWod(_ wod: SavedWod) {
        guard let config = wod.timerConfig() else { return }
        store.recordUsage(wod)
        isDrawerOpen = false
        path.removeAll()
        startTimer(config: config)
    }

    /// Called by TimerRunningView when engine.isCompleted fires.
    func onTimerCompleted() {
        if let engine = activeEngine, let config = pendingConfig {
            pendingWorkoutLog = WorkoutLog(
                type: config.timerType,
                durationSeconds: engine.elapsedSeconds,
                completedAt: Date().timeIntervalSince1970
            )
        }
        path.append(.completion)
    }

    func stopTimer() {
        activeEngine?.stop()
        activeEngine = nil
    }

    func goHome() {
        stopTimer()
        path.removeAll()
        isDrawerOpen = false
    }

    // MARK: – WOD Store helpers

    func saveWod(name: String, description: String, config: TimerConfig) {
        guard let wod = try? SavedWod.make(name: name, description: description, config: config) else { return }
        store.save(wod)
    }
}
