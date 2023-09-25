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
    .library(name: "ButtonStyles", targets: ["ButtonStyles"]),
    .library(name: "ColorHex", targets: ["ColorHex"]),
    .library(name: "Colors", targets: ["Colors"]),
    .library(name: "GodActionSheet", targets: ["GodActionSheet"]),
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
    .library(name: "NameImage", targets: ["NameImage"]),
    .library(name: "RoundedCorner", targets: ["RoundedCorner"]),
    .library(name: "SearchField", targets: ["SearchField"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "AnimationDisableTransaction"),
    .target(name: "ButtonStyles"),
    .target(name: "ColorHex"),
    .target(name: "Colors", dependencies: ["ColorHex"]),
    .target(name: "GodActionSheet", dependencies: ["ButtonStyles"]),
    .target(name: "LabeledButton"),
    .target(name: "NameImage", dependencies: ["Colors"]),
    .target(name: "RoundedCorner"),
    .target(name: "SearchField"),
  ]
)
