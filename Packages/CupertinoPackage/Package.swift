// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CupertinoPackage",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "Build", targets: ["Build"]),
    .library(name: "Constants", targets: ["Constants"]),
    .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
    .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
    .library(name: "WidgetClient", targets: ["WidgetClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.5.1"),
  ],
  targets: [
    .target(name: "Build", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "Constants", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "UIApplicationClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "UserDefaultsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "WidgetClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
  ]
)
