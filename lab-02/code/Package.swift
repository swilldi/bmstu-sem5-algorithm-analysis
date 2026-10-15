// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lab02",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "lab02",
            dependencies: ["MatrixMultiply"],
        ),
        .target(name: "MatrixMultiply"),
        .testTarget(
            name: "MatrixMultiplyTests",
            dependencies: ["MatrixMultiply"],
        ),
    ],
)
