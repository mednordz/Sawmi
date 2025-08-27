import SwiftUI

struct SettingsView: View {
    @AppStorage("targetDays") private var targetDays: Int = 0
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = false
    @AppStorage("reminderWeekly") private var reminderWeekly: Bool = false
    @AppStorage("reminderTime") private var reminderTime: Double = Date().timeIntervalSince1970

    var body: some View {
        Form {
            Stepper(value: $targetDays, in: 0...100) {
                Text("Objectif: \(targetDays)")
            }

            Section(header: Text(NSLocalizedString("rappels", comment: "reminders"))) {
                Toggle(isOn: $remindersEnabled) {
                    Text("Activer")
                }
                if remindersEnabled {
                    Picker("Fréquence", selection: $reminderWeekly) {
                        Text("Quotidien").tag(false)
                        Text("Hebdomadaire").tag(true)
                    }
                    DatePicker("Heure", selection: Binding(
                        get: { Date(timeIntervalSince1970: reminderTime) },
                        set: { reminderTime = $0.timeIntervalSince1970; schedule() }
                    ), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("Paramètres")
        .onChange(of: remindersEnabled) { _ in schedule() }
        .onChange(of: reminderWeekly) { _ in schedule() }
    }

    private func schedule() {
        let time = Date(timeIntervalSince1970: reminderTime)
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        if remindersEnabled {
            ReminderService.shared.requestAuthorization()
            if reminderWeekly {
                let weekday = Calendar.current.component(.weekday, from: Date())
                ReminderService.shared.scheduleWeekly(weekday: weekday, time: comps)
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
        NavigationView { SettingsView() }
    }
}
