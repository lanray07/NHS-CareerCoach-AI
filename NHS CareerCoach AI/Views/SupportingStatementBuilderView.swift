import SwiftData
import SwiftUI

struct SupportingStatementBuilderView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]
    @StateObject private var viewModel = SupportingStatementViewModel()

    private let tones = ["Professional", "Supportive", "Direct", "Confidence-building"]

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    intro
                    inputs

                    if viewModel.isLoading {
                        LoadingStateView(message: "Drafting a tailored NHS supporting statement...")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if let draft = viewModel.draft {
                        draftView(draft)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Statement Builder")
        .premiumNavigationTitleStyle()
    }

    private var intro: some View {
        PremiumDashboardCard(title: "AI supporting statement builder", subtitle: "Generate professional NHS-style drafts that you review and personalise.", systemImage: "text.badge.star", accent: CareerCoachTheme.gold) {
            Text("This builder is a coaching tool. It should strengthen structure, clarity, and relevance without inventing experience.")
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private var inputs: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Tone", selection: $viewModel.tone) {
                ForEach(tones, id: \.self) { tone in
                    Text(tone).tag(tone)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $viewModel.atsOptimisationEnabled) {
                Label("ATS keyword optimisation", systemImage: "slider.horizontal.3")
            }
            .tint(CareerCoachTheme.electricBlue)
            .foregroundStyle(CareerCoachTheme.textPrimary)

            labeledEditor("Job description", text: $viewModel.jobDescription, minHeight: 150)
            labeledEditor("Experience notes", text: $viewModel.experienceNotes, minHeight: 150)

            Button {
                Task { await viewModel.generate(using: aiService, profile: profiles.first) }
            } label: {
                Label("Generate statement", systemImage: "sparkles")
            }
            .buttonStyle(PremiumPrimaryButtonStyle())
            .disabled(viewModel.isLoading)
        }
        .premiumCard()
    }

    private func draftView(_ draft: SupportingStatementDraft) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumDashboardCard(title: "Generated draft", subtitle: "Review, edit, then export as a PDF.", systemImage: "doc.text.fill") {
                Text(draft.supportingStatement)
                    .font(.body)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .textSelection(.enabled)
            }

            resultList("Competency paragraphs", draft.competencyParagraphs, "list.bullet.rectangle")
            resultList("NHS values examples", draft.nhsValuesExamples, "heart.text.square.fill")
            resultList("STAR examples", draft.starExamples, "star.bubble.fill")
            resultList("ATS keyword suggestions", draft.atsKeywords, "number")

            VStack(spacing: 12) {
                Button {
                    Task { await viewModel.generate(using: aiService, profile: profiles.first) }
                } label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                HStack(spacing: 12) {
                    Button {
                        save(draft)
                    } label: {
                        Label("Save", systemImage: "tray.and.arrow.down.fill")
                    }
                    .buttonStyle(PremiumSecondaryButtonStyle())

                    Button {
                        viewModel.exportPDF()
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(PremiumPrimaryButtonStyle())
                }
            }

            if let exportedURL = viewModel.exportedURL {
                ShareLink(item: exportedURL) {
                    Label("Share exported PDF", systemImage: "paperplane.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
    }

    private func resultList(_ title: String, _ values: [String], _ systemImage: String) -> some View {
        PremiumDashboardCard(title: title, subtitle: "\(values.count) generated suggestions", systemImage: systemImage) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CareerCoachTheme.elevatedPanel.opacity(0.66)))
                }
            }
        }
    }

    private func labeledEditor(_ title: String, text: Binding<String>, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CareerCoachTheme.textSecondary)
            TextEditor(text: text)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .frame(minHeight: minHeight)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))
        }
    }

    private func save(_ draft: SupportingStatementDraft) {
        modelContext.insert(SupportingStatement(content: draft.supportingStatement))
        try? modelContext.save()
    }
}
