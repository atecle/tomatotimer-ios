import Foundation

enum NotificationSound: Int {
    case bell
    case coins
    case pluck
    case synth

    /// PRO
    case electric
    case swiftly
    case hooray
    case longbell
    case shortpluck
    case xylophone
    case toodleLoo
    case pristine
    case goodDay
    case upward

    static var `default`: NotificationSound { .bell }

    var isProSound: Bool {
        !NotificationSound.nonProSounds.contains(self)
    }
}

extension NotificationSound {
    static var nonProSounds: [NotificationSound] {
        return [.bell, .coins, .pluck, .synth]
    }
}

extension NotificationSound: CustomStringConvertible {
    var description: String {
        switch self {
        case .bell: return "Bell"
        case .coins: return "Coins"
        case .pluck: return "Pluck"
        case .synth: return "Synth"

        case .electric: return "Electric"
        case .swiftly: return "Swiftly"
        case .hooray: return "Hooray"
        case .longbell: return "Long Bell"
        case .shortpluck: return "Short Pluck"
        case .xylophone: return "Xylophone"
        case .toodleLoo: return "Toodle Loo"
        case .pristine: return "Pristine"
        case .goodDay: return "Good Day"
        case .upward: return "Upward"
        }
    }
}

extension NotificationSound: CaseIterable {}
extension NotificationSound: Swift.Identifiable {
    var id: Int { self.rawValue }
}
extension NotificationSound: Hashable {}
