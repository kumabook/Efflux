//
//  Subscriber.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/28.
//

import Foundation

protocol Subscriber: class {
    associatedtype E
    func subscriberDidReceiveEvent(_ event: E)
}
