import Foundation

class DatabaseService {
    static let shared = DatabaseService()
    private let fileManager = FileManager.default
    private init() {}

    func loadDebts(for userId: UUID) throws -> [FastDebt] {
        let url = fileURL(for: userId)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([FastDebt].self, from: data)
        } catch {
            print("Failed to load debts: \(error)")
            do {
                if let migrated = try migrateFromUserDefaults(for: userId) {
                    return migrated
                }
            } catch {
                print("Migration failed: \(error)")
                throw error
            }
            throw error
        }
    }

    func saveDebts(_ debts: [FastDebt], for userId: UUID) throws {
        let url = fileURL(for: userId)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(debts)
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save debts: \(error)")
            throw error
        }
    }

    private func fileURL(for userId: UUID) -> URL {
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return dir.appendingPathComponent("debts_\(userId.uuidString).json")
    }

    private func migrateFromUserDefaults(for userId: UUID) throws -> [FastDebt]? {
        let storage = Storage()
        var debts = storage.load()
        guard !debts.isEmpty else { return nil }
        debts = debts.map { debt in
            var d = debt
            d.userId = userId
            return d
        }
        do {
            try saveDebts(debts, for: userId)
            storage.clear()
            return debts
        } catch {
            print("Failed to migrate debts: \(error)")
            throw error
        }
    }
}
