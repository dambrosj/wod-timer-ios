import Foundation

@MainActor
final class SavedWodStore {
    private static let key = "saved_wods_v1"

    private(set) var wods: [SavedWod] = []

    init() {
        load()
        seedBuiltIns()
    }

    func save(_ wod: SavedWod) {
        if let idx = wods.firstIndex(where: { $0.id == wod.id }) {
            wods[idx] = wod
        } else {
            wods.insert(wod, at: 0)
        }
        persist()
    }

    func delete(_ wod: SavedWod) {
        wods.removeAll { $0.id == wod.id }
        persist()
    }

    func toggleFavourite(_ wod: SavedWod) {
        if let idx = wods.firstIndex(where: { $0.id == wod.id }) {
            wods[idx].isFavourite.toggle()
            persist()
        }
    }

    func recordUsage(_ wod: SavedWod) {
        if let idx = wods.firstIndex(where: { $0.id == wod.id }) {
            wods[idx].timesUsed += 1
            wods[idx].lastUsedAt = Date().timeIntervalSince1970
            persist()
        }
    }

    func duplicate(_ wod: SavedWod) {
        var copy = wod
        copy.id = UUID().uuidString
        copy.name = "\(wod.name) (copia)"
        copy.isBuiltIn = false
        copy.timesUsed = 0
        copy.lastUsedAt = nil
        copy.createdAt = Date().timeIntervalSince1970
        wods.insert(copy, at: 0)
        persist()
    }

    private func seedBuiltIns() {
        let existingIds = Set(wods.map(\.id))
        let seeds = BuiltInWods.all.filter { !existingIds.contains($0.id) }
        wods.append(contentsOf: seeds)
        if !seeds.isEmpty { persist() }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(wods) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([SavedWod].self, from: data) else { return }
        wods = decoded
    }
}
