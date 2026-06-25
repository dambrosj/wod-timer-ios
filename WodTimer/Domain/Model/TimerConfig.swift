import Foundation

struct WodRepeatConfig: Codable, Equatable {
    var wodRounds: Int = 1
    var restBetweenRoundsSeconds: Int = 0
}

struct CustomInterval: Codable, Equatable {
    var name: String = ""
    var durationSeconds: Int = 30
}

struct TabataSet: Codable, Equatable {
    var series: Int
    var workSeconds: Int
    var restSeconds: Int
}

// Mirrors Kotlin sealed class TimerConfig
enum TimerConfig: Codable {
    case amrap(Amrap)
    case forTime(ForTime)
    case emom(Emom)
    case tabata(Tabata)
    case custom(Custom)

    // MARK: – Nested types

    struct Amrap: Codable, Equatable {
        var durationSeconds: Int
        var exercises: [String] = []
        var exerciseReps: [Int] = []
        var exerciseMinReps: [Int] = []
        var notes: String = ""
        var wodRepeat: WodRepeatConfig = WodRepeatConfig()
    }

    struct ForTime: Codable, Equatable {
        var timecapSeconds: Int
        var rounds: Int = 1
        var exercises: [String] = []
        var exerciseReps: [Int] = []
        var exerciseMinReps: [Int] = []
        var notes: String = ""
        var wodRepeat: WodRepeatConfig = WodRepeatConfig()
    }

    struct Emom: Codable, Equatable {
        var totalMinutes: Int
        var intervalSeconds: Int = 60
        var exercises: [String] = []
        var notes: String = ""
        var wodRepeat: WodRepeatConfig = WodRepeatConfig()
    }

    struct Tabata: Codable, Equatable {
        var series: Int
        var workSeconds: Int
        var restSeconds: Int
        var sets: [TabataSet] = []
        var exercises: [String] = []
        var notes: String = ""
        var wodRepeat: WodRepeatConfig = WodRepeatConfig()
    }

    struct Custom: Codable, Equatable {
        var intervals: [CustomInterval] = []
        var notes: String = ""
        var wodRepeat: WodRepeatConfig = WodRepeatConfig()
    }

    // MARK: – Helpers

    var timerType: TimerType {
        switch self {
        case .amrap:   return .amrap
        case .forTime: return .forTime
        case .emom:    return .emom
        case .tabata:  return .tabata
        case .custom:  return .custom
        }
    }

    var notes: String {
        switch self {
        case .amrap(let c):   return c.notes
        case .forTime(let c): return c.notes
        case .emom(let c):    return c.notes
        case .tabata(let c):  return c.notes
        case .custom(let c):  return c.notes
        }
    }

    var wodRepeat: WodRepeatConfig {
        switch self {
        case .amrap(let c):   return c.wodRepeat
        case .forTime(let c): return c.wodRepeat
        case .emom(let c):    return c.wodRepeat
        case .tabata(let c):  return c.wodRepeat
        case .custom(let c):  return c.wodRepeat
        }
    }

    // MARK: – JSON helpers

    func encoded() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func decoded(from json: String) throws -> TimerConfig {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(TimerConfig.self, from: data)
    }
}
