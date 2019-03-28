import XCTest
@testable import Efflux

final class EffluxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Efflux().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
