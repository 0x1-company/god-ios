// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UIComponentPackage",
  platforms: [
    .iOS(.v16),
  ],
  products: [
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
    .target(name: "ButtonStyles"),
    .target(name: "ColorHex"),
    .target(name: "Colors", dependencies: ["ColorHex"]),
    .target(name: "FullScreenActionView"),
    .target(name: "FullScreenCoverView"),
    .target(name: "LabeledButton"),
    .target(name: "RoundedCorner"),
  ]
)
