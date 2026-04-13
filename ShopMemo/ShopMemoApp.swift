import SwiftUI

@main
struct ShopMemoApp: App {
    @State private var languageManager = LanguageManager()
    @State private var purchaseService = PurchaseService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
                .environment(purchaseService)
        }
    }
}
