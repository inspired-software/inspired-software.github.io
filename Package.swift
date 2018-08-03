// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "inspired-software-site",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "inspired-software-site",
            targets: ["InspiredSoftware"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "InspiredSoftware",
            dependencies: [
                .product(name: "Publish", package: "publish")
            ]
        )
    ]
)
