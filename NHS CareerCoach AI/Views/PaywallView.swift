import StoreKit
import SwiftUI

struct PaywallView: View {
    @State private var store = SubscriptionStore()

    private let freeFeatures = [
        "Limited applications",
        "Basic supporting statements",
        "Limited mock questions"
    ]

    private let premiumFeatures = [
        "Unlimited AI coaching",
        "Voice input system",
        "Voice interviews",
        "Supporting statement generation",
        "Advanced mock interviews",
        "Premium dashboards",
        "PDF exports",
        "Advanced analytics"
    ]

    private let eliteFeatures = [
        "Advanced AI career roadmap",
        "Premium coaching personalities",
        "Advanced interview simulation",
        "Advanced voice coaching tools",
        "Premium templates",
        "Deep analytics"
    ]

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    planCard(.premiumMonthly, features: premiumFeatures, highlighted: true)
                    planCard(.premiumYearly, features: premiumFeatures + ["Best annual value"], highlighted: false)
                    planCard(.eliteMonthly, features: eliteFeatures, highlighted: false)
                    freePlan

                    if let errorMessage = store.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Premium")
        .premiumNavigationTitleStyle()
        .task { await store.loadProducts() }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Elite NHS career preparation")
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.gold)
                .textCase(.uppercase)

            Text("Unlock the full AI coaching studio.")
                .font(.system(.largeTitle, design: .rounded).weight(.black))
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose the coaching level that fits your NHS application and interview preparation.")
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)

            HStack {
                Label(store.snapshot.plan.rawValue, systemImage: store.snapshot.isActive ? "crown.fill" : "lock.open.fill")
                Spacer()
                Text(store.snapshot.isActive ? "Active" : "Preview")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(CareerCoachTheme.textSecondary)
        }
        .premiumCard(cornerRadius: 28, padding: 22)
    }

    private func planCard(_ plan: SubscriptionPlan, features: [String], highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.rawValue)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(CareerCoachTheme.textPrimary)
                    Text(plan.price)
                        .font(.system(.title, design: .rounded).weight(.black))
                        .foregroundStyle(highlighted ? CareerCoachTheme.gold : CareerCoachTheme.electricBlue)
                }
                Spacer()
                if highlighted {
                    Text("Most popular")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CareerCoachTheme.background)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(CareerCoachTheme.gold))
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                ForEach(features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
            }

            if highlighted {
                subscribeButton(for: plan)
                    .buttonStyle(PremiumPrimaryButtonStyle())
            } else {
                subscribeButton(for: plan)
                    .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
        .premiumCard(cornerRadius: 24, padding: 20)
    }

    private func subscribeButton(for plan: SubscriptionPlan) -> some View {
        Button {
            if let productID = plan.productID,
               let product = store.products.first(where: { $0.id == productID }) {
                Task { await store.purchase(product) }
            } else {
                store.activateMockPlan(plan)
            }
        } label: {
            Label(store.products.isEmpty ? "Select \(plan.rawValue)" : "Subscribe", systemImage: "crown.fill")
        }
    }

    private var freePlan: some View {
        PremiumDashboardCard(title: "Free plan", subtitle: "For light preparation and exploration.", systemImage: "lock.open.fill") {
            VStack(alignment: .leading, spacing: 9) {
                ForEach(freeFeatures, id: \.self) { feature in
                    Label(feature, systemImage: "circle")
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
            }
        }
    }
}
