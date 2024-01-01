import SwiftUI
import ComposableArchitecture

// swiftlint:disable line_length

struct NotificationSoundSectionView: View {

    let store: StoreOf<ClassicSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
                if viewStore.settings.purchasedPro {
                    NavigationLink(
                        destination: NotificationSoundPickerView(selection: viewStore.binding(get: { Optional.some($0.settings.workSound) }, send: ClassicSettingsReducer.Action.setWorkSound))) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(viewStore.settings.workSound.description)")
                                Text("Work Session")
                                    .font(.caption)
                            }.padding([.top, .bottom], 2)
                        }
                    NavigationLink(destination: NotificationSoundPickerView(selection: viewStore.binding(get: { Optional.some($0.settings.breakSound) }, send: ClassicSettingsReducer.Action.setBreakSound))) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewStore.settings.breakSound.description)")
                            Text("Break Session")
                                .font(.caption)
                        }.padding([.top, .bottom], 2)
                    }

                } else {
                    ForEach(NotificationSound.nonProSounds) { sound in
                        HStack {
                            Text("\(sound.description)")
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(UIColor.label.asColor)
                                .isHidden(viewStore.settings.workSound != sound)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.setNotificationSound(sound))
                        }
                    }
            }
        }
    }
}

struct NotificationSoundSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("notification sound") {
                NotificationSoundSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(
                            timer: TomatoTimer(),
                            settings: Settings(purchasedPro: false)
                        ),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
            Section("notification sound pro") {
                NotificationSoundSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(
                            timer: TomatoTimer(),
                            settings: Settings(purchasedPro: true)
                        ),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
        }
        .listStyle(.insetGrouped)
        .listRowSeparator(.automatic)

    }
}
