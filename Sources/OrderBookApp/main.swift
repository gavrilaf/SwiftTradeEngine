import Foundation
import OrderBookLib

print("SwiftOrderBook score app")

let path = "/Users/eugenf/Documents/Projects/swift/SwiftOrderBook/Sources/OrderBookApp/OrdersFeed.json"


let executor = ScoresExecutor()
executor.runTest(factory: BTreeBasedOrderBookFactory(), path: path)







