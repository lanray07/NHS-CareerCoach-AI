import Foundation
import SwiftData

enum ExperienceLevel: String, CaseIterable, Codable, Identifiable {
    case newToNHS = "New to the NHS"
    case entryLevel = "Entry level"
    case experienced = "Experienced"
    case manager = "Manager or senior"
    case international = "International applicant"

    var id: String { rawValue }
}

enum CoachingStyle: String, CaseIterable, Codable, Identifiable {
    case supportive = "Supportive"
    case direct = "Direct"
    case professional = "Professional"
    case strict = "Strict"
    case confidenceBuilding = "Confidence-building"

    var id: String { rawValue }
}

enum HealthcareBackground: String, CaseIterable, Codable, Identifiable {
    case administration = "NHS admin"
    case healthcareAssistant = "Healthcare assistant"
    case nursing = "Nursing"
    case analyst = "Analyst"
    case apprentice = "Apprentice"
    case graduate = "Graduate"
    case careerChanger = "Career changer"
    case international = "International healthcare"
    case other = "Other"

    var id: String { rawValue }
}

enum ConfidenceLevel: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case building = "Building"
    case steady = "Steady"
    case high = "High"

    var id: String { rawValue }
}

enum InterviewExperience: String, CaseIterable, Codable, Identifiable {
    case none = "No NHS interviews yet"
    case oneOrTwo = "One or two interviews"
    case several = "Several interviews"
    case confident = "Confident interviewer"

    var id: String { rawValue }
}

enum ApplicationStatus: String, CaseIterable, Codable, Identifiable {
    case drafting = "Drafting"
    case submitted = "Submitted"
    case interview = "Interview"
    case rejected = "Rejected"
    case offer = "Offer"
    case accepted = "Accepted"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .drafting: return "square.and.pencil"
        case .submitted: return "paperplane.fill"
        case .interview: return "person.wave.2.fill"
        case .rejected: return "xmark.seal.fill"
        case .offer: return "sparkles"
        case .accepted: return "checkmark.seal.fill"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Codable, Identifiable {
    case free = "Free"
    case premiumMonthly = "Premium Monthly"
    case premiumYearly = "Premium Yearly"
    case eliteMonthly = "Elite Monthly"

    var id: String { rawValue }

    var price: String {
        switch self {
        case .free: return "£0"
        case .premiumMonthly: return "£12.99"
        case .premiumYearly: return "£99.99"
        case .eliteMonthly: return "£24.99"
        }
    }

    var productID: String? {
        switch self {
        case .free: return nil
        case .premiumMonthly: return "nhs_careercoach_ai_premium_monthly"
        case .premiumYearly: return "nhs_careercoach_ai_premium_yearly"
        case .eliteMonthly: return "nhs_careercoach_ai_elite_monthly"
        }
    }
}

enum InterviewMode: String, CaseIterable, Codable, Identifiable {
    case text = "Text interview"
    case voice = "Voice interview"
    case rapidFire = "Rapid-fire"
    case confidence = "Confidence-building"

    var id: String { rawValue }
}

enum InterviewCategory: String, CaseIterable, Codable, Identifiable {
    case values = "NHS values"
    case safeguarding = "Safeguarding"
    case teamwork = "Teamwork"
    case conflict = "Conflict resolution"
    case communication = "Communication"
    case pressure = "Pressure situations"
    case leadership = "Leadership"
    case equality = "Equality and diversity"
    case patientCare = "Patient care"
    case bandSpecific = "Band-specific"

    var id: String { rawValue }
}

enum VoiceProcessingModule: String, CaseIterable, Identifiable {
    case supportingStatement = "Supporting statement"
    case starAnswer = "STAR answer"
    case interviewSummary = "Interview summary"
    case competencyExample = "Competency example"

    var id: String { rawValue }
}

@Model
final class UserProfile: Identifiable {
    @Attribute(.unique) var id: UUID
    var targetRole: String
    var targetBand: String
    var experienceLevel: String
    var coachingStyle: String
    var healthcareBackground: String
    var confidenceLevel: String
    var interviewExperience: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        targetRole: String,
        targetBand: String,
        experienceLevel: ExperienceLevel,
        coachingStyle: CoachingStyle,
        healthcareBackground: HealthcareBackground,
        confidenceLevel: ConfidenceLevel,
        interviewExperience: InterviewExperience,
        createdAt: Date = .now
    ) {
        self.id = id
        self.targetRole = targetRole
        self.targetBand = targetBand
        self.experienceLevel = experienceLevel.rawValue
        self.coachingStyle = coachingStyle.rawValue
        self.healthcareBackground = healthcareBackground.rawValue
        self.confidenceLevel = confidenceLevel.rawValue
        self.interviewExperience = interviewExperience.rawValue
        self.createdAt = createdAt
    }
}

@Model
final class JobApplication: Identifiable {
    @Attribute(.unique) var id: UUID
    var roleTitle: String
    var trustName: String
    var band: String
    var applicationStatus: String
    var interviewDate: Date?
    var rejectionReason: String
    var notes: String
    var createdAt: Date

    var status: ApplicationStatus {
        get { ApplicationStatus(rawValue: applicationStatus) ?? .drafting }
        set { applicationStatus = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        roleTitle: String,
        trustName: String,
        band: String,
        applicationStatus: ApplicationStatus = .drafting,
        interviewDate: Date? = nil,
        rejectionReason: String = "",
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.roleTitle = roleTitle
        self.trustName = trustName
        self.band = band
        self.applicationStatus = applicationStatus.rawValue
        self.interviewDate = interviewDate
        self.rejectionReason = rejectionReason
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class SupportingStatement: Identifiable {
    @Attribute(.unique) var id: UUID
    var applicationId: UUID?
    var content: String
    var exported: Bool
    var createdAt: Date

    init(id: UUID = UUID(), applicationId: UUID? = nil, content: String, exported: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.applicationId = applicationId
        self.content = content
        self.exported = exported
        self.createdAt = createdAt
    }
}

@Model
final class STARAnswer: Identifiable {
    @Attribute(.unique) var id: UUID
    var competency: String
    var situation: String
    var task: String
    var action: String
    var result: String
    var aiFeedback: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        competency: String,
        situation: String,
        task: String,
        action: String,
        result: String,
        aiFeedback: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.competency = competency
        self.situation = situation
        self.task = task
        self.action = action
        self.result = result
        self.aiFeedback = aiFeedback
        self.createdAt = createdAt
    }
}

@Model
final class MockInterviewSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var mode: String
    var score: Double
    var transcript: String
    var category: String
    var feedbackSummary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        mode: InterviewMode,
        score: Double,
        transcript: String,
        category: InterviewCategory,
        feedbackSummary: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.mode = mode.rawValue
        self.score = score
        self.transcript = transcript
        self.category = category.rawValue
        self.feedbackSummary = feedbackSummary
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript: Identifiable {
    @Attribute(.unique) var id: UUID
    var transcript: String
    var processedOutput: String
    var confidenceScore: Double
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, processedOutput: String = "", confidenceScore: Double = 0.78, createdAt: Date = .now) {
        self.id = id
        self.transcript = transcript
        self.processedOutput = processedOutput
        self.confidenceScore = confidenceScore
        self.createdAt = createdAt
    }
}

@Model
final class Achievement: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var detail: String
    var unlocked: Bool
    var unlockedAt: Date?

    init(id: UUID = UUID(), title: String, description: String, unlocked: Bool = false, unlockedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.detail = description
        self.unlocked = unlocked
        self.unlockedAt = unlockedAt
    }
}

@Model
final class SubscriptionState: Identifiable {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = false, renewsAt: Date? = nil) {
        self.id = id
        self.plan = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}

struct JobAnalysis: Codable, Equatable {
    var personSpecification: [String]
    var keyCompetencies: [String]
    var essentialCriteria: [String]
    var likelyInterviewTopics: [String]
    var valuesAlignment: [String]
    var importantKeywords: [String]
}

struct SupportingStatementDraft: Codable, Equatable {
    var professionalSummary: String
    var supportingStatement: String
    var competencyParagraphs: [String]
    var nhsValuesExamples: [String]
    var starExamples: [String]
    var atsKeywords: [String]
}

struct STARAnswerDraft: Codable, Equatable {
    var polishedAnswer: String
    var improvedSituation: String
    var improvedTask: String
    var improvedAction: String
    var improvedResult: String
    var feedback: String
}

struct InterviewQuestion: Codable, Equatable, Identifiable {
    var id = UUID()
    var question: String
    var category: String
    var coachingPrompt: String
}

struct InterviewFeedback: Codable, Equatable {
    var score: Double
    var summary: String
    var starStructureFeedback: String
    var confidenceNotes: String
    var fillerWordNotes: String
    var improvements: [String]
}

struct VoiceProcessingResult: Codable, Equatable {
    var polishedOutput: String
    var summary: String
    var confidenceScore: Double
    var suggestedNextSteps: [String]
}

struct CareerInsight: Codable, Equatable, Identifiable {
    var id = UUID()
    var title: String
    var detail: String
    var priority: String
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
