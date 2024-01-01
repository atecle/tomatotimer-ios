import Foundation
import SwiftUI

class UIKeyboardAccessoryTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

struct KeyboardAccessoryTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""

    func makeUIView(context: Context) -> UIKeyboardAccessoryTextField {
        let textField = UIKeyboardAccessoryTextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.font = UIFont.preferredFont(forTextStyle: .title2)
        textField.delegate = context.coordinator
        textField.textColor = .clear
        return textField
    }

    func updateUIView(_ uiView: UIKeyboardAccessoryTextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KeyboardAccessoryTextField

        init(parent: KeyboardAccessoryTextField) {
            self.parent = parent
        }
    }
}
