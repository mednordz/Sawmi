import SwiftUI

struct SettingsView: View {
    @AppStorage("targetDays") private var targetDays: Int = 0
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = false
    @AppStorage("reminderWeekly") private var reminderWeekly: Bool = false
    @AppStorage("reminderTime") private var reminderTime: Double = Date().timeIntervalSince1970
    @AppStorage("reminderWeekday") private var reminderWeekday: Int = Calendar.current.component(.weekday, from: Date())

    var body: some View {
        Form {
            Stepper(value: $targetDays, in: 0...100) {
                Text("\(NSLocalizedString("target", comment: "target")): \(targetDays)")
            }

            Section(header: Text(NSLocalizedString("rappels", comment: "reminders"))) {
                Toggle(isOn: $remindersEnabled) {
                    Text(NSLocalizedString("enable", comment: "enable"))
                }
                if remindersEnabled {
                    Picker(NSLocalizedString("frequency", comment: "frequency"), selection: $reminderWeekly) {
                        Text(NSLocalizedString("daily", comment: "daily")).tag(false)
                        Text(NSLocalizedString("weekly", comment: "weekly")).tag(true)
                    }
                    if reminderWeekly {
                        Picker(NSLocalizedString("weekday", comment: "weekday"), selection: $reminderWeekday) {
                            ForEach(1..<8) { index in
                                Text(Calendar.current.weekdaySymbols[index - 1]).tag(index)
                            }
                        }
                    }
                    DatePicker(NSLocalizedString("time", comment: "time"), selection: Binding(
                        get: { Date(timeIntervalSince1970: reminderTime) },
                        set: { reminderTime = $0.timeIntervalSince1970; schedule() }
                    ), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings", comment: "settings"))
        .onChange(of: remindersEnabled) { _ in schedule() }
        .onChange(of: reminderWeekly) { _ in schedule() }
        .onChange(of: reminderWeekday) { _ in schedule() }
    }

    private func schedule() {
        let time = Date(timeIntervalSince1970: reminderTime)
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        if remindersEnabled {
            ReminderService.shared.requestAuthorization()
            if reminderWeekly {
                ReminderService.shared.scheduleWeekly(weekday: reminderWeekday, time: comps)
            } else {
                ReminderService.shared.scheduleDaily(at: comps)
            }
        } else {
            ReminderService.shared.cancel()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { SettingsView() }
    }
}
