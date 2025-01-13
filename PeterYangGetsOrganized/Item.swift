import Foundation

struct Item: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isMorning: Bool  // true = morning, false = night
}
