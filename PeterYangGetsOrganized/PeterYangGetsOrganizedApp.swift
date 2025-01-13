import SwiftUI

@main
struct PeterYangGetsOrganizedApp: App {
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            // We can use a TabView to show “Home,” “Stats,” and “Settings.”
            TabView {
                ContentView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .environmentObject(dataStore)

                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .environmentObject(dataStore)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .environmentObject(dataStore)
            }
            .preferredColorScheme(.dark)  // Force a dark theme for the entire app
        }
    }
}
