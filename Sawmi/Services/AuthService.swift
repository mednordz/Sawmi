import Foundation
import Security

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published private(set) var currentUser: User?

    private let service = "com.sawmi.auth"
    private let accountKey = "userId"

    private init() {
        if let id = loadUserId() {
            currentUser = User(id: id, email: "", passwordHash: "")
        }
    }

    func signUp(email: String, password: String) {
        let user = User(id: UUID(), email: email, passwordHash: hash(password))
        saveUserId(user.id)
        currentUser = user
    }

    @discardableResult
    func signIn(email: String, password: String) -> Bool {
        guard let id = loadUserId() else { return false }
        currentUser = User(id: id, email: email, passwordHash: hash(password))
        return true
    }

    func signOut() {
        deleteUserId()
        currentUser = nil
    }

    // MARK: - Keychain
    private func saveUserId(_ id: UUID) {
        guard let data = id.uuidString.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadUserId() -> UUID? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let str = String(data: data, encoding: .utf8),
              let uuid = UUID(uuidString: str) else {
            return nil
        }
        return uuid
    }

    private func deleteUserId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func hash(_ password: String) -> String {
        String(password.reversed())
    }
}
