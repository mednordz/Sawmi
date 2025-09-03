import Foundation
import UserNotifications

class ReminderService {
    static let shared = ReminderService()
    private init() {}

    private enum Identifier: String, CaseIterable {
        case daily = "dailyReminder"
        case weekly = "weeklyReminder"
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func scheduleDaily(at components: DateComponents) {
        cancel()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("rappels", comment: "reminders")
        content.body = "Sawmi — Ton jeûne, bien organisé."
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Identifier.daily.rawValue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleWeekly(weekday: Int, time: DateComponents) {
        cancel()
        var comps = time
        comps.weekday = weekday
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("rappels", comment: "reminders")
        content.body = "Sawmi — Ton jeûne, bien organisé."
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: Identifier.weekly.rawValue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancel() {
        let ids = Identifier.allCases.map { $0.rawValue }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
