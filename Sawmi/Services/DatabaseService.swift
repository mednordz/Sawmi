import Foundation

class DatabaseService {
    static let shared = DatabaseService()
    private let fileManager = FileManager.default
    private init() {}

    func loadDebts(for userId: UUID) -> [FastDebt] {
        let url = fileURL(for: userId)
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let debts = try? decoder.decode([FastDebt].self, from: data) {
                return debts
            }
        }
        if let migrated = migrateFromUserDefaults(for: userId) {
            return migrated
        }
        return []
    }

    func saveDebts(_ debts: [FastDebt], for userId: UUID) {
        let url = fileURL(for: userId)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(debts) {
            try? fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: url, options: .atomic)
        }
    }

    private func fileURL(for userId: UUID) -> URL {
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return dir.appendingPathComponent("debts_\(userId.uuidString).json")
    }

    private func migrateFromUserDefaults(for userId: UUID) -> [FastDebt]? {
        let storage = Storage()
        let debts = storage.load()
        guard !debts.isEmpty else { return nil }
        saveDebts(debts, for: userId)
        storage.clear()
        return debts
    }
}
