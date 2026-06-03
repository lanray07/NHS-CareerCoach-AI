import SwiftUI

struct ShareCardsView: View {
    private let cards = [
        ShareCard(title: "Interview Ready", subtitle: "Confidence mode complete", detail: "Prepared values, STAR structure, and realistic NHS prompts.", symbol: "checkmark.seal.fill"),
        ShareCard(title: "Band 5 Application Submitted", subtitle: "Career milestone", detail: "Statement tailored, examples reviewed, application tracked.", symbol: "paperplane.fill"),
        ShareCard(title: "NHS Values Mastered", subtitle: "Values coaching", detail: "Compassion, respect, teamwork, improving lives, and quality.", symbol: "heart.text.square.fill"),
        ShareCard(title: "Completed 50 Mock Questions", subtitle: "Interview practice", detail: "Consistent preparation across values, safeguarding, and pressure.", symbol: "mic.and.signal.meter.fill")
    ]

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumDashboardCard(title: "Share cards", subtitle: "Elegant milestone cards for confidence, progress, and reflection.", systemImage: "square.and.arrow.up", accent: CareerCoachTheme.gold) {
                        Text("Share cards are designed as personal milestones. They should not imply guaranteed NHS outcomes.")
                            .font(.subheadline)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }

                    ForEach(cards) { card in
                        VStack(spacing: 12) {
                            ShareCardPreview(title: card.title, subtitle: card.subtitle, detail: card.detail, symbol: card.symbol)
                            ShareLink(item: "\(card.title) - \(card.subtitle). Built with NHS CareerCoach AI.") {
                                Label("Share card text", systemImage: "paperplane.fill")
                            }
                            .buttonStyle(PremiumSecondaryButtonStyle())
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Share Cards")
        .premiumNavigationTitleStyle()
    }
}

private struct ShareCard: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var detail: String
    var symbol: String
}
