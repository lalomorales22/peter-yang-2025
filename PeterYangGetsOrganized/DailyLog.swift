import Foundation

struct DailyLog: Identifiable, Equatable {
    let id = UUID()
    var date: Date
    /// Maps Item.id -> completed (true/false)
    var completions: [UUID : Bool]

    /// Helper to extract just "YYYY-MM-dd"
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
