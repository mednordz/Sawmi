import SwiftUI

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
