//
//  BTreeOrderBookSimpleTests.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/14/17.
//  Copyright © 2017 gavrilaf. All rights reserved.
//

import XCTest
@testable import TradeEngineLib

class BTreeOrderBookSimpleTests: XCTestCase {
    
    let oa101x100 = Order(id: 1, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let ob101x100 = Order(id: 2, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let oa101x50  = Order(id: 3, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let ob101x50  = Order(id: 4, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let oa101x25  = Order(id: 5, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25  = Order(id: 6, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25x = Order(id: 7, side: .buy, symbol: "JPM", trader: "XAM", price: 101, shares: 25)
    
    var orderBook: OrderBookProtocol!
    
    var tradeHistory = Array<TradeEvent>()
    
    //

    override func setUp() {
        super.setUp()
        
        let factory = BTreeBasedOrderBookFactory()
        orderBook = factory.createOrderBook()
        
        orderBook.tradeHandler = { (event) in
            self.tradeHistory.append(event)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimpleSell() {
        orderBook.add(order: oa101x100)
        
        XCTAssertEqual(orderBook.topSellOrder?.price, oa101x100.price)
        XCTAssertEqual(orderBook.topSellOrder?.shares, oa101x100.shares)
    }
    
    func testSimpleBuy() {
        orderBook.add(order: ob101x100)
        
        XCTAssertEqual(orderBook.topBuyOrder?.price, ob101x100.price)
        XCTAssertEqual(orderBook.topBuyOrder?.shares, ob101x100.shares)
    }
    
    func testExecution() {
        orderBook.add(order: ob101x100)
        orderBook.add(order: oa101x100)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info: OrderExecutionInfo(buyer: ob101x100, seller: oa101x100, shares: 100)),
                                      TradeEvent.orderCompleted(id: ob101x100.id),
                                      TradeEvent.orderCompleted(id: oa101x100.id)])
        
        XCTAssertNil(orderBook.topBuyOrder)
        XCTAssertNil(orderBook.topSellOrder)
    }
    
    func testExecution2() {
        orderBook.add(order: oa101x100)
        orderBook.add(order: ob101x100)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info: OrderExecutionInfo(buyer: ob101x100, seller: oa101x100, shares: 100)),
                                      TradeEvent.orderCompleted(id: ob101x100.id),
                                      TradeEvent.orderCompleted(id: oa101x100.id)])
        
        XCTAssertNil(orderBook.topBuyOrder)
        XCTAssertNil(orderBook.topSellOrder)
    }
    
    func testPartialFill1() {
        orderBook.add(order: oa101x100)
        orderBook.add(order: ob101x50)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x50, seller: oa101x100, shares: 50)),
                                      TradeEvent.orderCompleted(id: ob101x50.id)])
        
        XCTAssertNil(orderBook.topBuyOrder)
        
        XCTAssertEqual(orderBook.topSellOrder?.price, oa101x100.price)
        XCTAssertEqual(orderBook.topSellOrder?.shares, oa101x100.shares - ob101x50.shares)
    }
    
    
    func testPartialFill2() {
        orderBook.add(order: ob101x100)
        orderBook.add(order: oa101x50)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x100, seller: oa101x50, shares: 50)),
                                      TradeEvent.orderCompleted(id: oa101x50.id)])
        
        XCTAssertNil(orderBook.topSellOrder)
        
        XCTAssertEqual(orderBook.topBuyOrder?.price, ob101x100.price)
        XCTAssertEqual(orderBook.topBuyOrder?.shares, ob101x100.shares - oa101x50.shares)
    }
    
    func testIncrementalOverFill1() {
        [oa101x100, ob101x25, ob101x25, ob101x25, ob101x25, ob101x25].forEach {
            self.orderBook.add(order: $0)
        }
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25, seller: oa101x100, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25, seller: oa101x100, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25, seller: oa101x100, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25, seller: oa101x100, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25.id),
                                      TradeEvent.orderCompleted(id: oa101x100.id)])
        
        XCTAssertNil(orderBook.topSellOrder)
        
        XCTAssertEqual(orderBook.topBuyOrder?.price, ob101x25.price)
        XCTAssertEqual(orderBook.topBuyOrder?.shares, ob101x25.shares)
    }
    
    func testIncrementalOverFill2() {
        [ob101x100, oa101x25, oa101x25, oa101x25, oa101x25, oa101x25].forEach {
            self.orderBook.add(order: $0)
        }
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x100, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: oa101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x100, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: oa101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x100, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: oa101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x100, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x100.id),
                                      TradeEvent.orderCompleted(id: oa101x25.id)])
        
        XCTAssertNil(orderBook.topBuyOrder)
        
        XCTAssertEqual(orderBook.topSellOrder?.price, oa101x25.price)
        XCTAssertEqual(orderBook.topSellOrder?.shares, oa101x25.shares)
    }
    
    func testQueuePosition() {
        [ob101x25x, ob101x25, oa101x25].forEach {
            self.orderBook.add(order: $0)
        }
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25x, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25x.id),
                                      TradeEvent.orderCompleted(id: oa101x25.id)])
        
        XCTAssertNil(orderBook.topSellOrder)
        XCTAssertEqual(orderBook.topBuyOrder?.price, ob101x25.price)
        XCTAssertEqual(orderBook.topBuyOrder?.shares, ob101x25.shares)
    }
    
    func testCancel() {
        orderBook.add(order: ob101x25)
        orderBook.cancel(orderById: ob101x25.id)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderCancelled(id: ob101x25.id)])
        
        XCTAssertNil(orderBook.topSellOrder)
        XCTAssertNil(orderBook.topBuyOrder)
    }
    
    func testCancelFromFrontOfQueue() {
        orderBook.add(order: ob101x25x)
        orderBook.add(order: ob101x25)
        orderBook.cancel(orderById: ob101x25.id)
        orderBook.add(order: oa101x25)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderCancelled(id: ob101x25.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25x, seller: oa101x25, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25x.id),
                                      TradeEvent.orderCompleted(id: oa101x25.id)])
        
        XCTAssertNil(orderBook.topSellOrder)
        XCTAssertNil(orderBook.topBuyOrder)
    }
    
    
    func testCancelFrontBackOutOfOrderThenPartialExecution() {
        [ob101x100, ob101x25x, ob101x25, ob101x50].forEach { self.orderBook.add(order: $0) }
        [ob101x100, ob101x50, ob101x25x].forEach { self.orderBook.cancel(orderById: $0.id)}
        orderBook.add(order: oa101x50)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderCancelled(id: ob101x100.id),
                                      TradeEvent.orderCancelled(id: ob101x50.id),
                                      TradeEvent.orderCancelled(id: ob101x25x.id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: ob101x25, seller: oa101x50, shares: 25)),
                                      TradeEvent.orderCompleted(id: ob101x25.id)])
        
        XCTAssertNil(orderBook.topBuyOrder)
        XCTAssertEqual(orderBook.topSellOrder?.price, oa101x50.price)
        XCTAssertEqual(orderBook.topSellOrder?.shares, 25)
    }
}
