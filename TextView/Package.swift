// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextView",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TextView",
            targets: ["TextView"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TextView",
            dependencies: []),
        .testTarget(
            name: "TextViewTests",
            dependencies: ["TextView"])
    ]
)
