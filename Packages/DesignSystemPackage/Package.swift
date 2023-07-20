// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DesignSystemPackage",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "ButtonStyles", targets: ["ButtonStyles"]),
    .library(name: "Colors", targets: ["Colors"]),
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "ButtonStyles"),
    .target(name: "Colors"),
    .target(name: "LabeledButton"),
  ]
)
