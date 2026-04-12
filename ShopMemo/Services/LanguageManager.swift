import Foundation
import Observation

enum Language: String, CaseIterable, Identifiable {
    case system     = "system"
    case english    = "en"
    case japanese   = "ja"
    case chinese    = "zh-Hans"
    case vietnamese = "vi"
    case thai       = "th"
    case french     = "fr"
    case portuguese = "pt-BR"
    case spanish    = "es"
    case german     = "de"
    case hindi      = "hi"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .system:     return "System Default"
        case .english:    return "English"
        case .japanese:   return "日本語"
        case .chinese:    return "中文（简体）"
        case .vietnamese: return "Tiếng Việt"
        case .thai:       return "ภาษาไทย"
        case .french:     return "Français"
        case .portuguese: return "Português"
        case .spanish:    return "Español"
        case .german:     return "Deutsch"
        case .hindi:      return "हिन्दी"
        }
    }

    var badge: String {
        switch self {
        case .system:     return "AUTO"
        case .english:    return "EN"
        case .japanese:   return "JA"
        case .chinese:    return "ZH"
        case .vietnamese: return "VI"
        case .thai:       return "TH"
        case .french:     return "FR"
        case .portuguese: return "PT"
        case .spanish:    return "ES"
        case .german:     return "DE"
        case .hindi:      return "HI"
        }
    }

    var bundle: Bundle {
        guard self != .system,
              let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let b    = Bundle(path: path) else { return .main }
        return b
    }
}

@Observable
final class LanguageManager {
    private static let key = "app_language"

    private(set) var currentLanguage: Language
    private(set) var bundle: Bundle

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key)
        let lang  = Language(rawValue: saved ?? "system") ?? .system
        currentLanguage = lang
        bundle          = lang.bundle
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
        bundle          = language.bundle
        UserDefaults.standard.set(language.rawValue, forKey: Self.key)
    }

    func l(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    func lf(_ key: String, _ args: CVarArg...) -> String {
        String(format: l(key), arguments: args)
    }
}
