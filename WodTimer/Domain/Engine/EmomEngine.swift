import Foundation

final class EmomEngine: BaseIntervalEngine {

    private let config: TimerConfig.Emom

    init(config: TimerConfig.Emom) {
        self.config = config
    }

    override func buildPlan() -> [PhaseStep] {
        var steps: [PhaseStep] = []
        let intervalSeconds = config.intervalSeconds
        let totalIntervals = (config.totalMinutes * 60) / intervalSeconds
        let wodRounds = max(1, config.wodRepeat.wodRounds)

        for wodRound in 1...wodRounds {
            steps.append(PhaseStep(phaseType: .countdown, durationSeconds: Self.countdownSeconds, seriesIndex: 0, wodRound: wodRound))
            for i in 0..<totalIntervals {
                steps.append(PhaseStep(phaseType: .work, durationSeconds: intervalSeconds, seriesIndex: i, wodRound: wodRound))
            }
            if wodRound < wodRounds && config.wodRepeat.restBetweenRoundsSeconds > 0 {
                steps.append(PhaseStep(phaseType: .wodRest, durationSeconds: config.wodRepeat.restBetweenRoundsSeconds, seriesIndex: totalIntervals - 1, wodRound: wodRound))
            }
        }
        return steps
    }

    override func makePhase(step: PhaseStep, planIndex: Int, remaining: Int) -> TimerPhase {
        let totalIntervals = (config.totalMinutes * 60) / config.intervalSeconds
        let ex = config.exercises
        let exercise: String? = ex.isEmpty ? nil : ex[step.seriesIndex % ex.count]

        return TimerPhase(
            label: step.phaseType == .countdown ? "Pronti" : step.phaseType == .wodRest ? "Riposo WOD" : "EMOM",
            currentRound: step.seriesIndex + 1,
            totalRounds: totalIntervals,
            currentWodRound: step.wodRound,
            totalWodRounds: max(1, config.wodRepeat.wodRounds),
            remainingSeconds: remaining, totalSeconds: step.durationSeconds,
            phase: step.phaseType,
            currentExercise: step.phaseType == .work ? exercise : nil,
            nextExercise: nil,
            isPaused: isPaused
        )
    }

    static func totalSeconds(_ config: TimerConfig.Emom) -> Int {
        let rounds = max(1, config.wodRepeat.wodRounds)
        let rest = (rounds - 1) * config.wodRepeat.restBetweenRoundsSeconds
        return config.totalMinutes * 60 * rounds + rest
    }
}
