import SwiftUI

struct NHSValuesCoachView: View {
    private let values: [(String, String, String, String)] = [
        ("Compassion", "heart.fill", "Show empathy, dignity, active listening, and person-centred support.", "Tell us about a time you supported someone who was anxious or upset."),
        ("Respect", "person.crop.circle.badge.checkmark", "Evidence confidentiality, inclusive language, and respect for different needs.", "How do you adapt your communication to treat people fairly?"),
        ("Teamwork", "person.3.fill", "Demonstrate collaboration, escalation, shared goals, and reliability.", "Describe a time you worked with others to improve a service outcome."),
        ("Improving lives", "arrow.up.heart.fill", "Connect your actions to better experience, safer service, or improved access.", "Give an example of making a positive difference for someone."),
        ("Commitment to quality", "checkmark.seal.fill", "Use reflection, policy, accuracy, learning, and continuous improvement.", "Tell us about a time you improved how work was done.")
    ]

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumDashboardCard(title: "NHS values coach", subtitle: "Build interview-ready examples around core values.", systemImage: "heart.text.square.fill", accent: CareerCoachTheme.mint) {
                        Text("Use these prompts to prepare accurate, reflective examples. Keep your final answer grounded in your own experience.")
                            .font(.subheadline)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }

                    ForEach(values, id: \.0) { value in
                        valueCard(value)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("NHS Values")
        .premiumNavigationTitleStyle()
    }

    private func valueCard(_ value: (String, String, String, String)) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: value.1)
                    .foregroundStyle(CareerCoachTheme.electricBlue)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(CareerCoachTheme.electricBlue.opacity(0.12)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(value.0)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(CareerCoachTheme.textPrimary)
                    Text(value.2)
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer template")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.electricBlue)
                Text("In my role, I demonstrated \(value.0.lowercased()) when [situation]. I was responsible for [task]. I [actions]. The result was [outcome], and I learned [reflection].")
                    .font(.subheadline)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CareerCoachTheme.elevatedPanel.opacity(0.70)))

            VStack(alignment: .leading, spacing: 8) {
                Text("Practice prompt")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.mint)
                Text(value.3)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
            }
        }
        .premiumCard()
    }
}

