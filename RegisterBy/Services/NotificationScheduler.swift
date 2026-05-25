import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func rescheduleAll(products: [ProductItem]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let prefs = AppSettings.notificationPrefs
        for product in products where !product.isArchived {
            schedule(for: product, prefs: prefs)
        }
    }

    static func schedule(for product: ProductItem, prefs: NotificationPrefs = AppSettings.notificationPrefs) {
        let center = UNUserNotificationCenter.current()
        let idPrefix = product.id.uuidString

        if product.registrationRequired, product.registeredAt == nil, let registerBy = product.registerByDate {
            for days in prefs.registerDaysBefore where days > 0 {
                if let fire = Calendar.current.date(byAdding: .day, value: -days, to: registerBy), fire > .now {
                    let content = UNMutableNotificationContent()
                    content.title = "RegisterBy"
                    if days == 1 {
                        content.body = "Last day to register \(product.name) for full warranty coverage."
                    } else {
                        content.body = "Register \(product.name) by \(formatted(registerBy)) for full warranty coverage."
                    }
                    content.sound = .default
                    addRequest(center: center, id: "\(idPrefix)-reg-\(days)", date: fire, content: content)
                }
            }
        }

        if product.trackReturn, let returnBy = product.returnByDate {
            for days in prefs.returnDaysBefore where days > 0 {
                if let fire = Calendar.current.date(byAdding: .day, value: -days, to: returnBy), fire > .now {
                    let content = UNMutableNotificationContent()
                    content.title = "RegisterBy"
                    content.body = days == 1
                        ? "Return window for \(product.name) ends tomorrow."
                        : "Return window for \(product.name) ends on \(formatted(returnBy))."
                    content.sound = .default
                    addRequest(center: center, id: "\(idPrefix)-ret-\(days)", date: fire, content: content)
                }
            }
        }

        for days in prefs.expiryDaysBefore where days > 0 {
            if let fire = Calendar.current.date(byAdding: .day, value: -days, to: product.warrantyEndDate), fire > .now {
                let content = UNMutableNotificationContent()
                content.title = "RegisterBy"
                content.body = "\(product.name) warranty ends in \(days) day\(days == 1 ? "" : "s")."
                content.sound = .default
                addRequest(center: center, id: "\(idPrefix)-exp-\(days)", date: fire, content: content)
            }
        }
    }

    private static func addRequest(center: UNUserNotificationCenter, id: String, date: Date, content: UNMutableNotificationContent) {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    private static func formatted(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}

struct NotificationPrefs: Codable {
    var registerDaysBefore: [Int] = [14, 7, 3, 1]
    var returnDaysBefore: [Int] = [7, 1]
    var expiryDaysBefore: [Int] = [90, 30, 7, 1]
}

enum AppSettings {
    static let onboardingKey = "hasCompletedOnboarding"
    private static let proKey = "isProUnlocked"
    private static let prefsKey = "notificationPrefs"

    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }

    static var isProUnlocked: Bool {
        get { UserDefaults.standard.bool(forKey: proKey) }
        set { UserDefaults.standard.set(newValue, forKey: proKey) }
    }

    static var notificationPrefs: NotificationPrefs {
        get {
            guard let data = UserDefaults.standard.data(forKey: prefsKey),
                  let prefs = try? JSONDecoder().decode(NotificationPrefs.self, from: data) else {
                return NotificationPrefs()
            }
            return prefs
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: prefsKey)
            }
        }
    }

    static let freeItemLimit = 5
    static let proProductID = "registerby_pro_lifetime"
    static let supportEmail = "registerby.app.support@gmail.com"
    static let privacyPolicyURL = URL(string: "https://patconsidine.github.io/RegisterBy/")!
    static let supportPageURL = URL(string: "https://patconsidine.github.io/RegisterBy/support.html")!
}
