//
//  Formatter.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/15/17.
//
//

import Foundation

extension Double {
    var sf2:String {
        get {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.hasThousandSeparators = false
            
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter.string(from: NSNumber(floatLiteral: self))!
        }
    }
}
