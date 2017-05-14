//
//  PricePoint.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 4/16/17.
//
//

import Foundation


public struct BuyPricePoint: Comparable, CustomStringConvertible {
    
    public let amount: Money

    public init(amount: Money) {
        self.amount = amount
    }
    
    public static func ==(lhs: BuyPricePoint, rhs: BuyPricePoint) -> Bool {
        return lhs.amount == rhs.amount
    }
    
    public static func <(lhs: BuyPricePoint, rhs: BuyPricePoint) -> Bool {
        return lhs.amount < rhs.amount
    }

    public var description: String {
        return "BuyPricePoint(\(amount))"
    }
}


public struct SellPricePoint: Comparable, CustomStringConvertible {
    
    public let amount: Money
    
    public init(amount: Money) {
        self.amount = amount
    }
    
    public static func ==(lhs: SellPricePoint, rhs: SellPricePoint) -> Bool {
        return lhs.amount == rhs.amount
    }
    
    public static func <(lhs: SellPricePoint, rhs: SellPricePoint) -> Bool {
        return lhs.amount > rhs.amount
    }
    
    public var description: String {
        return "SellPricePoint(\(amount))"
    }
}
