// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DependencyPackage",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "AnalyticsClient", targets: ["AnalyticsClient"]),
    .library(name: "Constants", targets: ["Constants"]),
    .library(name: "FirebaseAuthClient", targets: ["FirebaseAuthClient"]),
    .library(name: "FirebaseCoreClient", targets: ["FirebaseCoreClient"]),
    .library(name: "FirestoreClient", targets: ["FirestoreClient"]),
    .library(name: "PhoneNumberClient", targets: ["PhoneNumberClient"]),
    .library(name: "ProfileClient", targets: ["ProfileClient"]),
    .library(name: "ServerConfig", targets: ["ServerConfig"]),
    .library(name: "ServerConfigClient", targets: ["ServerConfigClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.8.0"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.6.0"),
  ],
  targets: [
    .target(name: "AnalyticsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
    ]),
    .target(name: "Constants"),
    .target(name: "FirebaseAuthClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
    ]),
    .target(name: "FirebaseCoreClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
    ]),
    .target(name: "FirestoreClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
      .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
    ]),
    .target(name: "PhoneNumberClient", dependencies: [
      .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ProfileClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
      .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
    ]),
    .target(name: "ServerConfig"),
    .target(name: "ServerConfigClient", dependencies: [
      "ServerConfig",
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
  ]
)
