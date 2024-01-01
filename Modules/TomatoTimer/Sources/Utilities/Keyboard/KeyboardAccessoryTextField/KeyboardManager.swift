import Foundation
import SwiftUI

// An epsilon needed to publish keyboard height changes
// after the current layout pass is complete (seconds).
let kKeyboardNotificationEpsilon = 0.000
// Standard duration for accessory view exit (seconds).
let kKeyboardAccessoryAnimationDuration = 0.00

class KeyboardManager: ObservableObject {
    // A keyboard accessory view that will render above the
    // keyboard when activated. May be set to arbitrary views.
    @Published var accessory: (() -> AnyView)?
    // Indicates the current height of the keyboard, if active.
    @Published var isKeyboardActive: Bool = false
    // Initialize by observing future keyboard notifications.
    init() { self.observeKeyboardNotifications() }
    // A method that listens to the height of the keyboard,
    // so that we can reason about where to place overlays.
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
                // swiftlint:disable:next force_cast
                let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) {
                    withAnimation(.easeInOut(duration: keyboardDuration)) { [weak self] in
                        self?.isKeyboardActive = true
                    }
                }
            }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) {
                    withAnimation(.easeInOut(duration: kKeyboardAccessoryAnimationDuration)) { [weak self] in
                        self?.isKeyboardActive = false
                    }
                }
            }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + kKeyboardNotificationEpsilon) { [weak self] in
                    self?.clearAccessory()
                }
            }
    }

    func addAccessory(layer: @escaping (() -> AnyView)) {
        accessory = layer
    }

    func clearAccessory() {
        withAnimation(.easeOut(duration: kKeyboardAccessoryAnimationDuration)) {
            self.accessory = nil
        }
    }
}
