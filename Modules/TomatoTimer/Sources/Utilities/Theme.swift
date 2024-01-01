//
//  Theme.swift
//  TomatoTimer
//
//  Created by adam on 12/6/20.
//  Copyright © 2020 Adam Tecle. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    var complementaryColor: UIColor {
        self.isLight() ? .appOffBlack : .white
    }
}

extension Color {
    var complementaryColor: Color {
        UIColor(self).complementaryColor.asColor
    }
}
