// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StylableSwiftUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "StylableSwiftUI",
            targets: ["StylableSwiftUI"]
        ),

    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.3")],
    targets: [
        .target(name: "StylableSwiftUI",
                dependencies: [.product(name: "Lottie", package: "lottie-ios")],
                path: "Sources"
               ),
        .testTarget(
            name: "StylableTests",
            dependencies: ["StylableSwiftUI"]
        )
    ]
)
