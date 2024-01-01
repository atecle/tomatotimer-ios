import Foundation
import SwiftUI
import ComposableArchitecture
import UIColorHexSwift

// swiftlint:disable line_length
struct ThemeColorSettingsSectionView: View {
    let store: StoreOf<ClassicSettingsReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {

                HStack(spacing: 14) {
                    /// ColorView(color, isSelected)
                    ForEach(0..<4) { index in
                        ThemeColorView(
                            UIColor.themeColors[index],
                            isSelected: UIColor.themeColors[index].hexString() == viewStore.settings.themeColor.hexString()
                        ).gesture(TapGesture().onEnded {
                            viewStore.send(.setThemeColor(UIColor.themeColors[index]))
                        })
                    }
                }

                HStack(spacing: 14) {
                    /// ColorView(color, isSelected)
                    ForEach(4..<8) { index in
                        ThemeColorView(
                            UIColor.themeColors[index],
                            isSelected: UIColor.themeColors[index].hexString() == viewStore.settings.themeColor.hexString()
                        ).gesture(TapGesture().onEnded {
                            viewStore.send(.setThemeColor(UIColor.themeColors[index]))
                        })
                    }
                }

                HStack(spacing: 14) {
                    /// ColorView(color, isSelected)
                    ForEach(8..<12) { index in
                        ThemeColorView(
                            UIColor.themeColors[index],
                            isSelected: UIColor.themeColors[index].hexString() == viewStore.settings.themeColor.hexString()
                        ).gesture(TapGesture().onEnded {
                            viewStore.send(.setThemeColor(UIColor.themeColors[index]))
                        })
                    }
                }

                if viewStore.settings.purchasedPro {
                    HStack {
                        SwiftUI.ColorPicker(
                            selection: viewStore.binding(
                                get: {
                                    $0.settings.usingCustomColor
                                    ? $0.settings.themeColor.asColor
                                    : UIColor.systemBackground.asColor

                                },
                                send: { ClassicSettingsReducer.Action.setCustomThemeColor(UIColor($0)) }),
                            supportsOpacity: false
                        ) {
                            Text("Custom color")
                                .foregroundColor(UIColor.label.asColor)
                            Text("\(viewStore.settings.usingCustomColor ? "\((try? viewStore.settings.themeColor.hexStringThrows()) ?? UIColor.white.hexString())" : "inactive")")
                                .foregroundColor(UIColor.label.asColor)
                        }
                    }

                }
            }
            .frame(height: 200)
            .padding()
            .animation(.linear(duration: 0.045), value: UUID())
        }
    }
}

struct ThemeColorSettingsSectionView_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section("theme color") {
                ThemeColorSettingsSectionView(
                    store: Store(
                        initialState: ClassicSettingsReducer.State(
                            timer: TomatoTimer(),
                            settings: Settings(usingCustomColor: true, purchasedPro: true)
                        ),
                        reducer: ClassicSettingsReducer()
                    )
                )
            }
        }
    }
}

private struct ThemeColorView: View {
    let color: Color
    let isSelected: Bool

    init(_ color: UIColor, isSelected: Bool) {
        self.color = color.asColor
        self.isSelected = isSelected
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(UIColor.label.withAlphaComponent(0.2).asColor, lineWidth: 3)
                .isHidden(isSelected == false)
            Circle()
                .scaleEffect(0.75)
                .foregroundColor(color)
        }
    }
}
