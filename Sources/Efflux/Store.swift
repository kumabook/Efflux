//
//  Store.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation

open class Store<R: Reducer> {
    private let isolationQueue = DispatchQueue(label: "Efflux.Store.isolation")
    private let effectQueue = DispatchQueue(label: "Efflux.Store.effect")
    private let queueTag = DispatchSpecificKey<Void>()
    private let effectTag = DispatchSpecificKey<Void>()

    public class StoreSubscription: Subscription {
        weak var store: Store?
        var id: Int64
        init(_ store: Store, _ id: Int64) {
            self.store = store
            self.id = id
        }
        public func unsubscribe() {
            store?.removeSubscriber(id)
        }
    }
    private var _state: R.State
    public var state: R.State {
        sync { _state }
    }
    var reducer: R
    var subscribers: [Int64: (R.Event, R.State) -> Void]
    private var latestId: Int64 = 0

    public init(state: R.State, reducer: R) {
        self._state = state
        self.reducer = reducer
        subscribers = [:]
        isolationQueue.setSpecific(key: queueTag, value: ())
        effectQueue.setSpecific(key: effectTag, value: ())
    }

    private var isOnIsolationQueue: Bool {
        return DispatchQueue.getSpecific(key: queueTag) != nil
    }

    private var isOnEffectQueue: Bool {
        return DispatchQueue.getSpecific(key: effectTag) != nil
    }

    private func sync<T>(_ work: () -> T) -> T {
        if isOnIsolationQueue {
            return work()
        } else {
            return isolationQueue.sync(execute: work)
        }
    }

    private func syncEffect<T>(_ work: () -> T) -> T {
        if isOnEffectQueue {
            return work()
        } else {
            return effectQueue.sync(execute: work)
        }
    }

    public func emit(_ event: R.Event) {
        let (state, subscribers): (R.State, [(R.Event, R.State) -> Void]) = sync {
            let subscribers = Array(self.subscribers.values)
            return (self._state, subscribers)
        }
        guard !subscribers.isEmpty else { return }
        let notify = {
            for subscriber in subscribers {
                subscriber(event, state)
            }
        }
        if Thread.isMainThread {
            notify()
        } else {
            DispatchQueue.main.async(execute: notify)
        }
    }

    public func dispatch(_ action: R.Action) {
        syncEffect {
            self.sync {
                self._state = self.reducer.reduce(action, self._state)
            }
            let dispatch: (R.Action) -> () = { [weak self] in self?.dispatch($0) }
            let getState: () -> R.State? = { [weak self] in self?.state }
            let emit: (R.Event) -> () = { [weak self] in self?.emit($0) }
            self.reducer.effect(action, getState, dispatch, emit)
        }
    }

    public func subscribe(_ handler: @escaping (R.Event, R.State) -> Void) -> Subscription? {
        return sync {
            latestId += 1
            subscribers[latestId] = handler
            return StoreSubscription(self, latestId)
        }
    }

    fileprivate func removeSubscriber(_ id: Int64) {
        sync {
            self.subscribers[id] = nil
        }
    }
}
