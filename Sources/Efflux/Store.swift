//
//  Store.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation

open class Store<R: Reducer> {
    private let isolationQueue = DispatchQueue(label: "Efflux.Store.isolation")
    private static var queueKey: DispatchSpecificKey<Void> {
        return DispatchSpecificKey<Void>()
    }
    private let queueTag = DispatchSpecificKey<Void>()

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
    public private(set) var state: R.State
    var reducer: R
    var subscribers: [Int64: (R.Event, R.State) -> Void]
    private var latestId: Int64 = 0

    public init(state: R.State, reducer: R) {
        self.state = state
        self.reducer = reducer
        subscribers = [:]
        isolationQueue.setSpecific(key: queueTag, value: ())
    }

    private var isOnIsolationQueue: Bool {
        return DispatchQueue.getSpecific(key: queueTag) != nil
    }

    private func sync<T>(_ work: () -> T) -> T {
        if isOnIsolationQueue {
            return work()
        } else {
            return isolationQueue.sync(execute: work)
        }
    }

    private func reduce(_ action: R.Action) {
        state = reducer.reduce(action, self.state)
        let dispatch: (R.Action) -> () = { [weak self] in self?.dispatch($0) }
        let getState: () -> R.State? = { [weak self] in self?.state }
        let emit: (R.Event) -> () = { [weak self] in self?.emit($0) }
        reducer.effect(action, getState, dispatch, emit)
    }

    public func emit(_ event: R.Event) {
        sync {
            let state = self.state
            let subscribers = Array(self.subscribers.values)
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
    }

    public func dispatch(_ action: R.Action) {
        sync {
            self.reduce(action)
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
