// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftOrderBook",
    targets: [
        Target(name: "OrderBookLib"),
        Target(name: "OrderBookApp", dependencies: ["OrderBookLib"])
    ]
)
