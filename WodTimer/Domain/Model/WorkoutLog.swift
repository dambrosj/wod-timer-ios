import Foundation

struct WorkoutLog: Identifiable, Codable, Hashable {
    let id: String
    let type: TimerType
    let durationSeconds: Int
    let completedAt: TimeInterval  // Unix timestamp
    var notes: String

    init(
        id: String = UUID().uuidString,
        type: TimerType,
        durationSeconds: Int,
        completedAt: TimeInterval = Date().timeIntervalSince1970,
        notes: String = ""
    ) {
        self.id = id
        self.type = type
        self.durationSeconds = durationSeconds
        self.completedAt = completedAt
        self.notes = notes
    }

    var formattedDuration: String {
        let h = durationSeconds / 3600
        let m = (durationSeconds % 3600) / 60
        let s = durationSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: completedAt))
    }
}
