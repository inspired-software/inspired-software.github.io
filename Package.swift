// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "InspiredSoftware",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/loopwerk/Saga.git", exact: "3.6.0"),
        .package(url: "https://github.com/loopwerk/SagaSwimRenderer.git", exact: "1.4.1"),
        // Used directly too: Saga and its renderer don't re-export these.
        .package(url: "https://github.com/robb/Swim.git", from: "0.4.0"),
        .package(url: "https://github.com/loopwerk/SagaPathKit.git", from: "1.6.1"),
    ],
    targets: [
        .executableTarget(
            name: "InspiredSoftware",
            dependencies: [
                .product(name: "Saga", package: "Saga"),
                .product(name: "SagaSwimRenderer", package: "SagaSwimRenderer"),
                .product(name: "HTML", package: "Swim"),
                .product(name: "SagaPathKit", package: "SagaPathKit"),
            ]
        ),
    ]
)
