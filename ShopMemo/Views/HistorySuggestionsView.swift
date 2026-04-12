import SwiftUI

/// キーボード表示中に過去の商品をサジェストする横スクロールビュー
struct HistorySuggestionsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions.prefix(15), id: \.self) { suggestion in
                    Button {
                        onSelect(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Capsule())
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    HistorySuggestionsView(
        suggestions: ["にんじん", "キャベツ", "豚肉", "コーヒー", "ティッシュ"],
        onSelect: { _ in }
    )
}
