// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Destinations",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
     ],
    products: [
        .library(
            name: "Destinations",
            targets: ["Destinations"])
    ],
    targets: [
        .target(
            name: "Destinations", path: "Sources"),
        .testTarget(
            name: "DestinationsUIKitTests",
            dependencies: ["Destinations"],
            path: "Tests/UIKit"),
        .testTarget(
            name: "DestinationsSwiftUITests",
            dependencies: ["Destinations"],
            path: "Tests/SwiftUI")

    ],
    swiftLanguageModes: [.v6]
)
