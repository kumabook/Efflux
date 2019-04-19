import XCTest
@testable import Efflux

final class EffluxTests: XCTestCase {
    let timeout: TimeInterval = 0.1
    var store = TestStore(state: TestReducer.State(count: 0), reducer: TestReducer())
    override func setUp() {
        super.setUp()
        store = TestStore(state: TestReducer.State(count: 0), reducer: TestReducer())
    }
    func testReduce() {
        XCTAssertEqual(store.state.count, 0)
        store.dispatch(TestAction.increment)
        let e: XCTestExpectation? = expectation(description: "count up")
        DispatchQueue.main.async {
            XCTAssertEqual(self.store.state.count, 1)
            e?.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDispatch() {
        store.dispatch(TestAction.increment)
        store.dispatch(TestAction.increment)
        store.dispatch(TestAction.increment)
        store.dispatch(TestAction.increment)
        let e: XCTestExpectation? = expectation(description: "count up")
        DispatchQueue.main.async {
            XCTAssertEqual(self.store.state.count, 4)
            e?.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testSubscribe() {
        let e: XCTestExpectation? = expectation(description: "receive event")
        let _ = store.subscribe { (event, state) in
            XCTAssertEqual(event, TestEvent.incremented)
            e?.fulfill()
        }
        store.dispatch(TestAction.increment)
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testUnsbscribe() {
        let subscribe = store.subscribe { (event, state) in
            XCTFail()
        }
        subscribe?.unsubscribe()
        store.dispatch(TestAction.increment)
        let e: XCTestExpectation? = expectation(description: "just wait")
        DispatchQueue.main.async {
            e?.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    static var allTests = [
        ("testReduce", testReduce),
        ("testDispatch", testDispatch),
        ("testSubscribe", testSubscribe),
        ("testUnsbscribe", testUnsbscribe),
    ]
}
