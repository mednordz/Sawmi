import Foundation

struct Storage {
    private let key = "fastDebts.json"
    private var defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [FastDebt] {
        guard let data = defaults.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([FastDebt].self, from: data)) ?? []
    }

    func save(_ debts: [FastDebt]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(debts) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
