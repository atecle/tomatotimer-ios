//
//  CreateActivityGoalView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/15/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct CreateActivityGoalView: View {

    let store: StoreOf<CreateActivityGoalReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {

                List {
                    Section("Title") {
                        TextField(
                            viewStore.placeholder,
                            text: viewStore.binding(get: \.activityGoal.title, send: { .setTitle($0) })
                        )
                        .multilineTextAlignment(.leading)
                        .padding()
                        .bold()
                        .frame(height: 55)
                        .background(UIColor.label.withAlphaComponent(0.07).asColor)
                        .foregroundColor(UIColor.label.asColor)
                        .cornerRadius(10)
                        .padding(8)
                    }
                    Section("Frequency") {
                        Stepper(
                            value: viewStore.binding(
                                get: { $0.activityGoal.goalSeconds / 60 },
                                send: CreateActivityGoalReducer.Action.setTarget
                            ), in: 1...120) {
                                Text("Target")
                                Text("\(Int(viewStore.activityGoal.goalSeconds / 60)) minutes")

                            }.frame(minHeight: 44)
                        Button(action: { viewStore.send(.setDaily)}) {
                            HStack {
                                Text("Per day")
                                Spacer()
                                Image(systemSymbol: .checkmark)
                                    .isHidden(viewStore.activityGoal.goalIntervalType == .weekly)
                            }
                            .contentShape(Rectangle())
                        }
                        .foregroundColor(UIColor.label.asColor)
                        Button(action: { viewStore.send(.setWeekly) }) {
                            HStack {
                                Text("Per week")
                                Spacer()
                                Image(systemSymbol: .checkmark)
                                    .isHidden(viewStore.activityGoal.goalIntervalType == .daily)
                            }
                            .contentShape(Rectangle())
                        }
                        .foregroundColor(UIColor.label.asColor)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.dismissButtonPressed) }) {
                            Image(systemSymbol: .xmark)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.doneButtonPressed) }) {
                            Text("Done")
                                .bold()
                        }
                        .disabled(!viewStore.canSave)
                    }
                }
                .navigationTitle("Create Activity Goal")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct CreateActivityGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateActivityGoalView(
            store: Store(
                initialState: CreateActivityGoalReducer.State(),
                reducer: CreateActivityGoalReducer()
            )
        )
    }
}

let activityGoalPlaceholders: [String] = [
    "e.g., Practice Spanish",
    "e.g., Read",
    "e.g., Study for midterm",
    "e.g., Play piano",
    "e.g., Learn to draw"
]
