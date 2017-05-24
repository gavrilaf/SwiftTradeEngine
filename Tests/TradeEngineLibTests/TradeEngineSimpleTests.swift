//
//  TradeEngineSimpleTests.swift
//  SwiftTradeEngine
//
//  Created by Eugen Fedchenko on 5/24/17.
//
//

import XCTest
@testable import TradeEngineLib

extension TradeEngineProtocol {
    
    func addLimit(_ p: Order) throws -> Order {
        return try self.createLimitOrder(side: p.side, symbol: p.symbol, trader: p.trader, price: p.price, shares: p.shares)
    }
    
    func addMarket(_ p: Order) throws -> Order {
        return try self.createMarketOrder(side: p.side, symbol: p.symbol, trader: p.trader, shares: p.shares)
    }
}

class TradeEngineSimpleTests: XCTestCase {
    
    let oa101x100 = Order(id: 1, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let ob101x100 = Order(id: 2, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let oa101x50  = Order(id: 3, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let ob101x50  = Order(id: 4, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let oa101x25  = Order(id: 5, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25  = Order(id: 6, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 25)
    let ob101x25x = Order(id: 7, side: .buy, symbol: "JPM", trader: "XAM", price: 101, shares: 25)
    let oa101x100x2 = Order(id: 8, side: .sell, symbol: "MPJ", trader: "MAX", price: 101, shares: 100)
    let ob101x100x2 = Order(id: 9, side: .buy, symbol: "MPJ", trader: "MAX", price: 101, shares: 100)
    
    var engine: TradeEngineProtocol!
    var tradeHistory = Array<TradeEvent>()
    
    //
    
    override func setUp() {
        super.setUp()
        
        engine = TradeEngine(symbols: ["JPM", "MPJ"], factory: BTreeBasedOrderBookFactory())
        
        engine.tradeHandler = { (event) in
            self.tradeHistory.append(event)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK:
    
    func testExecution() {
        let o1 = try! engine.addLimit(ob101x100)
        let o2 = try! engine.addLimit(oa101x100)
        
        XCTAssertEqual(o1.id, 1)
        XCTAssertEqual(o2.id, 2)
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info: OrderExecutionInfo(buyer: o1, seller: o2, shares: 100)),
                                      TradeEvent.orderCompleted(id: 1),
                                      TradeEvent.orderCompleted(id: 2)])
        
        XCTAssertNil(engine.buyMax(forSymbol: ob101x100.symbol))
        XCTAssertNil(engine.buyMax(forSymbol: oa101x100.symbol))
    }

    func testIncrementalOverFill2() {
        let oo = [ob101x100, oa101x25, oa101x25, oa101x25, oa101x25, oa101x25, oa101x100x2, ob101x100x2].map {
            return try! self.engine.addLimit($0)
        }
        
        XCTAssertEqual(tradeHistory, [TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: oo[0], seller: oo[1], shares: 25)),
                                      TradeEvent.orderCompleted(id: oo[1].id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: oo[0], seller: oo[2], shares: 25)),
                                      TradeEvent.orderCompleted(id: oo[2].id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: oo[0], seller: oo[3], shares: 25)),
                                      TradeEvent.orderCompleted(id: oo[3].id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: oo[0], seller: oo[4], shares: 25)),
                                      TradeEvent.orderCompleted(id: oo[0].id),
                                      TradeEvent.orderCompleted(id: oo[4].id),
                                      TradeEvent.orderExecuted(info:OrderExecutionInfo(buyer: oo[7], seller: oo[6], shares: 100)),
                                      TradeEvent.orderCompleted(id: oo[7].id),
                                      TradeEvent.orderCompleted(id: oo[6].id)])
        
        XCTAssertNil(engine.buyMax(forSymbol: ob101x100.symbol))
        XCTAssertEqual(engine.sellMin(forSymbol: oa101x25.symbol), 101)
    }

    
}
