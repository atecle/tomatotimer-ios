//
//  SelectTaskEmptyStateView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/21/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct SelectTaskEmptyStateView: View {

    @Environment(\.colorScheme) var colorScheme
    @State var isPressedDown = false
    var scale: Double { isPressedDown ? 0.98 : 1 }
    private var onTap: () -> Void

    init(
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
    }

    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(UIColor.label.asColor)
                .bold()
            Text("Select a task to get started")
                .foregroundColor(UIColor.label.asColor)
                .bold()
        }
        .contentShape(Rectangle())
        .frame(height: 50)
        .padding()
        .background(UIColor.systemBackground.asColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .scaleEffect(scale)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressedDown = true
                }
                .onEnded { _ in
                    isPressedDown = false
                    onTap()
                }
        )
        .animation(
            .linear(
                duration: 0.065
            ),
            value: scale
        )
    }
}

struct SelectTaskEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectTaskEmptyStateView(
            onTap: {}
        )
    }
}
