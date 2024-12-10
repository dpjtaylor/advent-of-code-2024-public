import Foundation

public enum Day04 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            let grid = data.grid
            let rotated = grid.rotatedClockwise.toStringArray
            let clockwiseDiagonals = grid.rotateDiagonals(clockwise: true).toStringArray
            let anticlockwiseDiagonals = grid.rotateDiagonals(clockwise: false).toStringArray
            return data.lines().xmasCount +
                rotated.xmasCount +
                clockwiseDiagonals.xmasCount +
                anticlockwiseDiagonals.xmasCount
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.characterGridXmasAs.count
        }
    }
}

struct GridCharacter {
    let northEast: Character?
    let northWest: Character?
    let southEast: Character?
    let southWest: Character?
    let character: Character

    var isXmas: Bool {
        guard character == "A",
              northEast != nil,
              northWest != nil,
              southEast != nil,
              southWest != nil else {
            return false
        }
        return northEastToSouthWest.isMAS && northWestToSouthEast.isMAS
    }

    private var northEastToSouthWest: String {
        "\(northEast!)\(character)\(southWest!)"
    }

    private var northWestToSouthEast: String {
        "\(northWest!)\(character)\(southEast!)"
    }
}

extension String {
    var characterGridXmasAs: [GridCharacter] {
        var charGrid = [GridCharacter]()
        let grid = self.grid
        let maxX = grid.maxX
        let maxY = grid.maxY

        for (y, row) in grid.enumerated() {
            for (x, char) in row.enumerated() where char == "A" {
                var southEast, southWest, northEast, northWest: Character?
                if y + 1 <= maxY {
                    if x + 1 <= maxX {
                        southEast = grid[y + 1][x + 1]
                    }
                    if x - 1 >= 0 {
                        southWest = grid[y + 1][x - 1]
                    }
                }
                if y - 1 >= 0 {
                    if x + 1 <= maxX {
                        northEast = grid[y - 1][x + 1]
                    }
                    if x - 1 >= 0 {
                        northWest = grid[y - 1][x - 1]
                    }
                }
                let gridCharacter = GridCharacter(
                    northEast: northEast,
                    northWest: northWest,
                    southEast: southEast,
                    southWest: southWest,
                    character: char
                )
                if gridCharacter.isXmas {
                    charGrid.append(gridCharacter)
                }
            }
        }
        return charGrid
    }

    var isMAS: Bool {
        self == "MAS" || self == "SAM"
    }

    var xmasCount: Int {
        ranges(of: "XMAS").count + ranges(of: "SAMX").count
    }
}

extension Array where Element == String {
    var xmasCount: Int {
        reduce(0) { $0 + $1.xmasCount }
    }
}
