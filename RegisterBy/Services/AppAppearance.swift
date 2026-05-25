import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension AppSettings {
    static let appearanceKey = "appAppearance"

    static var appearance: AppAppearance {
        get {
            AppAppearance(rawValue: UserDefaults.standard.string(forKey: appearanceKey) ?? "") ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: appearanceKey)
        }
    }
}
