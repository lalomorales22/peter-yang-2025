import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var today = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Today is \(formattedDate(today))")
                        .font(.title2)
                        .bold()

                    morningTasksSection
                    nightTasksSection

                    // Optional: show a simple table of last 7 days
                    Divider()
                    Text("Last 7 Days")
                        .font(.headline)
                    dailyLogTable
                }
                .padding()
            }
            .navigationTitle("Peter Yang's 2025 Tasks")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    private var morningTasksSection: some View {
        let morningItems = dataStore.items.filter { $0.isMorning }

        return VStack(alignment: .leading) {
            Text("Morning Tasks")
                .font(.headline)
            ForEach(morningItems) { item in
                Toggle(item.title, isOn: Binding(
                    get: { dataStore.isCompleted(item: item, date: today) },
                    set: { dataStore.updateCompletion(for: item, date: today, completed: $0) }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.2))
        .cornerRadius(8)
    }

    private var nightTasksSection: some View {
        let nightItems = dataStore.items.filter { !$0.isMorning }

        return VStack(alignment: .leading) {
            Text("Night Tasks")
                .font(.headline)
            ForEach(nightItems) { item in
                Toggle(item.title, isOn: Binding(
                    get: { dataStore.isCompleted(item: item, date: today) },
                    set: { dataStore.updateCompletion(for: item, date: today, completed: $0) }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.2))
        .cornerRadius(8)
    }

    private var dailyLogTable: some View {
        let stats = dataStore.last7DaysStats() // Array of (dateString, percent)
        return VStack(spacing: 8) {
            ForEach(stats, id: \.0) { (dateStr, percent) in
                HStack {
                    Text(dateStr)
                    Spacer()
                    Text("\(Int(percent))%")
                        .foregroundColor(percent >= 100 ? .green : .white)
                }
                .padding(.vertical, 2)
                Divider()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
