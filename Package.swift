// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeatherWiseAI",
    platforms: [
        .iOS(.v16) // WeatherKit requires iOS 16+
    ],
    products: [
        .library(
            name: "WeatherWiseAI",
            targets: ["WeatherWiseAI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.18.0")
        )
    ],
    targets: [
        .target(
            name: "WeatherWiseAI",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "WeatherWiseAITests",
            dependencies: ["WeatherWiseAI"]
        ),
    ]
)
