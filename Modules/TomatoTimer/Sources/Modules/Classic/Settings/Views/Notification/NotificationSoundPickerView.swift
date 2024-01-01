//
//  NotificationSoundPickerView.swift
//  TomatoTimer
//
//  Created by adam tecle on 1/2/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct NotificationSoundPickerView: View {

    @SwiftUI.Environment(\.dismiss) var dismiss
    @Binding var selection: NotificationSound?

    var body: some View {
        NavigationStack {
            List(NotificationSound.allCases, selection: $selection) { sound in
                HStack {
                    Text("\(sound.description)")
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(UIColor.label.asColor)
                        .isHidden(sound != selection)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = sound
                    dismiss()
                }
                .contentShape(Rectangle())
            }
        }
    }
}

struct NotificationSoundPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSoundPickerView(selection: .constant(.bell))
    }
}
