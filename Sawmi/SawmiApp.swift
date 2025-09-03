import SwiftUI

/// Main application entry point
@main
struct SawmiApp: App {
    @StateObject private var store = FastDebtStore()
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.currentUser == nil {
                    AuthView()
                } else {
                    TabView {
                        NavigationStack { HomeView() }
                            .tabItem {
                                Label(NSLocalizedString("home", comment: "home"), systemImage: "house")
                            }
                        NavigationStack { SettingsView() }
                            .tabItem {
                                Label(NSLocalizedString("settings", comment: "settings"), systemImage: "gear")
                            }
                        NavigationStack { ProfileView() }
                            .tabItem {
                                Label(NSLocalizedString("profile", comment: "profile"), systemImage: "person")
                            }
                    }
                    .environmentObject(store)
                }
            }
            .accentColor(Color("AccentColor"))
            .preferredColorScheme(.dark)
        }
    }
}
