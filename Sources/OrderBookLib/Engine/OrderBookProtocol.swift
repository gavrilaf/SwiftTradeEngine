//
//  OrderBookProtocol.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

protocol TradeObserverProtocol: class {
    func handle(tradeEvent: TradeEvent)
}

protocol OrderBookProtocol {
    
    weak var delegate: TradeObserverProtocol? { get set }
    
    func add(order: Order)
    func cancel(orderById id: OrderID)
    
    var askMin: Money { get }
    var bidMax: Money { get }
}

protocol OrderBookFactory {
    func createOrderBook() -> OrderBookProtocol
}
