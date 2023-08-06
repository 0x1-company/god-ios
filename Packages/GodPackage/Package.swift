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
    .library(name: "ActivityFeature", targets: ["ActivityFeature"]),
    .library(name: "AddFeature", targets: ["AddFeature"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "Constants", targets: ["Constants"]),
    .library(name: "ForceUpdateFeature", targets: ["ForceUpdateFeature"]),
    .library(name: "GenderSettingFeature", targets: ["GenderSettingFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "GodModeFeature", targets: ["GodModeFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "ManageAccountFeature", targets: ["ManageAccountFeature"]),
    .library(name: "NavigationFeature", targets: ["NavigationFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "ProfileEditFeature", targets: ["ProfileEditFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileShareFeature", targets: ["ProfileShareFeature"]),
    .library(name: "SchoolSettingFeature", targets: ["SchoolSettingFeature"]),
    .library(name: "ShareScreenshotFeature", targets: ["ShareScreenshotFeature"]),
    .library(name: "ShopFeature", targets: ["ShopFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../UIComponentPackage"),
    .package(path: "../FirebasePackage"),
    .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.2.0"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
  ],
  targets: [
    .target(name: "AboutFeature", dependencies: [
      "Constants",
      "HowItWorksFeature",
    ]),
    .target(name: "ActivityFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AddFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AppFeature", dependencies: [
      "OnboardFeature",
      "NavigationFeature",
      "ForceUpdateFeature",
    ]),
    .target(name: "Constants"),
    .target(name: "ForceUpdateFeature", dependencies: [
      "Constants",
      .product(name: "FullScreenActionView", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GenderSettingFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodFeature", dependencies: [
      .product(name: "ColorHex", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodModeFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "HowItWorksFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "InboxFeature", dependencies: [
      .product(name: "ColorHex", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ManageAccountFeature", dependencies: [
      .product(name: "ColorHex", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "NavigationFeature", dependencies: [
      "AboutFeature",
      "ActivityFeature",
      "AddFeature",
      "GodFeature",
      "InboxFeature",
      "ProfileFeature",
    ]),
    .target(name: "OnboardFeature", dependencies: [
      "HowItWorksFeature",
      "GenderSettingFeature",
      .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
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
    .target(name: "ShopFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
