//
//  UIColor+BrightnessCheck.swift
//  TomatoTimer
//
//  Created by adam on 12/6/20.
//  Copyright © 2020 Adam Tecle. All rights reserved.
//

import Foundation
import UIKit

// Thank you to https://stackoverflow.com/a/29044899/3354041
public extension UIColor {

    func isLight(threshold: Float = 0.7) -> Bool {
        let originalCGColor = self.cgColor

        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return false
        }
        guard components.count >= 3 else {
            return false
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
