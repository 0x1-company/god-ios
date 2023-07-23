// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GodPackage",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "AboutFeature", targets: ["AboutFeature"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "ManageAccountFeature", targets: ["ManageAccountFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "ProfileEditFeature", targets: ["ProfileEditFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileShareFeature", targets: ["ProfileShareFeature"]),
    .library(name: "SchoolSettingFeature", targets: ["SchoolSettingFeature"]),
    .library(name: "ShareScreenshotFeature", targets: ["ShareScreenshotFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../DesignSystemPackage"),
    .package(path: "../FirebasePackage"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.54.0"),
  ],
  targets: [
    .target(name: "AboutFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AppFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodFeature", dependencies: [
      .product(name: "ColorHex", package: "DesignSystemPackage"),
      .product(name: "LabeledButton", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "HowItWorksFeature", dependencies: [
      .product(name: "ColorHex", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "InboxFeature", dependencies: [
      .product(name: "ColorHex", package: "DesignSystemPackage"),
      .product(name: "LabeledButton", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ManageAccountFeature", dependencies: [
      .product(name: "ColorHex", package: "DesignSystemPackage"),
      .product(name: "ButtonStyles", package: "DesignSystemPackage"),
      .product(name: "LabeledButton", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "OnboardFeature", dependencies: [
      .product(name: "ColorHex", package: "DesignSystemPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ProfileEditFeature", dependencies: [
      "ManageAccountFeature",
    ]),
    .target(name: "ProfileFeature", dependencies: [
      "ProfileEditFeature",
    ]),
    .target(name: "ProfileShareFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "SchoolSettingFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShareScreenshotFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
