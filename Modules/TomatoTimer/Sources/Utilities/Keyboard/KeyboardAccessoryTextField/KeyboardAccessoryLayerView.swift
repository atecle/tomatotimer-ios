import SwiftUI

struct KeyboardAccessoryLayerView<Presenting>: View where Presenting: View {

    // The parent view that's presenting our keyboard accessory view.
    let presenting: () -> Presenting
    // Our Keyboard Accessory View Manager.
    @StateObject var keyboardManager: KeyboardManager

    var body: some View {
        ZStack(alignment: .center) {
            self.presenting()
            if let accessory = keyboardManager.accessory {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.4))
                    .onTapGesture {
                        dismissKeyboard()
                        keyboardManager.clearAccessory()
                    }
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    accessory()
                        .opacity(keyboardManager.isKeyboardActive ? 1 : 0)
                }
            }
        }
        .environmentObject(keyboardManager)
    }
}
