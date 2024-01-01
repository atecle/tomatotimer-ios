import SwiftUI
import ComposableArchitecture

struct CreateFocusProjectView: View {

    // MARK: - Properties

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: - Methods

    init(store: StoreOf<CreateFocusProjectReducer>) {
        self.store = store
    }

    // MARK: Body

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                // MARK: List
                List {
                    SelectTitleAndImageSectionView(store: store)
                    SelectThemeSectionView(store: store)
                    SelectTimerTypeSectionView(store: store)
                    if viewStore.timerType == .standard {
                        TimerConfigurationSectionView(store: store)
                        SelectNotificationSoundSectionView(store: store)
                        SelectAutostartSectionView(store: store)
                    }
                    SelectListTypeSectionView(store: store)
                    SelectRecurrenceSectionView(store: store)
                    SelectActivityGoalSectionView(store: store)
                }
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }
                .navigationTitle("\(viewStore.isEditing ? "Edit" : "Create") Project")
                .navigationBarTitleDisplayMode(.inline)
                // MARK: Toolbar
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.doneButtonPressed) }) {
                            Text("Done")
                                .bold()
                        }
                        .disabled(viewStore.canSave == false || viewStore.isSaving)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.dismissButtonPressed) }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .fullScreenCover(
                    store: self.store.scope(
                        state: \.$paywall,
                        action: CreateFocusProjectReducer.Action.paywall
                    ),
                    content: PaywallView.init(store:)
                )

                // MARK: Navigation

            }
        } destination: { state in
            switch state {
            case .selectTimerType:
                CaseLet(
                    state: /CreateFocusProjectReducer.Path.State.selectTimerType,
                    action: CreateFocusProjectReducer.Path.Action.selectTimerType,
                    then: SelectTimerTypeView.init(store:)
                )
            case .selectWorkSound:
                CaseLet(
                    state: /CreateFocusProjectReducer.Path.State.selectWorkSound,
                    action: CreateFocusProjectReducer.Path.Action.selectWorkSound,
                    then: SelectNotificationSoundView.init(store:)
                )
            case .selectBreakSound:
                CaseLet(
                    state: /CreateFocusProjectReducer.Path.State.selectBreakSound,
                    action: CreateFocusProjectReducer.Path.Action.selectBreakSound,
                    then: SelectNotificationSoundView.init(store:)
                )
            case .selectListType:
                CaseLet(
                    state: /CreateFocusProjectReducer.Path.State.selectListType,
                    action: CreateFocusProjectReducer.Path.Action.selectListType,
                    then: SelectListTypeView.init(store:)
                )
            case .selectActivityGoal:
                CaseLet(
                    state: /CreateFocusProjectReducer.Path.State.selectActivityGoal,
                    action: CreateFocusProjectReducer.Path.Action.selectActivityGoal,
                    then: SelectActivityGoalView.init(store:)
                )
            }
        }
    }
}

// MARK: - Previews

struct CreateFocusProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFocusProjectView(
            store: Store(
                initialState: CreateFocusProjectReducer.State(),
                reducer: CreateFocusProjectReducer()
            )
        )
    }
}
