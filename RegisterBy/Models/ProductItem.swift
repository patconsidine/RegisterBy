import Foundation
import SwiftData

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case baby = "Baby"
    case electronics = "Electronics"
    case appliance = "Appliance"
    case tools = "Tools"
    case furniture = "Furniture"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .baby: return "figure.and.child.holdinghands"
        case .electronics: return "laptopcomputer"
        case .appliance: return "washer.fill"
        case .tools: return "wrench.and.screwdriver"
        case .furniture: return "sofa"
        case .other: return "shippingbox"
        }
    }

    static func defaults(for category: ProductCategory) -> CategoryDefaults {
        switch category {
        case .baby:
            return CategoryDefaults(registrationRequired: true, registerWithinDays: 30, trackReturn: true, returnWithinDays: 30, warrantyYears: 2)
        case .appliance:
            return CategoryDefaults(registrationRequired: true, registerWithinDays: 60, trackReturn: true, returnWithinDays: 30, warrantyYears: 2)
        case .electronics:
            return CategoryDefaults(registrationRequired: true, registerWithinDays: 30, trackReturn: true, returnWithinDays: 14, warrantyYears: 1)
        case .tools:
            return CategoryDefaults(registrationRequired: false, registerWithinDays: 30, trackReturn: true, returnWithinDays: 30, warrantyYears: 3)
        case .furniture:
            return CategoryDefaults(registrationRequired: false, registerWithinDays: 30, trackReturn: true, returnWithinDays: 30, warrantyYears: 1)
        case .other:
            return CategoryDefaults(registrationRequired: false, registerWithinDays: 30, trackReturn: true, returnWithinDays: 30, warrantyYears: 2)
        }
    }
}

struct CategoryDefaults {
    let registrationRequired: Bool
    let registerWithinDays: Int
    let trackReturn: Bool
    let returnWithinDays: Int
    let warrantyYears: Int
}

enum ProductStatus: String {
    case registerSoon
    case registerOverdue
    case registered
    case returnEnding
    case expiringSoon
    case expired
    case active
}

@Model
final class ProductItem {
    var id: UUID
    var name: String
    var brand: String
    var categoryRaw: String
    var purchaseDate: Date
    var purchasePrice: Double?
    var storeName: String

    var registrationRequired: Bool
    var registerWithinDays: Int
    var registeredAt: Date?

    var trackReturn: Bool
    var returnWithinDays: Int

    var warrantyYears: Int
    var warrantyEndDate: Date

    var registrationURL: String
    var modelNumber: String
    var serialNumber: String
    var claimNotes: String

    var receiptImageFilename: String?
    var serialImageFilename: String?

    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    var category: ProductCategory {
        get { ProductCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        brand: String = "",
        category: ProductCategory = .electronics,
        purchaseDate: Date = .now,
        purchasePrice: Double? = nil,
        storeName: String = "",
        registrationRequired: Bool = true,
        registerWithinDays: Int = 30,
        registeredAt: Date? = nil,
        trackReturn: Bool = true,
        returnWithinDays: Int = 30,
        warrantyYears: Int = 2,
        warrantyEndDate: Date? = nil,
        registrationURL: String = "",
        modelNumber: String = "",
        serialNumber: String = "",
        claimNotes: String = "",
        receiptImageFilename: String? = nil,
        serialImageFilename: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.categoryRaw = category.rawValue
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.storeName = storeName
        self.registrationRequired = registrationRequired
        self.registerWithinDays = registerWithinDays
        self.registeredAt = registeredAt
        self.trackReturn = trackReturn
        self.returnWithinDays = returnWithinDays
        self.warrantyYears = warrantyYears
        self.warrantyEndDate = warrantyEndDate ?? Calendar.current.date(byAdding: .year, value: warrantyYears, to: purchaseDate) ?? purchaseDate
        self.registrationURL = registrationURL
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.claimNotes = claimNotes
        self.receiptImageFilename = receiptImageFilename
        self.serialImageFilename = serialImageFilename
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }

    var registerByDate: Date? {
        guard registrationRequired, registeredAt == nil else { return nil }
        return Calendar.current.date(byAdding: .day, value: registerWithinDays, to: purchaseDate)
    }

    var returnByDate: Date? {
        guard trackReturn else { return nil }
        return Calendar.current.date(byAdding: .day, value: returnWithinDays, to: purchaseDate)
    }

    var status: ProductStatus {
        let now = Date()
        if warrantyEndDate < now { return .expired }
        if let reg = registerByDate {
            if reg < now { return .registerOverdue }
            if reg.timeIntervalSince(now) < 7 * 86400 { return .registerSoon }
        }
        if registeredAt != nil {
            if warrantyEndDate.timeIntervalSince(now) < 90 * 86400 { return .expiringSoon }
            return .registered
        }
        if let ret = returnByDate, ret > now, ret.timeIntervalSince(now) < 7 * 86400 {
            return .returnEnding
        }
        if let reg = registerByDate, reg > now { return .registerSoon }
        return .active
    }

    var urgencyScore: Int {
        switch status {
        case .registerOverdue: return 0
        case .registerSoon: return 1
        case .returnEnding: return 2
        case .expiringSoon: return 3
        case .registered: return 4
        case .active: return 5
        case .expired: return 6
        }
    }

    func recomputeWarrantyEnd() {
        warrantyEndDate = Calendar.current.date(byAdding: .year, value: warrantyYears, to: purchaseDate) ?? purchaseDate
    }
}
