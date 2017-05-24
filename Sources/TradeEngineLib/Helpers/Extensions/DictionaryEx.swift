//
//  DictionaryEx.swift
//  SwiftTradeEngine
//
//  Created by Eugen Fedchenko on 5/24/17.
//
//

import Foundation

func += <K, V> (left: inout Dictionary<K, V>, right: (K, V)) {
    left[right.0] = right.1
}

func + <K, V> (left: Dictionary<K, V>, right: (K, V)) -> Dictionary<K, V> {
    var res = left
    res[right.0] = right.1
    return res
}

