import Foundation
import UserNotifications

class ReminderService {
    static let shared = ReminderService()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func scheduleDaily(at components: DateComponents) {
        cancel()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("rappels", comment: "reminders")
        content.body = "Sawmi — Ton jeûne, bien organisé."
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
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
        let request = UNNotificationRequest(identifier: "weeklyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
