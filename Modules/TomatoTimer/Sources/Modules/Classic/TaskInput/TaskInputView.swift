import SwiftUI
import ComposableArchitecture
import UITextView_Placeholder

struct TaskInputView: View {

    // MARK: - Definitions

    private enum ActiveTextField: Int, Hashable, Equatable {
        case taskInput
    }

    // MARK: - Properties

    @FocusState private var activeTextInput: ActiveTextField?
    @SwiftUI.Environment(\.dismiss) var dismiss
    let store: StoreOf<TaskInputReducer>

    init(store: StoreOf<TaskInputReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                BackgroundColorView(color: viewStore.themeColor) {
                    VStack {
                        TextView(
                            text: viewStore.binding(
                                get: \.enteredText,
                                send: { .setEnteredText($0) }
                            )
                        ) {
                            $0.text = viewStore.enteredText
                            $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                            $0.textColor = viewStore.themeColor.complementaryColor
                            $0.placeholder = "What are you working on?"
                            $0.placeholderColor = viewStore.themeColor.complementaryColor.withAlphaComponent(0.5)
                            $0.placeholderTextView.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                            $0.backgroundColor = .clear
                        }
                        .padding()
                        .focused($activeTextInput, equals: .taskInput)
                        .tint(viewStore.themeColor.complementaryColor.asColor)
                        .foregroundColor(viewStore.themeColor.complementaryColor.asColor)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: dismiss.callAsFunction) {
                                Image(systemName: "xmark")
                                    .foregroundColor(viewStore.themeColor.complementaryColor.asColor)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewStore.send(.setTask(viewStore.enteredText))
                                dismiss()
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(viewStore.themeColor.complementaryColor.asColor)
                            }
                        }
                    }
                    .onAppear {
                        activeTextInput = .taskInput
                        viewStore.send(.setEnteredText(viewStore.project.currentTaskTitle))
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct TaskInputView_Previews: PreviewProvider {
    static var previews: some View {
        TaskInputView(
            store: Store(
                initialState: TaskInputReducer.State(
                    settings: .init(),
                    project: .init()
                ),
                reducer: TaskInputReducer()
            )
        )
    }
}

// MARK: - Helper

struct TextView: UIViewRepresentable {

    @Binding var text: String
    typealias UIViewType = UITextView
    var configuration = { (_: UIViewType) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        UIViewType()
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
        uiView.delegate = context.coordinator
    }

    func makeCoordinator() -> TextView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
