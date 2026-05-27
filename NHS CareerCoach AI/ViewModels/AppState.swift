import Observation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case applications = "Applications"
    case interview = "Interview"
    case voice = "Voice"
    case insights = "Insights"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard: return "sparkles.rectangle.stack.fill"
        case .applications: return "tray.full.fill"
        case .interview: return "mic.and.signal.meter.fill"
        case .voice: return "waveform"
        case .insights: return "chart.xyaxis.line"
        case .settings: return "gearshape.fill"
        }
    }
}

enum AppRoute: Hashable {
    case jobScanner
    case supportingStatement
    case voiceInput
    case mockInterview
    case starBuilder
    case valuesCoach
    case applicationTracker
    case readiness
    case careerProgression
    case shareCards
    case paywall
}

@Observable
final class AppState {
    var selectedTab: AppTab = .dashboard
    var dashboardPath: [AppRoute] = []
    var applicationsPath: [AppRoute] = []
    var interviewPath: [AppRoute] = []
    var voicePath: [AppRoute] = []
    var insightsPath: [AppRoute] = []
    var settingsPath: [AppRoute] = []
    var hasCompletedOnboarding: Bool

    private let onboardingKey = "nhsCareerCoachAI.hasCompletedOnboarding"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func resetOnboardingFlag() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }
}
