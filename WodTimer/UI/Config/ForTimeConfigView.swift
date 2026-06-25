import SwiftUI

struct ForTimeConfigView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors

    @State private var timecapSeconds = 10 * 60
    @State private var rounds = 1
    @State private var exercises: [String] = []
    @State private var exerciseReps: [Int] = []
    @State private var exerciseMinReps: [Int] = []
    @State private var wodRounds = 1
    @State private var restSeconds = 0
    @State private var notes = ""

    private var config: TimerConfig.ForTime {
        TimerConfig.ForTime(timecapSeconds: timecapSeconds, rounds: rounds,
                            exercises: exercises, exerciseReps: exerciseReps,
                            exerciseMinReps: exerciseMinReps,
                            notes: notes,
                            wodRepeat: WodRepeatConfig(wodRounds: wodRounds, restBetweenRoundsSeconds: restSeconds))
    }

    var body: some View {
        ConfigScaffold(
            title: "FOR TIME",
            accentColor: colors.accentForTime,
            totalSeconds: ForTimeEngine.totalSeconds(config),
            ctaLabel: "INIZIA",
            onStart: { appState.startTimer(config: .forTime(config)) },
            configForSave: .forTime(config)
        ) {
            VStack(alignment: .leading, spacing: 24) {
                SectionLabel("Timecap")
                TimePickerView(totalSeconds: $timecapSeconds, label: "Timecap")

                SectionLabel("Round")
                NumberPickerView(value: $rounds, label: "Round", min: 1, max: 20)
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
