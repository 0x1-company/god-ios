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
    .library(name: "FullScreenActionView", targets: ["FullScreenActionView"]),
    .library(name: "FullScreenCoverView", targets: ["FullScreenCoverView"]),
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
    .library(name: "RoundedCorner", targets: ["RoundedCorner"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "AnimationDisableTransaction"),
    .target(name: "ButtonStyles"),
    .target(name: "ColorHex"),
    .target(name: "Colors", dependencies: ["ColorHex"]),
    .target(name: "FullScreenActionView"),
    .target(name: "FullScreenCoverView"),
    .target(name: "LabeledButton"),
    .target(name: "RoundedCorner"),
  ]
)
