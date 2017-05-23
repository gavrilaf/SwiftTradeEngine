//
//  Event.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

public struct OrderExecutionInfo {
    let symbol: OBString
    let buyTrader: OBString
    let sellTrader: OBString
    let buyOrder: OrderID
    let sellOrder: OrderID
    let price: Money
    let shares: Quantity
    
    init(buyer: Order, seller: Order, shares: Quantity) {
        self.symbol     = buyer.symbol
        self.buyTrader  = buyer.trader
        self.sellTrader = seller.trader
        self.buyOrder   = buyer.id
        self.sellOrder  = seller.id
        self.price      = buyer.price
        self.shares     = shares
    }
}

extension OrderExecutionInfo: CustomStringConvertible {
    public var description: String {
        return "Trade(\(symbol), \(buyTrader), \(sellTrader), \(price), \(shares))"
    }
}

extension OrderExecutionInfo: Equatable {}

public func ==(lhs: OrderExecutionInfo, rhs: OrderExecutionInfo) -> Bool {
    return lhs.symbol == rhs.symbol && lhs.buyOrder == rhs.buyOrder && lhs.sellOrder == rhs.sellOrder
        && lhs.price == rhs.price && lhs.shares == rhs.shares
}

// MARK:
public enum TradeEvent {
    case orderCreated(order: Order)
    case orderExecuted(info: OrderExecutionInfo)
    case orderCompleted(id: OrderID)
    case orderCancelled(id: OrderID)
}

extension TradeEvent: Equatable {}

public func ==(lhs: TradeEvent, rhs: TradeEvent) -> Bool {
    switch (lhs, rhs) {
    case (.orderCreated(let a), .orderCreated(let b)):
        return a.id == b.id
    case (.orderCancelled(let a), .orderCancelled(let b)):
        return a == b
    case (.orderExecuted(let a), .orderExecuted(let b)):
        return a == b
    case (.orderCompleted(let a), .orderCompleted(let b)):
        return a == b
    default: return false
    }
}

extension TradeEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .orderCreated(let a):
            return a.description
        case .orderCancelled(let a):
            return "cancelled(\(a))"
        case .orderExecuted(let a):
            return a.description
        case .orderCompleted(let a):
            return "completed(\(a))"
        }
    }
}


