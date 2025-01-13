import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore

    // Bitcoin address divided into 10 parts
    private let bitcoinAddress = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

    // Updated helper computed properties
    private var daysCompleted: Int {
        dataStore.getConsecutiveDaysCompleted()
    }
    
    private var unlockedBitcoinAddress: String {
        let segments = daysCompleted / 100 // One segment per 100 days
        let partLength = bitcoinAddress.count / 10
        let unlockedLength = segments * partLength
        return String(bitcoinAddress.prefix(max(1, unlockedLength)))
    }
    
    private var progressToNextUnlock: Double {
        let progress = Double(daysCompleted % 100)
        return progress
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("7-Day Completion Percentage")
                        .font(.title2)
                        .padding(.top)

                    Chart {
                        ForEach(dataStore.last7DaysStats(), id: \.0) { (dateString, percent) in
                            LineMark(
                                x: .value("Date", dateString),
                                y: .value("Completion %", percent)
                            )
                            PointMark(
                                x: .value("Date", dateString),
                                y: .value("Completion %", percent)
                            )
                        }
                    }
                    .chartYAxisLabel("Percent")
                    .padding()

                    // Updated Achievement Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Bitcoin Address Achievement")
                            .font(.title2)

                        // Overall progress
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Overall Progress: \(daysCompleted) / 1000 days")
                                .foregroundColor(.gray)
                            ProgressView(value: Double(daysCompleted), total: 1000)
                                .tint(.orange)
                        }

                        // Progress to next unlock
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress to Next Unlock: \(Int(progressToNextUnlock)) / 100 days")
                                .foregroundColor(.gray)
                            ProgressView(value: progressToNextUnlock, total: 100)
                                .tint(.green)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unlocked Address Part:")
                                .font(.headline)
                            Text(unlockedBitcoinAddress)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical)

                        Text("Unlock a new part every 100 days! Complete 1000 days to reveal the full address.")
                            .italic()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .padding()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            .navigationTitle("Stats")
        }
    }
}
