//
//  BackgroundColorView.swift
//  TomatoTimer
//
//  Created by adam tecle on 1/12/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct BackgroundColorView<Content>: View where Content: View {

    let color: UIColor
    let content: Content

    init(color: UIColor, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(color)
                .ignoresSafeArea()

            content
        }
    }
}

struct BackgroundColorView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColorView(color: .purple) {
            Text("Hello world!")
                .foregroundColor(.white)
        }
    }
}
