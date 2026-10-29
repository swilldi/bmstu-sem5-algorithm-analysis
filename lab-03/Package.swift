// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lab03",
    targets: [
        .executableTarget(name: "lab03", dependencies: ["Algorithms"]),
        .target(name: "Algorithms"),
        .testTarget(name: "TestsLab03", dependencies: ["Algorithms"])
    ]
)
