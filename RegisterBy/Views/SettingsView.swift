import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager
    @Query(filter: #Predicate<ProductItem> { !$0.isArchived })
    private var allItems: [ProductItem]
    @State private var prefs = AppSettings.notificationPrefs
    @State private var showPaywall = false
    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppAppearance.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                if !purchases.isPro {
                    Section {
                        Button("Upgrade to RegisterBy Pro") { showPaywall = true }
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.label).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Register reminders") {
                    Toggle("14 days before", isOn: binding(for: 14, in: \.registerDaysBefore))
                    Toggle("7 days before", isOn: binding(for: 7, in: \.registerDaysBefore))
                    Toggle("3 days before", isOn: binding(for: 3, in: \.registerDaysBefore))
                    Toggle("1 day before", isOn: binding(for: 1, in: \.registerDaysBefore))
                }

                Section("Return reminders") {
                    Toggle("7 days before", isOn: binding(for: 7, in: \.returnDaysBefore))
                    Toggle("1 day before", isOn: binding(for: 1, in: \.returnDaysBefore))
                }

                Section("Expiry reminders") {
                    Toggle("90 days before", isOn: binding(for: 90, in: \.expiryDaysBefore))
                    Toggle("30 days before", isOn: binding(for: 30, in: \.expiryDaysBefore))
                    Toggle("7 days before", isOn: binding(for: 7, in: \.expiryDaysBefore))
                    Toggle("1 day before", isOn: binding(for: 1, in: \.expiryDaysBefore))
                }

                Section("Support") {
                    Button("Leave an App Store review") {
                        requestAppReview()
                    }
                    if let mailURL = supportMailURL {
                        Link("Email support", destination: mailURL)
                    }
                }

                Section("About") {
                    Text(legalDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link("Notification settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        AppSettings.notificationPrefs = prefs
                        NotificationScheduler.rescheduleAll(products: allItems)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func binding(for day: Int, in keyPath: WritableKeyPath<NotificationPrefs, [Int]>) -> Binding<Bool> {
        Binding(
            get: { prefs[keyPath: keyPath].contains(day) },
            set: { on in
                var list = prefs[keyPath: keyPath]
                if on, !list.contains(day) { list.append(day) }
                if !on { list.removeAll { $0 == day } }
                prefs[keyPath: keyPath] = list.sorted(by: >)
            }
        )
    }

    private var legalDisclaimer: String {
        """
        RegisterBy provides reminder estimates only. Registration and warranty rules vary by brand, retailer, and country. In Australia, consumer guarantees may apply separately from manufacturer registration. Always confirm deadlines on your receipt or manual.
        """
    }

    /// Support inbox for App Store listing and in-app contact.
    private var supportMailURL: URL? {
        let subject = "RegisterBy feedback"
        let encoded = "mailto:\(AppSettings.supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)"
        return URL(string: encoded)
    }

    private func requestAppReview() {
        AppReview.requestReviewIfPossible()
    }
}
