import SwiftUI
import ComposableArchitecture

struct ClassicOnboardingView: View {

    // MARK: - Properties

    let store: StoreOf<ClassicOnboardingReducer>

    // MARK: - Properties

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Button("Skip") { viewStore.send(.skipButtonTapped) }
                        .foregroundColor(Color.primary)
                        .bold()
                    Spacer()
                }
                .padding([.leading, .trailing])

                TabView {
                    IntroOnboardingView()

                    HowItWorksOnboardingView()

                    ShortBreakOnboardingView()

                    LongBreakOnboardingView()

//                    StopwatchTimerOnboardingView()
//                    SessionListOnboardingView()

                    BenefitsOnboardingView(
                        buttonAction: {
                            viewStore.send(.finishButtonTapped)
                        }
                    )
                }
                .ignoresSafeArea()
                .tabViewStyle(
                    .page(indexDisplayMode: .automatic)
                )

            }
            .onAppear {
                viewStore.send(.onAppear)
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primary)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.primary).withAlphaComponent(0.2)
            }
        }
    }
}

struct ClassicOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicOnboardingView(
            store: Store(
                initialState: ClassicOnboardingReducer.State(),
                reducer: ClassicOnboardingReducer()
            )
        )
    }
}
