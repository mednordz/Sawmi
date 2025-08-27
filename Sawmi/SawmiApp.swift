import SwiftUI

/// Main application entry point
@main
struct SawmiApp: App {
    @StateObject private var store = FastDebtStore()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environmentObject(store)
            }
            .accentColor(Color("AccentColor"))
            .preferredColorScheme(.dark)
        }
    }
}