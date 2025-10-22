// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WeWillDoItLive",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "WeWillDoItLive", targets: ["WeWillDoItLive"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WeWillDoItLive",
            path: ".",
            swiftSettings: [
                .define("ENABLE_PREVIEWS", .when(configuration: .debug))
            ]
        )
    ]
)
