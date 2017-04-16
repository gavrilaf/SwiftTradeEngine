//
//  Order.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/13/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

typealias OrderID = UInt64

typealias Money = UInt64
typealias Quantity = UInt64

typealias OBString = String

enum OrderType {
    case limit
    case market
}

enum OrderSide {
    case bid
    case ask
}


struct Order {
    let id: OrderID
    let type: OrderType
    let side: OrderSide
    let symbol: OBString
    let trader: OBString
    var price: Money
    var shares: Quantity
}
