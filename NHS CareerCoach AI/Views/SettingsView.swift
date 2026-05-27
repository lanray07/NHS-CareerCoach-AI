import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]
    @Query private var subscriptions: [SubscriptionState]
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
                    subscriptionCard
                    voiceSettings
                    notificationSettings
                    legalAndPrivacy
                    platformPlaceholders
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

    private var subscriptionCard: some View {
        PremiumDashboardCard(title: "Subscription", subtitle: subscriptionLabel, systemImage: "crown.fill", accent: CareerCoachTheme.gold) {
            VStack(alignment: .leading, spacing: 12) {
                NavigationLink(value: AppRoute.paywall) {
                    Label("Manage subscription", systemImage: "creditcard.fill")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                Text("StoreKit 2 purchase restoration and App Store account management should be connected before release.")
                    .font(.caption)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
    }

    private var voiceSettings: some View {
        PremiumDashboardCard(title: "Voice settings", subtitle: "Interview voice capture and AI voice placeholder.", systemImage: "waveform") {
            Toggle("Voice feedback placeholder", isOn: $voiceFeedbackEnabled)
                .tint(CareerCoachTheme.electricBlue)
                .foregroundStyle(CareerCoachTheme.textPrimary)

            Text(VoicePlaybackPlaceholder().message)
                .font(.caption)
                .foregroundStyle(CareerCoachTheme.textSecondary)

            Text(SoundEffectsPlaceholder().message)
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
                disclosure("Privacy policy", "Local mock AI is enabled by default. Do not store API keys in the app. Use a secure backend for remote AI.")
                disclosure("Terms of use", "The app provides educational career coaching, drafting help, and interview preparation support.")
                disclosure("Career disclaimer", "Independent coaching platform. Not affiliated with the NHS. No guaranteed interviews, job offers, progression, or employment outcomes.")
            }
        }
    }

    private var platformPlaceholders: some View {
        PremiumDashboardCard(title: "Widgets and Watch", subtitle: "Architecture placeholders for companion surfaces.", systemImage: "applewatch") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(WidgetPlaceholderFactory.snapshots().prefix(2)) { snapshot in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(snapshot.kind)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CareerCoachTheme.electricBlue)
                        Text("\(snapshot.title): \(snapshot.value)")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(CareerCoachTheme.textPrimary)
                        Text(snapshot.caption)
                            .font(.caption)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CareerCoachTheme.elevatedPanel.opacity(0.66)))
                }

                ForEach(WatchSyncPlaceholder().makeDefaultPayloads().prefix(2)) { payload in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "applewatch.side.right")
                            .foregroundStyle(CareerCoachTheme.electricBlue)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(payload.kind.rawValue)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(CareerCoachTheme.textPrimary)
                            Text(payload.message)
                                .font(.caption)
                                .foregroundStyle(CareerCoachTheme.textSecondary)
                        }
                    }
                }
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

    private func pickerRow<T: RawRepresentable & CaseIterable & Identifiable>(_ title: String, selection: Binding<T>, values: [T]) -> some View where T.RawValue == String {
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

    private var subscriptionLabel: String {
        guard let subscription = subscriptions.first else { return "Free plan" }
        return subscription.isActive ? subscription.plan : "Free plan"
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
        subscriptions.forEach { modelContext.delete($0) }
        try? modelContext.save()
        appState.resetOnboardingFlag()
    }
}
