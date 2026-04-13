import SwiftUI

/// キーボード表示中に過去の商品をサジェストする2行横スクロールビュー
struct HistorySuggestionsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    private let rows = [
        GridItem(.fixed(32), spacing: 8),
        GridItem(.fixed(32), spacing: 8)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(suggestions.prefix(30), id: \.self) { suggestion in
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
        .frame(height: 80)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    HistorySuggestionsView(
        suggestions: ["にんじん", "キャベツ", "豚肉", "コーヒー", "ティッシュ"],
        onSelect: { _ in }
    )
}
