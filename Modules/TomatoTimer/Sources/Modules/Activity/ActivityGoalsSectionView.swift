//
//  ActivityGoalsSectionView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/17/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ActivityGoalsSectionView: View {

    let store: StoreOf<ActivityTabReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text("MY ACTIVITY GOALS")
                        .foregroundColor(.secondary)
                    Image(systemSymbol: .trophyFill)
                    Spacer()
                    Text("View all")
                        .foregroundColor(.secondary)
                    Image(systemSymbol: .chevronRight)
                        .foregroundColor(.secondary)
                }
                .padding([.leading, .trailing])
                .font(.caption)
                ForEach(viewStore.stats) { stat in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(stat.activityGoal.title)")
                                    .font(.title2)
                                    .bold()
                                HStack(spacing: 4) {
                                    Image(systemSymbol: .clockFill)
                                    Text("Total")
                                    Text("\(DateComponentsFormatter.abbreviated(stat.totalElapsedTime))")
                                        .foregroundColor(UIColor.label.asColor)

                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                            }
                            Spacer()
                            Button(action: { viewStore.send(.menuButtonPressed(stat)) }) {
                                Image(systemSymbol: .ellipsis)
                            }
                            .foregroundColor(UIColor.label.asColor)

                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 14)
                                    .foregroundColor(.accentColor)
                                    .frame(width: geo.size.width * min(1, (stat.totalElapsedTimeInDateRange / stat.activityGoal.goalSeconds)))
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                Rectangle()
                                    .frame(height: 14)
                                    .foregroundColor(.accentColor.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            }
                        }
                        HStack {
                            // swiftlint:disable:next line_length
                            Text("\(DateComponentsFormatter.abbreviated(stat.totalElapsedTimeInDateRange)) of \(DateComponentsFormatter.abbreviated(stat.activityGoal.goalSeconds)) \(stat.activityGoal.goalIntervalType.description.lowercased()) goal complete")
                                .font(.caption)
                                .bold()
                                .foregroundColor(UIColor.secondaryLabel.asColor)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(UIColor.secondarySystemGroupedBackground.asColor)
                    .cornerRadius(10)
                    .padding([.leading, .trailing])
                }
                Button(action: { viewStore.send(.plusButtonPressed) }) {
                    HStack {
                        Image(systemSymbol: .plusCircleFill)
                        Text("New Activity Goal")
                    }
                    .padding()
                    .foregroundColor(UIColor.label.asColor)
                    .background(UIColor.secondarySystemGroupedBackground.asColor)
                    .cornerRadius(10)
                }
                .padding(30)
            }
        }
    }
}

struct ActivityGoalsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ActivityGoalsSectionView(
                store: Store(
                    initialState: ActivityTabReducer.State(stats: [
//                        .init(
//                            dateRange: (Date(), Date()),
//                            activityGoal: .init(
//                                title: "Practice Spanish"
//                            ),
//                            totalElapsedTimeInDateRange: 60 * 5,
//                            totalElapsedTime: 60 * 10
//                        )
                    ]),
                    reducer: ActivityTabReducer()
                )
            )
        }
        .background(UIColor.systemGroupedBackground.asColor)
    }
}

//
//VStack(alignment: .leading, spacing: 6) {
//    HStack {
//        Text("\(stat.activityGoal.title)")
//            .font(.title2)
//            .bold()
//        Spacer()
//        Button(action: { viewStore.send(.menuButtonPressed(stat)) }) {
//            Image(systemSymbol: .ellipsis)
//        }
//    }
//    Text("\(DateComponentsFormatter.abbreviated(stat.totalElapsedTime))")
//        .font(.body)
//        .bold()
//        .foregroundColor(UIColor.secondaryLabel.asColor)
//    GeometryReader { geo in
//        ZStack(alignment: .leading) {
//            Rectangle()
//                .frame(height: 14)
//                .foregroundColor(UIColor.appGreen.asColor)
//                .frame(width: geo.size.width * (stat.totalElapsedTime / stat.activityGoal.goalSeconds))
//                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//            Rectangle()
//                .frame(height: 14)
//                .foregroundColor(UIColor.appGreen.asColor.opacity(0.2))
//                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//        }
//    }
//    // swiftlint:disable:next line_length
//    Text("\(NumberFormatter.percent(stat.totalElapsedTime / stat.activityGoal.goalSeconds)) of \(stat.activityGoal.goalIntervalType.description.lowercased()) goal complete")
//        .font(.caption)
//        .bold()
//        .foregroundColor(UIColor.secondaryLabel.asColor)
//}
//.padding([.bottom], 12)
