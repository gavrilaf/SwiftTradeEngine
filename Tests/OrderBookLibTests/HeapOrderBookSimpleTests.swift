//
//  HeapOrderBookSimpleTests.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import XCTest
@testable import OrderBookLib

class HeapOrderBookSimpleTests: XCTestCase {
    
    let oa101x100 = Order(id: 1, type: .limit, side: .ask, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let ob101x100 = Order(id: 2, type: .limit, side: .bid, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let oa101x50  = Order(id: 3, type: .limit, side: .ask, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let ob101x50  = Order(id: 4, type: .limit, side: .bid, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let oa101x25  = Order(id: 5, type: .limit, side: .ask, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25  = Order(id: 6, type: .limit, side: .bid, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25x = Order(id: 7, type: .limit, side: .bid, symbol: "JPM", trader: "XAM", price: 101, shares: 25)
    
    var orderBook: OrderBookProtocol!

    override func setUp() {
        super.setUp()
        
        let factory = HeapBasedOrderBookFactory()
        orderBook = factory.createOrderBook()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimpleAsk() {
        orderBook.add(order: oa101x100)
        XCTAssertEqual(orderBook.askMin, oa101x100.price)
    }
    
    func testSimpleBid() {
        orderBook.add(order: ob101x100)
        XCTAssertEqual(orderBook.bidMax, ob101x100.price)
    }
}
