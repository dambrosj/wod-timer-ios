import Foundation

enum TimerType: String, Codable, CaseIterable {
    case amrap    = "AMRAP"
    case forTime  = "FOR_TIME"
    case emom     = "EMOM"
    case tabata   = "TABATA"
    case mix      = "MIX"
    case custom   = "CUSTOM"

    var displayName: String {
        switch self {
        case .amrap:   return "AMRAP"
        case .forTime: return "FOR TIME"
        case .emom:    return "EMOM"
        case .tabata:  return "TABATA"
        case .mix:     return "MIX"
        case .custom:  return "CUSTOM"
        }
    }
}
