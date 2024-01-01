import SwiftUI
import ComposableArchitecture

struct OtherSettingsSectionView: View {

    // MARK: - Properties

    let store: StoreOf<SettingsTabReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            Section("Additional") {
//                ListRowView(
//                    title: "Analytics",
//                    icon: .chartBarDocHorizontalFill,
//                    iconBackground: UIColor.appGreen.asColor,
//                    accessory: .chevron
//                )
                ListRowView(
                    title: "Privacy Policy",
                    icon: .handRaisedFill,
                    iconBackground: UIColor.appPurple.asColor,
                    accessory: .none
                )
                .onTapGesture {
                    if let url = URL(string: "https://www.termsfeed.com/live/5f2d0b09-8627-4a7e-aa5d-97aee8af9ab3") {
                        // Ask the system to open that URL.
                        UIApplication.shared.open(url)
                    }
                }
                ListRowView(
                    title: "Terms of Service",
                    icon: .docFill,
                    iconBackground: UIColor.appCyan.asColor,
                    accessory: .none
                )
                .onTapGesture {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                        // Ask the system to open that URL.
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

struct OtherSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            OtherSettingsSectionView(
                store: Store(
                    initialState: SettingsTabReducer.State(),
                    reducer: SettingsTabReducer()
                )
            )
        }
    }
}
