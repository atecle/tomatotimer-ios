import SwiftUI
import ComposableArchitecture

// swiftlint:disable identifier_name line_length

struct TomatoTimerControlView: View {

    // MARK: - Properties

    let store: StoreOf<TomatoTimerReducer>

    @GestureState private var isPressedDown = false
    private var strokeBorderScale: CGFloat { isPressedDown ? 0.98 : 1 }
    private var strokeBorderScaleDuration: CGFloat { 0.065 }
    private let innerCircleScale: Double = 0.8325
    @State var seedViewRotation: Angle = .zero
    @State var seedViewScale: CGFloat = 1
    @State var elapsedTimeMaskValue: CGFloat = 0

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { _ in
                ZStack {
                    CircularBorder(
                        themeColor: viewStore.settings.themeColor.asColor,
                        disabled: !viewStore.authorizedNotifications
                    )

                    switch viewStore.animation {
                    case .none:
                        if viewStore.tomatoTimer.hasBegun {
                            ElapsedTimeView(
                                viewStore.settings.themeColor.asColor,
                                timer: viewStore.tomatoTimer
                            )
                        } else {
                            SeedView(
                                themeColor: viewStore.settings.themeColor.asColor,
                                disabled: !viewStore.authorizedNotifications
                            )
                        }
                    case .some:
                        SeedView(themeColor: viewStore.settings.themeColor.asColor, disabled: !viewStore.authorizedNotifications)
                            .scaleEffect(seedViewScale)
                            .rotationEffect(seedViewRotation)

                        Circle()
                            .foregroundColor(viewStore.settings.themeColor.complementaryColor.asColor)
                            .scaleEffect(innerCircleScale)
                            .mask(
                                from: .top,
                                padding: 30,
                                value: elapsedTimeMaskValue
                            )
                    }

                    PauseView()
                        .opacity((viewStore.tomatoTimer.isRunning || (!viewStore.tomatoTimer.isRunning && !viewStore.tomatoTimer.hasBegun) ? 0 : 1))
                        .animation(.linear(duration: 0.125), value: (viewStore.tomatoTimer.isRunning || (!viewStore.tomatoTimer.isRunning && !viewStore.tomatoTimer.hasBegun) ? 0 : 1))

                }
                .onChange(of: viewStore.animation) { newValue in
                    switch newValue {
                    case .none:
                        break
                    case let .some(animation):
                        setStartingAnimationValues(animation)
                        animate(animation) {
                            viewStore.send(.setAnimation(nil))
                        }
                    }
                }
                .contentShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isPressedDown) { _, isPressedDown, _ in
                            isPressedDown = true
                        })
            }
        }
    }

    func setStartingAnimationValues(_ animation: TomatoTimerReducer.Animation) {
        switch animation {
        case .pristineToStarted:
            elapsedTimeMaskValue = 0
            seedViewScale = 1
            seedViewRotation = .zero
        case .startNextSession, .finishedToPristine:
            elapsedTimeMaskValue = 0
            seedViewScale = 0
            seedViewRotation = .zero
        case
                let .startedToPristine(secondsLeft, totalSeconds),
                let .refill(secondsLeft, totalSeconds),
                let .completeAndContinue(secondsLeft, totalSeconds):
            elapsedTimeMaskValue = calculateMask(
                secondsLeft: CGFloat(secondsLeft),
                totalSeconds: CGFloat(totalSeconds)
            )
            seedViewScale = 0
            seedViewRotation = .zero
        }
    }

    func CircularBorder(
        themeColor: Color,
        disabled: Bool
    ) -> some View {
        Circle()
            .strokeBorder(themeColor.complementaryColor.opacity(disabled ? 0.2 : 1), lineWidth: 13.5)
            .scaleEffect(strokeBorderScale)
            .animation(
                .linear(
                    duration: strokeBorderScaleDuration
                ),
                value: strokeBorderScale
            )
    }

    func PauseView() -> some View {
        ZStack {
            Circle()
                .scaleEffect(innerCircleScale)
                .foregroundColor(UIColor.black.withAlphaComponent(0.2).asColor)

            TomatoTimerAsset.pause.swiftUIImage
                .foregroundColor(.white)
        }
    }

    func SeedView(themeColor: Color, disabled: Bool = false) -> some View {
        return TomatoSeedView(color: themeColor.complementaryColor, disabled: disabled)
    }

    func ElapsedTimeView(_ themeColor: Color, timer: TomatoTimer) -> some View {
        let percentageOfTimeLeft = calculateMask(
            secondsLeft: CGFloat(timer.secondsLeftInCurrentSession),
            totalSeconds: CGFloat(timer.totalSecondsInCurrentSession)
        )
        return Circle()
            .foregroundColor(themeColor.complementaryColor)
            .scaleEffect(innerCircleScale)
            .mask(
                from: .top,
                value: percentageOfTimeLeft
            )
            .animation(.linear(duration: 0.2), value: percentageOfTimeLeft)
    }
}

struct TimerControlView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColorView(color: .appPomodoroRed) {
            TomatoTimerView(
                store: Store(
                    initialState: TomatoTimerReducer.State(
                        tomatoTimer: {
                            let timer = TomatoTimer()
                            return timer
                        }(),
                        scheduledNotifications: .init(),
                        settings: .init()
                    ),
                    reducer: TomatoTimerReducer()
                )
            )
        }
    }
}

extension TomatoTimerControlView {
    // swiftlint:disable function_body_length
    func animate(
        _ animation: TomatoTimerReducer.Animation,
        completion: @escaping () -> Void
    ) {

        switch animation {
        case .pristineToStarted:

            // Rotate seeds
            withAnimation(.spring(response: 0.6, dampingFraction: 0.89, blendDuration: 1)) {
                seedViewRotation = seedViewRotation + .degrees(180)
            }

            withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1).delay(0.6)) {
                seedViewScale = 0
            }

            withAnimation(.spring(response: 0.73, dampingFraction: 0.9, blendDuration: 1).delay(0.9)) {
                elapsedTimeMaskValue = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600 + 200 + 730 + 100)) {
                completion()
            }

        case .startedToPristine:
            withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                elapsedTimeMaskValue = 0
            }

            withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1).delay(0.4)) {
                seedViewScale = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 + 100)) {
                completion()
            }
        case .refill:

            withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                elapsedTimeMaskValue = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                completion()
            }
        case .startNextSession:
            withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1)) {
                seedViewScale = 1
            }

            // Rotate seeds
            withAnimation(.spring(response: 0.6, dampingFraction: 0.89, blendDuration: 1).delay(0.2)) {
                seedViewRotation = seedViewRotation + .degrees(180)
            }

            withAnimation(.easeInOut(duration: 0.3).delay(0.8)) {
                seedViewScale = 0
            }

            withAnimation(.easeOut(duration: 0.5).delay(1.1)) {
                elapsedTimeMaskValue = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200 + 600 + 300 + 500)) {
                completion()
            }
        case .finishedToPristine:
            withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1)) {
                seedViewScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                completion()
            }
        case .completeAndContinue:

            withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                elapsedTimeMaskValue = 0
            }

            withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 1).delay(0.4)) {
                seedViewScale = 1
            }

            // Rotate seeds
            withAnimation(.spring(response: 0.6, dampingFraction: 0.89, blendDuration: 1).delay(0.7)) {
                seedViewRotation = seedViewRotation + .degrees(180)
            }

            withAnimation(.easeInOut(duration: 0.3).delay(1.3)) {
                seedViewScale = 0
            }

            withAnimation(.easeOut(duration: 0.5).delay(1.6)) {
                elapsedTimeMaskValue = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 + 200 + 600 + 300 + 500)) {
                completion()
            }
        }
    }
}

// MARK: - Helper Views

func calculateMask(secondsLeft: CGFloat, totalSeconds: CGFloat) -> CGFloat {
    let percentageOfTimeLeft = secondsLeft / totalSeconds
    return percentageOfTimeLeft
}

private struct TomatoSeedView: View {
    let color: Color
    let disabled: Bool

    init(
        color: Color,
        disabled: Bool
    ) {
        self.color = color
        self.disabled = disabled
    }

    var body: some View {
        ZStack {
          Circle()
                .fill(.clear)
                .overlay(
                    GeometryReader { geo in
                        VStack {
                            HStack {
                                SeedImageView(.topLeft, disabled ? color.opacity(0.5) : color)
                                Spacer()
                                SeedImageView(.topRight, disabled ? color.opacity(0.5) : color)
                            }
                            Spacer()
                            HStack {
                                SeedImageView(.bottomLeft, disabled ? color.opacity(0.5) : color)
                                Spacer()
                                SeedImageView(.bottomRight, disabled ? color.opacity(0.5) : color)
                            }
                        }.padding(geo.size.height * 0.30)
                    }
                )

        }
    }
}

struct SeedImageView: View {

    // static let seedWidth: CGFloat = UIDevice.isIPhone ? (UIDevice.isIPhone5 ? 18 : 23) : 32
    static let seedWidth: CGFloat = 23
    static let seedSize: CGSize = CGSize(width: seedWidth, height: seedWidth)

    enum SeedDirection: String {
        case topLeft = "seed1"
        case topRight = "seed2"
        case bottomRight = "seed3"
        case bottomLeft = "seed4"
    }

    private let seedDirection: SeedDirection
    private let fgColor: Color

    init(
        _ seedDirection: SeedDirection,
        _ fgColor: Color
    ) {
        self.seedDirection = seedDirection
        self.fgColor = fgColor
    }

    var body: some View {
        Image(seedDirection.rawValue)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(fgColor)
            .frame(width: SeedImageView.seedWidth, height: SeedImageView.seedWidth, alignment: .center)
    }
}
