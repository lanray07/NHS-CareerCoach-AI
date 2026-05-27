import Foundation
import Observation
import StoreKit

struct SubscriptionSnapshot: Equatable {
    var plan: SubscriptionPlan
    var isActive: Bool
    var renewsAt: Date?
}

@MainActor
@Observable
final class SubscriptionStore {
    private(set) var products: [Product] = []
    private(set) var snapshot = SubscriptionSnapshot(plan: .free, isActive: false, renewsAt: nil)
    var isLoading = false
    var errorMessage: String?

    let productIDs = SubscriptionPlan.allCases.compactMap(\.productID)

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
        } catch {
            errorMessage = "StoreKit products are scaffolded. Add matching subscription products in App Store Connect or a StoreKit configuration file."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                if case .verified(let transaction) = verificationResult {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "The purchase could not be completed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func activateMockPlan(_ plan: SubscriptionPlan) {
        snapshot = SubscriptionSnapshot(plan: plan, isActive: plan != .free, renewsAt: Calendar.current.date(byAdding: .month, value: 1, to: .now))
    }

    func refreshEntitlements() async {
        var bestPlan: SubscriptionPlan = .free
        var renewsAt: Date?

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement,
                  let plan = SubscriptionPlan.allCases.first(where: { plan in
                      guard let productID = plan.productID else { return false }
                      return productID == transaction.productID
                  }) else {
                continue
            }

            bestPlan = plan
            renewsAt = transaction.expirationDate
        }

        snapshot = SubscriptionSnapshot(plan: bestPlan, isActive: bestPlan != .free, renewsAt: renewsAt)
    }
}
