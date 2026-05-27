import Foundation
import SwiftUI

protocol AIService {
    func analyzeJobDescription(jobDescription: String, targetRole: String, targetBand: String) async throws -> JobAnalysis
    func generateSupportingStatement(profile: UserProfile?, jobDescription: String, experienceNotes: String, tone: String) async throws -> SupportingStatementDraft
    func generateSTARAnswer(competency: String, situation: String, task: String, action: String, result: String) async throws -> STARAnswerDraft
    func generateInterviewQuestion(category: InterviewCategory, band: String, mode: InterviewMode) async throws -> InterviewQuestion
    func analyzeInterviewResponse(question: String, response: String, mode: InterviewMode) async throws -> InterviewFeedback
    func summarizeVoiceTranscript(_ transcript: String, targetModule: VoiceProcessingModule) async throws -> VoiceProcessingResult
    func generateCareerInsights(profile: UserProfile?, applications: [JobApplication], sessions: [MockInterviewSession]) async throws -> [CareerInsight]
}

private struct AIServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceEnvironmentKey.self] }
        set { self[AIServiceEnvironmentKey.self] = newValue }
    }
}

struct MockAIService: AIService {
    private let prompt = """
    You are NHS CareerCoach AI, a professional NHS career coaching assistant. Help users prepare stronger NHS applications, supporting statements, STAR answers, and interview responses using professional UK healthcare recruitment standards. Do not guarantee interviews, job offers, or career outcomes.
    """

    func analyzeJobDescription(jobDescription: String, targetRole: String, targetBand: String) async throws -> JobAnalysis {
        try await premiumDelay()

        return JobAnalysis(
            personSpecification: [
                "Demonstrates strong communication with patients, colleagues, and multidisciplinary teams.",
                "Can prioritise workload, maintain confidentiality, and follow local policies.",
                "Shows commitment to safe, inclusive, compassionate care."
            ],
            keyCompetencies: [
                "Communication",
                "Teamwork",
                "Attention to detail",
                "Patient-centred judgement",
                "Resilience under pressure"
            ],
            essentialCriteria: [
                "Evidence of relevant experience for \(targetRole.isEmpty ? "the target role" : targetRole).",
                "Clear examples aligned with Band \(targetBand.isEmpty ? "target" : targetBand) expectations.",
                "Understanding of NHS values, safeguarding, equality, and confidentiality."
            ],
            likelyInterviewTopics: [
                "Tell us about a time you handled a difficult conversation.",
                "How would you prioritise competing tasks during a busy shift or service period?",
                "Give an example of improving a process or patient experience.",
                "How do you demonstrate compassion, respect, and inclusion?"
            ],
            valuesAlignment: [
                "Compassion: mention listening, dignity, and person-centred support.",
                "Respect: show inclusive communication and confidentiality.",
                "Teamwork: evidence collaboration and escalation when needed.",
                "Commitment to quality: include reflection, learning, and improvement."
            ],
            importantKeywords: [
                "safeguarding",
                "confidentiality",
                "patient experience",
                "multidisciplinary",
                "NHS values",
                "equality and diversity",
                "quality improvement"
            ]
        )
    }

    func generateSupportingStatement(profile: UserProfile?, jobDescription: String, experienceNotes: String, tone: String) async throws -> SupportingStatementDraft {
        try await premiumDelay()

        let role = profile?.targetRole.isEmpty == false ? profile?.targetRole ?? "this NHS role" : "this NHS role"
        let band = profile?.targetBand.isEmpty == false ? profile?.targetBand ?? "target band" : "target band"

        return SupportingStatementDraft(
            professionalSummary: "A polished \(tone.lowercased()) summary positioning the applicant for \(role), with credible evidence of service focus, communication, confidentiality, and commitment to quality.",
            supportingStatement: """
            I am applying for \(role) at \(band) because I am motivated by the opportunity to contribute to safe, compassionate, and efficient NHS services. My experience has helped me build strong communication, prioritisation, and problem-solving skills, particularly when supporting people under pressure and working with colleagues to maintain high standards.

            In my previous experience, I have demonstrated the ability to listen carefully, act with professionalism, and adapt my approach to different people and situations. I understand the importance of confidentiality, safeguarding, accurate documentation, and inclusive practice. I would bring a calm, organised, and reflective approach to the role, with a willingness to keep learning and improve the service around me.

            I align strongly with NHS values, especially compassion, respect, teamwork, improving lives, and commitment to quality. I would review this AI-assisted draft carefully, add precise personal examples, and ensure the final submission accurately reflects my own experience.
            """,
            competencyParagraphs: [
                "Communication: describe a situation where you adapted your language, listened actively, and checked understanding.",
                "Teamwork: show how you supported colleagues, escalated appropriately, and contributed to a shared outcome.",
                "Quality: include a measurable improvement, learning point, or reflection."
            ],
            nhsValuesExamples: [
                "Compassion: supporting a person who was anxious by listening and explaining the next step.",
                "Respect: maintaining dignity, confidentiality, and inclusive communication.",
                "Commitment to quality: reflecting on feedback and improving a process."
            ],
            starExamples: [
                "Situation: A busy service period created delays. Task: Keep people informed and maintain accuracy. Action: Prioritised urgent items, communicated clearly, and escalated risk. Result: Service flow improved and colleagues had clearer visibility.",
                "Situation: A patient or colleague needed extra support. Task: Respond professionally. Action: Listened, clarified needs, and followed policy. Result: The person felt heard and the issue was handled safely."
            ],
            atsKeywords: [
                "NHS values",
                "safeguarding",
                "confidentiality",
                "patient-centred",
                "multidisciplinary team",
                "quality improvement"
            ]
        )
    }

    func generateSTARAnswer(competency: String, situation: String, task: String, action: String, result: String) async throws -> STARAnswerDraft {
        try await premiumDelay()

        return STARAnswerDraft(
            polishedAnswer: """
            For \(competency), I would use a clear STAR answer. Situation: \(situation.trimmed.isEmpty ? "I faced a service pressure that required calm communication and careful prioritisation." : situation) Task: \(task.trimmed.isEmpty ? "My task was to support the person or team while maintaining safety, accuracy, and professionalism." : task) Action: \(action.trimmed.isEmpty ? "I listened carefully, clarified the priority, followed policy, and kept the relevant people updated." : action) Result: \(result.trimmed.isEmpty ? "The situation was handled safely, the team had a clearer plan, and I reflected on what I could improve next time." : result)
            """,
            improvedSituation: situation.trimmed.isEmpty ? "Set the scene in one sentence with the service context and pressure." : situation,
            improvedTask: task.trimmed.isEmpty ? "State your responsibility, not the whole team's responsibility." : task,
            improvedAction: action.trimmed.isEmpty ? "Use first-person action verbs and include policy, communication, escalation, and reflection where relevant." : action,
            improvedResult: result.trimmed.isEmpty ? "Add a measurable or observable outcome, plus learning." : result,
            feedback: "Strong answers for NHS interviews should be specific, reflective, values-led, and clearly structured. Avoid claiming outcomes that cannot be evidenced."
        )
    }

    func generateInterviewQuestion(category: InterviewCategory, band: String, mode: InterviewMode) async throws -> InterviewQuestion {
        try await premiumDelay()

        let question: String
        switch category {
        case .values:
            question = "Tell us about a time you demonstrated NHS values when supporting a patient, service user, colleague, or member of the public."
        case .safeguarding:
            question = "What would you do if you noticed a safeguarding concern during your work?"
        case .teamwork:
            question = "Describe a time you worked with others to improve a service outcome."
        case .conflict:
            question = "Tell us about a time you managed disagreement or a difficult conversation professionally."
        case .communication:
            question = "Give an example of adapting your communication for someone with different needs."
        case .pressure:
            question = "How do you prioritise safely when several tasks feel urgent?"
        case .leadership:
            question = "Describe a time you influenced others or took responsibility for improving a situation."
        case .equality:
            question = "How do you make sure your practice is inclusive and respectful?"
        case .patientCare:
            question = "Tell us about a time you improved someone's experience of care or support."
        case .bandSpecific:
            question = "For Band \(band.isEmpty ? "your target band" : band), what strengths would you bring and what development areas are you actively working on?"
        }

        return InterviewQuestion(
            question: question,
            category: category.rawValue,
            coachingPrompt: mode == .confidence ? "Start with one strong example. Aim for calm, honest, specific language." : "Answer using STAR: situation, task, action, result, then a short reflection."
        )
    }

    func analyzeInterviewResponse(question: String, response: String, mode: InterviewMode) async throws -> InterviewFeedback {
        try await premiumDelay()

        let lengthBoost = min(Double(response.split(separator: " ").count) / 140.0, 1.0)
        let score = max(0.58, min(0.92, 0.62 + lengthBoost * 0.24))

        return InterviewFeedback(
            score: score,
            summary: "Your answer has a credible foundation. The next improvement is to make the result more specific and connect the example back to NHS values.",
            starStructureFeedback: "Situation and task should be short. Spend most of the answer on your action, then close with a clear result and reflection.",
            confidenceNotes: "Use steady first-person phrasing: 'I listened', 'I escalated', 'I documented', 'I reflected'. This sounds confident without becoming exaggerated.",
            fillerWordNotes: "Filler-word detection is scaffolded for a future audio model. For now, review the transcript for repeated phrases such as 'basically', 'just', or 'sort of'.",
            improvements: [
                "Add one measurable outcome or observable impact.",
                "Name the relevant NHS value explicitly.",
                "Mention policy, confidentiality, safeguarding, or escalation where relevant.",
                "End with what you learned and would carry forward."
            ]
        )
    }

    func summarizeVoiceTranscript(_ transcript: String, targetModule: VoiceProcessingModule) async throws -> VoiceProcessingResult {
        try await premiumDelay()

        return VoiceProcessingResult(
            polishedOutput: """
            Polished \(targetModule.rawValue.lowercased()):
            \(transcript.trimmed.isEmpty ? "Add your spoken experience first, then NHS CareerCoach AI will convert it into a structured draft." : transcript)

            Suggested rewrite: I approached the situation professionally by listening carefully, clarifying what was needed, taking appropriate action, and reflecting on how the experience connects to NHS values.
            """,
            summary: "Converted the spoken notes into a concise, professional, NHS-aligned draft.",
            confidenceScore: transcript.trimmed.isEmpty ? 0.0 : 0.82,
            suggestedNextSteps: [
                "Add the exact role, setting, and outcome.",
                "Check the wording is accurate before submitting.",
                "Turn this into a STAR answer or supporting statement paragraph."
            ]
        )
    }

    func generateCareerInsights(profile: UserProfile?, applications: [JobApplication], sessions: [MockInterviewSession]) async throws -> [CareerInsight] {
        try await premiumDelay()

        return [
            CareerInsight(title: "Band progression focus", detail: "For \(profile?.targetBand ?? "your target band"), build evidence around responsibility, prioritisation, escalation, and reflective learning.", priority: "High"),
            CareerInsight(title: "Application rhythm", detail: "You have \(applications.count) tracked application\(applications.count == 1 ? "" : "s"). Keep one tailored statement and one STAR bank for each role family.", priority: "Medium"),
            CareerInsight(title: "Interview readiness", detail: "Complete three mock questions across values, safeguarding, and pressure situations before your next interview.", priority: "High"),
            CareerInsight(title: "CPD placeholder", detail: "Future CPD analysis can suggest training in safeguarding, equality and diversity, quality improvement, and leadership.", priority: "Future")
        ]
    }

    private func premiumDelay() async throws {
        _ = prompt
        try await Task.sleep(nanoseconds: 450_000_000)
    }
}

struct RemoteAIService: AIService {
    enum RemoteAIError: Error {
        case missingBackendURL
        case invalidResponse
    }

    var backendURL: URL?

    init(backendURL: URL? = URL(string: "https://YOUR_BACKEND_URL.com/nhs-careercoach-ai")) {
        self.backendURL = backendURL
    }

    func analyzeJobDescription(jobDescription: String, targetRole: String, targetBand: String) async throws -> JobAnalysis {
        let response: RemoteAIResponse = try await post(module: "job_description_scanner", targetRole: targetRole, jobDescription: jobDescription, targetBand: targetBand)
        return JobAnalysis(
            personSpecification: response.interviewFeedback,
            keyCompetencies: response.careerInsights,
            essentialCriteria: response.summary.isEmpty ? [] : [response.summary],
            likelyInterviewTopics: response.interviewFeedback,
            valuesAlignment: response.careerInsights,
            importantKeywords: response.careerInsights
        )
    }

    func generateSupportingStatement(profile: UserProfile?, jobDescription: String, experienceNotes: String, tone: String) async throws -> SupportingStatementDraft {
        let response: RemoteAIResponse = try await post(
            module: "supporting_statement",
            targetRole: profile?.targetRole ?? "",
            jobDescription: jobDescription,
            experienceNotes: experienceNotes,
            targetBand: profile?.targetBand ?? ""
        )

        return SupportingStatementDraft(
            professionalSummary: response.summary,
            supportingStatement: response.supportingStatement,
            competencyParagraphs: response.careerInsights,
            nhsValuesExamples: response.careerInsights,
            starExamples: response.starAnswer.isEmpty ? [] : [response.starAnswer],
            atsKeywords: []
        )
    }

    func generateSTARAnswer(competency: String, situation: String, task: String, action: String, result: String) async throws -> STARAnswerDraft {
        let response: RemoteAIResponse = try await post(module: "star_answer", experienceNotes: "\(competency)\n\(situation)\n\(task)\n\(action)\n\(result)")
        return STARAnswerDraft(
            polishedAnswer: response.starAnswer,
            improvedSituation: situation,
            improvedTask: task,
            improvedAction: action,
            improvedResult: result,
            feedback: response.summary
        )
    }

    func generateInterviewQuestion(category: InterviewCategory, band: String, mode: InterviewMode) async throws -> InterviewQuestion {
        let response: RemoteAIResponse = try await post(module: "interview_question", targetBand: band, experienceNotes: "\(category.rawValue) \(mode.rawValue)")
        return InterviewQuestion(question: response.summary, category: category.rawValue, coachingPrompt: "Use STAR and connect the answer to NHS values.")
    }

    func analyzeInterviewResponse(question: String, response: String, mode: InterviewMode) async throws -> InterviewFeedback {
        let remote: RemoteAIResponse = try await post(module: "interview_feedback", voiceTranscript: response, experienceNotes: question)
        return InterviewFeedback(score: 0.78, summary: remote.summary, starStructureFeedback: remote.starAnswer, confidenceNotes: remote.careerInsights.first ?? "", fillerWordNotes: "Filler-word detection placeholder.", improvements: remote.interviewFeedback)
    }

    func summarizeVoiceTranscript(_ transcript: String, targetModule: VoiceProcessingModule) async throws -> VoiceProcessingResult {
        let response: RemoteAIResponse = try await post(module: targetModule.rawValue, voiceTranscript: transcript)
        return VoiceProcessingResult(polishedOutput: response.supportingStatement, summary: response.summary, confidenceScore: 0.8, suggestedNextSteps: response.careerInsights)
    }

    func generateCareerInsights(profile: UserProfile?, applications: [JobApplication], sessions: [MockInterviewSession]) async throws -> [CareerInsight] {
        let response: RemoteAIResponse = try await post(module: "career_insights", targetRole: profile?.targetRole ?? "", targetBand: profile?.targetBand ?? "")
        return response.careerInsights.map { CareerInsight(title: "Career insight", detail: $0, priority: "AI") }
    }

    private func post<T: Decodable>(
        module: String,
        targetRole: String = "",
        jobDescription: String = "",
        voiceTranscript: String = "",
        experienceNotes: String = "",
        targetBand: String = ""
    ) async throws -> T {
        guard let backendURL else { throw RemoteAIError.missingBackendURL }

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RemoteAIRequest(
            module: module,
            targetRole: targetRole,
            jobDescription: jobDescription,
            voiceTranscript: voiceTranscript,
            experienceNotes: experienceNotes,
            targetBand: targetBand
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw RemoteAIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct RemoteAIRequest: Codable {
    var module: String
    var targetRole: String
    var jobDescription: String
    var voiceTranscript: String
    var experienceNotes: String
    var targetBand: String
}

private struct RemoteAIResponse: Codable {
    var supportingStatement: String
    var starAnswer: String
    var interviewFeedback: [String]
    var careerInsights: [String]
    var summary: String
}
