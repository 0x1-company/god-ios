// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UIComponentPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "AnimationDisableTransaction", targets: ["AnimationDisableTransaction"]),
    .library(name: "BackgroundClearSheet", targets: ["BackgroundClearSheet"]),
    .library(name: "ButtonStyles", targets: ["ButtonStyles"]),
    .library(name: "ColorHex", targets: ["ColorHex"]),
    .library(name: "Colors", targets: ["Colors"]),
    .library(name: "GodActionSheet", targets: ["GodActionSheet"]),
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
    .library(name: "NameImage", targets: ["NameImage"]),
    .library(name: "ProfileImage", targets: ["ProfileImage"]),
    .library(name: "RoundedCorner", targets: ["RoundedCorner"]),
    .library(name: "SearchField", targets: ["SearchField"]),
  ],
  dependencies: [
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", from: "2.1.1"),
  ],
  targets: [
    .target(name: "AnimationDisableTransaction"),
    .target(name: "BackgroundClearSheet"),
    .target(name: "ButtonStyles"),
    .target(name: "ColorHex"),
    .target(name: "Colors", dependencies: ["ColorHex"]),
    .target(name: "GodActionSheet", dependencies: ["ButtonStyles"]),
    .target(name: "LabeledButton"),
    .target(name: "NameImage", dependencies: ["Colors"]),
    .target(name: "ProfileImage", dependencies: [
      "NameImage",
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
    ]),
    .target(name: "RoundedCorner"),
    .target(name: "SearchField"),
  ]
)
