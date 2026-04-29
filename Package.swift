// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BackgroundComputerUse",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "BackgroundComputerUseKit", targets: ["BackgroundComputerUse"]),
        .executable(name: "BackgroundComputerUse", targets: ["BackgroundComputerUseServer"]),
        .executable(name: "BackgroundComputerUseMCP", targets: ["BackgroundComputerUseMCP"]),
    ],
    targets: [
        .target(
            name: "BackgroundComputerUse",
            path: "Sources/BackgroundComputerUse"
        ),
        .executableTarget(
            name: "BackgroundComputerUseServer",
            dependencies: ["BackgroundComputerUse"],
            path: "Sources/BackgroundComputerUseServer"
        ),
        .executableTarget(
            name: "BackgroundComputerUseMCP",
            dependencies: ["BackgroundComputerUse"],
            path: "Sources/BackgroundComputerUseMCP"
        ),
        .testTarget(
            name: "BackgroundComputerUseTests",
            dependencies: ["BackgroundComputerUse"],
            path: "Tests/BackgroundComputerUseTests"
        ),
    ]
)
