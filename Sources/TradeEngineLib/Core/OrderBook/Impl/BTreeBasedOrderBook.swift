//
//  BTreeBasedOrderBook.swift
//  SwiftTradeEngine
//
//  Created by Eugen Fedchenko on 5/6/17.
//
//

import Foundation

public struct BTreeBasedOrderBookFactory: OrderBookFactory {
    public init() {}
    
    public func createOrderBook() -> OrderBookProtocol {
        return BTreeBasedOrderBook()
    }
}

class BTreeBasedOrderBook: OrderBookProtocol {
    
    var tradeHandler: TradeHandler?
    
    func reset() {
        sellBook.removeAll()
        buyBook.removeAll()
        prices.removeAll()
    }
    
    func add(order: Order) {
        var copy = order // Create mutable copy
        
        switch order.side {
        case .buy:
            addBuy(order: &copy)
        case .sell:
            addSell(order: &copy)
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
        return sellBook.first?.1.checkedTop
    }
    
    var topBuyOrder: Order? {
        return buyBook.first?.1.checkedTop
    }
    
    typealias BuyOrderBook = BTree<BuyPricePoint, OrdersList>
    typealias SellOrderBook = BTree<SellPricePoint, OrdersList>
    
    fileprivate var sellBook = SellOrderBook()
    fileprivate var buyBook = BuyOrderBook()
    
    fileprivate var sellMin: UInt64 = UInt64.max
    fileprivate var buyMax: UInt64 = 0
    
    fileprivate var prices = Dictionary<OrderID, (Money, OrderSide)>()
}

extension BTreeBasedOrderBook {
    
    func addSell(order: inout Order) {
        if buyMax >= order.price {
            buyBook.withCursorAtStart { (cursor) in
                while !cursor.isAtEnd && cursor.key.amount >= order.price && order.shares > 0 {
                    let pointOrders = cursor.value
                    
                    while !pointOrders.isEmpty && order.shares > 0  {
                        let shares = min(order.shares, pointOrders.topShares)
                        
                        order.shares -= shares
                        let updatedTop = pointOrders.updateTop(minusShares: shares)
                        
                        tradeEvent(buyer: updatedTop, seller: order, shares: shares)
                    }
                    
                    if pointOrders.isEmpty {
                        cursor.remove()
                    } else {
                        break
                    }
                }
                
                if !cursor.isAtEnd {
                    buyMax = cursor.key.amount
                } else {
                    buyMax = 0
                }
            }
        }
        
        if order.shares > 0 {
            let point = SellPricePoint(amount: order.price)
            sellBook.withCursor(onKey: point, body: { (cursor) in
                if !cursor.isAtEnd {
                    cursor.value.add(order: order)
                } else {
                    cursor.insert((point, OrdersList(withOrder: order)))
                }
            })
            
            if order.price < sellMin {
                sellMin = order.price
            }
            
            prices[order.id] = (order.price, order.side)
        }
    }
    
    func addBuy(order: inout Order) {
        if sellMin <= order.price {
            sellBook.withCursorAtStart { (cursor) in
                while !cursor.isAtEnd && cursor.key.amount <= order.price && order.shares > 0 {
                    let pointOrders = cursor.value
                    
                    while !pointOrders.isEmpty && order.shares > 0  {
                        let shares = min(order.shares, pointOrders.topShares)
                    
                        order.shares -= shares
                        let updatedTop = pointOrders.updateTop(minusShares: shares)
                        
                        tradeEvent(buyer: order, seller: updatedTop, shares: shares)
                    }
                
                    if pointOrders.isEmpty {
                        cursor.remove()
                    } else {
                        break
                    }
                }
                
                if !cursor.isAtEnd {
                    sellMin = cursor.key.amount
                } else {
                    sellMin = UInt64.max
                }
            }
        }
        
        if order.shares > 0 {
            let point = BuyPricePoint(amount: order.price)
            buyBook.withCursor(onKey: point, body: { (cursor) in
                if !cursor.isAtEnd {
                    cursor.value.add(order: order)
                } else {
                    cursor.insert((point, OrdersList(withOrder: order)))
                }
            })
            
            if order.price > buyMax {
                buyMax = order.price
            }
            
            prices[order.id] = (order.price, order.side)
        }
    }
    
    func cancelBuyOrder(price: Money, id: OrderID) {
        let point = BuyPricePoint(amount: price)
        buyBook.withCursor(onKey: point) { (cursor) in
            if !cursor.isAtEnd {
                cursor.value.cancel(orderById: id)
                self.cancelEvent(orderId: id)
            }
        }
    }
    
    func cancelSellOrder(price: Money, id: OrderID) {
        let point = SellPricePoint(amount: price)
        sellBook.withCursor(onKey: point) { (cursor) in
            if !cursor.isAtEnd {
                cursor.value.cancel(orderById: id)
                self.cancelEvent(orderId: id)
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
