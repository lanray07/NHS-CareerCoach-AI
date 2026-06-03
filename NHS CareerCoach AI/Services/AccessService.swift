import Foundation
import Observation

struct AccessSnapshot {
    var plan: AccessPlan
    var isActive: Bool
    var renewsAt: Date?
}

@Observable
final class AccessStore {
    var snapshot = AccessSnapshot(plan: .included, isActive: true, renewsAt: nil)
    var errorMessage: String?

    func loadProducts() async {
        errorMessage = nil
        snapshot = AccessSnapshot(plan: .included, isActive: true, renewsAt: nil)
    }

    func refreshEntitlements() async {
        snapshot = AccessSnapshot(plan: .included, isActive: true, renewsAt: nil)
    }
}
