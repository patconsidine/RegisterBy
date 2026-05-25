import SwiftUI

struct RootView: View {
    @AppStorage(AppSettings.onboardingKey) private var hasCompletedOnboarding = false
    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}
