// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Messaging",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Messaging",
            targets: ["Messaging"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: .init(1, 18, 0)),
        .package(url: "https://github.com/ChrisLawther/SwiftZeroMQ", .upToNextMajor(from: Version(0, 0, 7)))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Messaging",
            dependencies: ["SwiftProtobuf", "SwiftZeroMQ"]),
        .testTarget(
            name: "MessagingTests",
            dependencies: ["Messaging", "SwiftZeroMQ"]),
    ]
)
