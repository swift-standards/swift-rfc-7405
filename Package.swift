// swift-tools-version: 6.2

import PackageDescription

// RFC 7405: Case-Sensitive String Support in ABNF
//
// Extends RFC 5234 ABNF to add case-sensitive string literal support.
// RFC 7405 adds the %s"..." syntax for case-sensitive matching while
// retaining the default case-insensitive %i"..." syntax from RFC 5234.
//
// This is a pure Swift implementation with no Foundation dependencies,
// suitable for Swift Embedded and constrained environments.

let package = Package(
    name: "swift-rfc-7405",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "RFC 7405",
            targets: ["RFC 7405"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-ascii.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-rfc-5234.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "RFC 7405",
            dependencies: [
                .product(name: "RFC 5234", package: "swift-rfc-5234"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "ASCII", package: "swift-ascii")
            ]
        ),
        .testTarget(
            name: "RFC 7405".tests,
            dependencies: [
                "RFC 7405",
                .product(name: "Test Primitives", package: "swift-test-primitives")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
