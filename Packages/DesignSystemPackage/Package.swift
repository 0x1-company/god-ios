// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DesignSystemPackage",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "LabeledButton", targets: ["LabeledButton"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "LabeledButton"),
  ]
)
