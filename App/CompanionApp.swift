import SwiftUI

@main
struct CompanionApp: App {
    @StateObject private var store = CompanionStore.shared
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(purchaseManager)
                .preferredColorScheme(.light)
                .tint(Theme.accent)
        }
    }
}
