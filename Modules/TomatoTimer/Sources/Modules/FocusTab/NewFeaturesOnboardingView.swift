import SwiftUI

struct NewFeaturesOnboardingView: View {

    let store: StoreOf<NewFeaturesOnboardingReducer>

    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            ZStack {
                                Color.clear
                                VStack {
                                    TomatoTimerAsset.tomato.swiftUIImage
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundColor(UIColor.appPomodoroRed.asColor)
                                        .frame(width: 200, height: 200)
                                }
                            }.frame(height: geo.size.height * 0.35)

                            VStack(spacing: 28) {
                                Group {
                                    Text("Tomato Timer has a new design and some new features!\n\n").bold()
                                    +
                                    Text("If you miss the old experience, just turn on Classic Mode in Settings ❤️")
                                        .foregroundColor(.secondary)
                                        .bold()
                                        .font(.body)
                                }
                                .font(.title3)
                                .multilineTextAlignment(.center)

                                VStack(alignment: .center) {
                                    ListRowView(
                                        title: "Calendar",
                                        subtitle: "Plan ahead and view previous timers with the calendar.",
                                        icon: .calendar,
                                        iconBackground: .green
                                    )
                                        .padding()
                                        .background(UIColor.secondarySystemBackground.asColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)

                                    ListRowView(
                                        title: "Stopwatch Timer",
                                        subtitle: "A new timer type which allows you to start a work session or a break session at your own pace.",
                                        icon: .stopwatchFill,
                                        iconBackground: UIColor.appPomodoroRed.asColor
                                    )
                                        .padding()
                                        .background(UIColor.secondarySystemBackground.asColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)

                                    ListRowView(
                                        title: "Session List",
                                        subtitle: "A new list type which timeboxes each task to the work session. Completing the task completes the work session, and vice versa.",
                                        icon: .clockBadgeCheckmarkFill,
                                        iconBackground: .blue
                                    )
                                        .padding()
                                        .background(UIColor.secondarySystemBackground.asColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                                    ListRowView(
                                        title: "Activity",
                                        subtitle: "View your past activity in the Activity tab and set goals.",
                                        icon: .chartBarFill,
                                        iconBackground: UIColor.appOrange.asColor
                                    )
                                        .padding()
                                        .background(UIColor.secondarySystemBackground.asColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                                    ListRowView(
                                        title: "iCloud Sync",
                                        subtitle: "Backup your data to iCloud and sync between devices.",
                                        icon: .chartBarFill,
                                        iconBackground: .blue
                                    )
                                        .padding()
                                        .background(UIColor.secondarySystemBackground.asColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                                }

                                VStack {
                                    Group {
                                        Text("Get ") +
                                        Text("Tomato Timer+")
                                            .bold()
                                            .foregroundColor(UIColor.appPomodoroRed.asColor) +
                                        Text(" for \(viewStore.product?.price ?? "") to unlock everything. ") +
                                        Text("\n\nAll basic features are still available for free.")
                                    }
                                }
                                .bold()
                                .multilineTextAlignment(.center)

                                Button(
                                    action: { viewStore.send(.doneButtonPressed) }
                                ) {
                                    HStack {
                                        Spacer()
                                        Text("OK")
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .font(.title2)
                                .foregroundColor(.white)
                                .bold()
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(.blue)
                                .cornerRadius(10)
                                .padding([.leading, .trailing], 24)

                                Spacer()
                            }.padding([.leading, .trailing], 16)
                        }
                        .onAppear { viewStore.send(.viewDidAppear) }
                    }
                    .navigationBarTitle("What's New?")
                }
            }
        }
    }
}

struct NewFeaturesOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeaturesOnboardingView(
            store: Store(
                initialState: NewFeaturesOnboardingReducer.State(
                    product: .init(productID: "1", price: "$19.99")
                ),
                reducer: NewFeaturesOnboardingReducer()
            )
        )
    }
}

import ComposableArchitecture

struct NewFeaturesOnboardingReducer: ReducerProtocol {

    enum Action: Equatable {
        case viewDidAppear
        case setProduct(InAppPurchaseProduct)
        case doneButtonPressed
    }

    struct State: Equatable {
        var product: InAppPurchaseProduct?
    }

    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewDidAppear:
            return .none

        case let .setProduct(product):
            state.product = product
            return .none

        case .doneButtonPressed:
            return .fireAndForget {
                await self.dismiss()
            }
        }
    }
}
