import Foundation

final class ForTimeEngine: BaseIntervalEngine {

    private let config: TimerConfig.ForTime

    init(config: TimerConfig.ForTime) {
        self.config = config
    }

    override func buildPlan() -> [PhaseStep] {
        var steps: [PhaseStep] = []
        let wodRounds = max(1, config.wodRepeat.wodRounds)

        for wodRound in 1...wodRounds {
            steps.append(PhaseStep(phaseType: .countdown, durationSeconds: Self.countdownSeconds, seriesIndex: 0, wodRound: wodRound))
            steps.append(PhaseStep(phaseType: .work, durationSeconds: config.timecapSeconds, seriesIndex: 0, wodRound: wodRound))
            if wodRound < wodRounds && config.wodRepeat.restBetweenRoundsSeconds > 0 {
                steps.append(PhaseStep(phaseType: .wodRest, durationSeconds: config.wodRepeat.restBetweenRoundsSeconds, seriesIndex: 0, wodRound: wodRound))
            }
        }
        return steps
    }

    override func makePhase(step: PhaseStep, planIndex: Int, remaining: Int) -> TimerPhase {
        let ex = config.exercises
        let current = ex.isEmpty ? nil : ex[0]
        return TimerPhase(
            label: step.phaseType == .countdown ? "Pronti" : step.phaseType == .wodRest ? "Riposo WOD" : "FOR TIME",
            currentRound: 1, totalRounds: 1,
            currentWodRound: step.wodRound,
            totalWodRounds: max(1, config.wodRepeat.wodRounds),
            remainingSeconds: remaining, totalSeconds: step.durationSeconds,
            phase: step.phaseType,
            currentExercise: step.phaseType == .work ? current : nil,
            nextExercise: nil,
            isPaused: isPaused
        )
    }

    static func totalSeconds(_ config: TimerConfig.ForTime) -> Int {
        let rounds = max(1, config.wodRepeat.wodRounds)
        let rest = (rounds - 1) * config.wodRepeat.restBetweenRoundsSeconds
        return config.timecapSeconds * rounds + rest
    }
}
