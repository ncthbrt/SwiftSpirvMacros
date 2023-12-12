// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SpirvMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpirvMacros",
            targets: ["SpirvMacros"]
        ),
        .executable(
            name: "SpirvMacrosClient",
            targets: ["SpirvMacrosClient"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/ncthbrt/SPIRV-Headers-Swift.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(name: "SpirvMacrosShared", dependencies: [
            .product(name: "SPIRV-Headers-Swift", package: "SPIRV-Headers-Swift")
        ]),
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "SpirvMacrosMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SPIRV-Headers-Swift", package: "SPIRV-Headers-Swift"),
                .target(name: "SpirvMacrosShared")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "SpirvMacros", dependencies: [
            .target(name: "SpirvMacrosShared"),
            .target(name: "SpirvMacrosMacros"),
            .product(name: "SPIRV-Headers-Swift", package: "SPIRV-Headers-Swift")
        ]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "SpirvMacrosClient", dependencies: [
            .target(name: "SpirvMacros"),
            .product(name: "SPIRV-Headers-Swift", package: "SPIRV-Headers-Swift")
            ]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SpirvMacrosTests",
            dependencies: [
                "SpirvMacrosMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    cLanguageStandard: .c18,
    cxxLanguageStandard: .cxx14
)
