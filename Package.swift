// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftTradeEngine",
    targets: [
        Target(name: "TradeEngineLib"),
        Target(name: "TradeEngineBenchmark", dependencies: ["TradeEngineLib"]),
        Target(name: "TradeEngineApp", dependencies: ["TradeEngineLib"])
    ],
    dependencies: [
        //.Package(url: "https://github.com/lorentey/BTree", "4.0.2"),
    ]
)
