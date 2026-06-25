import SwiftUI

/// Inline +/− stepper for small integer values (rounds, series count, etc.).
struct NumberPickerView: View {
    @Binding var value: Int
    var label: String = ""
    var min: Int = 1
    var max: Int = 99

    private let colors = WodTheme.colors

    var body: some View {
        HStack(spacing: 16) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 17))
                    .foregroundStyle(colors.textPrimary)
                Spacer()
            }

            HStack(spacing: 0) {
                Button {
                    if value > min { value -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                        .foregroundStyle(value > min ? colors.textPrimary : colors.textDisabled)
                }

                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .frame(minWidth: 48)

                Button {
                    if value < max { value += 1 }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                        .foregroundStyle(value < max ? colors.textPrimary : colors.textDisabled)
                }
            }
            .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(colors.divider, lineWidth: 1))
        }
    }
}
