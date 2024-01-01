import SwiftUI
import ComposableArchitecture

// swiftlint:disable identifier_name line_length

extension StandardTimerReducer.State {
    var controlViewState: StandardTimerControlView.ViewState {
        return .init(
            timer: timer,
            taskCount: incompleteTaskCount,
            animation: animation
        )
    }
}

struct StandardTimerControlView: View {

    // MARK: - Definitions

    struct ViewState: Equatable {
        let timer: StandardTimer
        let taskCount: Int
        let animation: StandardTimerAnimation?
    }

    // MARK: - Properties

    let viewState: ViewState
    let animationCompletion: () -> Void

    // Animation values
    @GestureState private var isPressedDown = false
    private var strokeBorderScale: CGFloat { isPressedDown ? 0.98 : 1 }
    private var strokeBorderScaleDuration: CGFloat { 0.065 }
    private let innerCircleScale: Double = 0.85
    @State var seedViewRotation: Angle = .zero
    @State var seedViewScale: CGFloat = 1
    @State var elapsedTimeMaskValue: CGFloat = 0

    // MARK: Body

    var body: some View {
        ZStack {
            CircularBorder(
                disabled: viewState.taskCount == 0
            )

            switch viewState.animation {
            case .none:
                if viewState.timer.hasBegun {
                    ElapsedTimeView(
                        timer: viewState.timer,
                        disabled: viewState.taskCount == 0
                    )
                } else {
                    SeedView(disabled: viewState.taskCount == 0)
                }
            case .some:
                SeedView(
                    disabled: viewState.taskCount == 0
                )
                .scaleEffect(seedViewScale)
                .rotationEffect(seedViewRotation)

                Circle()
                    .foregroundColor(UIColor.label.asColor.opacity(viewState.taskCount == 0 ? 0.5 : 1))
                    .scaleEffect(innerCircleScale)
                    .mask(
                        from: .top,
                        padding: 30,
                        value: elapsedTimeMaskValue
                    )
            }

            PauseView()
                .opacity((viewState.timer.isRunning || (!viewState.timer.isRunning && !viewState.timer.hasBegun) ? 0 : 1))
                .animation(.linear(duration: 0.125), value: (viewState.timer.isRunning || (!viewState.timer.isRunning && !viewState.timer.hasBegun) ? 0 : 1))

        }
        .onChange(of: viewState.animation) { newValue in
            switch newValue {
            case .none:
                break
            case let .some(animation):
                setStartingAnimationValues(animation)
                animate(animation) {
                    animationCompletion()
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

    func setStartingAnimationValues(_ animation: StandardTimerAnimation) {
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
        disabled: Bool
    ) -> some View {
        Circle()
            .stroke(UIColor.label.asColor.opacity(disabled ? 0.2 : 1), lineWidth: 13.5)
            .scaleEffect(strokeBorderScale)
            .animation(
                .linear(
                    duration: strokeBorderScaleDuration
                ),
                value: strokeBorderScale
            )
            .disabled(disabled)
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

    func SeedView(
        disabled: Bool
    ) -> some View {
        return TomatoSeedView(
            disabled: disabled
        )
    }

    func ElapsedTimeView(
        timer: StandardTimer,
        disabled: Bool
    ) -> some View {
        Circle()
            .foregroundColor(UIColor.label.asColor.opacity(disabled ? 0.5 : 1))
            .scaleEffect(innerCircleScale)
            .mask(
                from: .top,
                padding: 30, // 15 * 2
                value: calculateMask(
                    secondsLeft: CGFloat(timer.timeLeftInSession),
                    totalSeconds: CGFloat(timer.sessionLength)
                )
            )
            .animation(.linear(duration: 0.2), value: calculateMask(
                secondsLeft: CGFloat(timer.timeLeftInSession),
                totalSeconds: CGFloat(timer.sessionLength)
            ))
    }
}

struct StandardTimerControlView_Previews: PreviewProvider {
    static var previews: some View {
        StandardTimerControlView(
            viewState: .init(
                timer: .init(),
                taskCount: 0,
                animation: nil
            ),
            animationCompletion: {}
        ).padding(36)
    }
}

extension StandardTimerControlView {
    // swiftlint:disable function_body_length
    func animate(
        _ animation: StandardTimerAnimation,
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

private struct TomatoSeedView: View {
    let disabled: Bool

    init(
        disabled: Bool
    ) {
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
                                SeedImageView(.topLeft, UIColor.label.asColor.opacity(disabled ? 0.2 : 1))
                                Spacer()
                                SeedImageView(.topRight, UIColor.label.asColor.opacity(disabled ? 0.2 : 1))
                            }
                            Spacer()
                            HStack {
                                SeedImageView(.bottomLeft, UIColor.label.asColor.opacity(disabled ? 0.2 : 1))
                                Spacer()
                                SeedImageView(.bottomRight, UIColor.label.asColor.opacity(disabled ? 0.2 : 1))
                            }
                        }.padding(geo.size.height * 0.30)
                    }
                )

        }
    }
}
