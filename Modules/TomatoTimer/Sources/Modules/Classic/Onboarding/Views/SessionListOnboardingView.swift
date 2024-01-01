import SwiftUI

struct SessionListOnboardingView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        TomatoTimerAsset.listclock.swiftUIImage
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 200, height: 200)
                    }
                }.frame(height: geo.size.height * 0.5)

                VStack(spacing: 28) {
                    Group {
                        Text("Session List").bold()
                    }
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                    Group {
                        Text("Timebox").bold() +
                        Text(" each task to the") +
                        Text(" work session. ").bold() +
                        Text("\n\nCompleting the task completes the work session, and vice versa.")
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

struct SessionListOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListOnboardingView()
    }
}
