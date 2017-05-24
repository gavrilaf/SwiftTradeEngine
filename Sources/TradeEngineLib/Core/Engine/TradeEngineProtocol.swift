//
//  TradeEngineProtocol.swift
//  SwiftTradeEngine
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

enum EngineError : Error {
    case UnknownSymbol(symbol: OBString)
    case EmptyMarket(symbol: OBString)
}

protocol TradeEngineProtocol {
    
    var tradeHandler: TradeHandler? { get set }
    
    func createMarketOrder(side: OrderSide, symbol: String, trader: String, shares: Quantity) throws -> OrderID
    func createLimitOrder(side: OrderSide, symbol: String, trader: String, price: Money, shares: Quantity) throws -> OrderID
    
    func cancel(orderById id: OrderID)
    
    func sellMin(forSymbol symbol: String) -> Money?
    func buyMax(forSymbol symbol: String) -> Money?
}
