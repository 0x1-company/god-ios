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
    .library(name: "CashOutFeature", targets: ["CashOutFeature"]),
    .library(name: "ForceUpdateFeature", targets: ["ForceUpdateFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "GodModeFeature", targets: ["GodModeFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
    .library(name: "MaintenanceFeature", targets: ["MaintenanceFeature"]),
    .library(name: "ManageAccountFeature", targets: ["ManageAccountFeature"]),
    .library(name: "NavigationFeature", targets: ["NavigationFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "PlayAgainFeature", targets: ["PlayAgainFeature"]),
    .library(name: "PollFeature", targets: ["PollFeature"]),
    .library(name: "ProfileEditFeature", targets: ["ProfileEditFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileShareFeature", targets: ["ProfileShareFeature"]),
    .library(name: "ShareScreenshotFeature", targets: ["ShareScreenshotFeature"]),
    .library(name: "ShopFeature", targets: ["ShopFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../UIComponentPackage"),
    .package(path: "../DependencyPackage"),
    .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
  ],
  targets: [
    .target(name: "AboutFeature", dependencies: [
      "HowItWorksFeature",
      .product(name: "Constants", package: "DependencyPackage"),
    ]),
    .target(name: "ActivityFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AddFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AppFeature", dependencies: [
      "LaunchFeature",
      "OnboardFeature",
      "NavigationFeature",
      "ForceUpdateFeature",
      "MaintenanceFeature",
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "TcaHelpers", package: "DependencyPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "FirestoreClient", package: "DependencyPackage"),
      .product(name: "FirebaseCoreClient", package: "DependencyPackage"),
    ]),
    .target(name: "CashOutFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-ios"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ], resources: [.copy("coin.json")]),
    .target(name: "ForceUpdateFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodFeature", dependencies: [
      "PollFeature",
      "CashOutFeature",
      "PlayAgainFeature",
    ]),
    .target(name: "GodModeFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "HowItWorksFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "InboxFeature", dependencies: [
      "GodModeFeature",
      "ShareScreenshotFeature",
      .product(name: "ColorHex", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "LaunchFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "MaintenanceFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ManageAccountFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
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
      .product(name: "Lottie", package: "lottie-ios"),
      .product(name: "God", package: "DependencyPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "StringHelpers", package: "DependencyPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "ProfileClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "PhoneNumberClient", package: "DependencyPackage"),
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
    ], resources: [.copy("onboarding.json")]),
    .target(name: "PlayAgainFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "PollFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ProfileEditFeature", dependencies: [
      "ManageAccountFeature",
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
    ]),
    .target(name: "ProfileFeature", dependencies: [
      "ShopFeature",
      "ProfileEditFeature",
      "ProfileShareFeature",
    ]),
    .target(name: "ProfileShareFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShareScreenshotFeature", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShopFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
