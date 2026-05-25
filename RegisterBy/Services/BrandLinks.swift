import Foundation

enum BrandRegion: String, CaseIterable, Identifiable {
    case au = "AU"
    case uk = "UK"
    case us = "US"

    var id: String { rawValue }

    static var current: BrandRegion {
        let code = Locale.current.region?.identifier ?? "AU"
        switch code {
        case "GB", "IE": return .uk
        case "US", "CA": return .us
        default: return .au
        }
    }
}

struct BrandLink: Identifiable {
    let id: String
    let name: String
    /// Verified registration or product-registration entry points (May 2026).
    let urls: [BrandRegion: String]
}

enum BrandLinks {
    static let all: [BrandLink] = [
        BrandLink(id: "apple", name: "Apple", urls: [
            .au: "https://checkcoverage.apple.com/",
            .uk: "https://checkcoverage.apple.com/",
            .us: "https://checkcoverage.apple.com/"
        ]),
        BrandLink(id: "samsung", name: "Samsung", urls: [
            .au: "https://www.samsung.com/au/support/your-service/register-product/",
            .uk: "https://www.samsung.com/uk/support/warranty/register-your-samsung-product-warranty/",
            .us: "https://www.samsung.com/us/support/register/"
        ]),
        BrandLink(id: "dyson", name: "Dyson", urls: [
            .au: "https://support.dyson.com.au/product-registration/registration.aspx",
            .uk: "https://www.dyson.co.uk/register",
            .us: "https://www.dyson.com/registration"
        ]),
        BrandLink(id: "breville", name: "Breville", urls: [
            .au: "https://www.mybreville.com/",
            .uk: "https://www.mybreville.com/",
            .us: "https://www.mybreville.com/"
        ]),
        BrandLink(id: "lg", name: "LG", urls: [
            .au: "https://www.lg.com/au/mylg/",
            .uk: "https://www.lg.com/uk/support/product-support/product-registration/",
            .us: "https://www.lg.com/us/support/product-registration"
        ]),
        BrandLink(id: "bosch", name: "Bosch", urls: [
            .au: "https://www.bosch-home.com.au/en/services",
            .uk: "https://www.bosch-home.co.uk/en/services",
            .us: "https://www.bosch-home.com/us/en/services"
        ]),
        BrandLink(id: "philips", name: "Philips", urls: [
            .au: "https://www.philips.com.au/c-w/product-registration",
            .uk: "https://www.philips.co.uk/c-s/support/register-your-product",
            .us: "https://www.usa.philips.com/c-w/product-registration"
        ]),
        BrandLink(id: "ninja", name: "Ninja", urls: [
            .au: "https://ninjakitchen.com.au/pages/warranty-registration",
            .uk: "https://www.sharkninja.co.uk/register",
            .us: "https://www.sharkninja.com/register"
        ])
    ]

    static func url(for brand: BrandLink, region: BrandRegion) -> URL? {
        guard let string = brand.urls[region], let url = URL(string: string) else { return nil }
        return url
    }
}
