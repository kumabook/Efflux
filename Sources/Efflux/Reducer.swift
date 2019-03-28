//
//  Reducer.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation
import Result
import ReactiveSwift

public protocol Reducer {
    associatedtype Action
    associatedtype Event
    associatedtype State

    typealias Dispatch = (Action) -> Void
    typealias Observer = Signal<Event, NoError>.Observer

    func reduce(_ state: State, _ action: Action) -> State
    func effect(_ state: State, _ action: Action, _ dispatch: Dispatch, _ output: Observer)
}
