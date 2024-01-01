//
//  UIColor+AsColor.swift
//  TomatoTimer
//
//  Created by adam tecle on 1/15/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    var asColor: Color { Color(self) }
}

extension Color {
    var asUIColor: UIColor { UIColor(self) }
}
