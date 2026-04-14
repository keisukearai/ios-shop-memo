import SwiftUI

/// 買い物リストの1行（商品名＋チェックボタン）
struct ItemRowView: View {
    let item: ShoppingItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? Color.green : Color(uiColor: .systemGray3))
                    .contentTransition(.symbolEffect(.replace))

                Text(item.name)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? Color.secondary : Color.primary)
                    .animation(.easeInOut(duration: 0.15), value: item.isChecked)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        ItemRowView(item: ShoppingItem(name: "にんじん"), onToggle: {})
        ItemRowView(
            item: {
                var i = ShoppingItem(name: "キャベツ")
                i.isChecked = true
                return i
            }(),
            onToggle: {}
        )
    }
}
