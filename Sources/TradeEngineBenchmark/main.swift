import Foundation
import TradeEngineLib

print("TradeEngine benchmark app")

let path = "/Users/eugenf/Documents/Projects/swift/SwiftTradeEngine/Sources/TradeEngineBenchmark/OrdersFeed.json"


let executor = ScoresExecutor()
executor.runTest(factory: BTreeBasedOrderBookFactory(), path: path)







