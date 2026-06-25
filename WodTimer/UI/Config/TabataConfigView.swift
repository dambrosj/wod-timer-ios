import SwiftUI

struct TabataConfigView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors

    @State private var series = 8
    @State private var workSeconds = 20
    @State private var restSeconds = 10
    @State private var exercises: [String] = []
    @State private var wodRounds = 1
    @State private var wodRestSeconds = 0
    @State private var notes = ""

    private var config: TimerConfig.Tabata {
        TimerConfig.Tabata(series: series, workSeconds: workSeconds, restSeconds: restSeconds,
                           exercises: exercises,
                           notes: notes,
                           wodRepeat: WodRepeatConfig(wodRounds: wodRounds, restBetweenRoundsSeconds: wodRestSeconds))
    }

    var body: some View {
        ConfigScaffold(
            title: "TABATA",
            accentColor: colors.accentTabata,
            totalSeconds: TabataEngine.totalSeconds(config),
            ctaLabel: "INIZIA",
            onStart: { appState.startTimer(config: .tabata(config)) },
            configForSave: .tabata(config)
        ) {
            VStack(alignment: .leading, spacing: 24) {
                SectionLabel("Serie")
                NumberPickerView(value: $series, label: "Serie", min: 1, max: 99)

                SectionLabel("Lavoro")
                TimePickerView(totalSeconds: $workSeconds, label: "Lavoro", maxMinutes: 9)

                SectionLabel("Riposo")
                TimePickerView(totalSeconds: $restSeconds, label: "Riposo", maxMinutes: 9)
            }
            .padding(.top, 24)

            ExercisesBlockView(exercises: $exercises, seriesCount: series)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 24) {
                WodRepeatView(wodRounds: $wodRounds, restSeconds: $wodRestSeconds)

                SectionLabel("Note")
                NotesFieldView(notes: $notes)
            }
        }
    }
}
