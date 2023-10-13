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
    .library(name: "GodActionSheet", targets: ["GodActionSheet"]),
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
    .library(name: "NameImage", targets: ["NameImage"]),
    .library(name: "ProfileImage", targets: ["ProfileImage"]),
    .library(name: "RoundedCorner", targets: ["RoundedCorner"]),
    .library(name: "SearchField", targets: ["SearchField"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
  ],
  dependencies: [
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", from: "2.1.1"),
  ],
  targets: [
    .target(name: "AnimationDisableTransaction"),
    .target(name: "BackgroundClearSheet"),
    .target(name: "GodActionSheet", dependencies: ["Styleguide"]),
    .target(name: "LabeledButton"),
    .target(name: "NameImage", dependencies: ["Styleguide"]),
    .target(name: "ProfileImage", dependencies: [
      "NameImage",
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
    ]),
    .target(name: "RoundedCorner"),
    .target(name: "SearchField"),
    .target(name: "Styleguide", resources: [
      .process("Fonts")
    ]),
  ]
)
