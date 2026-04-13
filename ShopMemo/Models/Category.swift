import Foundation

/// 商品カテゴリ。表示順は sortOrder プロパティで管理する。
enum ItemCategory: String, CaseIterable, Codable, Hashable {
    case vegetable = "野菜"
    case meatFish  = "肉・魚"
    case staple    = "主食・パン"
    case beverage  = "飲料"
    case daily     = "日用品"
    case other     = "その他"

    var displayName: String { rawValue }

    var localizationKey: String {
        switch self {
        case .vegetable: return "category_vegetable"
        case .meatFish:  return "category_meat_fish"
        case .staple:    return "category_staple"
        case .beverage:  return "category_beverage"
        case .daily:     return "category_daily"
        case .other:     return "category_other"
        }
    }

    /// カテゴリの表示順（野菜 → 肉・魚 → 主食・パン → 飲料 → 日用品 → その他）
    var sortOrder: Int {
        switch self {
        case .vegetable: return 0
        case .meatFish:  return 1
        case .staple:    return 2
        case .beverage:  return 3
        case .daily:     return 4
        case .other:     return 5
        }
    }

    var icon: String {
        switch self {
        case .vegetable: return "leaf.fill"
        case .meatFish:  return "fish.fill"
        case .staple:    return "fork.knife"
        case .beverage:  return "cup.and.saucer.fill"
        case .daily:     return "house.fill"
        case .other:     return "bag.fill"
        }
    }

    // MARK: - サジェスト

    /// 入力文字列を含むキーワードを keywordMap から返す
    /// より長いキーワードが存在する場合は完全一致の短いキーワードを除外する
    /// 例: "牛" → ["牛乳", "牛肉"]（"牛" 自体は除外）
    /// 例: "carrot" → ["carrot"]（longer がないので完全一致を返す）
    static func suggestions(matching input: String) -> [String] {
        guard !input.isEmpty else { return [] }
        let all = keywordMap.flatMap { $0.1 }.filter { $0.localizedCaseInsensitiveContains(input) }
        let longer = all.filter { $0.count > input.count }
        return longer.isEmpty ? all : longer
    }

    // MARK: - 自動分類

    /// 商品名からキーワードマッチングでカテゴリを自動判定する
    static func classify(_ name: String) -> ItemCategory {
        for (category, keywords) in keywordMap {
            if keywords.contains(where: { name.localizedCaseInsensitiveContains($0) }) {
                return category
            }
        }
        return .other
    }

    // MARK: - キーワードマップ（言語切替）

    /// システム言語が日本語かどうか
    private static var isJapanese: Bool {
        Locale.current.language.languageCode?.identifier == "ja"
    }

    /// 言語に応じたキーワードマップを返す
    private static var keywordMap: [(ItemCategory, [String])] {
        isJapanese ? japaneseKeywordMap : englishKeywordMap
    }

    /// 日本語キーワードマップ（上から順に評価される）
    private static let japaneseKeywordMap: [(ItemCategory, [String])] = [
        (.staple, [
            "パン", "食パン", "バゲット", "クロワッサン", "ロールパン", "トースト",
            "ラーメン", "インスタントラーメン", "カップラーメン", "カップ麺",
            "うどん", "そば", "パスタ", "スパゲッティ", "ペンネ", "マカロニ",
            "ライス", "ご飯", "ごはん", "お米", "米", "白米", "玄米",
            "麺", "焼きそば", "そうめん", "冷麦", "ビーフン", "フォー",
            "餅", "もち", "おにぎり", "お好み焼き粉", "小麦粉", "ホットケーキ",
            "シリアル", "オートミール", "グラノーラ"
        ]),
        (.vegetable, [
            "にんじん", "キャベツ", "かぼちゃ", "レタス", "玉ねぎ", "たまねぎ",
            "じゃがいも", "トマト", "きゅうり", "なす", "ほうれん草", "ブロッコリー",
            "ピーマン", "ねぎ", "ニンニク", "にんにく", "しょうが", "もやし",
            "大根", "だいこん", "ごぼう", "れんこん", "アスパラ", "セロリ",
            "パプリカ", "白菜", "はくさい", "野菜", "サラダ",
            "えだまめ", "枝豆", "ズッキーニ", "とうもろこし", "コーン",
            "小松菜", "チンゲン菜", "春菊", "水菜", "オクラ", "インゲン"
        ]),
        (.beverage, [
            "牛乳", "ミルク", "豆乳", "ヨーグルト",  // 乳製品は meatFish より先に評価
            "水", "お茶", "緑茶", "麦茶", "コーヒー", "紅茶", "ジュース",
            "ビール", "ワイン", "日本酒", "焼酎", "コーラ", "サイダー",
            "ポカリ", "スポーツドリンク", "炭酸", "ドリンク", "飲料",
            "アルコール", "酎ハイ", "チューハイ", "オレンジジュース", "野菜ジュース"
        ]),
        (.meatFish, [
            "牛肉", "豚肉", "鶏肉", "ひき肉", "ミンチ", "ベーコン", "ソーセージ",
            "ハム", "魚", "鮭", "さけ", "サーモン", "まぐろ", "マグロ",
            "えび", "エビ", "イカ", "いか", "タコ", "たこ", "アジ", "あじ",
            "さば", "サバ", "ぶり", "ブリ", "カツオ", "かつお", "ちくわ",
            "はんぺん", "かまぼこ", "刺身", "鶏", "豚", "牛", "シーフード",
            "ホタテ", "ほたて", "カニ", "かに", "アサリ", "あさり"
        ]),
        (.daily, [
            "シャンプー", "リンス", "コンディショナー", "石鹸", "せっけん",
            "洗剤", "柔軟剤", "ティッシュ", "トイレットペーパー", "キッチンペーパー",
            "サランラップ", "ラップ", "アルミホイル", "歯ブラシ", "歯磨き",
            "洗顔", "化粧水", "マスク", "電池", "薬", "日用品", "掃除",
            "スポンジ", "ボディソープ", "ハンドソープ", "生理用品", "おむつ",
            "ハンドクリーム", "日焼け止め", "綿棒", "ばんそうこう"
        ])
    ]

    /// 英語キーワードマップ（上から順に評価される）
    private static let englishKeywordMap: [(ItemCategory, [String])] = [
        (.staple, [
            "bread", "toast", "baguette", "croissant", "roll",
            "ramen", "noodle", "pasta", "spaghetti", "penne", "macaroni", "fettuccine",
            "rice", "brown rice", "cereal", "oatmeal", "granola",
            "udon", "soba", "vermicelli", "flour", "pancake mix"
        ]),
        (.vegetable, [
            "carrot", "cabbage", "pumpkin", "lettuce", "onion",
            "potato", "tomato", "cucumber", "eggplant", "aubergine", "spinach", "broccoli",
            "bell pepper", "pepper", "garlic", "ginger", "bean sprout",
            "radish", "burdock", "lotus root", "asparagus", "celery",
            "paprika", "bok choy", "zucchini", "courgette", "corn", "edamame",
            "komatsuna", "okra", "green bean", "kale", "leek", "vegetable", "salad"
        ]),
        (.beverage, [
            "milk", "soy milk", "yogurt", "yoghurt",  // dairy before meat
            "water", "tea", "green tea", "coffee", "juice", "beer", "wine",
            "sake", "cola", "soda", "sports drink", "drink", "alcohol",
            "orange juice", "lemonade", "smoothie", "sparkling"
        ]),
        (.meatFish, [
            "beef", "pork", "chicken", "ground meat", "minced meat", "mince",
            "bacon", "sausage", "ham", "fish", "salmon", "tuna",
            "shrimp", "prawn", "squid", "octopus", "mackerel", "yellowtail",
            "seafood", "scallop", "crab", "clam", "anchovy", "cod", "tilapia",
            "steak", "fillet", "meat"
        ]),
        (.daily, [
            "shampoo", "conditioner", "rinse", "soap", "detergent", "softener",
            "tissue", "toilet paper", "kitchen paper", "paper towel",
            "plastic wrap", "aluminum foil", "toothbrush", "toothpaste",
            "face wash", "toner", "mask", "battery", "medicine", "daily",
            "sponge", "body wash", "hand soap", "diaper", "nappy",
            "hand cream", "sunscreen", "cotton swab", "bandage", "band-aid"
        ])
    ]
}
