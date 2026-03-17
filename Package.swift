// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tracker",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Tracker",
            path: "Sources/Tracker",
            resources: [.copy("Resources")]
        )
    ]
)
