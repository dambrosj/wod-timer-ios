import SwiftUI

/// Tappable MM:SS badge that opens a sheet with two wheel pickers.
struct TimePickerView: View {
    @Binding var totalSeconds: Int
    var label: String = ""
    var maxMinutes: Int = 99

    @State private var showSheet = false
    @State private var tempMinutes = 0
    @State private var tempSeconds = 0

    private let colors = WodTheme.colors
    private let minuteItems: [String]
    private let secondItems = (0...59).map { String(format: "%02d", $0) }

    init(totalSeconds: Binding<Int>, label: String = "", maxMinutes: Int = 99) {
        self._totalSeconds = totalSeconds
        self.label = label
        self.maxMinutes = maxMinutes
        self.minuteItems = (0...maxMinutes).map { String(format: "%02d", $0) }
    }

    var displayText: String {
        String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    var body: some View {
        HStack(spacing: 20) {
            Button { showSheet = true } label: {
                Text(displayText)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .frame(width: 110, height: 68)
                    .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colors.accentTabata, lineWidth: 2)
                    )
            }
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(colors.textPrimary)
            }
            Spacer()
        }
        .sheet(isPresented: $showSheet) {
            sheetContent
                .presentationDetents([.medium])
                .presentationBackground(colors.bgPrimary)
        }
        .onAppear { sync() }
        .onChange(of: totalSeconds) { sync() }
    }

    private func sync() {
        tempMinutes = min(totalSeconds / 60, maxMinutes)
        tempSeconds = totalSeconds % 60
    }

    private var sheetContent: some View {
        VStack(spacing: 0) {
            if !label.isEmpty {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(colors.textSecondary)
                    .padding(.top, 16)
            }
            HStack {
                WheelPickerView(items: minuteItems, selectedIndex: $tempMinutes)
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colors.textPrimary)
                WheelPickerView(items: secondItems, selectedIndex: $tempSeconds)
            }
            .padding(.horizontal)

            Button {
                totalSeconds = max(1, tempMinutes * 60 + tempSeconds)
                showSheet = false
            } label: {
                Text("Conferma")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(colors.accentTabata, in: RoundedRectangle(cornerRadius: 999))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
