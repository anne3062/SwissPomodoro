// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwissPomodoro",
  platforms: [
    .macOS(.v14)
  ],
  targets: [
    .executableTarget(
      name: "SwissPomodoro",
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .testTarget(
      name: "SwissPomodoroTests",
      dependencies: ["SwissPomodoro"]
    ),
  ]
)
