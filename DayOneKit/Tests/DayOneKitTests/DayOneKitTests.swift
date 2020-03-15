import XCTest
@testable import DayOneKit

final class DayOneKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DayOneKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
