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
            do {
                debts = try database.loadDebts(for: id)
            } catch {
                print("Failed to load debts: \(error)")
                debts = []
            }
        }
        auth.$currentUser
            .sink { [weak self] user in
                guard let self = self else { return }
                if let id = user?.id {
                    do {
                        self.debts = try self.database.loadDebts(for: id)
                    } catch {
                        print("Failed to load debts: \(error)")
                        self.debts = []
                    }
                } else {
                    self.debts = []
                }
            }
            .store(in: &cancellables)
    }

    func add(date: Date, note: String?, userId: UUID) {
        let debt = FastDebt(id: UUID(), userId: userId, date: date, note: note)
        debts.append(debt)
    }

    func remove(_ debt: FastDebt) {
        guard auth.currentUser?.id == debt.userId else { return }
        debts.removeAll { $0.id == debt.id && $0.userId == debt.userId }
    }

    func remaining(target: Int) -> Int {
        guard let id = auth.currentUser?.id else { return target }
        let count = debts.filter { $0.userId == id }.count
        return max(target - count, 0)
    }

    private func save() {
        guard let id = auth.currentUser?.id else { return }
        let userDebts = debts.filter { $0.userId == id }
        do {
            try database.saveDebts(userDebts, for: id)
        } catch {
            print("Failed to save debts: \(error)")
        }
    }
}
