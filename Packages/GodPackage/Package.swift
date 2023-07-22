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
    .library(name: "EditProfileFeature", targets: ["EditProfileFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
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
    .target(name: "EditProfileFeature", dependencies: [
      "ManageAccountFeature",
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
    .target(name: "ProfileFeature", dependencies: [
      "EditProfileFeature",
    ]),
    .target(name: "SchoolSettingFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShareScreenshotFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
