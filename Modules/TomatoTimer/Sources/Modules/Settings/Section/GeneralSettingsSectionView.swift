import SwiftUI
import ComposableArchitecture
import SFSafeSymbols

struct GeneralSettingsSectionView: View {

    // MARK: - Properties

    let store: StoreOf<SettingsTabReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("General") {
//                ListRowView(
//                    title: "Notifications",
//                    icon: .appBadgeFill,
//                    iconBackground: UIColor.appPomodoroRed.asColor,
//                    accessory: .chevron
//                )
                ListRowView(
                    title: "iCloud Sync",
                    icon: .arrowClockwiseIcloudFill,
                    iconBackground: .blue,
                    accessory: .chevron
                )
                .onTapGesture {
                    viewStore.send(.iCloudSyncSettingsRowPressed)
                }
                ListRowView(
                    title: "Advanced",
                    icon: .gearshape2Fill,
                    iconBackground: UIColor.appGray.asColor,
                    accessory: .chevron
                )
                .onTapGesture {
                    viewStore.send(.advancedSettingsRowPressed)
                }
            }
        }
    }
}

struct GeneralSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            GeneralSettingsSectionView(
                store: Store(
                    initialState: SettingsTabReducer.State(),
                    reducer: SettingsTabReducer()
                )
            )
        }
    }
}
