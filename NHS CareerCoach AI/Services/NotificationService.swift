import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleInterviewReminder(application: JobApplication) async {
        guard let interviewDate = application.interviewDate else { return }
        let allowed = await requestAuthorization()
        guard allowed else { return }

        let content = UNMutableNotificationContent()
        content.title = "Interview preparation"
        content.body = "Your \(application.roleTitle) interview is coming up. Review STAR answers and NHS values today."
        content.sound = .default

        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: interviewDate) ?? interviewDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "interview-\(application.id.uuidString)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }
}

