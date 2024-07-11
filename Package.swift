// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StylableSwiftUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "StylableSwiftUI", targets: ["StylableSwiftUI"]),
        .library(name: "StylableSwiftUIAnimated", targets: ["StylableSwiftUIAnimated"])
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.3")],
    targets: [
        .target(name: "StylableSwiftUI"),
        .target(name: "StylableSwiftUIAnimated",
                dependencies: [ 
                    "StylableSwiftUI",
                    .product(name: "Lottie", package: "lottie-ios") 
                ]),
        .testTarget(
            name: "StylableSwiftUITests",
            dependencies: ["StylableSwiftUI", "StylableSwiftUIAnimated"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
