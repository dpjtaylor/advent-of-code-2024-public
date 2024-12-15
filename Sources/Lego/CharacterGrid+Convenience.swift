import Foundation

extension Array where Element == [Character] {
    func walk(performing action: (_ x: Int, _ y: Int, _ char: Character) -> Void) {
        for (y, row) in enumerated() {
            for (x, char) in row.enumerated() {
                action(x, y, char)
            }
        }
    }

    var rotatedClockwise: [[Character]] {
        var rotatedGrid = self
        let maxY = self.count - 1
        for (y, row) in enumerated() {
            for (x, char) in row.enumerated() {
                let coords = (maxY - y, x)
                rotatedGrid[coords.1][coords.0] = char
            }
        }
        return rotatedGrid
    }

    func rotateDiagonals(clockwise: Bool) -> [[Character]] {
        let width = self[0].count
        let height = count
        let maxY = self.count - 1
        let diagnonalLength = Int((sqrt(Double(width * height))).rounded(.down))
        var rotatedGrid = [[Character]](repeating: [Character](repeating: "-", count: diagnonalLength), count: width + maxY)
        for (y, row) in enumerated() {
            for (x, char) in row.enumerated() {
                let coords = if clockwise {
                    (x, x + y)
                } else {
                    (x, y + maxY - x)
                }
                rotatedGrid[coords.1][coords.0] = char
            }
        }
        return rotatedGrid
    }

    var toString: String {
        var string = ""
        for row in self {
            for char in row {
                string += String(char)
            }
            string += "\n"
        }
        string.removeLast() // trail "\n"
        return string
    }

    var toStringArray: [String] {
        var strings = [String]()
        for row in self {
            var string = ""
            for char in row {
                string += String(char)
            }
            strings.append(string)
        }
        return strings
    }

    func debug() {
        for row in self {
            var rowString = ""
            for character in row {
                rowString = rowString + "\(character) "
            }
            print(rowString)
        }
    }

    var maxX: Int {
        self[0].count - 1
    }

    var maxY: Int {
        self.count - 1
    }
}
