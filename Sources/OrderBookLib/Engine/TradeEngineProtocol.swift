//
//  TradeEngineProtocol.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

protocol TradeEngineProtocol {
    
    var tradeHandler: TradeHandler? { get set }
    
    func createMarketOrder(side: OrderSide, symbol: String, trader: String, shares: Quantity) -> Order
    func createLimitOrder(side: OrderSide, symbol: String, trader: String, price: Money, shares: Quantity) -> Order
    
    func add(order: Order)
    func cancel(orderById id: OrderID)
    
    func sellMin(forSymbol symbol: String) -> Money?
    func buyMax(forSymbol symbol: String) -> Money?
}
