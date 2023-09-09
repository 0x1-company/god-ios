// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DependenciesGraph",
  platforms: [.macOS(.v10_13)],
  dependencies: [
    .package(url: "https://github.com/tomokisun/swift-dependencies-graph", branch: "include-product"),
  ],
  targets: [.target(name: "DependenciesGraph", path: "")]
)
