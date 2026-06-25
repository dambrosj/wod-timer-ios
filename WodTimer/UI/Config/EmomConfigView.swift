import SwiftUI

struct EmomConfigView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors

    @State private var totalMinutes = 10
    @State private var intervalSeconds = 60
    @State private var exercises: [String] = []
    @State private var wodRounds = 1
    @State private var restSeconds = 0
    @State private var notes = ""

    private var intervalsCount: Int {
        ((totalMinutes * 60) / max(1, intervalSeconds)).clamped(to: 1...20)
    }

    private var config: TimerConfig.Emom {
        TimerConfig.Emom(totalMinutes: totalMinutes, intervalSeconds: intervalSeconds,
                         exercises: exercises,
                         notes: notes,
                         wodRepeat: WodRepeatConfig(wodRounds: wodRounds, restBetweenRoundsSeconds: restSeconds))
    }

    var body: some View {
        ConfigScaffold(
            title: "EMOM",
            accentColor: colors.accentEmom,
            totalSeconds: EmomEngine.totalSeconds(config),
            ctaLabel: "INIZIA",
            onStart: { appState.startTimer(config: .emom(config)) },
            configForSave: .emom(config)
        ) {
            VStack(alignment: .leading, spacing: 24) {
                SectionLabel("Durata totale")
                NumberPickerView(value: $totalMinutes, label: "Minuti", min: 1, max: 120)

                SectionLabel("Intervallo")
                NumberPickerView(value: $intervalSeconds, label: "Secondi", min: 10, max: 300)
            }
            .padding(.top, 24)

            ExercisesBlockView(exercises: $exercises, seriesCount: intervalsCount)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 24) {
                WodRepeatView(wodRounds: $wodRounds, restSeconds: $restSeconds)

                SectionLabel("Note")
                NotesFieldView(notes: $notes)
            }
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
