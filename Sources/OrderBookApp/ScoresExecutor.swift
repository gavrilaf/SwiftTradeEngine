//
//  ScoresExecutor.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/15/17.
//
//

import Foundation
import OrderBookLib

struct ScoresExecutor {
    
    let batchSize: Int = 10
    let replayCount: Int = 200
    
    
    func runTest(factory: OrderBookFactory, path: String) {
        let book = factory.createOrderBook()
        let feed = FeedParser.openFeed(path: path)
        
        var latencies = Array<UInt64>()
        
        let totalStart = DispatchTime.now()
        
        for _ in 0..<replayCount {
            book.reset()
            
            stride(from: batchSize, to: feed.count, by: batchSize).forEach { (i) in
                let start = DispatchTime.now()
                runBatch(book: book, feed: feed, begin: i - batchSize, end: i)
                let end = DispatchTime.now()
                latencies.append(end.uptimeNanoseconds - start.uptimeNanoseconds)
            }
        }
        
        let totalEnd = DispatchTime.now()
        let nanoTime = totalEnd.uptimeNanoseconds - totalStart.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        print("Total time: \(timeInterval.sf2)")
        
        calcScores(latencies: latencies)
    }
    

    private func runBatch(book: OrderBookProtocol, feed: [FeedOrder], begin: Int, end: Int) {
        for i in begin..<end {
            let fo = feed[i]
            
            if fo.price == 0 {
                book.cancel(orderById: OrderID(fo.shares))
            } else {
                let side = fo.side == .Ask ? OrderSide.sell : OrderSide.buy
                let order = Order(id: OrderID(i),
                                  type: .limit,
                                  side: side,
                                  symbol: OBString(fo.symbol),
                                  trader: OBString(fo.trader),
                                  price: Money(fo.price),
                                  shares: Quantity(fo.shares))
                
                book.add(order: order)
            }
        }
    }
    
    private func calcScores(latencies: [UInt64]) {
        let total = latencies.reduce(0) { (res, t) -> UInt64 in
            return res + t
        }
        
        print("Total latencies: \((Double(total) / 1_000_000_000).sf2)")
        
        let mean = Double(total) / Double(latencies.count)
        let sqtotal = latencies.reduce(0.0) { (res, t) -> Double in
            var centered = Double(t) - mean
            return res + (centered * centered) / Double(latencies.count)
        }
        
        let sd = sqrt(sqtotal)
        let score = 0.5 * (mean + sd)
        
        print("mean(latency) = \(mean.sf2), sd(latency) = \(sd.sf2)")
        print("You scored \(score.sf2). Try to minimize this.")
    }
}
