import SwiftUI
import ComposableArchitecture

struct SelectTitleAndImageSectionView: View {

    // MARK: - Properties

    enum Field: Equatable {
        case timerName
    }

    let store: StoreOf<CreateFocusProjectReducer>
    @State var firstAppear = true
    @State var editing: Bool = false
    @FocusState var focus: Field?

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section("Title & Image") {
                VStack {
                    Button(action: { }) {
                        ZStack {
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(viewStore.project.themeColor.asColor)
                                .shadow(radius: 10.0)
                            Text("\(viewStore.project.emoji)")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }

                    }
                    .editableText(viewStore.binding(get: \.project.emoji, send: { .setEmoji($0) }), $editing)
                    .padding([.bottom, .top], 8)

                    TextField(
                        "Timer Name",
                        text: viewStore.binding(get: \.project.title, send: { .setTitle($0) })
                    )
                    .focused($focus, equals: .timerName)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .bold()
                    .frame(height: 55)
                    .background(UIColor.label.withAlphaComponent(0.07).asColor)
                    .foregroundColor(UIColor.label.asColor)
                    .cornerRadius(10)
                    .padding(8)
                }
                .contentShape(Rectangle())
            }
            .onAppear {
                if firstAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
                       // focus = .timerName
                    }
                    firstAppear = false
                }
            }
            .onTapGestureSimultaneous {
                editing = false
            }
        }
    }
}

// MARK: - Previews

struct SelectTitleAndImageSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectTitleAndImageSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
