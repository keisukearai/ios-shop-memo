import SwiftUI

struct ItemListView: View {
    @Environment(ShopMemoViewModel.self) private var viewModel
    @Environment(LanguageManager.self) private var lm
    let listId: UUID

    @State private var newItemName: String = ""
    @State private var isEditingName = false
    @State private var editedName = ""
    @FocusState private var isInputFocused: Bool

    private var listName: String {
        viewModel.lists.first { $0.id == listId }?.name ?? ""
    }

    private var hasCheckedItems: Bool {
        viewModel.items(in: listId).contains(where: \.isChecked)
    }

    var body: some View {
        List {
            ForEach(viewModel.usedCategories(in: listId), id: \.self) { category in
                Section {
                    ForEach(viewModel.sortedItems(for: category, in: listId)) { item in
                        ItemRowView(item: item) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleItem(item, in: listId)
                            }
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteItem(at: offsets, in: category, listId: listId)
                    }
                    .onMove { source, destination in
                        viewModel.moveItem(from: source, to: destination, in: category, listId: listId)
                    }
                } header: {
                    CategoryHeaderView(category: category)
                }
            }

            if hasCheckedItems {
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteCheckedItems(in: listId)
                        }
                    } label: {
                        Label(lm.l("delete_checked_button"), systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }

            if viewModel.items(in: listId).isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.secondary.opacity(0.35))
                        Text(lm.l("empty_list_hint"))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                if isInputFocused {
                    let suggestions = viewModel.filteredHistory(for: listId, input: newItemName)
                    if !suggestions.isEmpty {
                        HistorySuggestionsView(suggestions: suggestions) { name in
                            viewModel.addItem(name: name, to: listId)
                            newItemName = ""
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                AddItemBarView(
                    text: $newItemName,
                    isFocused: $isInputFocused
                ) {
                    let trimmed = newItemName.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    viewModel.addItem(name: trimmed, to: listId)
                    newItemName = ""
                }
            }
            .background(Color(UIColor.systemBackground))
            .animation(.easeInOut(duration: 0.2), value: isInputFocused)
        }
        .navigationTitle(listName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    editedName = listName
                    isEditingName = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .alert(lm.l("rename_list_title"), isPresented: $isEditingName) {
            TextField(lm.l("list_name_placeholder"), text: $editedName)
            Button(lm.l("change_button")) {
                let trimmed = editedName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    viewModel.updateListName(trimmed, for: listId)
                }
            }
            Button(lm.l("cancel_button"), role: .cancel) {}
        }
    }
}

#Preview {
    let vm = ShopMemoViewModel()
    let lm = LanguageManager()
    let listId = vm.lists.first!.id
    return NavigationStack {
        ItemListView(listId: listId)
    }
    .environment(vm)
    .environment(lm)
}
