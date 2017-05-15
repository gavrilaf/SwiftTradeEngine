//
//  FeedParser.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/15/17.
//
//

import Foundation

struct FeedOrder {
    
    enum Side {
        case Ask
        case Bid
    }
    
    let symbol: String
    let trader: String
    let side: Side
    let price: UInt64
    let shares: UInt64
    
    init(_ symbol: String, _ trader: String, _ side: Side, _ price: UInt64, _ shares: UInt64) {
        self.symbol = symbol
        self.trader = trader
        self.side = side
        self.price = price
        self.shares = shares
    }
}


struct FeedParser {

    static func openFeed(path: String) -> [FeedOrder] {
        let file = URL(fileURLWithPath: path)
        
        guard let data = try? Data(contentsOf: file) else { return [] }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
        guard let orders = root?["orders"] as? [[Any]] else { return [] }
        
        let feed = orders.flatMap { (any) -> FeedOrder? in
            guard any.count == 5 else { return nil }
            
            guard let sym = any[0] as? String,
                let trader = any[1] as? String,
                let side = any[2] as? String,
                let shares = any[3] as? UInt64,
                let price = any[4] as? UInt64 else { return nil }
            
            switch side {
            case "Ask":
                return FeedOrder(sym, trader, .Ask, shares, price)
            case "Bid":
                return FeedOrder(sym, trader, .Bid, shares, price)
            default:
                return nil
            }
        }
        
        return feed
    }
}
