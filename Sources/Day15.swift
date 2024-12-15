import Foundation

public enum Day15 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.extractLanternfishRobotData
                .completeMoves()
                .allBoxes
                .map(\.gps)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
           -1
        }
    }
}

enum LanternRobotError: Error {
    case noMoreMoves
}

struct LanternWarehouse {
    var robotMoves: String
    var grid: [[Character]]

    func completeMoves() -> [[Character]] {
        var wharehouse = self
        while true {
            do {
                wharehouse = try wharehouse.attemptMove()
            } catch LanternRobotError.noMoreMoves {
                break
            } catch {
                assertionFailure("Unexpected error completing moves: \(error)")
            }
        }
        return wharehouse.grid
    }

    func attemptMove() throws -> LanternWarehouse {
        guard !isComplete else { throw LanternRobotError.noMoreMoves }
        guard canMoveToNextPosition else { return skipMove }
        var newGrid = grid

        if isBoxAtNextPosition {
            let nextChars = charactersInFrontOfRobot
            guard nextChars.hasEmptySpaces else { return skipMove }
            let pushedChars = nextChars.pushBoxes
            var steps = 2
            for char in pushedChars {
                newGrid[nextPosition(plus: steps)] = char
                steps += 1
            }
        }
        newGrid[currentPosition] = "."
        newGrid[nextPosition] = "@"

        return LanternWarehouse(
            robotMoves: String(robotMoves.dropFirst()),
            grid: newGrid
        )
    }

    var skipMove: LanternWarehouse {
        LanternWarehouse(
            robotMoves: String(robotMoves.dropFirst()),
            grid: grid
        )
    }

    var isComplete: Bool {
        robotMoves.count == 0
    }

    var currentPosition: Coordinates {
        grid.findCoordinates(for: "@")[0]
    }

    var isBoxAtNextPosition: Bool {
        grid.charAt(nextPosition) == "O"
    }

    var canMoveToNextPosition: Bool {
        let next = nextPosition
        if grid.charAt(next) == "#" {
            return false
        }
        return true
    }

    var charactersInFrontOfRobot: [Character] {
        var nextChars: [Character] = []
        var steps = 1
        while true {
            let char = grid.charAt(nextPosition(plus: steps))
            if char == "#" {
                break
            }
            nextChars.append(char)
            steps += 1
        }
        return nextChars
    }

    var nextPosition: Coordinates {
        nextPosition(plus: 1)
    }

    func nextPosition(plus value: Int) -> Coordinates {
        switch nextMove {
        case "^": currentPosition.up(by: value)
        case "v": currentPosition.down(by: value)
        case "<": currentPosition.left(by: value)
        case ">": currentPosition.right(by: value)
        default: preconditionFailure("Unexpected move \(nextMove)")
        }
    }

    var nextMove: Character {
        robotMoves.first!
    }
}

extension Coordinates {
    // The GPS coordinate of a box is equal to 100 times its distance from the top edge of the map plus its distance from the left edge of the map. (This process does not stop at wall tiles; measure all the way to the edges of the map.)
    var gps: Int {
        100 * y + x
    }
}

extension Array where Element == [Character] {
    var allBoxes: [Coordinates] {
        findCoordinates(for: "O")
    }
}

extension Array where Element == Character {
    var hasEmptySpaces: Bool {
        contains(".")
    }

    var pushBoxes: [Character] {
        var copy = self
        if self[1] == "." {
            copy[1] = "O"
        } else {
            let spaceIndex = firstIndex(of: ".")!
            var index = spaceIndex
            while index > 0 {
                copy[index] = copy[index - 1]
                index -= 1
            }
        }
        copy.removeFirst()
        return copy
    }
}

extension String {
    var extractLanternfishRobotData: LanternWarehouse {
        let data = splitByEmptyLines
        let grid = data[0].grid
        let moves = String(data[1].replacingOccurrences(of: "\n", with: ""))
        return LanternWarehouse(robotMoves: moves, grid: grid)
    }
}
