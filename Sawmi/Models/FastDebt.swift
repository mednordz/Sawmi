import Foundation

struct FastDebt: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var date: Date
    var note: String?
}
