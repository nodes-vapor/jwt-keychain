// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "jwt-keychain ",
    platforms: [
         .macOS(.v10_15)
      ],
    products: [
        .library(name: "JWTKeychain", targets: ["JWTKeychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "JWTKeychain", 
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(name: "JWTKeychainTests", dependencies: [
            .target(name:"JWTKeychain"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
