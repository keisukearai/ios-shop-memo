import Foundation

/// 買い物リストの1商品を表すモデル
struct ShoppingItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isChecked: Bool
    var category: ItemCategory
    /// カテゴリ内での表示順（小さいほど上）
    var sortOrder: Int
    var addedAt: Date

    /// 商品名からカテゴリを自動分類して初期化する
    init(id: UUID = UUID(), name: String, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.isChecked = false
        self.category = ItemCategory.classify(name)
        self.sortOrder = sortOrder
        self.addedAt = Date()
    }
}
