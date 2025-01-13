import XCTest
@testable import PeterYangGetsOrganized

final class PeterYangGetsOrganizedTests: XCTestCase {

    func testCreatingDailyLog() throws {
        let store = DataStore()
        let todayLog = store.getOrCreateLog(for: Date())
        XCTAssertNotNil(todayLog, "We should be able to create a daily log for today.")
    }
}
