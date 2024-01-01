//
//  ActivitySummaryDetailView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/16/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ActivitySummaryDetailView: View {

    @EnvironmentObject var weekStore: WeekStore
    @State var showDatePicker: Bool = false

    let store: StoreOf<ActivitySummaryDetailReducer>

    init(store: StoreOf<ActivitySummaryDetailReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            CurrentCalendarWeekTabView { _ in
                List {
                    Section {
                        WeeklyActivityTotalsView(data: viewStore.totals, showSectionHeader: false)
                    }
                    ForEach(viewStore.daysOfWeek, id: \.self) { date in
                        Section("\(DateFormatter.full(from: date))") {
                            ForEach(viewStore.projectsForDate(date)) { project in
                                FocusProjectRowActivity(project: project)
//                                HStack(alignment: .center) {
//                                    Text("\(project.emoji)")
//                                        .padding(10)
//                                        .background(project.themeColor.asColor)
//                                        .cornerRadius(10)
//
//                                    HStack {
//                                        Text("\(project.title)")
//                                            .strikethrough(project.timer.isComplete)
//                                            .bold()
//                                        Spacer()
//                                        Text("\(DateComponentsFormatter.abbreviated(TimeInterval(project.totalWorkSecondsElapsed)))")
//                                            .foregroundColor(.accentColor)
//                                            .bold()
//                                    }
//                                }
                            }
                        }
                        .isHidden(viewStore.projectsForDate(date).count == 0, remove: true)
                    }
                }
            }
            .onReceive(weekStore.$weeks) { _ in
                viewStore.send(.loadWeek(weekStore.currentWeek))
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("Select Date", selection: $weekStore.selectedDate)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .cornerRadius(15)
                        .padding()
                        .presentationDetents([.medium, .large])
                        .onChange(of: weekStore.selectedDate, perform: { _ in
                            showDatePicker = false
                        })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: { showDatePicker = true }) {
                        let text = Calendar.current.isDateInToday(weekStore.weeks[1].referenceDate)
                        ? "Current Week"
                        : weekStore.currentWeek.displayString
                        Text("\(text)")
                            .bold()
                    }
                }
                if !Calendar.current.isDateInToday(weekStore.weeks[1].referenceDate) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                weekStore.selectToday()
                            }
                        } label: {
                            Text("Today")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(4)
                                .background(.secondary)
                                .cornerRadius(4)
                        }

                    }
                }
            }
        }
    }
}

struct ActivitySummaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySummaryDetailView(
            store: Store(
                initialState: ActivitySummaryDetailReducer.State(),
                reducer: ActivitySummaryDetailReducer()
            )
        )
        .environmentObject(WeekStore())
    }
}
