import Foundation
import SwiftUI

struct TapGestureKeyboardAccessoryShowing: ViewModifier {

    @Binding var text: String
    var placeholder: String
    @StateObject var keyboardManager: KeyboardManager
    var onCommit: (String) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                KeyboardAccessoryTextField(text: $text)
                    .foregroundColor(.clear)
                    .frame(width: 1, height: 1)
            )
            .onTapGestureSimultaneous {
                keyboardManager.addAccessory {
                    AnyView(
                        TextFieldAccessoryView(
                            value: $text,
                            placeholder: placeholder,
                            type: .default,
                            onCommit: onCommit
                        )
                    )
                }
            }
    }
}

struct TapGestureKeyboardAccessoryShowingNonSim: ViewModifier {

    @Binding var text: String
    var placeholder: String
    @StateObject var keyboardManager: KeyboardManager
    var onCommit: (String) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                KeyboardAccessoryTextField(text: $text)
                    .foregroundColor(.clear)
                    .frame(width: 1, height: 1)
            )
            .onTapGesture {
                keyboardManager.addAccessory {
                    AnyView(
                        TextFieldAccessoryView(
                            value: $text,
                            placeholder: placeholder,
                            type: .default,
                            onCommit: onCommit
                        )
                    )
                }
            }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    func textPlaceholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder overlay: () -> Content) -> some View {
            ZStack(alignment: .leading) {
                self
                overlay().opacity(shouldShow ? 1 : 0).allowsHitTesting(false)
            }
        }

    func withKeyboardManager(keyboardManager: KeyboardManager) -> some View {
        KeyboardAccessoryLayerView(presenting: { self }, keyboardManager: keyboardManager)
    }

    func onTapGestureShowKeyboard(
        text: Binding<String>,
        placeholder: String,
        keyboardManager: KeyboardManager,
        onCommit: @escaping (String) -> Void
    ) -> some View {
        modifier(
            TapGestureKeyboardAccessoryShowing(
                text: text,
                placeholder: placeholder,
                keyboardManager: keyboardManager,
                onCommit: onCommit
            )
        )
    }

    func onTapGestureShowKeyboardNonSim(
        text: Binding<String>,
        placeholder: String,
        keyboardManager: KeyboardManager,
        onCommit: @escaping (String) -> Void
    ) -> some View {
        modifier(
            TapGestureKeyboardAccessoryShowingNonSim(
                text: text,
                placeholder: placeholder,
                keyboardManager: keyboardManager,
                onCommit: onCommit
            )
        )
    }
}
