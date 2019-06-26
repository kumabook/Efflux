//
//  Reducer.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation

public protocol Reducer {
    associatedtype Action
    associatedtype Event
    associatedtype State

    typealias GetState = () -> State?
    typealias Dispatch = (Action) -> Void
    typealias Emit = (Event) -> ()

    func reduce(_ action: Action, _ state: State) -> State
    func effect(_ action: Action, _ getState:  @escaping GetState, _ dispatch: @escaping Dispatch, _ emit: @escaping Emit)
}
