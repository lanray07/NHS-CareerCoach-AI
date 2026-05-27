import Observation
import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding || !profiles.isEmpty {
                AppShellView()
            } else {
                OnboardingView()
            }
        }
    }
}

private struct AppShellView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.dashboardPath) {
                DashboardView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.systemImage) }
            .tag(AppTab.dashboard)

            NavigationStack(path: $appState.applicationsPath) {
                ApplicationTrackerView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.applications.rawValue, systemImage: AppTab.applications.systemImage) }
            .tag(AppTab.applications)

            NavigationStack(path: $appState.interviewPath) {
                MockInterviewView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.interview.rawValue, systemImage: AppTab.interview.systemImage) }
            .tag(AppTab.interview)

            NavigationStack(path: $appState.voicePath) {
                VoiceInputView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.voice.rawValue, systemImage: AppTab.voice.systemImage) }
            .tag(AppTab.voice)

            NavigationStack(path: $appState.insightsPath) {
                ReadinessDashboardView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.insights.rawValue, systemImage: AppTab.insights.systemImage) }
            .tag(AppTab.insights)

            NavigationStack(path: $appState.settingsPath) {
                SettingsView()
                    .routeDestinations()
            }
            .tabItem { Label(AppTab.settings.rawValue, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
        .tint(CareerCoachTheme.electricBlue)
    }
}

private extension View {
    func routeDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .jobScanner:
                JobDescriptionScannerView()
            case .supportingStatement:
                SupportingStatementBuilderView()
            case .voiceInput:
                VoiceInputView()
            case .mockInterview:
                MockInterviewView()
            case .starBuilder:
                STARAnswerBuilderView()
            case .valuesCoach:
                NHSValuesCoachView()
            case .applicationTracker:
                ApplicationTrackerView()
            case .readiness:
                ReadinessDashboardView()
            case .careerProgression:
                CareerProgressionCoachView()
            case .shareCards:
                ShareCardsView()
            case .paywall:
                PaywallView()
            }
        }
    }
}
