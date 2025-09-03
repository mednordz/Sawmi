import Foundation
import Security
import CryptoKit

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published private(set) var currentUser: User?

    private let service = "com.sawmi.auth"
    private let userIdKey = "userId"
    private let emailKey = "email"
    private let passwordKey = "passwordHash"

    private init() {
        if let id = loadUserId(),
           let email = loadValue(for: emailKey),
           let hash = loadValue(for: passwordKey) {
            currentUser = User(id: id, email: email, passwordHash: hash)
        }
    }

    func signUp(email: String, password: String) {
        let hashedPassword = hash(password)
        let user = User(id: UUID(), email: email, passwordHash: hashedPassword)
        saveValue(user.id.uuidString, for: userIdKey)
        saveValue(email, for: emailKey)
        saveValue(hashedPassword, for: passwordKey)
        currentUser = user
    }

    @discardableResult
    func signIn(email: String, password: String) -> Bool {
        guard let storedEmail = loadValue(for: emailKey),
              let storedHash = loadValue(for: passwordKey),
              storedEmail == email,
              hash(password) == storedHash,
              let id = loadUserId() else {
            return false
        }
        currentUser = User(id: id, email: email, passwordHash: storedHash)
        return true
    }

    func signOut() {
        deleteValue(for: userIdKey)
        deleteValue(for: emailKey)
        deleteValue(for: passwordKey)
        currentUser = nil
    }

    // MARK: - Keychain
    private func saveValue(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

    private func loadUserId() -> UUID? {
        guard let str = loadValue(for: userIdKey) else { return nil }
        return UUID(uuidString: str)
    }

    private func deleteValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func hash(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
