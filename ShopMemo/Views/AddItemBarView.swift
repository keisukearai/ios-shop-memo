import SwiftUI

struct AddItemBarView: View {
    @Environment(LanguageManager.self) private var lm
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onAdd: () -> Void

    private var isAddable: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField(lm.l("item_name_placeholder"), text: $text)
                .textFieldStyle(.roundedBorder)
                .focused(isFocused)
                .submitLabel(.return)
                .onSubmit(onAdd)
                .autocorrectionDisabled()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isAddable ? Color.accentColor : Color.secondary)
            }
            .disabled(!isAddable)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemBackground))
    }
}
