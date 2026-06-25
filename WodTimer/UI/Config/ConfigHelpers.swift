import SwiftUI

/// Small bold section label used above pickers in config screens.
struct SectionLabel: View {
    let text: String
    private let colors = WodTheme.colors
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(colors.textSecondary)
            .textCase(.uppercase)
            .padding(.top, 8)
    }
}

/// Multiline notes field shown at the bottom of every config screen.
struct NotesFieldView: View {
    @Binding var notes: String
    private let colors = WodTheme.colors

    var body: some View {
        TextField("Aggiungi una nota...", text: $notes, axis: .vertical)
            .lineLimit(1...4)
            .font(.system(size: 15))
            .foregroundStyle(colors.textPrimary)
            .tint(colors.textPrimary)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.divider, lineWidth: 1))
    }
}

/// Collapsible WOD repeat block (rounds + rest between rounds).
struct WodRepeatView: View {
    @Binding var wodRounds: Int
    @Binding var restSeconds: Int
    private let colors = WodTheme.colors

    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(colors.divider)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Text("Ripetizioni WOD")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colors.textPrimary)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            if expanded {
                VStack(alignment: .leading, spacing: 16) {
                    NumberPickerView(value: $wodRounds, label: "Round WOD", min: 1, max: 10)

                    if wodRounds > 1 {
                        TimePickerView(totalSeconds: $restSeconds, label: "Riposo tra round", maxMinutes: 9)

                        Text(helperText)
                            .font(.system(size: 13))
                            .foregroundStyle(colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.bgSurface)
            }

            Divider().background(colors.divider)
        }
    }

    private var helperText: String {
        let m = restSeconds / 60
        let s = restSeconds % 60
        let time = m > 0
            ? String(format: "%d:%02d", m, s)
            : String(format: "0:%02d", s)
        return "Il WOD verrà ripetuto \(wodRounds) volte con \(time) di riposo tra una ripetizione e la successiva"
    }
}
