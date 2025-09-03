import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var store: FastDebtStore
    @ObservedObject private var auth = AuthService.shared
    @AppStorage("targetDays") var targetDays: Int = 0
    @State private var showingAdd = false
    @State private var newDate = Date()
    @State private var newNote = ""

    private let gregorian: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    private let hijri: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .islamicUmmAlQura)
        f.locale = Locale(identifier: "ar_SA")
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("tagline", comment: "tagline"))
                .font(.headline)
                .padding(.top)

            let userDebts = store.debts.filter { $0.userId == auth.currentUser?.id }
            ProgressView(value: targetDays == 0 ? 0 : Double(userDebts.count) / Double(targetDays))
            Text("\(NSLocalizedString("remaining", comment: "remaining")): \(store.remaining(target: targetDays)) / \(NSLocalizedString("target", comment: "target")): \(targetDays)")

            if userDebts.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(userDebts) { debt in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(gregorian.string(from: debt.date)) (\(hijri.string(from: debt.date)))")
                                if let note = debt.note, !note.isEmpty {
                                    Text(note).font(.subheadline)
                                }
                            }
                            Spacer()
                            Button(action: { removeDebt(debt) }) {
                                Image(systemName: "checkmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let debt = userDebts[index]
                            removeDebt(debt)
                        }
                    }
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(NSLocalizedString("add", comment: "add"))
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                Form {
                    DatePicker(NSLocalizedString("date", comment: "date"), selection: $newDate, displayedComponents: .date)
                    TextField(NSLocalizedString("note", comment: "note"), text: $newNote)
                    Button(NSLocalizedString("add", comment: "add")) {
                        if let userId = auth.currentUser?.id {
                            store.add(date: newDate, note: newNote.isEmpty ? nil : newNote, userId: userId)
                        }
                        newDate = Date()
                        newNote = ""
                        showingAdd = false
                    }
                }
                .navigationTitle(NSLocalizedString("add", comment: "add"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(NSLocalizedString("close", comment: "close")) { showingAdd = false }
                    }
                }
            }
        }
    }

    private func removeDebt(_ debt: FastDebt) {
        store.remove(debt)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(FastDebtStore())
    }
}
