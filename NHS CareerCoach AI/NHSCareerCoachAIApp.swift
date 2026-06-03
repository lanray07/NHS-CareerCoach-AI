import SwiftData
import SwiftUI

@main
struct NHSCareerCoachAIApp: App {
    @State private var appState = AppState()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            JobApplication.self,
            SupportingStatement.self,
            STARAnswer.self,
            MockInterviewSession.self,
            VoiceTranscript.self,
            Achievement.self,
            AccessState.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(\.aiService, MockAIService())
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
