//
//  BTreeBasedOrderBook.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/6/17.
//
//

import Foundation
import BTree


struct BTreeBasedOrderBookFactory: OrderBookFactory {
    func createOrderBook() -> OrderBookProtocol {
        return BTreeBasedOrderBook()
    }
}


class BTreeBasedOrderBook: OrderBookProtocol {
    
    var tradeHandler: TradeHandler?
    
    func add(order: Order) {
        var copy = order // Create mutable copy
        let type = (order.type, order.side)
        
        switch type {
        case (.limit, .buy):
            addLimitBuy(order: &copy)
        case (.limit, .sell):
            addLimitSell(order: &copy)
        default:
            break
        }
    }
    
    func cancel(orderById id: OrderID) {
        if let pair = prices.removeValue(forKey: id) {
            switch pair.1 {
            case .buy:
                cancelBuyOrder(price: pair.0, id: id)
            case .sell:
                cancelSellOrder(price: pair.0, id: id)
            }
        }
    }
    
    var topSellOrder: Order? {
        return sellBook.first?.1.first
    }
    
    var topBuyOrder: Order? {
        return buyBook.first?.1.first
    }
    
    typealias OrdersList = Array<Order>
    typealias BuyOrderBook = BTree<BuyPricePoint, OrdersList>
    typealias SellOrderBook = BTree<SellPricePoint, OrdersList>
    
    fileprivate var sellBook = SellOrderBook()
    fileprivate var buyBook = BuyOrderBook()
    
    fileprivate var prices = Map<OrderID, (Money, OrderSide)>()
}

extension BTreeBasedOrderBook {
    
    func addLimitSell(order: inout Order) {
        buyBook.withCursorAtStart { (cursor) in
            while !cursor.isAtEnd && cursor.key.amount >= order.price && order.shares > 0 {
                var pointOrders = cursor.value
                
                while pointOrders.count > 0 && order.shares > 0  {
                    let shares = min(order.shares, pointOrders[0].shares)
                    
                    order.shares -= shares
                    pointOrders[0].shares -= shares
                    
                    tradeEvent(buyer: pointOrders[0], seller: order, shares: shares)
                    
                    if pointOrders[0].shares == 0 {
                        pointOrders.remove(at: 0)
                    }
                }
                
                if pointOrders.count == 0 {
                    cursor.remove()
                } else {
                    _ = cursor.setValue(pointOrders)
                    break
                }
            }
        }
        
        if order.shares > 0 {
            let point = SellPricePoint(amount: order.price)
            var found = false
            sellBook.withCursor(onKey: point, body: { (cursor) in
                if !cursor.isAtEnd {
                    var orders = cursor.value
                    orders.append(order)
                    _ = cursor.setValue(orders)
                    found = true
                }
            })
            
            if !found {
                sellBook.insert((point, [order]))
            }
            
            prices[order.id] = (order.price, order.side)
        }
    }
    
    func addLimitBuy(order: inout Order) {
        sellBook.withCursorAtStart { (cursor) in
            while !cursor.isAtEnd && cursor.key.amount <= order.price && order.shares > 0 {
                var pointOrders = cursor.value
                
                while pointOrders.count > 0 && order.shares > 0  {
                    let shares = min(order.shares, pointOrders[0].shares)
                    
                    order.shares -= shares
                    pointOrders[0].shares -= shares
                    
                    tradeEvent(buyer: order, seller: pointOrders[0], shares: shares)
                    
                    if pointOrders[0].shares == 0 {
                        pointOrders.remove(at: 0)
                    }
                }
                
                if pointOrders.count == 0 {
                    cursor.remove()
                } else {
                    _ = cursor.setValue(pointOrders)
                    break
                }
            }
        }
        
        if order.shares > 0 {
            let point = BuyPricePoint(amount: order.price)
            var found = false
            buyBook.withCursor(onKey: point, body: { (cursor) in
                if !cursor.isAtEnd {
                    var orders = cursor.value
                    orders.append(order)
                    _ = cursor.setValue(orders)
                    found = true
                }
            })
            
            if !found {
                buyBook.insert((point, [order]))
            }
            
            prices[order.id] = (order.price, order.side)
        }
    }
    
    func cancelBuyOrder(price: Money, id: OrderID) {
        let point = BuyPricePoint(amount: price)
        buyBook.withCursor(onKey: point) { (cursor) in
            if !cursor.isAtEnd {
                var orders = cursor.value
                if let indx = orders.index(where: { (p) -> Bool in p.id == id }) {
                    orders.remove(at: indx)
                    _ = cursor.setValue(orders)
                    
                    self.cancelEvent(orderId: id)
                }
            }
        }
    }
    
    func cancelSellOrder(price: Money, id: OrderID) {
        let point = SellPricePoint(amount: price)
        sellBook.withCursor(onKey: point) { (cursor) in
            if !cursor.isAtEnd {
                var orders = cursor.value
                if let indx = orders.index(where: { (p) -> Bool in p.id == id }) {
                    orders.remove(at: indx)
                    _ = cursor.setValue(orders)
                    
                    self.cancelEvent(orderId: id)
                }
            }
        }
    }
}

extension BTreeBasedOrderBook {
    func cancelEvent(orderId: OrderID) {
        if let tradeHandler = tradeHandler {
            tradeHandler(.orderCancelled(id: orderId))
        }
    }
    
    func tradeEvent(buyer: Order, seller: Order, shares: Quantity) {
        if let tradeHandler = tradeHandler {
            let tradeInfo = OrderExecutionInfo(buyer: buyer, seller: seller, shares: shares)
            tradeHandler(.orderExecuted(info: tradeInfo))
            
            if buyer.shares == 0 {
                tradeHandler(.orderCompleted(id: buyer.id))
            }
            
            if seller.shares == 0 {
                tradeHandler(.orderCompleted(id: seller.id))
            }
        }
    }
}
