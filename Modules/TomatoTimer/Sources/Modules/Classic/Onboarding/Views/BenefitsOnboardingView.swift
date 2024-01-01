//
//  ShortBreakOnboardingView.swift
//  TomatoTimer
//
//  Created by adam tecle on 5/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct BenefitsOnboardingView: View {

    let buttonAction: () -> Void

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.star.swiftUIImage
                            .resizable()
                            .frame(width: 300, height: 300)
                    }
                }.frame(height: geo.size.height * 0.5)

                VStack(spacing: 28) {
                    Group {
                        Text("What are the ") +
                        Text("benefits?").bold()
                    }
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                    Group {
                        Text("You'll find yourself working more efficiently and getting distracted less often.")
                    }
                    .font(.title)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    Button(
                        action: buttonAction
                    ) {
                        HStack {
                            Spacer()
                            Text("Let's Go!")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(UIColor.appGreen.asColor)
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 24)
                }.padding([.leading, .trailing], 16)

            }
        }
    }
}

struct BenefitsOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        BenefitsOnboardingView(buttonAction: {})
    }
}
