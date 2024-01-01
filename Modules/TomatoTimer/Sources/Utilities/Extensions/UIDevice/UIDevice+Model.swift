import UIKit

/// I really want to delete this file but my layout logic is wrong

/// An enumeration of possible iPhone models.
@objc public enum DeviceType: Int {
    case unknown
    case iPhone5
    case iPhone6
    case iPhone6P
    case iPhoneX
    static let iPhone7 = iPhone6
    static let iPhone7P = iPhone6P
    static let iPhone8 = iPhone6
    static let iPhone8P = iPhone6P
}

/// An extension that provides information on the current device running used.
public extension UIDevice {

    static var isiPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// The iPhone model currently being used.
    @objc static var type: DeviceType {
        if isIPhone5 {
            return .iPhone5
        } else if isIPhone6 {
            return .iPhone6
        } else if isIPhone6P {
            return .iPhone6P
        } else if isIPhone7 {
            return .iPhone7
        } else if isIPhone7P {
            return .iPhone7P
        } else if isIPhone8 {
            return .iPhone8
        } else if isIPhone8P {
            return .iPhone8P
        } else if isIPhoneX {
            return .iPhoneX
        } else {
            return .unknown
        }
    }

    /// A flag for whether the current device is an iPhone.
    @objc static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    /// A flag for whether the current device is an iPhone5.
    @objc static var isIPhone5: Bool {
        return isIPhone && UIScreen.main.bounds.height == 568.0
    }

    /// A flag for whether the current device is an iPhone6.
    @objc static var isIPhone6: Bool {
        return isIPhone && UIScreen.main.bounds.height == 667.0
    }

    /// A flag for whether the current device is an iPhone6P.
    @objc static var isIPhone6P: Bool {
        return isIPhone && UIScreen.main.bounds.height == 736.0
    }

    /// A flag for whether the current device is an iPhone7.
    @objc static var isIPhone7: Bool {
        return isIPhone6
    }

    /// A flag for whether the current device is an iPhone7P.
    @objc static var isIPhone7P: Bool {
        return isIPhone6P
    }

    /// A flag for whether the current device is an iPhone8.
    @objc static var isIPhone8: Bool {
        return isIPhone6
    }

    /// A flag for whether the current device is an iPhone8P.
    @objc static var isIPhone8P: Bool {
        return isIPhone6P
    }

    /// A flag for whether the current device is an iPhoneX.
    @objc static var isIPhoneX: Bool {
        return isIPhone && UIScreen.main.bounds.height == 812.0
    }
}
