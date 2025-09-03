import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject private var auth = AuthService.shared

    var body: some View {
        VStack(spacing: 16) {
            TextField(NSLocalizedString("email", comment: "email"), text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            SecureField(NSLocalizedString("password", comment: "password"), text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            Button(NSLocalizedString("sign_in", comment: "sign in")) {
                _ = auth.signIn(email: email, password: password)
            }
            Button(NSLocalizedString("sign_up", comment: "sign up")) {
                auth.signUp(email: email, password: password)
            }
        }
        .padding()
    }
}
