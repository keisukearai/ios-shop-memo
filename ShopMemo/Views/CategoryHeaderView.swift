import SwiftUI

struct CategoryHeaderView: View {
    @Environment(LanguageManager.self) private var lm
    let category: ItemCategory

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.body)
                .foregroundStyle(Color.secondary)
            Text(lm.l(category.localizationKey))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
                .textCase(nil)
        }
    }
}

#Preview {
    let lm = LanguageManager()
    return List {
        Section(header: CategoryHeaderView(category: .vegetable).environment(lm)) {
            Text("にんじん")
        }
        Section(header: CategoryHeaderView(category: .meatFish).environment(lm)) {
            Text("豚肉")
        }
    }
}
