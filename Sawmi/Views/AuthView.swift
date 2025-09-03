import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject private var auth = AuthService.shared

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            Button("Sign In") {
                _ = auth.signIn(email: email, password: password)
            }
            Button("Sign Up") {
                auth.signUp(email: email, password: password)
            }
        }
        .padding()
    }
}
