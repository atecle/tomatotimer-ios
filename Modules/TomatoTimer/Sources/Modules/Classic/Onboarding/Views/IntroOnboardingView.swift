import Foundation
import SwiftUI

struct IntroOnboardingView: View {

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.logo.swiftUIImage
                            .resizable()
                            .frame(width: 300, height: 300)
                    }
                }.frame(height: geo.size.height * 0.5)

                VStack {
                    VStack(spacing: 28) {
                        Group {
                            Text("What is ") +
                            Text("Tomato Timer?").bold()
                        }
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        Group {
                            Text("Tomato Timer is a") +
                            Text("\npersonal productivity app").fontWeight(.semibold) +
                            Text("\nbased on the technique of timeboxing.")
                        }
                        .font(.title)
                        .foregroundColor(Color.secondary)
                        .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

struct IntroOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        IntroOnboardingView()
    }
}
