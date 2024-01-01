//
//  Int+Helpers.swift
//  TomatoTimer
//
//  Created by adam on 3/13/21.
//  Copyright © 2021 Adam Tecle. All rights reserved.
//

import Foundation

extension Int {
    var isEven: Bool { self % 2 == 0 }
    var isOdd: Bool { self % 2 != 0 }
}
