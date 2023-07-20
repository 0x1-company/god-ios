// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PinePackage",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "EditProfileFeature", targets: ["EditProfileFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../DesignSystemPackage"),
    .package(path: "../FirebasePackage"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.54.0"),
  ],
  targets: [
    .target(name: "AppFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "EditProfileFeature", dependencies: [
      .product(name: "LabeledButton", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
