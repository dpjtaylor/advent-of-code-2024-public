import Foundation

extension String {
    func lines() -> [String] {
        split(whereSeparator: \.isNewline).map { String($0) }
    }

    func intComponents() -> [Int] {
        split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .compactMap(Int.init)
    }

    var grid: [[Character]] {
        var grid = [[Character]]()
        for row in lines() {
            grid.append(Array(row))
        }
        return grid
    }
}
