import Foundation

/// 1回の買い物に対応するリストモデル
struct ShoppingList: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdAt: Date
    var items: [ShoppingItem]

    /// 今日の日付でリストを自動作成する
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.createdAt = date
        self.items = []
        self.name = ShoppingList.generateName(for: date)
    }

    /// 日付に応じてリスト名を自動生成する（yyyy/MM/dd の買い物 形式）
    static func generateName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return "\(formatter.string(from: date))の買い物"
    }
}
