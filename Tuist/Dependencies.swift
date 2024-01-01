import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            // Composable Arch
            .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "0.54.0")),
            .remote(url: "https://github.com/pointfreeco/swiftui-navigation", requirement: .upToNextMajor(from: "0.4.5")),
            .remote(url: "https://github.com/Miiha/composable-user-notifications", requirement: .upToNextMajor(from: "0.3.0")),
            
            // UI
            .remote(url: "https://github.com/yeahdongcn/UIColor-Hex-Swift", requirement: .upToNextMajor(from: "5.0.0")),
            .remote(url: "https://github.com/SFSafeSymbols/SFSafeSymbols", requirement: .upToNextMajor(from: "4.1.1"))
        ],
        baseSettings: .settings(
            configurations: [
                .debug(name: "Debug"),
                .release(name: "TestFlight"),
                .release(name: "Release"),
            ]
        )
    ),
    platforms: [.iOS]
)
