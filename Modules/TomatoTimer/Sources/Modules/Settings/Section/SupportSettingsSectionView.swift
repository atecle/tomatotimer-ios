import SwiftUI
import ComposableArchitecture

struct SupportSettingsSectionView: View {

    // MARK: - Properties

    let store: StoreOf<SettingsTabReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            Section("Support") {
                ListRowView(
                    title: "Rate Tomato Timer",
                    icon: .heartFill,
                    iconBackground: UIColor.appPomodoroRed.asColor
                )
                .onTapGesture {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id1453228755") {
                        UIApplication.shared.open(url)

                    }
                }
                ListRowView(
                    title: "Help & Feedback",
                    icon: .envelopeFill,
                    iconBackground: UIColor.appOrange.asColor
                )
                .onTapGesture {
                    if
                        let urlString = "mailto:support@tomatotimerapp.com"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

struct SupportSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SupportSettingsSectionView(
                store: Store(
                    initialState: SettingsTabReducer.State(),
                    reducer: SettingsTabReducer()
                )
            )
        }
    }
}
