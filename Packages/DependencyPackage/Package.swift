// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DependencyPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "AnalyticsClient", targets: ["AnalyticsClient"]),
    .library(name: "ApolloClientHelpers", targets: ["ApolloClientHelpers"]),
    .library(name: "AsyncValue", targets: ["AsyncValue"]),
    .library(name: "Constants", targets: ["Constants"]),
    .library(name: "FirebaseAuthClient", targets: ["FirebaseAuthClient"]),
    .library(name: "FirebaseCoreClient", targets: ["FirebaseCoreClient"]),
    .library(name: "FirebaseMessagingClient", targets: ["FirebaseMessagingClient"]),
    .library(name: "FirebaseStorageClient", targets: ["FirebaseStorageClient"]),
    .library(name: "FirestoreClient", targets: ["FirestoreClient"]),
    .library(name: "God", targets: ["God"]),
    .library(name: "GodClient", targets: ["GodClient"]),
    .library(name: "GodTestMock", targets: ["GodTestMock"]),
    .library(name: "PhoneNumberDependencies", targets: ["PhoneNumberDependencies"]),
    .library(name: "StoreKitHelpers", targets: ["StoreKitHelpers"]),
    .library(name: "StringHelpers", targets: ["StringHelpers"]),
    .library(name: "TcaHelpers", targets: ["TcaHelpers"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.15.0"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.2"),
    .package(url: "https://github.com/apollographql/apollo-ios", from: "1.5.0"),
  ],
  targets: [
    .target(name: "AnalyticsClient", dependencies: [
      .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ApolloClientHelpers", dependencies: [
      .product(name: "Apollo", package: "apollo-ios"),
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
    ]),
    .target(name: "AsyncValue"),
    .target(name: "Constants"),
    .target(name: "FirebaseAuthClient", dependencies: [
      .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FirebaseCoreClient", dependencies: [
      .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FirebaseMessagingClient", dependencies: [
      .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FirebaseStorageClient", dependencies: [
      .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FirestoreClient", dependencies: [
      .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
      .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "God", dependencies: [
      .product(name: "ApolloAPI", package: "apollo-ios"),
    ]),
    .target(name: "GodClient", dependencies: [
      "God",
      .product(name: "Apollo", package: "apollo-ios"),
      .product(name: "ApolloAPI", package: "apollo-ios"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodTestMock", dependencies: [
      "God",
      .product(name: "ApolloTestSupport", package: "apollo-ios"),
    ]),
    .target(name: "PhoneNumberDependencies", dependencies: [
      .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "StoreKitHelpers", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "StringHelpers"),
    .testTarget(name: "StringHelpersTests", dependencies: [
      "StringHelpers",
    ]),
    .target(name: "TcaHelpers", dependencies: [
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
