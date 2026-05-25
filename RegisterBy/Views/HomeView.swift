import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchases: PurchaseManager
    @Query(filter: #Predicate<ProductItem> { !$0.isArchived }, sort: \ProductItem.name)
    private var allItems: [ProductItem]

    @State private var showAdd = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var segment: HomeSegment = .actionNeeded

    enum HomeSegment: String, CaseIterable {
        case actionNeeded = "Action needed"
        case allItems = "All items"
    }

    private var activeItems: [ProductItem] {
        allItems.filter { $0.status != .expired }
    }

    private var actionItems: [ProductItem] {
        activeItems
            .filter { [.registerOverdue, .registerSoon, .returnEnding, .expiringSoon].contains($0.status) }
            .sorted { $0.urgencyScore < $1.urgencyScore }
    }

    private var displayed: [ProductItem] {
        switch segment {
        case .actionNeeded: return actionItems
        case .allItems: return allItems.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $segment) {
                    ForEach(HomeSegment.allCases, id: \.self) { seg in
                        Text(seg.rawValue).tag(seg)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if !purchases.isPro, activeItems.count >= AppSettings.freeItemLimit - 1 {
                    Text("\(activeItems.count) of \(AppSettings.freeItemLimit) free items")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Group {
                    if displayed.isEmpty {
                        ContentUnavailableView(
                            segment == .actionNeeded ? "All caught up" : "Nothing tracked yet",
                            systemImage: "checkmark.circle",
                            description: Text(segment == .actionNeeded
                                ? "No registrations or deadlines need attention."
                                : "Add your first purchase to track register-by, return, and warranty dates.")
                        )
                    } else {
                        List(displayed) { item in
                            NavigationLink(value: item.id) {
                                ProductRowView(item: item)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("RegisterBy")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if !purchases.isPro, activeItems.count >= AppSettings.freeItemLimit {
                            showPaywall = true
                        } else {
                            showAdd = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                if let item = allItems.first(where: { $0.id == id }) {
                    ProductDetailView(item: item)
                }
            }
            .sheet(isPresented: $showAdd) {
                AddProductView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                NotificationScheduler.rescheduleAll(products: allItems)
            }
            .onChange(of: allItems.count) { _, _ in
                NotificationScheduler.rescheduleAll(products: allItems)
            }
        }
    }
}

struct ProductRowView: View {
    let item: ProductItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.iconName)
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        switch item.status {
        case .registerOverdue, .registerSoon:
            if let d = item.registerByDate {
                return "Register by \(d.formatted(date: .abbreviated, time: .omitted))"
            }
        case .returnEnding:
            if let d = item.returnByDate {
                return "Return ends \(d.formatted(date: .abbreviated, time: .omitted))"
            }
        case .expiringSoon, .expired:
            return "Warranty ends \(item.warrantyEndDate.formatted(date: .abbreviated, time: .omitted))"
        case .registered, .active:
            return "Warranty ends \(item.warrantyEndDate.formatted(date: .abbreviated, time: .omitted))"
        }
        return item.category.rawValue
    }

    private var statusColor: Color {
        switch item.status {
        case .registerOverdue: return .red
        case .registerSoon: return .orange
        case .returnEnding: return .yellow
        case .expiringSoon: return .yellow
        case .registered: return .green
        case .expired: return .gray
        case .active: return .blue
        }
    }
}
