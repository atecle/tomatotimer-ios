import SwiftUI
import ComposableArchitecture

struct ProUpgradeView: View {

    // MARK: - Definitions

    // MARK: - Properties

    let store: StoreOf<ProUpgradeReducer>

    // MARK: View

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(alignment: .center) {

                    ScrollView {
                        FeaturesImageCollection()
                        VStack(alignment: .leading) {
                            FeaturesTitleView()
                            FeaturesView()
                            Spacer()
                        }
                    }

                    Spacer()

                    // MARK: - Purchase Buttons

                    VStack(alignment: .center) {

                        HStack(alignment: .center) {
                            Button(action: {
                                viewStore.send(.purchasePro)
                            }, label: {
                                HStack {
                                    ProgressView()
                                        .isHidden(!viewStore.isLoading)
                                    Text("Unlock Tomato Timer Pro for \(viewStore.price)")
                                    ProgressView()
                                        .isHidden(true)
                                }
                                .padding()
                                .opacity(viewStore.isLoading ? 0.5 : 1)
                            })
                            .buttonStyle(.plain)
                            .bold()
                            .foregroundColor(.white)
                            .frame(minHeight: 64)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                            .disabled(viewStore.isLoading)
                        }

                        Button("Restore Purchases") {
                            viewStore.send(.restorePurchases)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                        .disabled(viewStore.isLoading)

                    }
                    .padding([.bottom], 16)
                }

                .alert(
                    store: self.store.scope(
                        state: \.$alert,
                        action: ProUpgradeReducer.Action.alert
                    )
                )

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.dismissButtonPressed) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(UIColor.label.asColor)
                        }
                    }
                }.onAppear {
                    viewStore.send(.onAppear)
                }
            }

        }
    }
}

struct ProUpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        ProUpgradeView(
            store: Store(
                initialState: ProUpgradeReducer.State(
                    settings: .init(),
                    isLoading: false
                ),
                reducer: ProUpgradeReducer()
            )
        )
    }
}

struct FeaturesImageCollection: View {
    var body: some View {
        TomatoTimerAsset.logo.swiftUIImage
            .resizable()
            .frame(width: 200, height: 200)
    }
}

struct FeaturesTitleView: View {

    var body: some View {
        Group {
            Text("More Features")
                .bold() +
            Text("\nTomato Timer Pro")
                .foregroundColor(Color.blue)
                .bold()
        }
        .multilineTextAlignment(.leading)
        .padding([.leading, .trailing, .top])
        .font(.title)

    }
}

struct FeaturesView: View {
    var body: some View {
        HStack {
            VStack(spacing: 30) {
                HStack {
                    BackgroundColorView(color: UIColor.tertiarySystemFill) {
                        Image(systemName: "list.clipboard.fill")
                    }
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    Group {
                        Text("Use a To-Do List. ")
                            .bold()
                        + Text("You can add up to 10 lists and add up to 15 to-dos per list.")
                    }
                    Spacer()
                }
                HStack {
                    BackgroundColorView(color: UIColor.tertiarySystemFill) {
                        Image(systemName: "paintbrush.pointed.fill")
                    }
                    .foregroundColor(.brown)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    Group {
                        Text("More Theme Colors. ")
                            .bold()
                        + Text("Use a color picker to set a custom color.")
                    }
                    Spacer()
                }
                HStack {
                    BackgroundColorView(color: UIColor.tertiarySystemFill) {
                        Image(systemName: "bell.fill")
                    }
                    .foregroundColor(.yellow)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    Group {
                        Text("Enhanced Notifications. ")
                            .bold()
                        + Text("Access to 10 more notification sounds. Set a different notification sound for work sessions and breaks.")
                    }
                    Spacer()
                }
            }
            .padding([.leading, .trailing])
            .padding(.top, 1)
            Spacer()
        }
    }
}
