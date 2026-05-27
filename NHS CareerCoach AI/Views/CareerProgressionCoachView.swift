import SwiftData
import SwiftUI

struct CareerProgressionCoachView: View {
    @Environment(\.aiService) private var aiService
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]
    @Query(sort: \JobApplication.createdAt, order: .reverse) private var applications: [JobApplication]
    @Query(sort: \MockInterviewSession.createdAt, order: .reverse) private var sessions: [MockInterviewSession]
    @StateObject private var viewModel = CareerProgressionViewModel()

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumDashboardCard(title: "AI career progression coach", subtitle: "Roadmaps for NHS bands, next roles, and development focus.", systemImage: "arrow.up.forward.circle.fill", accent: CareerCoachTheme.gold) {
                        Text("This roadmap is educational guidance. It does not guarantee progression, employment, interviews, or role outcomes.")
                            .font(.subheadline)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }

                    roadmap

                    Button {
                        Task {
                            await viewModel.generate(
                                using: aiService,
                                profile: profiles.first,
                                applications: applications,
                                sessions: sessions
                            )
                        }
                    } label: {
                        Label("Generate career insights", systemImage: "sparkles")
                    }
                    .buttonStyle(PremiumPrimaryButtonStyle())

                    if viewModel.isLoading {
                        LoadingStateView(message: "Mapping band progression, skill gaps, and CPD placeholders...")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if viewModel.insights.isEmpty {
                        EmptyStateView(title: "No roadmap generated yet", message: "Generate insights to see next-role suggestions, skill gap placeholders, and CPD ideas.", systemImage: "map.fill")
                    } else {
                        ForEach(viewModel.insights) { insight in
                            insightCard(insight)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Career Coach")
        .premiumNavigationTitleStyle()
    }

    private var roadmap: some View {
        PremiumDashboardCard(title: "Band progression roadmap", subtitle: "Common evidence themes for Band 2-7 applicants.", systemImage: "map.fill") {
            VStack(alignment: .leading, spacing: 12) {
                roadmapStep("Band 2-3", "Reliability, compassion, communication, basic prioritisation, accurate escalation.")
                roadmapStep("Band 4-5", "Autonomy, service awareness, documentation, quality improvement, reflective practice.")
                roadmapStep("Band 6-7", "Leadership, supervision, complex judgement, change delivery, service improvement evidence.")
            }
        }
    }

    private func roadmapStep(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle.hexagongrid.fill")
                .foregroundStyle(CareerCoachTheme.electricBlue)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
    }

    private func insightCard(_ insight: CareerInsight) -> some View {
        PremiumDashboardCard(title: insight.title, subtitle: insight.priority, systemImage: "lightbulb.fill", accent: insight.priority == "High" ? CareerCoachTheme.gold : CareerCoachTheme.electricBlue) {
            Text(insight.detail)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }
}

