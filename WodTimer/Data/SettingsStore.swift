import Foundation
import Combine

enum ThemeMode: String, CaseIterable {
    case dark  = "DARK"
    case light = "LIGHT"
    case auto  = "AUTO"

    var label: String {
        switch self {
        case .dark:  return "Scuro"
        case .light: return "Chiaro"
        case .auto:  return "Automatico"
        }
    }
}

@MainActor
@Observable
final class SettingsStore {
    var masterEnabled: Bool         { didSet { save() } }
    var masterVolume: Float         { didSet { save() } }
    var countdownEnabled: Bool      { didSet { save() } }
    var halfwayEnabled: Bool        { didSet { save() } }
    var phaseTransitionEnabled: Bool { didSet { save() } }
    var completionEnabled: Bool     { didSet { save() } }
    var themeMode: ThemeMode        { didSet { save() } }

    init() {
        let d = UserDefaults.standard
        masterEnabled          = d.object(forKey: "audio_master_enabled") as? Bool ?? true
        masterVolume           = d.object(forKey: "audio_master_volume") as? Float ?? 1.0
        countdownEnabled       = d.object(forKey: "audio_countdown") as? Bool ?? true
        halfwayEnabled         = d.object(forKey: "audio_halfway") as? Bool ?? true
        phaseTransitionEnabled = d.object(forKey: "audio_phase_transition") as? Bool ?? true
        completionEnabled      = d.object(forKey: "audio_completion") as? Bool ?? true
        themeMode              = ThemeMode(rawValue: d.string(forKey: "theme_mode") ?? "") ?? .dark
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(masterEnabled,          forKey: "audio_master_enabled")
        d.set(masterVolume,           forKey: "audio_master_volume")
        d.set(countdownEnabled,       forKey: "audio_countdown")
        d.set(halfwayEnabled,         forKey: "audio_halfway")
        d.set(phaseTransitionEnabled, forKey: "audio_phase_transition")
        d.set(completionEnabled,      forKey: "audio_completion")
        d.set(themeMode.rawValue,     forKey: "theme_mode")
    }
}
