//
//  OrderBookProtocol.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

public typealias TradeHandler = (TradeEvent) -> Void

public protocol OrderBookProtocol {
    
    var tradeHandler: TradeHandler? { get set }
    
    func reset()
    
    func add(order: Order)
    func cancel(orderById id: OrderID)
    
    var topBuyOrder: Order? { get }
    var topSellOrder: Order? { get }
}

public protocol OrderBookFactory {
    func createOrderBook() -> OrderBookProtocol
}
