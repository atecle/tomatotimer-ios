import Foundation
import AudioToolbox
import UIKit

struct HapticFeedbackGenerator {

    static func impactOccurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
