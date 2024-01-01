import SwiftUI
import SFSafeSymbols

struct ToggleSettingsRow: View {

    let text: String
    let isOn: Binding<Bool>
    let icon: SFSymbol
    let iconBackground: Color

    var body: some View {
        HStack {
            Toggle(isOn: isOn) {
                HStack {
                    Image(systemSymbol: icon)
                        .padding(12)
                        .background(iconBackground)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Text(text)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

struct ToggleSettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ToggleSettingsRow(
                text: "Classic Mode",
                isOn: Binding.constant(true),
                icon: .iphone,
                iconBackground: UIColor.appIndigo.asColor
            )
        }
    }
}
