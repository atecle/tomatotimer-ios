import SwiftUI
import ComposableArchitecture
import Charts

struct ActivityTabView: View {

    let store: StoreOf<ActivityTabReducer>

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            WithViewStore(store, observe: { $0 }) { viewStore in

                // MARK: - Main Scroll View

                ScrollView {
                    LazyVStack {
                        ActivityTotalsView(
                            totals: viewStore.totals
                        )

                        WeeklyActivityTotalsView(
                            data: viewStore.weeklyTotals
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.activitySummaryPressed)
                        }

                        ActivityGoalsSectionView(store: store)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.viewMoreButtonPressed)
                            }
                    }
                }
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }

                // MARK: - Presentation

                .fullScreenCover(
                    store: self.store.scope(
                        state: \.$createActivityGoal,
                        action: ActivityTabReducer.Action.createActivityGoal
                    ),
                    content: CreateActivityGoalView.init(store:)
                )
                .fullScreenCover(
                    store: self.store.scope(
                        state: \.$paywall,
                        action: ActivityTabReducer.Action.paywall
                    ),
                    content: PaywallView.init(store:)
                )
                .confirmationDialog(
                    store: self.store.scope(
                        state: \.$confirmationDialog,
                        action: ActivityTabReducer.Action.confirmationDialog
                    )
                )
                .alert(
                    store: self.store.scope(
                        state: \.$alert,
                        action: ActivityTabReducer.Action.alert
                    )
                )
                .navigationTitle("Activity")
                .background(UIColor.systemGroupedBackground.asColor)
            }

            // MARK: Transitions

        } destination: { state in
            switch state {
            case .allActivityGoals:
                CaseLet(
                    state: /ActivityTabReducer.Path.State.allActivityGoals,
                    action: ActivityTabReducer.Path.Action.allActivityGoals,
                    then: AllActivityGoalsView.init(store:)
                )

            case .activityGoalDetail:
                CaseLet(
                    state: /ActivityTabReducer.Path.State.activityGoalDetail,
                    action: ActivityTabReducer.Path.Action.activityGoalDetail,
                    then: ActivityGoalDetailView.init(store:)
                )

            case .activitySummaryDetail:
                CaseLet(
                    state: /ActivityTabReducer.Path.State.activitySummaryDetail,
                    action: ActivityTabReducer.Path.Action.activitySummaryDetail,
                    then: ActivitySummaryDetailView.init(store:)
                )
            }
        }
        .onAppear {
            UIScrollView.appearance().isScrollEnabled = true
        }
    }
}

struct ActivityTabView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityTabView(
            store: Store(
                initialState: ActivityTabReducer.State(stats: []),
                reducer: ActivityTabReducer()
            )
        )
    }
}
