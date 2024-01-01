import Foundation

extension Array where Element: Equatable {
    func next(startingAt element: Element, where condition: @escaping ((Element) -> Bool)) -> Element? {
        guard let startIndex = firstIndex(of: element) else { return nil }
        var curr = startIndex + 1
        var startedAgain = false
        while true {
            if curr > count - 1 && startedAgain == false {
                curr = 0
                startedAgain = true
                continue
            } else if curr > count - 1 && startedAgain == true {
                break
            }

            let item = self[curr]
            if condition(item) {
                return item
            }

            curr += 1
        }

        return nil
    }

    func nextIndex(startingAt startIndex: Int, where condition: @escaping ((Element) -> Bool)) -> Int? {
        guard self.indices.contains(startIndex) else { return nil }
        var curr = startIndex + 1
        var startedAgain = false
        while true {
            if curr > count - 1 && startedAgain == false {
                curr = 0
                startedAgain = true
                continue
            } else if curr > count - 1 && startedAgain == true {
                break
            }

            let task = self[curr]
            if condition(task) {
                return curr
            }

            curr += 1
        }

        return nil
    }
}
