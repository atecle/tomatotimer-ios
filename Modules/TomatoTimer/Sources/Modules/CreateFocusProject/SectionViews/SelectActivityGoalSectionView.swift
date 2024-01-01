//
//  SelectActivityGoalSectionView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/14/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct SelectActivityGoalSectionView: View {

    let store: StoreOf<CreateFocusProjectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                ListRowView(
                    title: "Select Activity Goals",
                    icon: .trophyFill,
                    iconBackground: UIColor.appOrange.asColor,
                    accessory: .chevron,
                    showPlusFeature: !viewStore.state.didPurchasePlus
                )
                .onTapGesture {
                    viewStore.send(.selectActivityGoalButtonPressed)
                }

                ForEach(viewStore.project.activityGoals) { goal in
                    ListRowView(
                        title: goal.title,
                        subtitle: "\(DateComponentsFormatter.abbreviated(goal.goalSeconds)) \(goal.goalIntervalType.description)",
                        icon: .clock,
                        iconBackground: UIColor.appPomodoroRed.asColor
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: { viewStore.send(.removeActivityGoal(goal)) }) {
                            Text("Remove")
                        }
                    }

                }
            }
        header: {
            Text("Link with Activity Goals (\(viewStore.project.activityGoals.count))")
        } footer: {
            Text(
                """
                An activity goal is a goal to do something consistently per day or per week. \
                You can use activity goals to help build or maintain a habit.
                """
            )
        }
        }
    }
}

struct SelectActivityGoalSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectActivityGoalSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(
                        project: .init(
                            activityGoals: [
                                .init(title: "Practice Spanish"),
                                .init(title: "Read more")
                            ]
                        )
                    ),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
