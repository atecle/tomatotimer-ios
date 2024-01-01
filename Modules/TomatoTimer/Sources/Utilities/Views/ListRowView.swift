import SwiftUI
import SFSafeSymbols

struct ListRowView: View {

    enum Accessory: Equatable {
        case checkmark
        case chevron
        case none
        var isNone: Bool { self == .none }

        var symbol: SFSymbol? {
            switch self {
            case .checkmark: return .checkmark
            case .chevron: return .chevronRight
            case .none: return nil
            }
        }
    }

    // MARK: - Properties

    let title: String
    let titleColor: Color
    let subtitle: String
    let icon: SFSymbol
    let iconBackground: Color
    let accessory: Accessory
    let showPlusFeature: Bool
    private let bold: Bool

    // MARK: - Methods

    init(
        title: String = "List Row Title",
        titleColor: Color = UIColor.label.asColor,
        subtitle: String = "",
        icon: SFSymbol = .clockFill,
        iconBackground: Color = UIColor.appPomodoroRed.asColor,
        accessory: Accessory = .none,
        showPlusFeature: Bool = false,
        bold: Bool = false
    ) {
        self.title = title
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.icon = icon
        self.iconBackground = iconBackground
        self.accessory = accessory
        self.showPlusFeature = showPlusFeature
        self.bold = bold
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: 8) {
            RowIcon(icon: icon, iconBackground: iconBackground)
                .padding([.top, .bottom], 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .bold(!subtitle.isEmpty || bold)
                    .foregroundColor(titleColor)
                Text(subtitle)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .isHidden(subtitle.isEmpty, remove: true)
            }
            Spacer()
            Image(systemSymbol: .starCircleFill)
                .isHidden(!showPlusFeature, remove: true)
            if let symbol = accessory.symbol {
                Image(systemSymbol: symbol)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowView(
                title: "iCloud Sync",
                icon: .arrowClockwiseIcloudFill,
                iconBackground: .blue,
                accessory: .chevron
            )
        }
    }
}
