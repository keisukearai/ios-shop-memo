import SwiftUI

@main
struct ShopMemoApp: App {
    @State private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
        }
    }
}
