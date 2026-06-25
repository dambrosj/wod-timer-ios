import Foundation

final class CustomEngine: BaseIntervalEngine {

    private let config: TimerConfig.Custom

    init(config: TimerConfig.Custom) {
        self.config = config
    }

    private var validIntervals: [CustomInterval] {
        config.intervals.filter { $0.durationSeconds > 0 }
    }

    override func buildPlan() -> [PhaseStep] {
        let intervals = validIntervals
        guard !intervals.isEmpty else { return [] }

        var steps: [PhaseStep] = []
        let wodRounds = max(1, config.wodRepeat.wodRounds)

        for wodRound in 1...wodRounds {
            steps.append(PhaseStep(phaseType: .countdown, durationSeconds: Self.countdownSeconds, seriesIndex: 0, wodRound: wodRound))
            for (i, interval) in intervals.enumerated() {
                steps.append(PhaseStep(phaseType: .work, durationSeconds: interval.durationSeconds, seriesIndex: i, wodRound: wodRound))
            }
            if wodRound < wodRounds && config.wodRepeat.restBetweenRoundsSeconds > 0 {
                steps.append(PhaseStep(phaseType: .wodRest, durationSeconds: config.wodRepeat.restBetweenRoundsSeconds, seriesIndex: intervals.count - 1, wodRound: wodRound))
            }
        }
        return steps
    }

    override func makePhase(step: PhaseStep, planIndex: Int, remaining: Int) -> TimerPhase {
        let intervals = validIntervals
        let interval = intervals.indices.contains(step.seriesIndex) ? intervals[step.seriesIndex] : nil

        let nextWork = plan.dropFirst(planIndex + 1).first { $0.phaseType == .work }
        let nextName: String? = nextWork.flatMap { s in
            intervals.indices.contains(s.seriesIndex) ? intervals[s.seriesIndex].name : nil
        }.flatMap { $0.isEmpty ? nil : $0 }

        return TimerPhase(
            label: {
                switch step.phaseType {
                case .work:
                    let name = interval?.name ?? ""
                    return name.isEmpty ? "Intervallo \(step.seriesIndex + 1)" : name
                case .countdown: return "Pronti"
                case .wodRest:   return "Riposo WOD"
                case .rest:      return "Riposo"
                }
            }(),
            currentRound: step.seriesIndex + 1,
            totalRounds: intervals.count,
            currentWodRound: step.wodRound,
            totalWodRounds: max(1, config.wodRepeat.wodRounds),
            remainingSeconds: remaining,
            totalSeconds: step.durationSeconds,
            phase: step.phaseType,
            currentExercise: step.phaseType == .countdown
                ? intervals.first?.name.nilIfEmpty
                : nil,
            nextExercise: nextName,
            isPaused: isPaused
        )
    }

    static func totalSeconds(_ config: TimerConfig.Custom) -> Int {
        let rounds = max(1, config.wodRepeat.wodRounds)
        let perRound = config.intervals.reduce(0) { $0 + max(0, $1.durationSeconds) }
        let rest = (rounds - 1) * config.wodRepeat.restBetweenRoundsSeconds
        return perRound * rounds + rest
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
