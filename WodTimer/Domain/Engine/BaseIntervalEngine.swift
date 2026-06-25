import Foundation

struct PhaseStep {
    let phaseType: PhaseType
    let durationSeconds: Int
    let seriesIndex: Int
    let wodRound: Int
}

@MainActor
@Observable
class BaseIntervalEngine {

    static let countdownSeconds = 10

    private(set) var currentPhase: TimerPhase?
    private(set) var isCompleted = false
    private(set) var elapsedSeconds = 0

    private(set) var plan: [PhaseStep] = []
    private(set) var isPaused = false

    private var timerTask: Task<Void, Never>?
    private var pauseContinuation: CheckedContinuation<Void, Never>?

    // Elapsed time tracking (excludes paused duration)
    private var startDate: Date?
    private var pausedTotal: TimeInterval = 0
    private var pauseStart: Date?

    // MARK: – Subclass interface

    func buildPlan() -> [PhaseStep] { [] }

    func makePhase(step: PhaseStep, planIndex: Int, remaining: Int) -> TimerPhase {
        TimerPhase(
            label: "", currentRound: 0, totalRounds: 0,
            currentWodRound: 0, totalWodRounds: 0,
            remainingSeconds: remaining, totalSeconds: step.durationSeconds,
            phase: step.phaseType, currentExercise: nil,
            nextExercise: nil, isPaused: isPaused
        )
    }

    // MARK: – Control

    func start() {
        plan = buildPlan()
        guard !plan.isEmpty else { isCompleted = true; return }
        startDate = Date()
        pausedTotal = 0
        pauseStart = nil
        // Set the first phase synchronously so the view never shows the loader
        let first = plan[0]
        currentPhase = makePhase(step: first, planIndex: 0, remaining: first.durationSeconds)
        timerTask = Task { await runLoop() }
    }

    func pause() {
        isPaused = true
        pauseStart = Date()
        if let p = currentPhase { currentPhase = p.paused() }
    }

    func resume() {
        isPaused = false
        if let ps = pauseStart {
            pausedTotal += Date().timeIntervalSince(ps)
            pauseStart = nil
        }
        if let p = currentPhase { currentPhase = p.resumed() }
        pauseContinuation?.resume()
        pauseContinuation = nil
    }

    func skip() {
        shouldSkip = true
        // Unblock pause so the loop can see shouldSkip immediately
        if isPaused {
            isPaused = false
            if let ps = pauseStart {
                pausedTotal += Date().timeIntervalSince(ps)
                pauseStart = nil
            }
            if let p = currentPhase { currentPhase = p.resumed() }
            pauseContinuation?.resume()
            pauseContinuation = nil
        }
    }

    func stop() {
        timerTask?.cancel()
    }

    private var shouldSkip = false

    // MARK: – Loop

    private func runLoop() async {
        for (index, step) in plan.enumerated() {
            var remaining = step.durationSeconds
            shouldSkip = false

            while remaining >= 0 {
                await yieldIfPaused()
                guard !Task.isCancelled else { return }

                currentPhase = makePhase(step: step, planIndex: index, remaining: remaining)

                if remaining == 0 || shouldSkip { break }
                remaining -= 1

                // 20 × 50ms = 1 second, checks shouldSkip each tick for fast skip response
                for _ in 0..<20 {
                    if shouldSkip { break }
                    try? await Task.sleep(nanoseconds: 50_000_000)
                }
            }
        }
        // Freeze elapsed time at completion (excluding any final pause)
        if let start = startDate {
            let currentPause = pauseStart.map { Date().timeIntervalSince($0) } ?? 0
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(start) - pausedTotal - currentPause))
        }
        isCompleted = true
    }

    private func yieldIfPaused() async {
        guard isPaused else { return }
        await withCheckedContinuation { continuation in
            pauseContinuation = continuation
        }
    }
}
