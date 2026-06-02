import Charts
import SwiftData
import SwiftUI

struct ReadinessDashboardView: View {
    @Query(sort: \MockInterviewSession.createdAt) private var sessions: [MockInterviewSession]
    @Query(sort: \STARAnswer.createdAt) private var starAnswers: [STARAnswer]
    @Query(sort: \SupportingStatement.createdAt) private var statements: [SupportingStatement]

    private var readinessScore: Double {
        guard !sessions.isEmpty else { return 0.62 }
        return sessions.map(\.score).reduce(0, +) / Double(sessions.count)
    }

    private var trend: [TrendPoint] {
        if sessions.isEmpty {
            return [
                TrendPoint(label: "Week 1", score: 0.54),
                TrendPoint(label: "Week 2", score: 0.60),
                TrendPoint(label: "Week 3", score: 0.68),
                TrendPoint(label: "Now", score: readinessScore)
            ]
        }

        return sessions.enumerated().map { index, session in
            TrendPoint(label: "S\(index + 1)", score: session.score)
        }
    }

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    scoreGrid
                    charts
                    competencyPanels
                    NavigationLink(value: AppRoute.careerProgression) {
                        Label("Open career progression coach", systemImage: "arrow.up.forward.circle.fill")
                    }
                    .buttonStyle(PremiumPrimaryButtonStyle())
                }
                .padding(20)
            }
        }
        .navigationTitle("Readiness")
        .premiumNavigationTitleStyle()
    }

    private var header: some View {
        PremiumDashboardCard(title: "Confidence and readiness", subtitle: "Track mock interview performance, statement progress, and NHS values mastery.", systemImage: "chart.xyaxis.line", accent: CareerCoachTheme.mint) {
            HStack(spacing: 20) {
                ConfidenceScoreRing(score: readinessScore, title: "Ready")
                VStack(alignment: .leading, spacing: 10) {
                    metricLine("Mock interview performance", "\(Int(readinessScore * 100))%")
                    metricLine("Supporting statement progress", "\(min(100, 38 + statements.count * 22))%")
                    metricLine("NHS values score", "\(min(96, 58 + sessions.count * 6 + starAnswers.count * 3))%")
                }
            }
        }
    }

    private var scoreGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricPill(title: "Strongest", value: strongestCompetency, systemImage: "arrow.up.circle.fill", tint: CareerCoachTheme.mint)
            MetricPill(title: "Needs focus", value: weakestArea, systemImage: "scope", tint: CareerCoachTheme.warning)
            MetricPill(title: "STAR bank", value: "\(starAnswers.count)", systemImage: "star.bubble.fill", tint: CareerCoachTheme.gold)
            MetricPill(title: "Mocks", value: "\(sessions.count)", systemImage: "mic.and.signal.meter.fill", tint: CareerCoachTheme.electricBlue)
        }
    }

    private var charts: some View {
        VStack(spacing: 14) {
            AnalyticsChartCard(title: "Confidence trend", subtitle: "Updates as interview sessions grow.") {
                Chart(trend) { point in
                    LineMark(x: .value("Session", point.label), y: .value("Score", point.score))
                        .foregroundStyle(CareerCoachTheme.electricBlue)
                    AreaMark(x: .value("Session", point.label), y: .value("Score", point.score))
                        .foregroundStyle(CareerCoachTheme.electricBlue.opacity(0.18))
                    PointMark(x: .value("Session", point.label), y: .value("Score", point.score))
                        .foregroundStyle(CareerCoachTheme.mint)
                }
                .chartYScale(domain: 0...1)
                .chartXAxis { AxisMarks(values: .automatic) }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(CareerCoachTheme.stroke)
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue * 100))%")
                                    .foregroundStyle(CareerCoachTheme.textSecondary)
                            }
                        }
                    }
                }
            }

            AnalyticsChartCard(title: "NHS values mastery", subtitle: "Balanced competency view.") {
                Chart(valuesMastery) { item in
                    BarMark(x: .value("Score", item.score), y: .value("Value", item.title))
                        .foregroundStyle(CareerCoachTheme.electricBlue)
                }
                .chartXScale(domain: 0...1)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var competencyPanels: some View {
        PremiumDashboardCard(title: "Coaching interpretation", subtitle: "Where to focus next.", systemImage: "brain.head.profile") {
            VStack(alignment: .leading, spacing: 10) {
                Label("Strongest competencies: \(strongestCompetency), communication, professionalism.", systemImage: "checkmark.seal.fill")
                Label("Weakest areas: \(weakestArea), measurable results, concise reflection.", systemImage: "scope")
                Label("Next action: complete one safeguarding and one pressure question.", systemImage: "arrow.up.forward.circle.fill")
            }
            .font(.subheadline)
            .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private func metricLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(CareerCoachTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textPrimary)
        }
    }

    private var strongestCompetency: String {
        sessions.last?.category ?? "Values"
    }

    private var weakestArea: String {
        starAnswers.isEmpty ? "STAR detail" : "Result evidence"
    }

    private var valuesMastery: [ValueScore] {
        [
            ValueScore(title: "Compassion", score: min(0.95, 0.62 + Double(sessions.count) * 0.05)),
            ValueScore(title: "Respect", score: min(0.92, 0.58 + Double(starAnswers.count) * 0.04)),
            ValueScore(title: "Teamwork", score: min(0.94, 0.64 + Double(starAnswers.count) * 0.03)),
            ValueScore(title: "Quality", score: min(0.9, 0.56 + Double(statements.count) * 0.08))
        ]
    }
}

private struct TrendPoint: Identifiable {
    let id = UUID()
    var label: String
    var score: Double
}

private struct ValueScore: Identifiable {
    let id = UUID()
    var title: String
    var score: Double
}
