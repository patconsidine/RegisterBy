import StoreKit
import UIKit

enum AppReview {
    private static let markRegisteredCountKey = "markRegisteredCount"

    /// Prompt after the 3rd successful "Mark registered" — positive moment, Apple throttles display.
    static func recordMarkRegisteredAndMaybeRequestReview() {
        let count = UserDefaults.standard.integer(forKey: markRegisteredCountKey) + 1
        UserDefaults.standard.set(count, forKey: markRegisteredCountKey)

        guard count == 3 else { return }
        requestReviewIfPossible()
    }

    static func requestReviewIfPossible() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
