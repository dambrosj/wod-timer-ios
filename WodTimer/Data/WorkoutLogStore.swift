import Foundation

@Observable
final class WorkoutLogStore {
    private(set) var logs: [WorkoutLog] = []
    private let key = "wod_workout_logs_v1"

    init() { load() }

    func log(_ entry: WorkoutLog) {
        logs.insert(entry, at: 0)
        persist()
    }

    func delete(_ entry: WorkoutLog) {
        logs.removeAll { $0.id == entry.id }
        persist()
    }

    func updateNotes(id: String, notes: String) {
        guard let idx = logs.firstIndex(where: { $0.id == id }) else { return }
        logs[idx].notes = notes
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutLog].self, from: data) else { return }
        logs = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
