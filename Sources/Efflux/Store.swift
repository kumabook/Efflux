//
//  Store.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation
import Result
import ReactiveSwift

class Store<R: Reducer> {
    var state: R.State
    private var inputPort: Signal<R.Action, NoError>.Observer
    private var outputPort: Signal<R.Event, NoError>
    var reducer: R

    public init(state: R.State, reducer: R) {
        self.state = state
        let inputPipe = Signal<R.Action, NoError>.pipe()
        let outputPipe = Signal<R.Event, NoError>.pipe()
        self.inputPort = inputPipe.input
        self.outputPort = outputPipe.output
        self.reducer = reducer
        inputPipe.output.observeValues { [weak self] action in
            guard let self = self else {
                return
            }
            self.state = reducer.reduce(self.state, action)
            let dispatch: (R.Action) -> Void = { (action: R.Action) -> Void in
                self.dispatch(action)
            }
            reducer.effect(self.state, action, dispatch, outputPipe.input)
        }
    }

    func dispatch(_ action: R.Action) {
        QueueScheduler.main.schedule { [weak self] in
            self?.inputPort.send(value: action)
        }
    }

    public func subscribe(_ handler: @escaping (R.Event, R.State) -> Void) -> Disposable? {
        return outputPort.observeValues { [weak self] event in
            guard let state = self?.state else { return }
            handler(event, state)
            return
        }
    }
}
