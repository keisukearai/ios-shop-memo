import SwiftUI

struct ShoppingListsView: View {
    @Environment(ShopMemoViewModel.self) private var viewModel
    @Environment(LanguageManager.self) private var lm
    @State private var showingLanguage = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.lists.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingLanguage = true } label: {
                        Image(systemName: "globe")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.createNewList()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingLanguage) {
                LanguageSettingsView()
            }
        }
    }

    // MARK: - Sub Views

    private var listContent: some View {
        List {
            ForEach(viewModel.lists) { list in
                NavigationLink {
                    ItemListView(listId: list.id)
                } label: {
                    ShoppingListRowView(list: list)
                }
                .contextMenu {
                    Button {
                        viewModel.duplicateList(list.id)
                    } label: {
                        Label(lm.l("duplicate_list_button"), systemImage: "doc.on.doc")
                    }
                }
            }
            .onDelete { offsets in
                viewModel.deleteList(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundStyle(Color.secondary.opacity(0.35))
            Text(lm.l("empty_lists_message"))
                .font(.title3)
                .foregroundStyle(Color.secondary)
            Button {
                viewModel.createNewList()
            } label: {
                Label(lm.l("create_list_button"), systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row View

struct ShoppingListRowView: View {
    @Environment(LanguageManager.self) private var lm
    let list: ShoppingList

    private var totalCount: Int { list.items.count }
    private var checkedCount: Int { list.items.filter(\.isChecked).count }
    private var allChecked: Bool { totalCount > 0 && checkedCount == totalCount }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: allChecked ? "checkmark.circle.fill" : "cart")
                .font(.title2)
                .foregroundStyle(allChecked ? Color.green : Color.accentColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(list.name)
                        .font(.headline)
                    if allChecked {
                        Text("Complete")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green, in: Capsule())
                    }
                }

                HStack(spacing: 6) {
                    if totalCount == 0 {
                        Text(lm.l("no_items"))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    } else {
                        Text(lm.lf("item_count", totalCount))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)

                        if checkedCount > 0 {
                            Text("·")
                                .foregroundStyle(Color.secondary)
                            Text(lm.lf("checked_count", checkedCount))
                                .font(.subheadline)
                                .foregroundStyle(Color.green)
                        }
                    }
                    Spacer()
                    Text(relativeDateString(list.createdAt))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(
            allChecked
                ? Color.green.opacity(0.08)
                : Color(UIColor.secondarySystemGroupedBackground)
        )
    }

    private func relativeDateString(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: targetDay, to: today).day ?? 0
        switch diff {
        case 0:  return lm.l("date_today")
        case 1:  return lm.l("date_yesterday")
        default:
            let fmt = DateFormatter()
            fmt.dateFormat = "M/d"
            return fmt.string(from: date)
        }
    }
}

#Preview {
    let vm = ShopMemoViewModel()
    let lm = LanguageManager()
    return ShoppingListsView()
        .environment(vm)
        .environment(lm)
}
