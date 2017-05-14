//
//  Order.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/13/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

public typealias OrderID = UInt64

public typealias Money = UInt64
public typealias Quantity = UInt64

public typealias OBString = String

public enum OrderType {
    case limit
    case market
}

public enum OrderSide {
    case sell
    case buy
}


public struct Order {
    let id: OrderID
    let type: OrderType
    let side: OrderSide
    let symbol: OBString
    let trader: OBString
    var price: Money
    var shares: Quantity
}
