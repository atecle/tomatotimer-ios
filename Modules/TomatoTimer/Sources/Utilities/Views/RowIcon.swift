//
//  RowIcon.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/19/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct RowIcon: View {
    let icon: SFSymbol
    let iconBackground: Color

    var body: some View {
        Image(systemSymbol: icon)
            .padding(8)
            .background(iconBackground)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct RowIcon_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HStack {
                RowIcon(
                    icon: .clockFill,
                    iconBackground: UIColor.appPomodoroRed.asColor
                )
                Text("List Row Title")
            }
        }
    }
}
