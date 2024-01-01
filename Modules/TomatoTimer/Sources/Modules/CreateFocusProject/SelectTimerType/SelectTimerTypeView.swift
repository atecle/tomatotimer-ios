import SwiftUI
import ComposableArchitecture

struct SelectTimerTypeView: View {

    // MARK: - Properties

    let store: StoreOf<SelectTimerTypeReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(TimerType.allCases, id: \.self) { type in
                ListRowView(
                    title: type.title,
                    subtitle: type.description,
                    icon: type == .standard ? .clockFill : .stopwatchFill,
                    iconBackground: UIColor.appPomodoroRed.asColor,
                    accessory: type == viewStore.selectedType ? .checkmark : .none,
                    showPlusFeature: type == .stopwatch ? !viewStore.didPurchasePlus : false
                )
                .onTapGesture {
                    viewStore.send(.selectedTimerType(type))
                }
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$paywall,
                    action: SelectTimerTypeReducer.Action.paywall
                ),
                content: PaywallView.init(store:)
            )
        }
    }
}

struct SelectTimerTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectTimerTypeView(
            store: Store(
                initialState: SelectTimerTypeReducer.State(),
                reducer: SelectTimerTypeReducer()
            )
        )
    }
}

extension TimerType {

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .stopwatch: return "Stopwatch"
        }
    }

    var description: String {
        switch self {
        case .standard: return "Work sessions, short breaks, and long breaks."
        case .stopwatch: return "Tap to begin a work session, tap again to start a break."
        }
    }
}
