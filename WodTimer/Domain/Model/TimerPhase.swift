import Foundation

enum PhaseType {
    case work, rest, countdown, wodRest
}

struct TimerPhase {
    let label: String
    let currentRound: Int
    let totalRounds: Int
    let currentWodRound: Int
    let totalWodRounds: Int
    let remainingSeconds: Int
    let totalSeconds: Int
    let phase: PhaseType
    let currentExercise: String?
    let nextExercise: String?
    let isPaused: Bool

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var formattedTime: String {
        let s = remainingSeconds
        if s >= 60 { return "\(s / 60):\(String(format: "%02d", s % 60))" }
        return "\(s)"
    }

    func paused() -> TimerPhase {
        TimerPhase(
            label: label, currentRound: currentRound, totalRounds: totalRounds,
            currentWodRound: currentWodRound, totalWodRounds: totalWodRounds,
            remainingSeconds: remainingSeconds, totalSeconds: totalSeconds,
            phase: phase, currentExercise: currentExercise,
            nextExercise: nextExercise, isPaused: true
        )
    }

    func resumed() -> TimerPhase {
        TimerPhase(
            label: label, currentRound: currentRound, totalRounds: totalRounds,
            currentWodRound: currentWodRound, totalWodRounds: totalWodRounds,
            remainingSeconds: remainingSeconds, totalSeconds: totalSeconds,
            phase: phase, currentExercise: currentExercise,
            nextExercise: nextExercise, isPaused: false
        )
    }
}
