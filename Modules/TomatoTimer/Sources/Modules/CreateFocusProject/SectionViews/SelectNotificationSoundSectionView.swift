import SwiftUI
import ComposableArchitecture

struct SelectNotificationSoundSectionView: View {

    // MARK: - Definitions

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("Notification Sound") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewStore.workSound.description)")
                        Text("Work Session")
                            .font(.caption)
                    }.padding([.top, .bottom], 2)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewStore.send(.workSoundRowPressed)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewStore.breakSound.description)")
                        Text("Break Session")
                            .font(.caption)
                    }.padding([.top, .bottom], 2)
                    Spacer()
                    if !viewStore.didPurchasePlus {
                        Image(systemSymbol: .starCircleFill)
                    }
                    Image(systemName: "chevron.right")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewStore.send(.breakSoundRowPressed)
                }
            }
        }
    }
}

// MARK: - Previews

struct SelectNotificationSoundSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectNotificationSoundSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
