//
//  Event.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

struct OrderExecutionInfo {
    let symbol: OBString
    let buyTrader: OBString
    let sellTrader: OBString
    let price: Money
    let shares: Quantity
}


enum TradeEvent {
    case orderCancelled(id: OrderID)
    case orderExecuted(info: OrderExecutionInfo)
    case orderCompleted(id: OrderID)
}

