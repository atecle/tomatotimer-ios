import SwiftUI
import ComposableArchitecture

struct ActivityGoalDetailView: View {

    let store: StoreOf<ActivityGoalDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            CalendarWeekTabView { day in
                ZStack {
                    GeometryReader { geo in
                        List {

                            Section {
                                VStack(alignment: .leading) {
                                    Text("\(DateComponentsFormatter.abbreviated(viewStore.timeSpentForDay(day))) ")
                                        .bold()
                                    ZStack(alignment: .leading) {
                                        if viewStore.goal.goalIntervalType == .weekly {
                                            Rectangle()
                                                .frame(height: 14)
                                                .foregroundColor(UIColor.appGreen.asColor)
                                                .frame(width: geo.size.width * (viewStore.timeSpentForWeek(day) / viewStore.goal.goalSeconds))
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                            Rectangle()
                                                .frame(height: 14)
                                                .foregroundColor(UIColor.appBlue.asColor)
                                                .frame(width: geo.size.width * (viewStore.timeSpentForDay(day) / viewStore.goal.goalSeconds))
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                            Rectangle()
                                                .frame(height: 14)
                                                .foregroundColor(UIColor.appGreen.asColor.opacity(0.2))
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        } else {
                                            Rectangle()
                                                .frame(height: 14)
                                                .foregroundColor(UIColor.appBlue.asColor)
                                                .frame(width: geo.size.width * (viewStore.timeSpentForDay(day) / viewStore.goal.goalSeconds))
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                            Rectangle()
                                                .frame(height: 14)
                                                .foregroundColor(UIColor.appGreen.asColor.opacity(0.2))
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        }

                                    }

                                    HStack {
                                        HStack {
                                            Rectangle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(UIColor.appBlue.asColor)
                                                .cornerRadius(12)
                                            Text("\(DateComponentsFormatter.abbreviated(viewStore.timeSpentForDay(day))) on this day")
                                        }
                                        HStack {
                                            Rectangle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(UIColor.appGreen.asColor)
                                                .cornerRadius(12)
                                            Text("\(DateComponentsFormatter.abbreviated(viewStore.timeSpentForWeek(day))) this week")
                                        }
                                    }
                                    .font(.caption)
                                }
                                .listRowSeparator(.hidden)
                            }
                            Section {
                                Text("Projects")
                                    .font(.largeTitle)
                                    .bold()
                            }
                            .listRowSeparator(.hidden)

                            Section {
                                ForEach(viewStore.projectsForToday(day)) { project in
                                    HStack(alignment: .center) {
                                        Text("\(project.emoji)")
                                            .padding(10)
                                            .background(project.themeColor.asColor)
                                            .cornerRadius(10)

                                        VStack(alignment: .leading) {
                                            Text("\(project.title)")
                                                .strikethrough(project.timer.isComplete)
                                                .bold()
                                        }

                                    }

                                }
                            }
                        }
                        .listStyle(.plain)

                    }
                }
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
        }
    }
}

struct ActivityGoalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityGoalDetailView(
            store: Store(
                initialState: ActivityGoalDetailReducer.State(
                    goal: .init(),
                    activityGoalWithProject: .init(activityGoal: .init(), projects: [.init()])),
                reducer: ActivityGoalDetailReducer()
            )
        )
        .environmentObject(WeekStore())
    }
}
