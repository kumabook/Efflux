//
//  Store.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation

open class Store<R: Reducer> {
    private let lockQueue = DispatchQueue(label: "Efflux id lock queue")
    public class StoreSubscription: Subscription {
        weak var store: Store?
        var id: Int64
        init(_ store: Store, _ id: Int64) {
            self.store = store
            self.id = id
        }
        public func unsubscribe() {
            store?.subscribers[id] = nil
        }
    }
    public private(set) var state: R.State
    var reducer: R
    var subscribers: [Int64: (R.Event, R.State) -> Void]
    private var latestId: Int64 = 0

    public init(state: R.State, reducer: R) {
        self.state = state
        self.reducer = reducer
        subscribers = [:]
    }

    private func reduce(_ action: R.Action) {
        state = reducer.reduce(action, self.state)
        let dispatch: (R.Action) -> () = { [weak self] in self?.dispatch($0) }
        let getState: () -> R.State? = { [weak self] in self?.state }
        let emit: (R.Event) -> () = { [weak self] in self?.emit($0) }
        reducer.effect(action, getState, dispatch, emit)
    }

    public func emit(_ event: R.Event) {
        for subscriber in subscribers.values {
            subscriber(event, state)
        }
    }

    public func dispatch(_ action: R.Action) {
        reduce(action)
    }

    public func subscribe(_ handler: @escaping (R.Event, R.State) -> Void) -> Subscription? {
        lockQueue.sync {
            latestId += 1
            subscribers[latestId] = handler
        }
        return StoreSubscription(self, latestId)
    }
}
