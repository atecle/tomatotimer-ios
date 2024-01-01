//
//  View+Extensions.swift
//  TomatoTimer
//
//  Created by adam tecle on 1/16/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import SwiftUI

// swiftlint:disable line_length

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

    @ViewBuilder func mask(
        from: Edge,
        padding: CGFloat = 0,
        value: CGFloat
    ) -> some View {
        self
            .mask(
                Rectangle()
                    .scaleEffect(x: 1, y: value, anchor: .bottom)
            )
    }

    /// This will add a tap gesture to a view which can be recognized simultaneously with any other gesture. Useful for components with touch down/up animations
    /// - Parameter perform: Some work to perform on touch up
    /// - Returns: A View with the simultaneous gesture attached
    @ViewBuilder func onTapGestureSimultaneous(_ perform: @escaping () -> Void) -> some View {
        self
            .simultaneousGesture(TapGesture().onEnded {
                perform()
            })
    }
}
