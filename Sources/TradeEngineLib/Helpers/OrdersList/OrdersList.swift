//
//  OrdersList.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/17/17.
//
//

import Foundation

final class OrdersList {

    static let capacity = 20
    
    var count: Int = 0
    
    var orders: [Order?]
    var head: Int = 0
    var tail: Int = 0
    
    init() {
        orders = Array<Order?>(repeating: nil, count: OrdersList.capacity)
    }
    
    init(withOrder order: Order) {
        orders = Array<Order?>(repeating: nil, count: OrdersList.capacity)
        orders[0] = order
        count += 1
        tail += 1
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    
    var checkedTop: Order? {
        return !isEmpty ? orders[head] : nil
    }
    
    var top: Order {
        return orders[head]!
    }
    
    var topShares: Quantity {
        return orders[head]?.shares ?? 0
    }
    
    func updateTop(minusShares shares: Quantity) -> Order {
        orders[head]!.shares -= shares
        let order = orders[head]!
        if order.shares <= 0 {
            count -= 1
            orders[head] = nil
            while count > 0 && orders[head] == nil {
                head += 1
            }
            
        }
        return order
    }
    
    func add(order: Order) {
        orders[tail] = order
        tail += 1
        count += 1
        
        if tail == orders.count {
            let emptySpace = [Order?](repeating: nil, count: OrdersList.capacity)
            orders.append(contentsOf: emptySpace)
        }
    }
    
    func cancel(orderById id: OrderID) {
        for i in head..<tail {
            if orders[i] != nil && orders[i]!.id == id {
                orders[i] = nil
                if i == head { head += 1 }
                if i == tail - 1 { tail -= 1 }
                
                count -= 1
                break
            }
        }
    }
}
