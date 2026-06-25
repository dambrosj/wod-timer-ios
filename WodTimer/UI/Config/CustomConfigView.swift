import SwiftUI

struct CustomConfigView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors

    @State private var intervals: [CustomInterval] = [CustomInterval()]
    @State private var wodRounds = 1
    @State private var restSeconds = 0

    @State private var editingInterval: Int?
    @State private var tempMinutes = 0
    @State private var tempSeconds = 30
    @State private var notes = ""

    private var config: TimerConfig.Custom {
        TimerConfig.Custom(intervals: intervals,
                           notes: notes,
                           wodRepeat: WodRepeatConfig(wodRounds: wodRounds, restBetweenRoundsSeconds: restSeconds))
    }

    var body: some View {
        ConfigScaffold(
            title: "CUSTOM",
            accentColor: colors.accentCustom,
            totalSeconds: CustomEngine.totalSeconds(config),
            ctaLabel: "INIZIA",
            onStart: { appState.startTimer(config: .custom(config)) },
            configForSave: .custom(config)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                SectionLabel("Intervalli")

                ForEach(intervals.indices, id: \.self) { i in
                    HStack(spacing: 8) {
                        Text("\(i + 1).")
                            .font(.caption).foregroundStyle(colors.textDisabled).frame(width: 22, alignment: .trailing)

                        TextField("Nome intervallo", text: $intervals[i].name)
                            .font(.system(size: 15))
                            .foregroundStyle(colors.textPrimary)
                            .tint(colors.accentCustom)

                        // Duration badge
                        Button {
                            tempMinutes = intervals[i].durationSeconds / 60
                            tempSeconds = intervals[i].durationSeconds % 60
                            editingInterval = i
                        } label: {
                            Text(String(format: "%02d:%02d",
                                        intervals[i].durationSeconds / 60,
                                        intervals[i].durationSeconds % 60))
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundStyle(colors.textPrimary)
                                .frame(width: 70, height: 36)
                                .background(colors.bgElevated, in: RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.accentCustom, lineWidth: 1))
                        }

                        if intervals.count > 1 {
                            Button { intervals.remove(at: i) } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13))
                                    .foregroundStyle(colors.textDisabled)
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                }

                Button { intervals.append(CustomInterval()) } label: {
                    Label("Aggiungi intervallo", systemImage: "plus")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(colors.accentCustom)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                }

                Divider().background(colors.divider).padding(.top, 8)

                WodRepeatView(wodRounds: $wodRounds, restSeconds: $restSeconds)

                SectionLabel("Note")
                NotesFieldView(notes: $notes)
            }
            .padding(.top, 24)
        }
        .sheet(isPresented: Binding(get: { editingInterval != nil }, set: { if !$0 { editingInterval = nil } })) {
            durationSheet
                .presentationDetents([.medium])
                .presentationBackground(colors.bgPrimary)
        }
    }

    private var durationSheet: some View {
        let minuteItems = (0...59).map { String(format: "%02d", $0) }
        let secondItems = (0...59).map { String(format: "%02d", $0) }

        return VStack(spacing: 0) {
            Text("Durata intervallo")
                .font(.subheadline).foregroundStyle(colors.textSecondary).padding(.top, 16)

            HStack {
                WheelPickerView(items: minuteItems, selectedIndex: $tempMinutes)
                Text(":").font(.system(size: 28, weight: .bold)).foregroundStyle(colors.textPrimary)
                WheelPickerView(items: secondItems, selectedIndex: $tempSeconds)
            }
            .padding(.horizontal)

            Button {
                if let i = editingInterval {
                    intervals[i].durationSeconds = max(1, tempMinutes * 60 + tempSeconds)
                }
                editingInterval = nil
            } label: {
                Text("Conferma")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(colors.accentCustom, in: RoundedRectangle(cornerRadius: 999))
            }
            .padding(.horizontal, 24).padding(.bottom, 32)
        }
    }
}
