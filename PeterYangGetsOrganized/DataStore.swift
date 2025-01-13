import Foundation
import SwiftUI

class DataStore: ObservableObject {
    @Published var items: [Item] = []
    @Published var dailyLogs: [DailyLog] = []

    init() {
        // Provide a few “default” tasks the first time.
        // In a production app, you might load from disk or Core Data.
        if items.isEmpty {
            items = [
                Item(title: "Wake Up & Drink Water", isMorning: true),
                Item(title: "Deep Work (1 hour)", isMorning: true),
                Item(title: "Workout (30 min)", isMorning: true),
                Item(title: "Stop Eating by 7:30 PM", isMorning: false),
                Item(title: "Stop Drinking Water by 8:00 PM", isMorning: false),
                Item(title: "Kindle Reading at 10:00 PM", isMorning: false),
                Item(title: "Sleep by 10:30 PM", isMorning: false)
            ]
        }
        // Optionally, load dailyLogs from persistent storage if needed.
    }

    func getOrCreateLog(for date: Date) -> DailyLog {
        // Extract just the day portion
        let dayOnly = trimmedDate(date)

        // Check if we already have a log for this day
        if let existing = dailyLogs.first(where: {
            trimmedDate($0.date) == dayOnly
        }) {
            return existing
        } else {
            // Create a new daily log with all tasks set to false by default.
            let newLog = DailyLog(
                date: dayOnly,
                completions: [:]
            )
            dailyLogs.append(newLog)
            return newLog
        }
    }

    func updateCompletion(for item: Item, date: Date, completed: Bool) {
        let dayOnly = trimmedDate(date)

        // Must find or create the relevant daily log
        if let index = dailyLogs.firstIndex(where: {
            trimmedDate($0.date) == dayOnly
        }) {
            // Update the existing log
            var log = dailyLogs[index]
            log.completions[item.id] = completed
            dailyLogs[index] = log
        } else {
            // Create new log
            var completions: [UUID: Bool] = [:]
            completions[item.id] = completed
            let newLog = DailyLog(date: dayOnly, completions: completions)
            dailyLogs.append(newLog)
        }
        objectWillChange.send()
    }

    /// Returns the completion status of a particular item on a given date.
    func isCompleted(item: Item, date: Date) -> Bool {
        let dayOnly = trimmedDate(date)
        if let log = dailyLogs.first(where: { trimmedDate($0.date) == dayOnly }) {
            return log.completions[item.id] ?? false
        }
        return false
    }

    // MARK: - Last 7 Days Stats
    /// Return an array of (dateString, completionPercent) for the last 7 days
    func last7DaysStats() -> [(String, Double)] {
        // For each of the last 7 days, find the completion %.
        var results: [(String, Double)] = []
        for i in 0..<7 {
            let day = Calendar.current.date(byAdding: .day, value: -i, to: trimmedDate(Date()))!
            let dateString = dateToString(day)
            let log = getOrCreateLog(for: day)

            // How many tasks are completed?
            let totalTasks = items.count
            let completedCount = log.completions.values.filter { $0 == true }.count
            let percent = Double(completedCount) / Double(totalTasks) * 100.0
            results.append((dateString, percent))
        }
        // We might want them in chronological order (oldest first):
        return results.reversed()
    }

    // MARK: - Helpers
    private func trimmedDate(_ date: Date) -> Date {
        // Zero out time components to get only the date portion
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Achievement Tracking
    
    /// Returns the total number of consecutive days with completions
    func getConsecutiveDaysCompleted() -> Int {
        let sortedLogs = dailyLogs.sorted { $0.date < $1.date }
        var consecutiveDays = 0
        var previousDate: Date? = nil
        
        for log in sortedLogs {
            // Check if any tasks were completed on this day
            let hasCompletions = log.completions.values.contains(true)
            
            if !hasCompletions {
                continue
            }
            
            if let previous = previousDate {
                let calendar = Calendar.current
                let daysBetween = calendar.dateComponents([.day], from: previous, to: log.date).day ?? 0
                
                // If there's a gap larger than 1 day, reset the counter
                if daysBetween > 1 {
                    consecutiveDays = 1
                } else if daysBetween == 1 {
                    consecutiveDays += 1
                }
            } else {
                consecutiveDays = 1
            }
            
            previousDate = log.date
        }
        
        return consecutiveDays
    }
    
    /// Returns the percentage progress towards 1000 days (0-100)
    func getOverallProgress() -> Double {
        let consecutiveDays = Double(getConsecutiveDaysCompleted())
        return min((consecutiveDays / 1000.0) * 100.0, 100.0)
    }
}
