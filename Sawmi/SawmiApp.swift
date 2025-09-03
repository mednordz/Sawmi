import SwiftUI

/// Main application entry point
@main
struct SawmiApp: App {
    @StateObject private var store = FastDebtStore()
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if auth.currentUser == nil {
                    AuthView()
                } else {
                    HomeView()
                        .environmentObject(store)
                }
            }
            .accentColor(Color("AccentColor"))
            .preferredColorScheme(.dark)
        }
    }
}
