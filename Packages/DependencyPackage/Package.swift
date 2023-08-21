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
    .library(name: "AsyncApollo", targets: ["AsyncApollo"]),
    .library(name: "Constants", targets: ["Constants"]),
    .library(name: "FirebaseAuthClient", targets: ["FirebaseAuthClient"]),
    .library(name: "FirebaseCoreClient", targets: ["FirebaseCoreClient"]),
    .library(name: "FirestoreClient", targets: ["FirestoreClient"]),
    .library(name: "God", targets: ["God"]),
    .library(name: "PhoneNumberClient", targets: ["PhoneNumberClient"]),
    .library(name: "ProfileClient", targets: ["ProfileClient"]),
    .library(name: "ServerConfig", targets: ["ServerConfig"]),
    .library(name: "ServerConfigClient", targets: ["ServerConfigClient"]),
    .library(name: "UserClient", targets: ["UserClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.8.0"),
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.6.0"),
    .package(url: "https://github.com/apollographql/apollo-ios", from: "1.4.0"),
  ],
  targets: [
    .target(name: "AnalyticsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
      .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
    ]),
    .target(name: "AsyncApollo", dependencies: [
      .product(name: "Apollo", package: "apollo-ios"),
    ]),
    .target(name: "Constants"),
    .target(name: "FirebaseAuthClient", dependencies: [
      .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
      .product(name: "Dependencies", package: "swift-dependencies"),
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
    .target(name: "God", dependencies: [
      .product(name: "ApolloAPI", package: "apollo-ios"),
    ]),
    .target(name: "GodApolloClient", dependencies: [
      .product(name: "Apollo", package: "apollo-ios"),
    ]),
    .target(name: "PhoneNumberClient", dependencies: [
      .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
      .product(name: "Dependencies", package: "swift-dependencies"),
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
    .target(name: "UserClient", dependencies: [
      "God",
      "AsyncApollo",
      "GodApolloClient",
    ]),
  ]
)
