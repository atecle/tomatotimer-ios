import Foundation
import Combine
import ComposableArchitecture
import UIKit

// MARK: Services

extension Services: DependencyKey {
    static let liveValue: ServiceProvider = Services(
        coreDataStack: CoreDataStack.createStack(container: .makePersistentContainer())
    )

    static let testValue: ServiceProvider = MockServices()
}

extension DependencyValues {
    var services: ServiceProvider {
        get { self[Services.self] }
        set { self[Services.self] = newValue }
    }

    var uiApplication: UIApplication {
        get { self[UIApplication.self] }
        set { self[UIApplication.self] = newValue }
    }

    var focusProjectClient: FocusProjectClientType {
        get { self[FocusProjectClient.self] }
        set { self[FocusProjectClient.self] = newValue }
    }

    var activityGoalClient: ActivityGoalClient {
        get { self[ActivityGoalClient.self] }
        set { self[ActivityGoalClient.self] = newValue }
    }

    var standardTimerClient: StandardTimerClient {
        get { self[StandardTimerClient.self] }
        set { self[StandardTimerClient.self] = newValue }
    }

    var standardListClient: StandardListClient {
        get { self[StandardListClient.self] }
        set { self[StandardListClient.self] = newValue }
    }

    var stopwatchTimerClient: StopwatchTimerClient {
        get { self[StopwatchTimerClient.self] }
        set { self[StopwatchTimerClient.self] = newValue }
    }

    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }

    public var emoji: EmojiGenerator {
        get { self[EmojiGeneratorKey.self] }
        set { self[EmojiGeneratorKey.self] = newValue }
    }

    public var color: ColorGenerator {
        get { self[ColorGeneratorKey.self] }
        set { self[ColorGeneratorKey.self] = newValue }
    }

    private enum EmojiGeneratorKey: DependencyKey {
        static let liveValue = EmojiGenerator { randomEmoji() }
    }

    private enum ColorGeneratorKey: DependencyKey {
        static let liveValue = ColorGenerator { randomThemeColor() }
    }
}

extension UIApplication: DependencyKey {
    public static let liveValue: UIApplication = .shared
    public static let testValue: UIApplication = .shared
}

public struct EmojiGenerator: Sendable {

    private let generate: @Sendable () -> String

    public static func constant(_ string: String) -> Self {
        Self { string }
    }

    public init(_ generate: @escaping @Sendable () -> String) {
        self.generate = generate
    }

    public func callAsFunction() -> String {
        self.generate()
    }
}

func randomEmoji() -> String {
    let range = 0x1F300...0x1F3F0
    // swiftlint:disable:next legacy_random
    let index = Int(arc4random_uniform(UInt32(range.count)))
    let ord = range.lowerBound + index
    guard let scalar = UnicodeScalar(ord) else { return "❓" }
    return String(scalar)
}

func randomThemeColor() -> UIColor {
    UIColor.themeColors.randomElement()!
}

public struct ColorGenerator: Sendable {

    private let generate: @Sendable () -> UIColor

    public static func constant(_ color: UIColor) -> Self {
        Self { color }
    }

    public init(_ generate: @escaping @Sendable () -> UIColor) {
        self.generate = generate
    }

    public func callAsFunction() -> UIColor {
        self.generate()
    }
}
