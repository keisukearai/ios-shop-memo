import Foundation
import Observation
import SwiftUI

/// アプリ全体の状態を管理するViewModel（複数リスト対応）
@Observable
class ShopMemoViewModel {

    // MARK: - State

    /// すべての買い物リスト（新しい順）
    var lists: [ShoppingList] = []
    /// よく使う商品の履歴（最新順）
    var itemHistory: [String] = []

    let freeLimit: Int = {
        #if DEBUG
        return 100
        #else
        return 4
        #endif
    }()

    func canCreateList(isPremium: Bool) -> Bool {
        isPremium || lists.count < freeLimit
    }

    // MARK: - Private

    private let listsKey   = "ShopMemoLists"
    private let historyKey = "ShopMemoHistory"
    private let maxHistoryCount = 30

    // MARK: - Init

    init() {
        lists = Self.loadLists()
        itemHistory = Self.loadHistory()

        // 初回起動時は今日のリストを自動作成
        if lists.isEmpty {
            createNewList()
        }
    }

    // MARK: - List Operations

    /// 新しいリストを作成して先頭に追加し、作成したリストを返す
    @discardableResult
    func createNewList(date: Date = Date()) -> ShoppingList {
        let newList = ShoppingList(date: date)
        lists.insert(newList, at: 0)
        saveLists()
        return newList
    }

    /// リストを複製して末尾に追加する（アイテムはチェックをリセット）
    func duplicateList(_ listId: UUID) {
        guard let source = lists.first(where: { $0.id == listId }) else { return }
        var newList = ShoppingList()
        newList.name = source.name
        newList.items = source.items.map { ShoppingItem(id: UUID(), name: $0.name, sortOrder: $0.sortOrder) }
        lists.append(newList)
        saveLists()
    }

    /// リストを削除する（IndexSet は lists 配列のインデックス）
    func deleteList(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets)
        saveLists()
    }

    /// リスト名を更新する
    func updateListName(_ name: String, for listId: UUID) {
        guard let i = listIndex(for: listId) else { return }
        lists[i].name = name
        saveLists()
    }

    // MARK: - Item Operations

    /// 商品を追加する
    func addItem(name: String, to listId: UUID) {
        guard let i = listIndex(for: listId) else { return }
        let category = ItemCategory.classify(name)
        let maxOrder = lists[i].items.filter { $0.category == category }.map(\.sortOrder).max() ?? -1
        lists[i].items.append(ShoppingItem(name: name, sortOrder: maxOrder + 1))
        addToHistory(name)
        saveLists()
    }

    /// チェック状態をトグルする
    func toggleItem(_ item: ShoppingItem, in listId: UUID) {
        guard let li = listIndex(for: listId),
              let ii = lists[li].items.firstIndex(where: { $0.id == item.id }) else { return }
        lists[li].items[ii].isChecked.toggle()
        saveLists()
    }

    /// スワイプ削除（カテゴリ内 IndexSet）
    func deleteItem(at offsets: IndexSet, in category: ItemCategory, listId: UUID) {
        guard let li = listIndex(for: listId) else { return }
        let catItems = sortedItems(for: category, in: listId)
        let idsToDelete = Set(offsets.map { catItems[$0].id })
        lists[li].items.removeAll { idsToDelete.contains($0.id) }
        saveLists()
    }

    /// ドラッグ＆ドロップで並び替え（カテゴリ内）
    func moveItem(from source: IndexSet, to destination: Int, in category: ItemCategory, listId: UUID) {
        guard let li = listIndex(for: listId) else { return }
        var catItems = sortedItems(for: category, in: listId)
        catItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in catItems.enumerated() {
            if let ii = lists[li].items.firstIndex(where: { $0.id == item.id }) {
                lists[li].items[ii].sortOrder = index
            }
        }
        saveLists()
    }

    /// チェック済みを一括削除する
    func deleteCheckedItems(in listId: UUID) {
        guard let li = listIndex(for: listId) else { return }
        lists[li].items.removeAll(where: \.isChecked)
        saveLists()
    }

    // MARK: - Sorting Helpers

    /// 使用中のカテゴリを表示順で返す
    func usedCategories(in listId: UUID) -> [ItemCategory] {
        guard let li = listIndex(for: listId) else { return [] }
        let usedSet = Set(lists[li].items.map(\.category))
        return ItemCategory.allCases.filter { usedSet.contains($0) }
    }

    /// カテゴリ内アイテムを sortOrder 順で返す
    func sortedItems(for category: ItemCategory, in listId: UUID) -> [ShoppingItem] {
        guard let li = listIndex(for: listId) else { return [] }
        return lists[li].items
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    /// 指定リストのアイテム一覧
    func items(in listId: UUID) -> [ShoppingItem] {
        guard let li = listIndex(for: listId) else { return [] }
        return lists[li].items
    }

    // MARK: - History

    /// 現在のリストに未追加の履歴を返す（入力中はフィルタリング）
    /// 履歴は最新10件のみ。入力がある場合はカテゴリキーワードのマッチも末尾に追加する
    func filteredHistory(for listId: UUID, input: String) -> [String] {
        let currentNames = Set(items(in: listId).map(\.name))
        if input.isEmpty {
            return itemHistory.filter { !currentNames.contains($0) }.prefix(10).map { $0 }
        } else {
            let historyMatches = Array(itemHistory.filter { !currentNames.contains($0) && $0.contains(input) }.prefix(10))
            let historySet = Set(historyMatches)
            let keywordMatches = ItemCategory.suggestions(matching: input).filter {
                !currentNames.contains($0) && !historySet.contains($0)
            }
            return historyMatches + keywordMatches
        }
    }

    private func addToHistory(_ name: String) {
        itemHistory.removeAll { $0 == name }
        itemHistory.insert(name, at: 0)
        if itemHistory.count > maxHistoryCount {
            itemHistory = Array(itemHistory.prefix(maxHistoryCount))
        }
        saveHistory()
    }

    // MARK: - Private Helpers

    private func listIndex(for id: UUID) -> Int? {
        lists.firstIndex { $0.id == id }
    }

    // MARK: - Persistence（UserDefaults + JSON）

    private func saveLists() {
        guard let data = try? JSONEncoder().encode(lists) else { return }
        UserDefaults.standard.set(data, forKey: listsKey)
    }

    private static func loadLists() -> [ShoppingList] {
        guard let data = UserDefaults.standard.data(forKey: "ShopMemoLists"),
              let lists = try? JSONDecoder().decode([ShoppingList].self, from: data)
        else { return [] }
        return lists
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(itemHistory) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }

    private static func loadHistory() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: "ShopMemoHistory"),
              let history = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return history
    }
}
