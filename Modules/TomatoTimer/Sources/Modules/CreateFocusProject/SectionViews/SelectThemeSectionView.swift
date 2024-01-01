import SwiftUI
import ComposableArchitecture

struct SelectThemeSectionView: View {

    // MARK: - Definitions

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("Theme") {
                HStack(spacing: 14) {
                    ForEach(0..<6) { index in
                        ThemeColorView(
                            UIColor.themeColors[index],
                            isSelected: UIColor.themeColors[index].hexString() == viewStore.project.themeColor.hexString()
                        ).gesture(TapGesture().onEnded {
                            viewStore.send(.selectedThemeColor(UIColor.themeColors[index]))
                        })
                    }
                }

                HStack(spacing: 14) {
                    ForEach(6..<12) { index in
                        ThemeColorView(
                            UIColor.themeColors[index],
                            isSelected: UIColor.themeColors[index].hexString() == viewStore.project.themeColor.hexString()
                        ).gesture(TapGesture().onEnded {
                            viewStore.send(.selectedThemeColor(UIColor.themeColors[index]))
                        })
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
    }
}

// MARK: - Previews

struct SelectThemeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectThemeSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}

// MARK: - Helper

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
                .frame(width: 40, height: 40)
                .scaleEffect(0.75)
            .foregroundColor(color)
        }
    }
}
