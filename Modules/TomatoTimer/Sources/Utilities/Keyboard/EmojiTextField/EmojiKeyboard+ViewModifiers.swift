//
//  EmojiKeyboard+ViewModifiers.swift
//  TomatoTimer
//
//  Created by adam tecle on 7/8/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import SwiftUI

struct EditableText: ViewModifier {
    @Binding var text: String
    @Binding var editing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                EmojiTextField(text: $text, isFirstResponder: $editing)
                    .frame(width: 1, height: 1)
            )
            .onTapGestureSimultaneous {
                editing.toggle()
            }
    }
}

extension View {
    func editableText(_ text: Binding<String>, _ editing: Binding<Bool>) -> some View {
        modifier(EditableText(text: text, editing: editing))
    }
}
