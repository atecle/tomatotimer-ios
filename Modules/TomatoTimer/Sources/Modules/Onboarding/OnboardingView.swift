import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {

    let store: StoreOf<OnboardingReducer>
    @Environment(\.colorScheme) var colorScheme

    init(store: StoreOf<OnboardingReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    Group {
                        switch viewStore.onboardingStep {
                        case .intro:
                            IntroView()
                        case .useATimer:
                            UseTimerView()
                        case .timerTypes:
                            TimerTypeView()
                        case .listTypes:
                            ListTypeView()
                        case .buildHabits:
                            CreateHabitsView()
                        case .createTimer:
                            CreateTimerView()
                        }
                    }
                    .padding()

                    Spacer()
                    Button(action: { viewStore.send(.nextButtonPressed) }) {
                        HStack {
                            Spacer()
                            Text("Next")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .foregroundColor(UIColor.label.asColor)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(UIColor.label.asColor)
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 24)
                }
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            store: Store(
                initialState: OnboardingReducer.State(onboardingStep: .intro),
                reducer: OnboardingReducer()
            )
        )
    }
}

// MARK: - Helper

private struct LogoView: View {
    let logo: Image
    var body: some View {
        ZStack {
            logo
                .resizable()
                .frame(width: 200, height: 200)
        }
        .frame(height: 200)
        .padding([.top], 50)
    }
}

private struct IntroView: View {
    var body: some View {
        VStack {
            LogoView(logo: TomatoTimerAsset.logo.swiftUIImage)

            Group {
                Text("Welcome to \n") +
                Text("Tomato Timer")
                    .bold()

            }
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.bottom], 30)
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

private struct UseTimerView: View {
    var body: some View {
        VStack {
            LogoView(logo: TomatoTimerAsset.clock.swiftUIImage)

            Group {
                Text("Use a ") +
                Text("Timer ")
                    .bold() +
                Text("\n") +
                Text("While You Work")
                    .bold()

            }
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.bottom], 30)
            Group {
                Text("Using a timer as a productivity tool is about") +
                Text("\nsetting an intention \n").fontWeight(.semibold) +
                Text("to block distractions and focus for ") +
                Text("\nsome period of time.").fontWeight(.semibold)
            }
            .font(.title)
            .foregroundColor(Color.secondary)
            .multilineTextAlignment(.center)
        }
    }
}

private struct TimerTypeView: View {
    var body: some View {
        VStack {
            LogoView(logo: TomatoTimerAsset.clock.swiftUIImage)
//            ZStack {
//
//                    .resizable()
//                    .renderingMode(.template)
//                    .tint(UIColor.label.asColor)
//                    .frame(width: 300, height: 300)
//            }
//            .frame(height: 300)
//            .padding([.top], 50)

            Group {
                Text("2 Timer Types")
                    .bold()
            }
            .font(.largeTitle)
            .padding([.bottom], 30)
            Group {
                Text("A ") +
                Text("Standard Timer\n").fontWeight(.semibold) +
                Text("is for fixed length work and break sessions. \n\n") +
                Text("A ") +
                Text("Stopwatch Timer\n").fontWeight(.semibold) +
                Text("lets you start a work or break session at your own pace.")
            }
            .font(.title)
            .foregroundColor(Color.secondary)
            .multilineTextAlignment(.center)
        }
    }
}

private struct ListTypeView: View {
    var body: some View {
        VStack {
            LogoView(logo: Image(systemSymbol: .listBullet))

            Group {
                Text("3 List Types")
                    .bold()
            }
            .font(.largeTitle)
            .padding([.bottom], 30)
            Group {
                Text("Standard is a basic to-do list.\n") +
                Text("Session timeboxes your tasks.\n") +
                Text("Single Task is for one single task.")
            }
            .font(.title)
            .foregroundColor(Color.secondary)

            Group {
                Text("\nYou can also choose to not use a list.")
            }
            .font(.title)
            .foregroundColor(Color.secondary)
            .multilineTextAlignment(.center)
        }
    }
}

private struct CreateHabitsView: View {
    var body: some View {
        VStack {
            LogoView(logo: Image(systemSymbol: .calendar))

            Group {
                Text("Build Habits")
                    .bold()
            }
            .font(.largeTitle)
            .padding([.bottom], 24)
            Group {
                // swiftlint:disable:next line_length
                Text("Tomato Timer allows you to create a recurring timer and set reminders. For example, create a recurring timer to study Spanish on Mondays.\n\n") +
                Text("Set activity goals and visualize progress in the Activity tab.")
            }
            .font(.title)
            .foregroundColor(Color.secondary)
            .multilineTextAlignment(.center)
        }
    }
}

private struct CreateTimerView: View {
    var body: some View {
        VStack {
            Spacer()
            Group {
                Text("Let's create your first timer.")
                    .bold()
            }
            .font(.largeTitle)
            .padding([.bottom], 24)
        }
    }
}
