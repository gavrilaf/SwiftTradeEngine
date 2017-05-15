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
    public init(id: OrderID, type: OrderType, side: OrderSide, symbol: OBString, trader: OBString, price: Money, shares: Quantity) {
        self.id     = id
        self.type   = type
        self.side   = side
        self.symbol = symbol
        self.trader = trader
        self.price  = price
        self.shares = shares
    }
    
    let id: OrderID
    let type: OrderType
    let side: OrderSide
    let symbol: OBString
    let trader: OBString
    var price: Money
    var shares: Quantity
}
