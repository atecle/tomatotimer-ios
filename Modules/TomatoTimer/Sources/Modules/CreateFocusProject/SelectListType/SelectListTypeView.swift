import SwiftUI
import ComposableArchitecture

struct SelectListTypeView: View {

    // MARK: - Properties

    let store: StoreOf<SelectListTypeReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.listItems) { type in
                ListRowView(
                    title: type.title,
                    subtitle: type.description,
                    icon: type.symbol,
                    iconBackground: .blue,
                    accessory: type.listType == viewStore.selectedListType.listType ? .checkmark : .none,
                    showPlusFeature: viewStore.didPurchasePlus
                    ? false
                    : type.isPlusFeature
                )

                .onTapGesture {
                    viewStore.send(.selectedListType(type))
                }
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$paywall,
                    action: SelectListTypeReducer.Action.paywall
                ),
                content: PaywallView.init(store:)
            )
        }
    }
}

struct SelectListTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectListTypeView(
            store: Store(
                initialState: SelectListTypeReducer.State(selectedTimerType: .standard),
                reducer: SelectListTypeReducer()
            )
        )
    }
}

extension FocusList {
    var title: String {
        switch self {
        case .standard: return "Standard"
        case .session: return "Session"
        case .singleTask: return "Single"
        case .none: return "None"
        }
    }

    var description: String {
        switch self {
        case .standard: return "A basic to-do list."
        case .session: return "Tasks are timeboxed to the session."
        case .singleTask: return "Set a single focus for the timer."
        case .none: return "Use the timer without a list."
        }
    }
}
