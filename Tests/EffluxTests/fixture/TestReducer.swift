//
//  TestReducer.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/04/15.
//

import Foundation
import Efflux

public enum TestAction {
    case increment
}

public struct TestState {
    var count: Int

    static func initial() -> TestState {
        return TestState(count: 0)
    }
}

public enum TestEvent {
    case incremented
}

public class TestReducer: Reducer {
    public typealias Action = TestAction
    public typealias Event = TestEvent
    public typealias State = TestState

    public func reduce(_ action: TestAction, _ state: TestState) -> TestState {
        switch action {
        case .increment:
            return TestState(count: state.count + 1)
        }
    }

    public func effect(_ action: TestAction, _ getState: () -> TestState?, _ dispatch: (TestAction) -> Void, _ emit: (TestEvent) -> ()) {
        switch action {
        case .increment:
            emit(.incremented)
        }
    }
}
