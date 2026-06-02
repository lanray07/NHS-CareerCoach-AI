import Foundation
import SwiftUI

#if canImport(WidgetKit)
import WidgetKit
#endif

enum CareerCoachWidgetKind: String, CaseIterable, Identifiable {
    case interviewCountdown = "Interview countdown"
    case dailyQuestion = "Daily NHS question"
    case confidenceScore = "Confidence score"
    case applicationTracker = "Application tracker"

    var id: String { rawValue }
}

struct CareerCoachWidgetSnapshot: Identifiable, Codable {
    var id = UUID()
    var kind: String
    var title: String
    var value: String
    var caption: String
    var generatedAt: Date = .now
}

struct WidgetPreviewCard: View {
    var snapshot: CareerCoachWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(snapshot.kind)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.electricBlue)
            Text(snapshot.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textPrimary)
            Text(snapshot.value)
                .font(.system(.title, design: .rounded).weight(.black))
                .foregroundStyle(CareerCoachTheme.textPrimary)
            Text(snapshot.caption)
                .font(.caption)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard(cornerRadius: 18, padding: 16)
    }
}

enum WidgetPreviewFactory {
    static func snapshots() -> [CareerCoachWidgetSnapshot] {
        [
            CareerCoachWidgetSnapshot(kind: CareerCoachWidgetKind.interviewCountdown.rawValue, title: "Next interview", value: "3 days", caption: "Review values and safeguarding."),
            CareerCoachWidgetSnapshot(kind: CareerCoachWidgetKind.dailyQuestion.rawValue, title: "Daily question", value: "Teamwork", caption: "Prepare one STAR example."),
            CareerCoachWidgetSnapshot(kind: CareerCoachWidgetKind.confidenceScore.rawValue, title: "Readiness", value: "78%", caption: "One mock session recommended."),
            CareerCoachWidgetSnapshot(kind: CareerCoachWidgetKind.applicationTracker.rawValue, title: "Applications", value: "4 active", caption: "Two statements need tailoring.")
        ]
    }
}
