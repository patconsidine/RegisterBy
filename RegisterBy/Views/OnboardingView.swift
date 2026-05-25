import SwiftUI

struct OnboardingView: View {
    @AppStorage(AppSettings.onboardingKey) private var hasCompletedOnboarding = false
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                onboardingPage(
                    title: "Don't lose warranty money",
                    body: "Many products need online registration within 30–90 days. Most people forget—or lose the receipt when something breaks.",
                    systemImage: "exclamationmark.shield"
                )
                .tag(0)

                onboardingPage(
                    title: "Three dates. One place.",
                    body: "Register by — for full manufacturer coverage.\nReturn by — store return windows.\nWarranty ends — claim before coverage runs out.",
                    systemImage: "calendar.badge.clock"
                )
                .tag(1)

                onboardingPage(
                    title: "Your receipts stay on your iPhone",
                    body: "No account. No cloud upload. We'll remind you about your items—only if you allow notifications.",
                    systemImage: "lock.shield"
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                if page < 2 {
                    Button("Continue") { withAnimation { page += 1 } }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                } else {
                    Button("Get started") {
                        Task {
                            _ = await NotificationScheduler.requestAuthorization()
                            await MainActor.run {
                                hasCompletedOnboarding = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Skip for now") {
                        hasCompletedOnboarding = true
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }

    private func onboardingPage(title: String, body: String, systemImage: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}
