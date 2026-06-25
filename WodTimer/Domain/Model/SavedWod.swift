import Foundation

struct SavedWod: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var type: TimerType
    var configJson: String
    var description: String = ""
    var tags: [String] = []
    var createdAt: Double
    var lastUsedAt: Double? = nil
    var timesUsed: Int = 0
    var isFavourite: Bool = false
    var isBuiltIn: Bool = false

    static func make(name: String, description: String = "", config: TimerConfig) throws -> SavedWod {
        SavedWod(
            id: UUID().uuidString,
            name: name,
            type: config.timerType,
            configJson: try config.encoded(),
            description: description,
            createdAt: Date().timeIntervalSince1970
        )
    }

    func timerConfig() -> TimerConfig? {
        try? TimerConfig.decoded(from: configJson)
    }

    var formattedDate: String {
        let d = Date(timeIntervalSince1970: createdAt)
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: d)
    }
}
