import Foundation

class FastDebtStore: ObservableObject {
    @Published var debts: [FastDebt] = [] {
        didSet {
            storage.save(debts)
        }
    }

    private let storage = Storage()

    init() {
        debts = storage.load()
    }

    func add(date: Date, note: String?) {
        let debt = FastDebt(id: UUID(), date: date, note: note)
        debts.append(debt)
    }

    func remove(_ debt: FastDebt) {
        debts.removeAll { $0.id == debt.id }
    }

    func remaining(target: Int) -> Int {
        max(target - debts.count, 0)
    }
}
