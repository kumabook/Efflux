//
//  Disposable.swift
//  Efflux
//
//  Created by Hiroki Kumamoto on 2019/03/31.
//

import Foundation

public protocol Subscription {
    func unsubscribe()
}
