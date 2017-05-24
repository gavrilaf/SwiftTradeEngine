//
//  DoubleEx.swift
//  SwiftTradeEngine
//
//  Created by Eugen Fedchenko on 5/15/17.
//
//

import Foundation

struct DoubleGlobals {
    
    static var sf2Formatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
}

public extension Double {
    public var sf2:String {
        get {
            return DoubleGlobals.sf2Formatter.string(from: NSNumber(floatLiteral: self))!
        }
    }
}
