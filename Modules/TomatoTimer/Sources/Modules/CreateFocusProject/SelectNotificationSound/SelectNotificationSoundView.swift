import SwiftUI
import ComposableArchitecture

struct SelectNotificationSoundView: View {

    let store: StoreOf<SelectNotificationSoundReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(NotificationSound.allCases) { sound in
                HStack {
                    Text("\(sound.description)")
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(UIColor.label.asColor)
                        .isHidden(sound != viewStore.sound)
                    if sound.isProSound {
                        Image(systemSymbol: .starCircleFill)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewStore.send(.selectedSound(sound))
                }
                .contentShape(Rectangle())
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$paywall,
                    action: SelectNotificationSoundReducer.Action.paywall
                ),
                content: PaywallView.init(store:)
            )
        }
    }
}

struct SelectNotificationSoundView_Previews: PreviewProvider {
    static var previews: some View {
        SelectNotificationSoundView(
            store: Store(
                initialState: SelectNotificationSoundReducer.State(),
                reducer: SelectNotificationSoundReducer()
            )
        )
    }
}
