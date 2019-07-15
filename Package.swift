// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "XCTAssertCrash",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XCTAssertCrash",
            targets: ["XCTAssertCrash"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: {
    #if canImport(Darwin) && !os(tvOS) && !os(watchOS)
        return [
            .target(name: "CMachExceptionHandler"),
            .target(name: "XCTAssertCrash",
                    dependencies: ["CMachExceptionHandler"]),
            .testTarget(
                name: "XCTAssertCrashTests",
                dependencies: ["XCTAssertCrash"]),
        ]
    #else
        return [
            .target(name: "XCTAssertCrash"),
                .testTarget(
                    name: "XCTAssertCrashTests",
                    dependencies: ["XCTAssertCrash"]),
        ]
    #endif

    }() + [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    ],
    cLanguageStandard: .gnu99
)

