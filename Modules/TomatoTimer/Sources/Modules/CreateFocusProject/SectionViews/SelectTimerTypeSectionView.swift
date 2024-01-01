import SwiftUI
import ComposableArchitecture

struct SelectTimerTypeSectionView: View {

    // MARK: - Definitions

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                ListRowView(
                    title: viewStore.timerType.title,
                    subtitle: viewStore.timerType.description,
                    icon: viewStore.timerType == .standard ? .clockFill : .stopwatchFill,
                    iconBackground: UIColor.appPomodoroRed.asColor,
                    accessory: .chevron
                )
                .onTapGesture {
                    viewStore.send(.timerTypeRowPressed)
                }
                .foregroundColor(
                    UIColor.label.asColor.opacity(
                        viewStore.isEditing ? 0.2 : 1
                    )
                )
                .disabled(viewStore.isEditing)
                .opacity(viewStore.isEditing ? 0.75 : 1)
            } header: {
                Text("Timer Type")
            } footer: {
                Text("You can't edit timer type after the project has been created.")
                    .isHidden(!viewStore.isEditing, remove: true)
            }

        }
    }
}

// MARK: - Previews

struct SelectTimerTypeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectTimerTypeSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
