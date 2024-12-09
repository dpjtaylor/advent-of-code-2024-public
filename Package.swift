// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "advent-of-code-2024",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "AdventOfCode2024",
            targets: ["AdventOfCode2024"]),
    ],
    targets: [
        .target(
            name: "AdventOfCode2024")
    ]
)
