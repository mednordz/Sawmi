import XCTest
@testable import Sawmi

final class StorageTests: XCTestCase {
    func testSaveAndLoad() {
        let defaults = UserDefaults(suiteName: "StorageTests")!
        defaults.removePersistentDomain(forName: "StorageTests")
        let storage = Storage(defaults: defaults)
        let userId = UUID()
        let debts = [
            FastDebt(id: UUID(), userId: userId, date: Date(), note: "A"),
            FastDebt(id: UUID(), userId: userId, date: Date().addingTimeInterval(86400), note: "B")
        ]
        storage.save(debts)
        let loaded = storage.load()
        XCTAssertEqual(loaded.count, debts.count)
    }
}
