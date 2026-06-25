import SwiftUI

struct WodTheme {
    static let colors = WodColors()
    static let spacing = WodSpacing()
}

struct WodColors {
    let bgPrimary   = Color(hex: "#0D0D0D")
    let bgSurface   = Color(hex: "#1A1A1A")
    let bgElevated  = Color(hex: "#242424")

    let textPrimary   = Color.white
    let textSecondary = Color(hex: "#8C8C8C")
    let textDisabled  = Color(hex: "#404040")

    let divider     = Color(hex: "#2A2A2A")
    let iconDefault = Color(hex: "#8C8C8C")

    let success = Color(hex: "#4CAF50")
    let error   = Color(hex: "#F44336")

    let phaseWork   = Color(hex: "#4CAF50")  // green
    let phaseRest   = Color(hex: "#9C27B0")  // purple
    let phaseWodRest = Color(hex: "#FF9800") // orange

    let accentAmrap   = Color(hex: "#4CAF50")
    let accentForTime = Color(hex: "#2196F3")
    let accentEmom    = Color(hex: "#FF9800")
    let accentTabata  = Color(hex: "#E91E63")
    let accentCustom  = Color(hex: "#3DBD8E")
    let accentMix     = Color(hex: "#5C677D")

    func accent(for type: TimerType) -> Color {
        switch type {
        case .amrap:   return accentAmrap
        case .forTime: return accentForTime
        case .emom:    return accentEmom
        case .tabata:  return accentTabata
        case .custom:  return accentCustom
        case .mix:     return accentTabata
        }
    }
}

struct WodSpacing {
    let xs: CGFloat = 4
    let s: CGFloat  = 8
    let m: CGFloat  = 16
    let l: CGFloat  = 24
    let xl: CGFloat = 32
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
