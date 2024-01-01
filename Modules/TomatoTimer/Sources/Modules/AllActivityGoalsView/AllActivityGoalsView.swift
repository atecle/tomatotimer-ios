//
//  AllActivityGoalsView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/16/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct AllActivityGoalsView: View {

    let store: StoreOf<AllActivityGoalsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("Active") {
                    ForEach(viewStore.activeGoals) { goal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(goal.title)")
                                .bold()
                            Text("\(DateComponentsFormatter.abbreviated(goal.goalSeconds)) \(goal.goalIntervalType.description)")
                                .font(.caption)
                                .foregroundColor(UIColor.secondaryLabel.asColor)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: { viewStore.send(.archiveButtonPressed(goal)) }) {
                                Text("Archive")
                            }
                            Button(role: .destructive, action: { viewStore.send(.deleteButtonPressed(goal)) }) {
                                Text("Delete")
                            }
                        }
                    }

                }
                Section("Archived") {
                    ForEach(viewStore.archivedGoals) { goal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(goal.title)")
                                .bold()
                            Text("\(DateComponentsFormatter.abbreviated(goal.goalSeconds)) \(goal.goalIntervalType.description)")
                                .font(.caption)
                                .foregroundColor(UIColor.secondaryLabel.asColor)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: { viewStore.send(.unarchiveButtonPressed(goal)) }) {
                                Text("Unarchive")
                            }
                            Button(role: .destructive, action: { viewStore.send(.deleteButtonPressed(goal)) }) {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: AllActivityGoalsReducer.Action.alert
                )
            )
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .navigationTitle("All Activity Goals")
        }
    }
}

struct AllActivityGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        AllActivityGoalsView(
            store: Store(
                initialState: AllActivityGoalsReducer.State(),
                reducer: AllActivityGoalsReducer()
            )
        )
    }
}
