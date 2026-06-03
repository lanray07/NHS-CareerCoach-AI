import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]
    @Query private var accessStates: [AccessState]
    @Query private var applications: [JobApplication]
    @Query private var statements: [SupportingStatement]
    @Query private var starAnswers: [STARAnswer]
    @Query private var sessions: [MockInterviewSession]
    @Query private var transcripts: [VoiceTranscript]
    @Query private var achievements: [Achievement]

    @State private var voiceFeedbackEnabled = true
    @State private var notificationPromptsEnabled = true
    @State private var selectedCoachingStyle: CoachingStyle = .professional

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    accountCard
                    accessCard
                    voiceSettings
                    notificationSettings
                    legalAndPrivacy
                    dataControls
                }
                .padding(20)
            }
        }
        .navigationTitle("Settings")
        .premiumNavigationTitleStyle()
        .onAppear {
            if let profile = profiles.first, let style = CoachingStyle(rawValue: profile.coachingStyle) {
                selectedCoachingStyle = style
            }
        }
    }

    private var accountCard: some View {
        PremiumDashboardCard(title: "Career profile", subtitle: profiles.first?.targetRole ?? "No profile", systemImage: "person.crop.circle.fill", accent: CareerCoachTheme.mint) {
            VStack(alignment: .leading, spacing: 12) {
                pickerRow("Coaching style", selection: $selectedCoachingStyle, values: CoachingStyle.allCases)

                Button {
                    profiles.first?.coachingStyle = selectedCoachingStyle.rawValue
                    try? modelContext.save()
                } label: {
                    Label("Save coaching style", systemImage: "checkmark")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
    }

    private var accessCard: some View {
        PremiumDashboardCard(title: "App access", subtitle: "Included in this build", systemImage: "checkmark.seal.fill", accent: CareerCoachTheme.gold) {
            VStack(alignment: .leading, spacing: 12) {
                NavigationLink(value: AppRoute.paywall) {
                    Label("View included access", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                Text("This submitted version does not sell digital purchases.")
                    .font(.caption)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
    }

    private var voiceSettings: some View {
        PremiumDashboardCard(title: "Voice settings", subtitle: "Interview voice capture and spoken coaching preferences.", systemImage: "waveform") {
            Toggle("Voice feedback prompts", isOn: $voiceFeedbackEnabled)
                .tint(CareerCoachTheme.electricBlue)
                .foregroundStyle(CareerCoachTheme.textPrimary)

            Text("Use voice prompts when practising interview answers and reviewing confidence notes.")
                .font(.caption)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private var notificationSettings: some View {
        PremiumDashboardCard(title: "Notifications", subtitle: "Interview reminders and confidence prompts.", systemImage: "bell.badge.fill", accent: CareerCoachTheme.warning) {
            Toggle("Interview reminder prompts", isOn: $notificationPromptsEnabled)
                .tint(CareerCoachTheme.electricBlue)
                .foregroundStyle(CareerCoachTheme.textPrimary)

            Button {
                Task { _ = await NotificationService.requestAuthorization() }
            } label: {
                Label("Request notification permission", systemImage: "bell.fill")
            }
            .buttonStyle(PremiumSecondaryButtonStyle())
        }
    }

    private var legalAndPrivacy: some View {
        PremiumDashboardCard(title: "Legal and privacy", subtitle: "Essential app disclosures.", systemImage: "doc.text.magnifyingglass") {
            VStack(alignment: .leading, spacing: 12) {
                disclosure("Privacy policy", "Coaching drafts, application notes, and voice transcripts are stored locally by default. This build does not send personal data to a developer AI server or third-party AI provider.")
                disclosure("Terms of use", "The app provides educational career coaching, drafting help, and interview preparation support.")
                disclosure("Career disclaimer", "Independent coaching platform. Not affiliated with the NHS. No guaranteed interviews, job offers, progression, or employment outcomes.")
            }
        }
    }

    private var dataControls: some View {
        PremiumDashboardCard(title: "Data", subtitle: "Offline-friendly local SwiftData storage.", systemImage: "externaldrive.fill") {
            VStack(alignment: .leading, spacing: 12) {
                ShareLink(item: exportSummaryText) {
                    Label("Export data summary", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                Button(role: .destructive) {
                    deleteAllData()
                } label: {
                    Label("Delete all local data", systemImage: "trash.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
    }

    private func pickerRow<T: RawRepresentable & CaseIterable & Identifiable & Hashable>(_ title: String, selection: Binding<T>, values: [T]) -> some View where T.RawValue == String {
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
        }
    }

    private func disclosure(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.textPrimary)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private var exportSummaryText: String {
        """
        NHS CareerCoach AI export summary
        Applications: \(applications.count)
        Supporting statements: \(statements.count)
        STAR answers: \(starAnswers.count)
        Mock interviews: \(sessions.count)
        Voice transcripts: \(transcripts.count)
        Achievements: \(achievements.count)

        Independent coaching platform. Not affiliated with the NHS. No guaranteed employment outcomes.
        """
    }

    private func deleteAllData() {
        profiles.forEach { modelContext.delete($0) }
        applications.forEach { modelContext.delete($0) }
        statements.forEach { modelContext.delete($0) }
        starAnswers.forEach { modelContext.delete($0) }
        sessions.forEach { modelContext.delete($0) }
        transcripts.forEach { modelContext.delete($0) }
        achievements.forEach { modelContext.delete($0) }
        accessStates.forEach { modelContext.delete($0) }
        try? modelContext.save()
        appState.resetOnboardingFlag()
    }
}
