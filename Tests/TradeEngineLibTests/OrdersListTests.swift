//
//  OrdersListTests.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/17/17.
//
//

import XCTest
@testable import TradeEngineLib

class OrdersListTests: XCTestCase {
    
    let o1 = Order(id: 1, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let o2 = Order(id: 2, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 100)
    let o3  = Order(id: 3, side: .sell, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    let o4  = Order(id: 4, side: .buy, symbol: "JPM", trader: "MAX", price: 101, shares: 50)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOrdersListSimple() {
        let lst = OrdersList()
        
        lst.add(order: o1)
        XCTAssertEqual(lst.isEmpty, false)
        XCTAssertEqual(lst.top.id, 1)
        
        lst.add(order: o2)
        
        _ = lst.updateTop(minusShares: 20)
        XCTAssertEqual(lst.top.shares, 80)
        
        _ = lst.updateTop(minusShares: 80)
        XCTAssertEqual(lst.top.id, 2)
        
        lst.cancel(orderById: 2)
        
        XCTAssertTrue(lst.isEmpty)
    }
    
    func testOrdersListCancel() {
        let lst = OrdersList()
        
        lst.add(order: o1)
        lst.add(order: o2)
        lst.add(order: o3)
        lst.add(order: o4)
        
        lst.cancel(orderById: o1.id)
        lst.cancel(orderById: o3.id)
        lst.cancel(orderById: o4.id)
        
        XCTAssertEqual(lst.top.id, o2.id)
        
    }
    
    func testOrdersListCooplex() {
        let lst = OrdersList()
        
        lst.add(order: o1)
        lst.add(order: o2)
        lst.add(order: o3)
        lst.add(order: o4)
        
        lst.cancel(orderById: o2.id)
        lst.cancel(orderById: o3.id)
        
        let o = lst.updateTop(minusShares: o1.shares)
        
        XCTAssertEqual(o.id, o1.id)
        XCTAssertEqual(o.shares, 0)
        
        XCTAssertEqual(lst.top.id, o4.id)
        
    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
