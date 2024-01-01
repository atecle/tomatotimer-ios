//
//  ShortBreakOnboardingView.swift
//  TomatoTimer
//
//  Created by adam tecle on 5/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct HowItWorksOnboardingView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.clock.swiftUIImage
                            .resizable()
                            .frame(width: 300, height: 300)
                    }
                }.frame(height: geo.size.height * 0.5)

                VStack(spacing: 28) {
                    Group {
                        Text("How ").bold() +
                        Text("does it work?")
                    }
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                    Group {
                        Text("Commit to a task, start the timer, and work until it rings.")
                    }
                    .font(.title)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    Spacer()
                }.padding([.leading, .trailing], 16)
            }
        }
    }
}

struct HowItWorksOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorksOnboardingView()
    }
}
