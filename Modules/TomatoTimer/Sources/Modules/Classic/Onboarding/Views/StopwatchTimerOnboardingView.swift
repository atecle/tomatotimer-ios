import SwiftUI

struct StopwatchTimerOnboardingView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.stopwatch.swiftUIImage
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(UIColor.appPomodoroRed.asColor)
                            .frame(width: 200, height: 200)
                    }
                }.frame(height: geo.size.height * 0.4)

                VStack(spacing: 28) {
                    Group {
                        Text("Stopwatch Timer").bold() +
                        Text("\nTomato Timer+")
                            .font(.body)
                            .bold()
                            .underline()
                            .foregroundColor(UIColor.appPomodoroRed.asColor)
                    }
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                    Group {
                        Text("Toggle between a work and break session at your own pace.")
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

struct StopwatchTimerOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchTimerOnboardingView()
    }
}
