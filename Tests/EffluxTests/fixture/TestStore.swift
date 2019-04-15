//
//  TestStore.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/04/15.
//

import Foundation
import Efflux

class TestStore: Store<TestReducer> {
    static var shared: TestStore = TestStore(state: TestState.initial(), reducer: TestReducer())
}
