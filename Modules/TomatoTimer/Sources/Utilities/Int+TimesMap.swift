import Foundation

extension Int {
    func timesMap<A>(_ f: (Int) -> (A)) -> [A] {
        var array: [A] = []
        if self > 0 {
            for count in 0..<self {
                array.append(f(count))
            }
        }
        return array
    }
}
