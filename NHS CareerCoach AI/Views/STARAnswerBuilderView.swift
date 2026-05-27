import SwiftData
import SwiftUI

struct STARAnswerBuilderView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = STARBuilderViewModel()
    @State private var exportedURL: URL?

    private let competencies = [
        "Communication",
        "Teamwork",
        "Safeguarding",
        "Conflict resolution",
        "Pressure situations",
        "Leadership",
        "Equality and diversity",
        "Patient care"
    ]

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumDashboardCard(title: "STAR answer builder", subtitle: "Turn raw experience into structured, professional NHS examples.", systemImage: "star.bubble.fill", accent: CareerCoachTheme.gold) {
                        Text("Strong answers are specific, honest, values-led, and reflective.")
                            .font(.subheadline)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                    }

                    form

                    if viewModel.isLoading {
                        LoadingStateView(message: "Improving clarity, professionalism, NHS alignment, and confidence tone...")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if let draft = viewModel.draft {
                        draftCard(draft)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("STAR Builder")
        .premiumNavigationTitleStyle()
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Competency", selection: $viewModel.competency) {
                ForEach(competencies, id: \.self) { competency in
                    Text(competency).tag(competency)
                }
            }
            .pickerStyle(.menu)
            .tint(CareerCoachTheme.electricBlue)

            editor("Situation", text: $viewModel.situation)
            editor("Task", text: $viewModel.task)
            editor("Action", text: $viewModel.action)
            editor("Result", text: $viewModel.result)

            Button {
                Task { await viewModel.generate(using: aiService) }
            } label: {
                Label("Improve STAR answer", systemImage: "wand.and.stars")
            }
            .buttonStyle(PremiumPrimaryButtonStyle())
        }
        .premiumCard()
    }

    private func draftCard(_ draft: STARAnswerDraft) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumDashboardCard(title: "Polished answer", subtitle: "Use as a review draft, not a script to memorise.", systemImage: "sparkles") {
                Text(draft.polishedAnswer)
                    .font(.body)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .textSelection(.enabled)
            }

            STARAnswerCard(answer: STARAnswer(
                competency: viewModel.competency,
                situation: draft.improvedSituation,
                task: draft.improvedTask,
                action: draft.improvedAction,
                result: draft.improvedResult,
                aiFeedback: draft.feedback
            ))

            HStack(spacing: 10) {
                Button {
                    save(draft)
                } label: {
                    Label("Save", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                Button {
                    export(draft)
                } label: {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())
            }

            if let exportedURL {
                ShareLink(item: exportedURL) {
                    Label("Share STAR sheet", systemImage: "paperplane.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
    }

    private func editor(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textSecondary)
            TextEditor(text: text)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .frame(minHeight: 96)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))
        }
    }

    private func save(_ draft: STARAnswerDraft) {
        modelContext.insert(STARAnswer(
            competency: viewModel.competency,
            situation: draft.improvedSituation,
            task: draft.improvedTask,
            action: draft.improvedAction,
            result: draft.improvedResult,
            aiFeedback: draft.feedback
        ))
        try? modelContext.save()
    }

    private func export(_ draft: STARAnswerDraft) {
        do {
            exportedURL = try PDFExportService.export(
                title: "STAR Answer Sheet",
                subtitle: viewModel.competency,
                body: draft.polishedAnswer,
                sections: [
                    ("Situation", draft.improvedSituation),
                    ("Task", draft.improvedTask),
                    ("Action", draft.improvedAction),
                    ("Result", draft.improvedResult),
                    ("AI feedback", draft.feedback)
                ]
            )
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
