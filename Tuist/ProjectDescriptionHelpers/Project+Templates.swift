import ProjectDescription

extension Project {
    public static func app(
        name: String,
        platform: Platform,
        options: Project.Options = .options(),
        packages: [Package] = []
    ) -> Project {
        let appTarget = makeAppTarget(
            name: name,
            platform: platform,
            dependencies: [
                // Composable Arch
                .external(name: "ComposableArchitecture"),
                .external(name: "SwiftUINavigation"),
                .external(name: "ComposableUserNotifications"),
                
                // UI
                .external(name: "UIColorHexSwift"),
                .external(name: "SFSafeSymbols")
            ]
            + // These have issues being installed the tuist preferred way so using native SPM
            [
                TargetDependency.package(product: "UITextView+Placeholder"),
            ]
        )

        let appTestTarget = makeAppTestTarget(
            name: name,
            platform: platform
        )

        let targets = [appTarget, appTestTarget]

        return Project(
            name: name,
            organizationName: "adamtecle",
            options: options,
            packages: packages,
            settings: Settings.settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: .relativeToRoot("Modules/TomatoTimer/Configs/Project.xcconfig")),
                    .release(name: "TestFlight", xcconfig: .relativeToRoot("Modules/TomatoTimer/Configs/Project.xcconfig")),
                    .release(name: "Release", xcconfig: .relativeToRoot("Modules/TomatoTimer/Configs/Project.xcconfig")),
                ],
                defaultSettings: .none
            ),
            targets: targets,
            schemes: [
                makeDebugScheme(),
                makeTestFlightScheme(),
                makeReleaseScheme(),
            ],
            additionalFiles: [.glob(pattern: .relativeToRoot("Modules/TomatoTimer/Configs/Debug.storekit"))]
        )
    }
    
    // MARK: - Private
    
    /// Helper function to create the application target
    private static func makeAppTarget(
        name: String,
        platform: Platform,
        dependencies: [TargetDependency]
    ) -> Target {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "$(BUNDLE_SHORT_VERSION_STRING)",
            "CFBundleVersion": "1",
            "CFBundleDisplayName": "$(BUNDLE_DISPLAY_NAME)",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "UISupportedInterfaceOrientations" : .array(["UIInterfaceOrientationPortrait"]),
            "ITSAppUsesNonExemptEncryption": .boolean(false),
        ]
        
        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: [.iphone, .ipad]),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: [
                .glob(.init("Sources/**"), excluding: .init("**/Tests/**"))
            ],
            resources: [
                "Resources/**",
                "InfoPlists/**",
                "Sources/Modules/**/*.storyboard"
            ],
            entitlements: .init("TomatoTimer.entitlements"),
            scripts: [
                .post(
                    script: """
                                if [[ "$(uname -m)" == arm64 ]]; then
                                    export PATH="/opt/homebrew/bin:$PATH"
                                fi
                                
                                if which swiftlint > /dev/null; then
                                  swiftlint
                                else
                                  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
                                fi
                            """,
                    name: "SwiftLint"
                )
            ],
            dependencies: dependencies,
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig"),
                    .release(name: "TestFlight", xcconfig: "Configs/TestFlight.xcconfig"),
                    .release(name: "Release", xcconfig: "Configs/Release.xcconfig")
                ],
                defaultSettings: .none
            ),
            coreDataModels: [.init(.relativeToManifest("Sources/Services/CoreData/Model.xcdatamodeld"))]
        )
        return mainTarget
    }
    
    /// Helper function to create the application test target
    private static func makeAppTestTarget(name: String, platform: Platform) -> Target {
        let platform: Platform = platform
        
        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "com.adamtecle.\(name)Tests",
            infoPlist: .default,
            sources: ["**/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ])
        return testTarget
    }
    
    private static func makeDebugScheme() -> Scheme {
        Scheme(
            name: "TomatoTimer-Debug",
            shared: true,
            buildAction: BuildAction(targets: [.init(stringLiteral: "TomatoTimer")]),
            testAction: TestAction.targets([.init(stringLiteral: "TomatoTimerTests")]),
            runAction: RunAction.runAction(
                configuration: .debug,
                executable: .init(stringLiteral: "TomatoTimer"),
                options: .options(storeKitConfigurationPath: .relativeToRoot("Modules/TomatoTimer/Configs/Debug.storekit"))
            )
        )
    }
    
    private static func makeTestFlightScheme() -> Scheme {
        Scheme(
            name: "TomatoTimer-TestFlight",
            shared: true,
            buildAction: BuildAction(targets: [.init(stringLiteral: "TomatoTimer")]),
            testAction: TestAction.targets([.init(stringLiteral: "TomatoTimerTests")]),
            runAction: RunAction.runAction(
                configuration: .configuration("TestFlight"),
                executable: .init(stringLiteral: "TomatoTimer")
            )
        )
    }
    
    private static func makeReleaseScheme() -> Scheme {
        Scheme(
            name: "TomatoTimer-Release",
            shared: true,
            buildAction: BuildAction(targets: [.init(stringLiteral: "TomatoTimer")]),
            testAction: TestAction.targets([.init(stringLiteral: "TomatoTimerTests")]),
            runAction: RunAction.runAction(
                configuration: .release,
                executable: .init(stringLiteral: "TomatoTimer")
            )
        )
    }
}
