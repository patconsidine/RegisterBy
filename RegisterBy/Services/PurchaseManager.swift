import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var isPro: Bool { AppSettings.isProUnlocked }

    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == AppSettings.proProductID {
                        AppSettings.isProUnlocked = true
                    }
                }
            }
        }
    }

    func loadProduct() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [AppSettings.proProductID])
            product = products.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase() async -> Bool {
        guard let product else {
            await loadProduct()
            guard let product else { return false }
            return await purchase(product: product)
        }
        return await purchase(product: product)
    }

    private func purchase(product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    AppSettings.isProUnlocked = true
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return false
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == AppSettings.proProductID {
                    AppSettings.isProUnlocked = true
                    return
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
