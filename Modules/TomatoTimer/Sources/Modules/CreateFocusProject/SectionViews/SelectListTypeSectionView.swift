import SwiftUI
import ComposableArchitecture
import SFSafeSymbols

struct SelectListTypeSectionView: View {

    // MARK: - Definitions

    let store: StoreOf<CreateFocusProjectReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                ListRowView(
                    title: viewStore.project.list.title,
                    subtitle: viewStore.project.list.description,
                    icon: viewStore.project.list.symbol,
                    iconBackground: .blue,
                    accessory: .chevron
                )
                .onTapGesture {
                    viewStore.send(.listTypeRowPressed)
                }
                .foregroundColor(
                    UIColor.label.asColor.opacity(
                        viewStore.isEditing ? 0.2 : 1
                    )
                )
                .disabled(viewStore.isEditing)
                .opacity(viewStore.isEditing ? 0.75 : 1)
            } header: {
                Text("List Type")
            } footer: {
                Text("You can't edit list type after the project has been created.")
                    .isHidden(!viewStore.isEditing, remove: true)
            }

        }
    }
}

// MARK: - Previews

struct SelectListTypeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectListTypeSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}

// MARK: - Helper

extension FocusList {
    var symbol: SFSymbol {
        switch self {
        case .standard:
            return .listBullet
        case .session:
            return .clockBadgeCheckmarkFill
        case .singleTask:
            return ._1CircleFill
        case .none:
            return .slashCircle
        }
    }
}
