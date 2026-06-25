import Foundation

final class TabataEngine: BaseIntervalEngine {

    private let config: TimerConfig.Tabata

    init(config: TimerConfig.Tabata) {
        self.config = config
    }

    // Resolved sets: if custom sets defined use those, else use single block repeated `series` times
    private var resolvedSets: [(series: Int, work: Int, rest: Int)] {
        if !config.sets.isEmpty {
            return config.sets.map { ($0.series, $0.workSeconds, $0.restSeconds) }
        }
        return [(config.series, config.workSeconds, config.restSeconds)]
    }

    override func buildPlan() -> [PhaseStep] {
        var steps: [PhaseStep] = []
        let wodRounds = max(1, config.wodRepeat.wodRounds)

        for wodRound in 1...wodRounds {
            steps.append(PhaseStep(phaseType: .countdown, durationSeconds: Self.countdownSeconds, seriesIndex: 0, wodRound: wodRound))
            var seriesIdx = 0
            for set in resolvedSets {
                for _ in 0..<set.series {
                    steps.append(PhaseStep(phaseType: .work, durationSeconds: set.work, seriesIndex: seriesIdx, wodRound: wodRound))
                    steps.append(PhaseStep(phaseType: .rest, durationSeconds: set.rest, seriesIndex: seriesIdx, wodRound: wodRound))
                    seriesIdx += 1
                }
            }
            if wodRound < wodRounds && config.wodRepeat.restBetweenRoundsSeconds > 0 {
                steps.append(PhaseStep(phaseType: .wodRest, durationSeconds: config.wodRepeat.restBetweenRoundsSeconds, seriesIndex: seriesIdx - 1, wodRound: wodRound))
            }
        }
        return steps
    }

    override func makePhase(step: PhaseStep, planIndex: Int, remaining: Int) -> TimerPhase {
        let totalSeries = resolvedSets.reduce(0) { $0 + $1.series }
        let ex = config.exercises
        let exercise: String? = ex.isEmpty ? nil : ex[step.seriesIndex % ex.count]

        let nextWork = plan.dropFirst(planIndex + 1).first { $0.phaseType == .work }
        let nextEx: String? = nextWork.flatMap { step in
            ex.isEmpty ? nil : ex[step.seriesIndex % ex.count]
        }

        return TimerPhase(
            label: step.phaseType == .countdown ? "Pronti" :
                   step.phaseType == .rest ? "Riposo" :
                   step.phaseType == .wodRest ? "Riposo WOD" : "Lavoro",
            currentRound: step.seriesIndex + 1,
            totalRounds: totalSeries,
            currentWodRound: step.wodRound,
            totalWodRounds: max(1, config.wodRepeat.wodRounds),
            remainingSeconds: remaining, totalSeconds: step.durationSeconds,
            phase: step.phaseType,
            currentExercise: step.phaseType == .work ? exercise : nil,
            nextExercise: step.phaseType == .rest ? nextEx : nil,
            isPaused: isPaused
        )
    }

    static func totalSeconds(_ config: TimerConfig.Tabata) -> Int {
        let sets: [(Int, Int, Int)] = config.sets.isEmpty
            ? [(config.series, config.workSeconds, config.restSeconds)]
            : config.sets.map { ($0.series, $0.workSeconds, $0.restSeconds) }
        let perRound = sets.reduce(0) { $0 + $1.0 * ($1.1 + $1.2) }
        let rounds = max(1, config.wodRepeat.wodRounds)
        let rest = (rounds - 1) * config.wodRepeat.restBetweenRoundsSeconds
        return perRound * rounds + rest
    }
}
