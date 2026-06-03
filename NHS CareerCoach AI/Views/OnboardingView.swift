import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var step = 0
    @State private var targetRole = ""
    @State private var targetBand = "5"
    @State private var experienceLevel: ExperienceLevel = .entryLevel
    @State private var healthcareBackground: HealthcareBackground = .healthcareAssistant
    @State private var confidenceLevel: ConfidenceLevel = .building
    @State private var interviewExperience: InterviewExperience = .oneOrTwo
    @State private var coachingStyle: CoachingStyle = .professional

    private let totalSteps = 4

    var body: some View {
        PremiumScreen {
            VStack(spacing: 0) {
                onboardingHeader

                TabView(selection: $step) {
                    roleStep.tag(0)
                    backgroundStep.tag(1)
                    confidenceStep.tag(2)
                    disclaimerStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.48, dampingFraction: 0.86), value: step)

                controls
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 20)
        }
    }

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NHS CareerCoach AI")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("AI career coaching for NHS applicants.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
                Spacer()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(CareerCoachTheme.stroke)
                    Capsule().fill(CareerCoachTheme.accentGradient)
                        .frame(width: geometry.size.width * CGFloat(step + 1) / CGFloat(totalSteps))
                }
            }
            .frame(height: 5)
        }
        .padding(.top, 12)
    }

    private var roleStep: some View {
        OnboardingPanel(title: "Define your NHS target", subtitle: "We will tune the coaching around the role, band, and application standard you are aiming for.") {
            TextField("Target role, e.g. Healthcare Assistant", text: $targetRole)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("Target band")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                Picker("Target band", selection: $targetBand) {
                    ForEach(["2", "3", "4", "5", "6", "7"], id: \.self) { band in
                        Text("Band \(band)").tag(band)
                    }
                }
                .pickerStyle(.segmented)
            }

            picker("Experience level", selection: $experienceLevel, values: ExperienceLevel.allCases)
        }
    }

    private var backgroundStep: some View {
        OnboardingPanel(title: "Shape your coaching profile", subtitle: "Your background helps the local coaching service suggest relevant examples without claiming outcomes.") {
            picker("Healthcare background", selection: $healthcareBackground, values: HealthcareBackground.allCases)
            picker("Preferred coaching style", selection: $coachingStyle, values: CoachingStyle.allCases)
        }
    }

    private var confidenceStep: some View {
        OnboardingPanel(title: "Calibrate confidence", subtitle: "Interview preparation should feel precise, supportive, and realistic.") {
            picker("Confidence level", selection: $confidenceLevel, values: ConfidenceLevel.allCases)
            picker("Interview experience", selection: $interviewExperience, values: InterviewExperience.allCases)
        }
    }

    private var disclaimerStep: some View {
        OnboardingPanel(title: "Career support, not a guarantee", subtitle: "NHS CareerCoach AI is designed for preparation, reflection, and better drafting.") {
            disclaimerRow("Independent coaching platform", "This app is not affiliated with, endorsed by, or operated by the NHS.")
            disclaimerRow("No guaranteed outcomes", "It does not guarantee interviews, job offers, progression, or employment outcomes.")
            disclaimerRow("Review before submission", "AI suggestions should be checked, personalised, and kept accurate before use.")
            disclaimerRow("Local-first AI in this build", "Job descriptions, notes, answers, and transcripts are not sent to a developer server or third-party AI provider.")
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                step = max(0, step - 1)
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(PremiumSecondaryButtonStyle())
            .opacity(step == 0 ? 0 : 1)

            Button {
                if step < totalSteps - 1 {
                    step += 1
                } else {
                    complete()
                }
            } label: {
                Label(step == totalSteps - 1 ? "Start coaching" : "Continue", systemImage: step == totalSteps - 1 ? "sparkles" : "chevron.right")
            }
            .buttonStyle(PremiumPrimaryButtonStyle())
        }
    }

    private func picker<T: RawRepresentable & CaseIterable & Identifiable & Hashable>(_ title: String, selection: Binding<T>, values: [T]) -> some View where T.RawValue == String {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textSecondary)
            Picker(title, selection: selection) {
                ForEach(values) { value in
                    Text(value.rawValue).tag(value)
                }
            }
            .pickerStyle(.menu)
            .tint(CareerCoachTheme.electricBlue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
        }
    }

    private func disclaimerRow(_ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(CareerCoachTheme.mint)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
    }

    private func complete() {
        let profile = UserProfile(
            targetRole: targetRole.trimmed.isEmpty ? "NHS applicant" : targetRole.trimmed,
            targetBand: targetBand,
            experienceLevel: experienceLevel,
            coachingStyle: coachingStyle,
            healthcareBackground: healthcareBackground,
            confidenceLevel: confidenceLevel,
            interviewExperience: interviewExperience
        )

        modelContext.insert(profile)
        modelContext.insert(AccessState())
        try? modelContext.save()
        appState.completeOnboarding()
    }
}

private struct OnboardingPanel<Content: View>: View {
    var title: String
    var subtitle: String
    private let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 20)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .premiumCard(cornerRadius: 24, padding: 18)

            Spacer(minLength: 20)
        }
    }
}
