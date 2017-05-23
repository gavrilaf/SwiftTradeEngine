// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftTradeEngine",
    targets: [
        Target(name: "OrderBookLib"),
        Target(name: "OrderBookBenchmark", dependencies: ["OrderBookLib"]),
        Target(name: "TradeEngineApp", dependencies: ["OrderBookLib"])
    ],
    dependencies: [
        //.Package(url: "https://github.com/lorentey/BTree", "4.0.2"),
    ]
)
