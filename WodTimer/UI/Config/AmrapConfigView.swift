import SwiftUI

struct AmrapConfigView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors

    @State private var durationSeconds = 8 * 60
    @State private var exercises: [String] = []
    @State private var exerciseReps: [Int] = []
    @State private var exerciseMinReps: [Int] = []
    @State private var wodRounds = 1
    @State private var restSeconds = 0
    @State private var notes = ""

    private var config: TimerConfig.Amrap {
        TimerConfig.Amrap(durationSeconds: durationSeconds, exercises: exercises,
                          exerciseReps: exerciseReps, exerciseMinReps: exerciseMinReps,
                          notes: notes,
                          wodRepeat: WodRepeatConfig(wodRounds: wodRounds, restBetweenRoundsSeconds: restSeconds))
    }

    var body: some View {
        ConfigScaffold(
            title: "AMRAP",
            accentColor: colors.accentAmrap,
            totalSeconds: AmrapEngine.totalSeconds(config),
            ctaLabel: "INIZIA",
            onStart: { appState.startTimer(config: .amrap(config)) },
            configForSave: .amrap(config)
        ) {
            VStack(alignment: .leading, spacing: 24) {
                SectionLabel("Durata")
                TimePickerView(totalSeconds: $durationSeconds, label: "Durata")
            }
            .padding(.top, 24)

            ExerciseSequenceView(
                exercises: $exercises,
                exerciseReps: $exerciseReps,
                exerciseMinReps: $exerciseMinReps
            )
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 24) {
                WodRepeatView(wodRounds: $wodRounds, restSeconds: $restSeconds)

                SectionLabel("Note")
                NotesFieldView(notes: $notes)
            }
        }
    }
}
