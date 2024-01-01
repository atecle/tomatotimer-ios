import Foundation
import SwiftUI

private enum ActiveTab: Equatable, Hashable {
    case yesterday
    case today
    case tomorrow
}

struct CurrentCalendarWeekTabView<Content: View>: View {

    // MARK: - Properties

    @EnvironmentObject var weekStore: WeekStore
    @State private var activeTab: ActiveTab = .today
    @State private var direction: TimeDirection = .unknown
    let content: (_ week: Week) -> Content

    // MARK: - Methods

    init(@ViewBuilder content: @escaping (_ week: Week) -> Content) {
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $activeTab) {
            content(weekStore.weeks[0])
                .frame(maxWidth: .infinity)
                .tag(ActiveTab.yesterday)

            content(weekStore.weeks[1])
                .frame(maxWidth: .infinity)
                .tag(ActiveTab.today)
                .onDisappear {
                    if direction != .unknown {
                        weekStore.update(to: direction)
                    }

                    direction = .unknown
                    activeTab = .today
                }

            content(weekStore.weeks[2])
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

struct CurrentCalendarWeekTabView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentCalendarWeekTabView { week in
            Text("\(DateFormatter.monthDayYear(from: week.referenceDate.startOfWeek))")
        }
        .environmentObject(WeekStore())
    }
}
