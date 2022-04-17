// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyLibPlist",
    products: [
        .library(
            name: "SwiftyLibPlist",
            targets: ["SwiftyLibPlist"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftyLibPlist",
            dependencies: ["CPlist"]),
        .testTarget(
            name: "SwiftyLibPlistTests",
            dependencies: ["SwiftyLibPlist"]),
        .systemLibrary(
            name: "CPlist",
            pkgConfig: "libplist-2.0",
            providers: [.brew(["libplist"])]
        )
    ]
)
