import Foundation
import UIKit

extension UIColor {

    // #A2A3A2
    static var appGray: UIColor = #colorLiteral(red: 0.6352941176, green: 0.6392156863, blue: 0.6352941176, alpha: 1)

    // #EE5253
    static var appPomodoroRed: UIColor = #colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.3254901961, alpha: 1)

    // #FC427B
    static var appPink: UIColor = #colorLiteral(red: 0.9882352941, green: 0.2588235294, blue: 0.4823529412, alpha: 1)

    // #FF6B81
    static var appRose: UIColor = #colorLiteral(red: 1, green: 0.4196078431, blue: 0.5058823529, alpha: 1)

    // #00B894
    static var appGreen: UIColor = #colorLiteral(red: 0, green: 0.7215686275, blue: 0.5803921569, alpha: 1)

    // #1B9CFC
    static var appBlue: UIColor = #colorLiteral(red: 0.1058823529, green: 0.6117647059, blue: 0.9882352941, alpha: 1)

    // #1E3799
    static var appIndigo: UIColor = #colorLiteral(red: 0.1176470588, green: 0.2156862745, blue: 0.6, alpha: 1)

    // #E58E26
    static var appOrange: UIColor = #colorLiteral(red: 0.8980392157, green: 0.5568627451, blue: 0.1490196078, alpha: 1)

    // #5758BB
    static var appPurple: UIColor = #colorLiteral(red: 0.3411764706, green: 0.3450980392, blue: 0.7333333333, alpha: 1)

    // #8395A7
    static var appGrayBlue: UIColor = #colorLiteral(red: 0.5137254902, green: 0.5843137255, blue: 0.6549019608, alpha: 1)

    // #795548
    static var appBrown: UIColor = #colorLiteral(red: 0.4745098039, green: 0.3333333333, blue: 0.2823529412, alpha: 1)

    // #00BCD4
    static var appCyan: UIColor = #colorLiteral(red: 0, green: 0.737254902, blue: 0.831372549, alpha: 1)

    // #5AC8FA
    static var appSkyBlue: UIColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)

    // #6B6C6B
    static var appOffBlack: UIColor = #colorLiteral(red: 0.4196078431, green: 0.4235294118, blue: 0.4196078431, alpha: 1)

    // #F1F1F1
    static var appDivider: UIColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)

    // #0085EB
    static var appRadioButton: UIColor = #colorLiteral(red: 0, green: 0.5215686275, blue: 0.9215686275, alpha: 1)

    // #B9C4C4
    static var appEdwardGray: UIColor = #colorLiteral(red: 0.7254901961, green: 0.768627451, blue: 0.768627451, alpha: 1)

    // #1d1d24
    static var midnight: UIColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1411764706, alpha: 1)
}

extension UIColor {
    static let defaultThemeColor: UIColor = .appPomodoroRed
    static var themeColors: [UIColor] {
        return [
            .appPomodoroRed,
            .appOrange,
            .appRose,
            .appPink,
            .appBlue,
            .appCyan,
            .appGreen,
            .appPurple,
            .appIndigo,
            .appBrown,
            .appGrayBlue,
            .black
        ]
    }
}
