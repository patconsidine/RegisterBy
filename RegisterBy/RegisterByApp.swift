import SwiftUI
import SwiftData

@main
struct RegisterByApp: App {
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(purchases)
                .onAppear {
                    purchases.listenForTransactions()
                }
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
