import Foundation

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

enum WatchPromptKind: String, CaseIterable, Identifiable, Codable {
    case interviewReminder = "Interview reminder"
    case confidencePrompt = "Confidence prompt"
    case breathingPrompt = "Breathing prompt"
    case quickVoiceNote = "Quick voice note"

    var id: String { rawValue }
}

struct WatchPromptPayload: Identifiable, Codable {
    var id = UUID()
    var kind: WatchPromptKind
    var title: String
    var message: String
    var scheduledAt: Date
}

final class WatchSyncPlaceholder {
    func makeDefaultPayloads() -> [WatchPromptPayload] {
        [
            WatchPromptPayload(kind: .interviewReminder, title: "Interview prep", message: "Review one values answer.", scheduledAt: .now),
            WatchPromptPayload(kind: .confidencePrompt, title: "Confidence reset", message: "Name one strength and one example.", scheduledAt: .now),
            WatchPromptPayload(kind: .breathingPrompt, title: "Breathe", message: "Use a short breathing prompt before practice.", scheduledAt: .now),
            WatchPromptPayload(kind: .quickVoiceNote, title: "Voice note", message: "Capture a STAR example idea.", scheduledAt: .now)
        ]
    }

    func sendPlaceholder(_ payload: WatchPromptPayload) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        _ = payload
        #else
        _ = payload
        #endif
    }
}

