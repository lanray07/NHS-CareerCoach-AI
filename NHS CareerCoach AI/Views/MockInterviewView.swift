import SwiftData
import SwiftUI

struct MockInterviewView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MockInterviewViewModel()
    @State private var exportedURL: URL?

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    controls

                    if viewModel.isLoadingQuestion {
                        LoadingStateView(message: "Generating an NHS interview question...")
                    }

                    if let question = viewModel.currentQuestion {
                        MockInterviewCard(question: question)
                        answerCard
                    } else {
                        EmptyStateView(title: "Start a simulation", message: "Choose a category, mode, and band to generate realistic NHS interview practice.", systemImage: "person.wave.2.fill")
                    }

                    if viewModel.isAnalyzing {
                        LoadingStateView(message: "Reviewing structure, confidence, values alignment, and improvement areas...")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if let feedback = viewModel.feedback {
                        feedbackCard(feedback)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Mock Interview")
        .premiumNavigationTitleStyle()
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("AI mock interview")
                .font(.title2.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textPrimary)

            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(InterviewCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(CareerCoachTheme.electricBlue)

            Picker("Mode", selection: $viewModel.selectedMode) {
                ForEach(InterviewMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Target band")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                TextField("5", text: $viewModel.band)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 72)
            }

            Button {
                Task { await viewModel.generateQuestion(using: aiService) }
            } label: {
                Label("Generate question", systemImage: "sparkles")
            }
            .buttonStyle(PremiumPrimaryButtonStyle())
        }
        .premiumCard()
    }

    private var answerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your answer")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Spacer()
                if viewModel.selectedMode == .voice {
                    NavigationLink("Open voice coach", value: AppRoute.voiceInput)
                        .font(.caption.weight(.bold))
                }
            }

            TextEditor(text: $viewModel.answer)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .frame(minHeight: 220)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))

            HStack(spacing: 10) {
                Button {
                    Task { await viewModel.analyze(using: aiService) }
                } label: {
                    Label("Analyze answer", systemImage: "chart.bar.doc.horizontal")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                Button {
                    saveSession()
                } label: {
                    Label("Save", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
                .disabled(viewModel.feedback == nil)
            }
        }
        .premiumCard()
    }

    private func feedbackCard(_ feedback: InterviewFeedback) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 18) {
                ConfidenceScoreRing(score: feedback.score, title: "Score")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interview feedback")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(CareerCoachTheme.textPrimary)
                    Text(feedback.summary)
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
            }

            feedbackRow("STAR structure", feedback.starStructureFeedback, "star.bubble.fill")
            feedbackRow("Confidence", feedback.confidenceNotes, "bolt.heart.fill")
            feedbackRow("Filler-word placeholder", feedback.fillerWordNotes, "waveform.badge.magnifyingglass")

            VStack(alignment: .leading, spacing: 8) {
                Text("Improvement suggestions")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.electricBlue)
                ForEach(feedback.improvements, id: \.self) { improvement in
                    Label(improvement, systemImage: "arrow.up.forward.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
            }

            HStack(spacing: 10) {
                Button {
                    exportPack(feedback)
                } label: {
                    Label("Export prep pack", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                if let exportedURL {
                    ShareLink(item: exportedURL) {
                        Label("Share", systemImage: "paperplane.fill")
                    }
                    .buttonStyle(PremiumSecondaryButtonStyle())
                }
            }
        }
        .premiumCard()
    }

    private func feedbackRow(_ title: String, _ body: String, _ systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(CareerCoachTheme.electricBlue)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CareerCoachTheme.textTertiary)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
            }
        }
    }

    private func saveSession() {
        guard let feedback = viewModel.feedback else { return }
        let session = MockInterviewSession(
            mode: viewModel.selectedMode,
            score: feedback.score,
            transcript: viewModel.answer,
            category: viewModel.selectedCategory,
            feedbackSummary: feedback.summary
        )
        modelContext.insert(session)
        try? modelContext.save()
    }

    private func exportPack(_ feedback: InterviewFeedback) {
        do {
            exportedURL = try PDFExportService.export(
                title: "Interview Prep Pack",
                subtitle: "\(viewModel.selectedCategory.rawValue) · \(viewModel.selectedMode.rawValue)",
                body: viewModel.currentQuestion?.question ?? "Mock interview question",
                sections: [
                    ("Your answer", viewModel.answer),
                    ("Feedback summary", feedback.summary),
                    ("STAR structure", feedback.starStructureFeedback),
                    ("Confidence notes", feedback.confidenceNotes),
                    ("Improvement suggestions", feedback.improvements.joined(separator: "\n"))
                ]
            )
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
