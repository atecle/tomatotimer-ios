import Foundation
import SwiftUI

struct TextFieldAccessoryView: View {
    // Access to our keyboard manager in the environment. This enables
    // us to define an accessory view throughout the app, but have its
    // presentation hierarchy controlled centrally.
    @EnvironmentObject var keyboardManager: KeyboardManager

    // A binding that stores the value entered by the user into the text field.
    @Binding var value: String

    // Allows us to control whether the binding is updated. Also ensures that our
    // placeholder continues to update even if the value binding is not backed by
    // view state.
    @State var internalValue = ""

    // Used to direct focus to our accessory view.
    @FocusState private var focused: Bool

    // A placeholder that's rendered over the text field when it's empty. This is
    // rendered in two places: (1) over the original tapped text field, and (2) over
    // the accessory view text field (floating above the keyboard).
    var placeholder: String = ""

    // Foreground color (text, border)
    var foregroundColor = Color(red: 100/255.0, green: 100/255.0, blue: 100/255.0)

    // Background color (canvas)
    var backgroundColor = Color.white

    // Accessory bar start color.
    let accessoryStartColor = Color(red: 74.0/255.0, green: 78.0/255.0, blue: 91.0/255.0)

    // Accessory bar end color.
    let accessoryEndColor = Color(red: 59.0/255.0, green: 62.0/255.0, blue: 72.0/255.0)

    // Determines the type of keyboard to display.
    var type: UIKeyboardType = .`default`

    var onCommit: (String) -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            TextField(placeholder, text: $internalValue, axis: .vertical)
                .font(.title2)
                .bold()
                .lineLimit(3)
                .onSubmit {
                    dismissKeyboard()
                    keyboardManager.clearAccessory()
                    onCommit(internalValue)
                }
                .keyboardType(type)
                .multilineTextAlignment(.leading)
                .focused($focused)
                .padding([.top], 8)
                .padding(.horizontal, 10)
                .submitLabel(.done)
                .onChange(of: internalValue) { newValue in
                      guard let newValueLastChar = newValue.last else { return }
                      if newValueLastChar == "\n" {
                          internalValue.removeLast()
                          dismissKeyboard()
                          keyboardManager.clearAccessory()
                          onCommit(internalValue)
                          HapticFeedbackGenerator.impactOccurred(.medium)
                      }
                  }

            Button {
                dismissKeyboard()
                keyboardManager.clearAccessory()
                onCommit(internalValue)
                HapticFeedbackGenerator.impactOccurred(.medium)
            } label: {
                Image(systemSymbol: .arrowUpCircleFill)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white, internalValue.isEmpty ? .gray : .accentColor)
                    .rotationEffect(.init(degrees: internalValue.isEmpty ? -180 : 0))
                    .animation(.spring(response: 0.1, dampingFraction: 0.8, blendDuration: 1), value: internalValue.isEmpty)

            }
        }
        .padding()
        .background(
            UIColor.secondarySystemGroupedBackground.asColor
        )
        .cornerRadius(10, corners: [.topLeft, .topRight])
        .onAppear {
            focused = true
            internalValue = value
        }
        .onDisappear {
            value = internalValue
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
