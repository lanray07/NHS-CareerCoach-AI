import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \JobApplication.createdAt, order: .reverse) private var applications: [JobApplication]
    @Query(sort: \MockInterviewSession.createdAt, order: .reverse) private var sessions: [MockInterviewSession]
    @Query(sort: \SupportingStatement.createdAt, order: .reverse) private var statements: [SupportingStatement]
    @Query private var subscriptions: [SubscriptionState]
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    private var readinessScore: Double {
        guard !sessions.isEmpty else { return 0.64 }
        return sessions.map(\.score).reduce(0, +) / Double(sessions.count)
    }

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    metricsGrid
                    UpgradeBanner()
                    quickActions
                    insights
                    upcomingInterviews
                }
                .padding(20)
            }
        }
        .navigationTitle("Career Coach")
        .premiumNavigationTitleStyle()
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Premium NHS application coaching")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CareerCoachTheme.mint)
                        .textCase(.uppercase)
                    Text(profileTitle)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Build stronger statements, rehearse STAR answers, and prepare with realistic NHS interview prompts.")
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }

                Spacer(minLength: 16)
                ConfidenceScoreRing(score: readinessScore, title: "Ready")
            }

            HStack {
                Label("Mock AI enabled", systemImage: "sparkles")
                Spacer()
                Text(subscriptionLabel)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(CareerCoachTheme.textSecondary)
        }
        .premiumCard(cornerRadius: 28, padding: 22)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricPill(title: "Active apps", value: "\(applications.filter { $0.status != .rejected && $0.status != .accepted }.count)", systemImage: "tray.full.fill", tint: CareerCoachTheme.electricBlue)
            MetricPill(title: "Values mastery", value: "\(Int(valuesScore * 100))%", systemImage: "heart.text.square.fill", tint: CareerCoachTheme.mint)
            MetricPill(title: "Statements", value: "\(statements.count)", systemImage: "doc.text.fill", tint: CareerCoachTheme.gold)
            MetricPill(title: "Mock sessions", value: "\(sessions.count)", systemImage: "mic.and.signal.meter.fill", tint: CareerCoachTheme.electricBlue)
        }
    }

    private var quickActions: some View {
        PremiumDashboardCard(title: "Quick actions", subtitle: "Premium workflows for application momentum.", systemImage: "bolt.fill") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickAction("Scan Job Description", "doc.viewfinder", .jobScanner)
                quickAction("Supporting Statement", "text.badge.star", .supportingStatement)
                quickAction("Voice Interview", "mic.fill", .mockInterview)
                quickAction("STAR Builder", "star.bubble.fill", .starBuilder)
                quickAction("NHS Values Coach", "heart.text.square.fill", .valuesCoach)
                quickAction("Application Tracker", "calendar.badge.clock", .applicationTracker)
            }
        }
    }

    private var insights: some View {
        PremiumDashboardCard(title: "AI coaching insights", subtitle: "A realistic prep plan for this week.", systemImage: "brain.head.profile", accent: CareerCoachTheme.mint) {
            VStack(alignment: .leading, spacing: 10) {
                insightRow("Tighten your STAR results with clearer evidence and reflection.")
                insightRow("Practise values, safeguarding, and pressure questions before interviews.")
                insightRow("Keep supporting statements accurate, specific, and role-matched.")
            }
        }
    }

    private var upcomingInterviews: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming interviews")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Spacer()
                NavigationLink("Track", value: AppRoute.applicationTracker)
                    .font(.caption.weight(.bold))
            }

            let upcoming = applications
                .filter { $0.interviewDate != nil }
                .sorted { ($0.interviewDate ?? .distantFuture) < ($1.interviewDate ?? .distantFuture) }

            if upcoming.isEmpty {
                EmptyStateView(title: "No interviews tracked", message: "Add interview dates in the application tracker to enable reminders and countdown prep.", systemImage: "calendar")
            } else {
                ForEach(upcoming.prefix(3)) { application in
                    ApplicationCard(application: application)
                }
            }
        }
    }

    private func quickAction(_ title: String, _ systemImage: String, _ route: AppRoute) -> some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(CareerCoachTheme.electricBlue)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(CareerCoachTheme.electricBlue.opacity(0.12)))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(CareerCoachTheme.elevatedPanel.opacity(0.72))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(CareerCoachTheme.stroke))
            )
        }
        .buttonStyle(.plain)
    }

    private func insightRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CareerCoachTheme.mint)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var profileTitle: String {
        guard let profile = profiles.first else { return "Prepare with executive-level clarity." }
        return "Targeting \(profile.targetRole), Band \(profile.targetBand)"
    }

    private var subscriptionLabel: String {
        guard let state = subscriptions.first else { return "Free plan" }
        return state.isActive ? state.plan : "Free plan"
    }

    private var valuesScore: Double {
        min(0.95, 0.58 + Double(sessions.count) * 0.05 + Double(statements.count) * 0.04)
    }
}
