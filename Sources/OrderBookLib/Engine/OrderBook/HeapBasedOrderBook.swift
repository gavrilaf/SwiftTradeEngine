//
//  HeapBasedOrderBook.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import Foundation

struct HeapBasedOrderBookFactory: OrderBookFactory {
    func createOrderBook() -> OrderBookProtocol {
        return HeapBasedOrderBook()
    }
}


struct HeapBasedOrderBook: OrderBookProtocol {
    
    weak var delegate: TradeObserverProtocol?
    
    func add(order: Order) {
    
    }
    
    func cancel(orderById id: OrderID) {
    
    }
    
    var askMin: Money {
        return 0
    }
    
    var bidMax: Money {
        return 0
    }
}
