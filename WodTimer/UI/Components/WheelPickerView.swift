import SwiftUI

// iOS-style drum-roll wheel picker wrapping the native Picker(.wheel) style.
struct WheelPickerView: View {
    let items: [String]
    @Binding var selectedIndex: Int
    private let colors = WodTheme.colors

    var body: some View {
        Picker("", selection: $selectedIndex) {
            ForEach(items.indices, id: \.self) { i in
                Text(items[i])
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .tag(i)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 200)
    }
}
