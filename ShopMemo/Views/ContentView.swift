import SwiftUI

/// アプリのルートビュー。ViewModelを生成し Environment に注入する。
struct ContentView: View {
    @State private var viewModel = ShopMemoViewModel()

    var body: some View {
        ShoppingListsView()
            .environment(viewModel)
    }
}

#Preview {
    ContentView()
}
