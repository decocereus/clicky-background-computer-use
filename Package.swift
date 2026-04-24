// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BackgroundComputerUse",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BackgroundComputerUse", targets: ["BackgroundComputerUse"]),
    ],
    targets: [
        .executableTarget(
            name: "BackgroundComputerUse",
            path: "Sources/BackgroundComputerUse"
        ),
        .testTarget(
            name: "BackgroundComputerUseTests",
            dependencies: ["BackgroundComputerUse"],
            path: "Tests/BackgroundComputerUseTests"
        ),
    ]
)
