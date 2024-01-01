import Foundation
import SwiftUI

private enum ActiveTab: Equatable, Hashable {
    case yesterday
    case today
    case tomorrow
}

struct CalendarWeekTabView<Content: View>: View {

    // MARK: - Properties

    @EnvironmentObject var weekStore: WeekStore
    @State private var activeTab: ActiveTab = .today
    @State private var direction: TimeDirection = .unknown
    let content: (_ day: Date) -> Content

    // MARK: - Methods

    init(@ViewBuilder content: @escaping (_ day: Date) -> Content) {
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        VStack {
            WeeksTabView { week in
                WeekView(week: week)
            }
            .frame(height: 80, alignment: .top)
            Text(weekStore.selectedDate.toString(format: "EEEE  MMMM d, yyyy"))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            TabView(selection: $activeTab) {
                content(weekStore.selectedDate.yesterday)
                    .frame(maxWidth: .infinity)
                    .tag(ActiveTab.yesterday)

                content(weekStore.selectedDate)
                    .frame(maxWidth: .infinity)
                    .tag(ActiveTab.today)
                    .onDisappear {
                        if direction != .unknown {
                            weekStore.select(
                                date: direction == .future
                                ? weekStore.selectedDate.tomorrow
                                : weekStore.selectedDate.yesterday
                            )
                        }

                        direction = .unknown
                        activeTab = .today
                    }

                content(weekStore.selectedDate.tomorrow)
                    .frame(maxWidth: .infinity)
                    .tag(ActiveTab.tomorrow)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: activeTab) { tab in
                switch tab {
                case .yesterday:
                    direction = .past
                case .tomorrow:
                    direction = .future
                default:
                    break
                }
            }
        }
    }
}

struct CalendarWeekTabView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWeekTabView { day in
            Text("\(day.toString(format: "EEEE, dd.MM.yyyy"))")
        }
        .environmentObject(WeekStore())
    }
}
