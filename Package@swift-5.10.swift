// swift-tools-version: 5.10

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
    swiftLanguageVersions: [.version("5.10")]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency"))
    target.swiftSettings = settings
}
