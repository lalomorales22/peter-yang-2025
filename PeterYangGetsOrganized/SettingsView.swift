import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore

    @State private var newTaskTitle: String = ""
    @State private var newTaskIsMorning: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tasks")) {
                    ForEach($dataStore.items) { $item in
                        HStack {
                            TextField("Task Title", text: $item.title)
                            Toggle("Morning?", isOn: $item.isMorning)
                                .labelsHidden()
                        }
                    }
                }

                Section(header: Text("Add New Task")) {
                    TextField("New Task Title", text: $newTaskTitle)
                    Toggle("Morning?", isOn: $newTaskIsMorning)
                    Button("Add") {
                        guard !newTaskTitle.isEmpty else { return }
                        let newItem = Item(title: newTaskTitle, isMorning: newTaskIsMorning)
                        dataStore.items.append(newItem)
                        newTaskTitle = ""
                        newTaskIsMorning = true
                    }
                }
            }
            .navigationTitle("Settings")
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }
}
