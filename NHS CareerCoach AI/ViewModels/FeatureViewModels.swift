import Combine
import Foundation

@MainActor
final class JobScannerViewModel: ObservableObject {
    @Published var jobDescription = ""
    @Published var analysis: JobAnalysis?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func analyze(using aiService: any AIService, profile: UserProfile?) async {
        guard !jobDescription.trimmed.isEmpty else {
            errorMessage = "Paste an NHS job advert before scanning."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            analysis = try await aiService.analyzeJobDescription(
                jobDescription: jobDescription,
                targetRole: profile?.targetRole ?? "",
                targetBand: profile?.targetBand ?? ""
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class SupportingStatementViewModel: ObservableObject {
    @Published var jobDescription = ""
    @Published var experienceNotes = ""
    @Published var tone = "Professional"
    @Published var atsOptimisationEnabled = true
    @Published var draft: SupportingStatementDraft?
    @Published var exportedURL: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generate(using aiService: any AIService, profile: UserProfile?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            draft = try await aiService.generateSupportingStatement(
                profile: profile,
                jobDescription: jobDescription,
                experienceNotes: experienceNotes,
                tone: tone
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func exportPDF() {
        guard let draft else { return }

        do {
            exportedURL = try PDFExportService.export(
                title: "NHS Supporting Statement",
                subtitle: "Generated coaching draft",
                body: draft.supportingStatement,
                sections: [
                    ("Professional summary", draft.professionalSummary),
                    ("Competency paragraphs", draft.competencyParagraphs.joined(separator: "\n\n")),
                    ("NHS values examples", draft.nhsValuesExamples.joined(separator: "\n\n")),
                    ("STAR examples", draft.starExamples.joined(separator: "\n\n"))
                ]
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class STARBuilderViewModel: ObservableObject {
    @Published var competency = "Communication"
    @Published var situation = ""
    @Published var task = ""
    @Published var action = ""
    @Published var result = ""
    @Published var draft: STARAnswerDraft?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generate(using aiService: any AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            draft = try await aiService.generateSTARAnswer(
                competency: competency,
                situation: situation,
                task: task,
                action: action,
                result: result
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class MockInterviewViewModel: ObservableObject {
    @Published var selectedCategory: InterviewCategory = .values
    @Published var selectedMode: InterviewMode = .text
    @Published var band = "5"
    @Published var currentQuestion: InterviewQuestion?
    @Published var answer = ""
    @Published var feedback: InterviewFeedback?
    @Published var isLoadingQuestion = false
    @Published var isAnalyzing = false
    @Published var errorMessage: String?

    func generateQuestion(using aiService: any AIService) async {
        isLoadingQuestion = true
        errorMessage = nil
        defer { isLoadingQuestion = false }

        do {
            currentQuestion = try await aiService.generateInterviewQuestion(category: selectedCategory, band: band, mode: selectedMode)
            feedback = nil
            answer = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func analyze(using aiService: any AIService) async {
        guard let currentQuestion else {
            errorMessage = "Generate a question first."
            return
        }

        guard !answer.trimmed.isEmpty else {
            errorMessage = "Add or dictate an answer before requesting feedback."
            return
        }

        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            feedback = try await aiService.analyzeInterviewResponse(question: currentQuestion.question, response: answer, mode: selectedMode)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class VoiceInputViewModel: ObservableObject {
    @Published var selectedModule: VoiceProcessingModule = .supportingStatement
    @Published var processedResult: VoiceProcessingResult?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    func process(transcript: String, using aiService: any AIService) async {
        guard !transcript.trimmed.isEmpty else {
            errorMessage = "Record or type a transcript before polishing it."
            return
        }

        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            processedResult = try await aiService.summarizeVoiceTranscript(transcript, targetModule: selectedModule)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class CareerProgressionViewModel: ObservableObject {
    @Published var insights: [CareerInsight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generate(using aiService: any AIService, profile: UserProfile?, applications: [JobApplication], sessions: [MockInterviewSession]) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            insights = try await aiService.generateCareerInsights(profile: profile, applications: applications, sessions: sessions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
