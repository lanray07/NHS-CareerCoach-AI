import Charts
import SwiftUI

struct PremiumDashboardCard<Content: View>: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var accent: Color = CareerCoachTheme.electricBlue
    private let content: Content

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        accent: Color = CareerCoachTheme.electricBlue,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(accent.opacity(0.14)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CareerCoachTheme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            content
        }
        .premiumCard()
    }
}

struct MetricPill: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color = CareerCoachTheme.electricBlue

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(CareerCoachTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CareerCoachTheme.elevatedPanel.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))
        )
    }
}

struct ApplicationCard: View {
    var application: JobApplication

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: application.status.systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(statusColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(statusColor.opacity(0.14)))

            VStack(alignment: .leading, spacing: 5) {
                Text(application.roleTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                    .lineLimit(1)

                Text("\(application.trustName) · Band \(application.band)")
                    .font(.subheadline)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .lineLimit(1)

                Text(application.applicationStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor)
            }

            Spacer()
        }
        .premiumCard(cornerRadius: 18, padding: 14)
    }

    private var statusColor: Color {
        switch application.status {
        case .drafting: return CareerCoachTheme.warning
        case .submitted: return CareerCoachTheme.electricBlue
        case .interview: return CareerCoachTheme.mint
        case .rejected: return CareerCoachTheme.destructive
        case .offer: return CareerCoachTheme.gold
        case .accepted: return CareerCoachTheme.mint
        }
    }
}

struct STARAnswerCard: View {
    var answer: STARAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(answer.competency, systemImage: "star.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Spacer()
                Text(answer.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(CareerCoachTheme.textTertiary)
            }

            VStack(alignment: .leading, spacing: 8) {
                starLine("Situation", answer.situation)
                starLine("Task", answer.task)
                starLine("Action", answer.action)
                starLine("Result", answer.result)
            }

            if !answer.aiFeedback.isEmpty {
                Text(answer.aiFeedback)
                    .font(.footnote)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CareerCoachTheme.nhsBlue.opacity(0.18)))
            }
        }
        .premiumCard()
    }

    private func starLine(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.electricBlue)
            Text(value.isEmpty ? "Add detail here." : value)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }
}

struct VoiceWaveformView: View {
    var samples: [CGFloat]
    var isActive: Bool

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let count = max(samples.count, 1)
                let spacing: CGFloat = 4
                let barWidth = max(3, (size.width - CGFloat(count - 1) * spacing) / CGFloat(count))
                let centerY = size.height / 2

                for index in samples.indices {
                    let height = max(8, samples[index] * size.height)
                    let x = CGFloat(index) * (barWidth + spacing)
                    var path = Path()
                    path.move(to: CGPoint(x: x + barWidth / 2, y: centerY - height / 2))
                    path.addLine(to: CGPoint(x: x + barWidth / 2, y: centerY + height / 2))

                    let opacity = isActive ? 0.45 + Double(samples[index]) * 0.55 : 0.26
                    context.stroke(path, with: .color(CareerCoachTheme.electricBlue.opacity(opacity)), style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: 116)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CareerCoachTheme.elevatedPanel.opacity(0.74))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(CareerCoachTheme.stroke))
        )
        .animation(.easeInOut(duration: 0.18), value: samples)
    }
}

struct MockInterviewCard: View {
    var question: InterviewQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(question.category, systemImage: "person.wave.2.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.mint)

            Text(question.question)
                .font(.title3.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(question.coachingPrompt)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
        .premiumCard()
    }
}

struct ConfidenceScoreRing: View {
    var score: Double
    var title: String = "Readiness"

    var body: some View {
        ZStack {
            Circle()
                .stroke(CareerCoachTheme.stroke, lineWidth: 13)

            Circle()
                .trim(from: 0, to: min(max(score, 0), 1))
                .stroke(CareerCoachTheme.accentGradient, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: CareerCoachTheme.electricBlue.opacity(0.35), radius: 12)

            VStack(spacing: 3) {
                Text("\(Int(score * 100))")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
        .frame(width: 132, height: 132)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: score)
    }
}

struct AnalyticsChartCard<Content: View>: View {
    var title: String
    var subtitle: String
    private let chart: Content

    init(title: String, subtitle: String, @ViewBuilder chart: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.chart = chart()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }

            chart
                .frame(height: 180)
        }
        .premiumCard()
    }
}

struct ShareCardPreview: View {
    var title: String
    var subtitle: String
    var detail: String
    var symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(CareerCoachTheme.accentGradient))
                Spacer()
                Text("NHS CareerCoach AI")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }

            Spacer(minLength: 8)

            Text(title)
                .font(.system(.title2, design: .rounded).weight(.black))
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.electricBlue)

            Text(detail)
                .font(.caption)
                .foregroundStyle(CareerCoachTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 230, alignment: .leading)
        .premiumCard(cornerRadius: 24, padding: 20)
    }
}

struct UpgradeBanner: View {
    var title: String = "Unlock premium coaching"
    var message: String = "Voice interviews, advanced statements, export packs, analytics, and deeper career roadmaps."
    var route: AppRoute = .paywall

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(CareerCoachTheme.gold)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(CareerCoachTheme.gold.opacity(0.14)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CareerCoachTheme.textPrimary)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textTertiary)
            }
            .premiumCard(cornerRadius: 18, padding: 14)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(CareerCoachTheme.electricBlue)
                .frame(width: 58, height: 58)
                .background(Circle().fill(CareerCoachTheme.electricBlue.opacity(0.12)))

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.textPrimary)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .premiumCard()
    }
}

struct LoadingStateView: View {
    var message: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(CareerCoachTheme.electricBlue)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.textSecondary)
            Spacer()
        }
        .premiumCard(cornerRadius: 16, padding: 14)
    }
}

struct ErrorStateView: View {
    var message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(CareerCoachTheme.warning)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
            Spacer()
        }
        .premiumCard(cornerRadius: 16, padding: 14)
    }
}
