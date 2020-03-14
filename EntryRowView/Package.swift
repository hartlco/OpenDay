// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EntryRowView",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "EntryRowView",
            targets: ["EntryRowView"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    .package(path: "../Models"),
    .package(path: "../OpenKit")
    ],
    targets: [
        .target(
            name: "EntryRowView",
            dependencies: ["Models", "OpenKit"]),
        .testTarget(
            name: "EntryRowViewTests",
            dependencies: ["EntryRowView"])
    ]
)
