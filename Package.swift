// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftOrderBook",
    targets: [
        Target(name: "OrderBookLib"),
        Target(name: "OrderBookApp", dependencies: ["OrderBookLib"])
    ],
    dependencies: [
        //.Package(url: "https://github.com/gavrilaf/Reviro.git", "0.0.1"),
        .Package(url: "https://github.com/lorentey/BTree", "4.0.2"),
    ]
)
