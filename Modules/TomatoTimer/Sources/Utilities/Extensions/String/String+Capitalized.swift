import Foundation

extension String {
    var capitalizingFirstLetter: String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
}
