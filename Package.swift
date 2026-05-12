// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let destinationsDependencies: [PackageDescription.Target.Dependency] = [
    .product(name: "SwiftDiagnostics", package: "swift-syntax"),
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
]

let package = Package(
    name: "Destinations",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15)
     ],
    products: [
        .library(
            name: "Destinations",
            targets: ["Destinations"])
    ],
    dependencies: [
            .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.0"..<"605.0.0"),
        ],
    targets: [
        .target(
            name: "Destinations",
            dependencies: ["AutomaticEnumCaseIterableMacro"],
            path: "Sources",
            exclude: ["Macros"]
        ),
        .macro(
            name: "AutomaticEnumCaseIterableMacro",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ] + destinationsDependencies,
            path: "Sources/Macros",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
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
