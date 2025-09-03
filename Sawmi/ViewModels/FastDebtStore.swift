import Foundation
import Combine

class FastDebtStore: ObservableObject {
    @Published var debts: [FastDebt] = [] {
        didSet { save() }
    }

    private let database = DatabaseService.shared
    private let auth = AuthService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        if let id = auth.currentUser?.id {
            debts = database.loadDebts(for: id)
        }
        auth.$currentUser
            .sink { [weak self] user in
                guard let self = self else { return }
                if let id = user?.id {
                    self.debts = self.database.loadDebts(for: id)
                } else {
                    self.debts = []
                }
            }
            .store(in: &cancellables)
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

    private func save() {
        guard let id = auth.currentUser?.id else { return }
        database.saveDebts(debts, for: id)
    }
}
