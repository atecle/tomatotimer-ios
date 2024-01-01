import SwiftUI

struct StopwatchTimerControlView: View {

    // Animation values
    @GestureState private var isPressedDown = false
    private var strokeBorderScale: CGFloat { isPressedDown ? 0.98 : 1 }
    private var strokeBorderScaleDuration: CGFloat { 0.065 }
    let viewState: StopwatchTimerView.ViewState
    var timer: StopwatchTimer { viewState.timer }
    let onTapGesture: () -> Void

    var body: some View {
        ZStack {

            PauseView()
                .opacity((viewState.timer.isRunning || (!viewState.timer.isRunning && !viewState.timer.hasBegun) ? 0 : 1))
                // swiftlint:disable:next line_length
                .animation(.linear(duration: 0.125), value: (viewState.timer.isRunning || (!viewState.timer.isRunning && !viewState.timer.hasBegun) ? 0 : 1))

            ClockBorder()
                .overlay(
                    ClockInterior(
                        isDisabled: viewState.isDisabled
                    )
                )

        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressedDown) { _, isPressedDown, _ in
                    isPressedDown = true
                }
                .onEnded { _ in
                    onTapGesture()
                }
        )
    }

    func ClockBorder() -> some View {
        Circle()
            .stroke(UIColor.label.asColor.opacity(viewState.isDisabled ? 0.2 : 1), lineWidth: 13.5)
            .scaleEffect(strokeBorderScale)
            .animation(
                .linear(
                    duration: strokeBorderScaleDuration
                ),
                value: strokeBorderScale
            )
            .disabled(viewState.isDisabled)

    }

    func ClockInterior(
        isDisabled: Bool
    ) -> some View {
        ZStack {
          Circle()
                .fill(.clear)
                .overlay(
                    ZStack {
                        VerticleClockTicks()
                            .foregroundColor(UIColor.label.asColor.opacity(viewState.isDisabled ? 0.2 : 1))
                        ClockHand()
                            .foregroundColor(UIColor.label.asColor.opacity(viewState.isDisabled ? 0.2 : 1))

                        HorizontalClockTicks()
                            .foregroundColor(UIColor.label.asColor.opacity(viewState.isDisabled ? 0.2 : 1))
                    }
                )
        }
    }

    func VerticleClockTicks() -> some View {
        HStack {
            Spacer()
            VStack {

                Text("60")
                Spacer()
                Text("30")

            }
            Spacer()
        }
        .padding()
    }

    func HorizontalClockTicks() -> some View {
        VStack {
            Spacer()
            HStack {

                Text("45")
                Spacer()
                Text("15")

            }
            Spacer()
        }
        .padding()
    }

    func ClockHand() -> some View {
        ZStack {
            Circle()
                .frame(width: 10, height: 10)
            Clock(model: .init(time: TimeInterval(timer.time)))
                .stroke(
                    UIColor.label.asColor.opacity(viewState.isDisabled ? 0.2 : 1),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
        }
    }

    func PauseView() -> some View {
        ZStack {
            Circle()
                .scaleEffect(strokeBorderScale)
                .foregroundColor(UIColor.black.withAlphaComponent(0.2).asColor)

            TomatoTimerAsset.pause.swiftUIImage
                .foregroundColor(.white)
        }
    }
}

struct StopwatchTimerControlView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchTimerControlView(
            viewState: .init(timer: .init(), isDisabled: false),
            onTapGesture: {}
        )
    }
}

struct Clock: Shape {
    var model: ClockTickerModel

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length = rect.width / 2.5
        let center = CGPoint(x: rect.midX, y: rect.midY)

        path.move(to: center)
        let hoursAngle = CGFloat.pi / 2 - .pi * 2 * model.angleMultiplier
        path.addLine(to: CGPoint(x: rect.midX + cos(hoursAngle) * length * model.tickerScale,
                                 y: rect.midY - sin(hoursAngle) * length * model.tickerScale))
        return path
    }
}

struct ClockTickerModel: Equatable {

    let time: TimeInterval

    var angleMultiplier: CGFloat {
        return CGFloat(self.time.remainder(dividingBy: 60)) / 60
    }

    var tickerScale: CGFloat {
        return 0.8
    }
}
