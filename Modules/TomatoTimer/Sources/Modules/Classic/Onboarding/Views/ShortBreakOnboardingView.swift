//
//  ShortBreakOnboardingView.swift
//  TomatoTimer
//
//  Created by adam tecle on 5/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct ShortBreakOnboardingView: View {
    @State var degrees: Double = 0

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.sun.swiftUIImage
                            .resizable()
                            .frame(width: 300, height: 300)
                            .rotationEffect(.degrees(degrees), anchor: .center)

                    }.frame(height: geo.size.height * 0.5)
                }

                VStack(spacing: 28) {
                    Group {
                        Text("Take a short break").bold()
                    }
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    Group {
                        Text("After it rings, relax for a while.\n\nThis time is for you to recharge.")
                    }
                    .font(.title)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    Spacer()
                }.padding([.leading, .trailing], 16)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                    degrees = 360
                 }
             }
        }
    }
}

struct ShortBreakOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ShortBreakOnboardingView()
    }
}
