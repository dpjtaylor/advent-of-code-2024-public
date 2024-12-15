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
            let warehouse = data.extractLanternfishRobotData(isDoubleWidth: true)
            return warehouse
                .completeMoves()
                .allDoubleWidthBoxes
                .map { $0.gps(gridWidth: warehouse.gridWidth, gridHeight: warehouse.gridHeight) }
                .reduce(0, +)
        }
    }
}

enum LanternRobotError: Error {
    case noMoreMoves
}

struct LanternWarehouseBox: Equatable {
    let leftCoords: Coordinates

    var rightCoords: Coordinates {
        Coordinates(x: leftCoords.x + 1, y: leftCoords.y)
    }

    // I originally interpreted "distances are measured from the edge of the map to the closest edge of the box in question" as meaning if the right edge of the box was the closer to the right edge of the map, than the left edge was to the left edge of the map, then we should use the distance to "]"
    //
    // it turns out it was simpler, and just meant the "[" part of the box, which makes more sense as a GPS-like thing
    func gps(gridWidth: Int, gridHeight: Int) -> Int {
        100 * leftCoords.y + leftCoords.x
    }
}

struct LanternWarehouse {
    let robotMoves: String
    let grid: [[Character]]
    let isDoubleWidth: Bool

    init(robotMoves: String, grid: [[Character]], isDoubleWidth: Bool = false) {
        self.robotMoves = robotMoves
        self.grid = grid
        self.isDoubleWidth = isDoubleWidth
    }

    func completeMoves() -> [[Character]] {
        var warehouse = self
        while true {
            do {
                if isDoubleWidth {
                    warehouse = try warehouse.attemptMoveDoubleWidth()
                } else {
                    warehouse = try warehouse.attemptMove()
                }
            } catch LanternRobotError.noMoreMoves {
                break
            } catch {
                assertionFailure("Unexpected error completing moves: \(error)")
            }
        }
        return warehouse.grid
    }

    func attemptMoveDoubleWidth() throws -> LanternWarehouse {
        guard !isComplete else { throw LanternRobotError.noMoreMoves }
        guard canMoveToNextPosition else { return skipMove }
        var newGrid = grid
        let robotPosition = currentPosition
        let robotNext = nextPosition
        let xModifier = robotNext.x - robotPosition.x
        let yModifier = robotNext.y - robotPosition.y

        if isBoxAtNextPosition {
            if yModifier != 0 {
                let boxesToPush = nextMoveBoxesToPush
                guard !boxesToPush.isEmpty else { return skipMove }
                for box in boxesToPush.reversed() { // reversed so we can set previous positions to "." safely (if we did it the other way around we could overright boxes)
                    let boxX = box.leftCoords.x
                    let boxY = box.leftCoords.y
                    newGrid[boxY + yModifier][boxX] = "["
                    newGrid[boxY + yModifier][boxX + 1] = "]"
                    newGrid[boxY][boxX] = "."
                    newGrid[boxY][boxX + 1] = "."
                }
            }
            if xModifier != 0 {
                let nextChars = charactersInFrontOfRobot
                guard nextChars.hasEmptySpaces else { return skipMove }
                let pushedChars = nextChars.pushBoxes
                var steps = 2
                for char in pushedChars {
                    newGrid[nextPosition(plus: steps)] = char
                    steps += 1
                }
            }
        }
        newGrid[currentPosition] = "."
        newGrid[nextPosition] = "@"

        return LanternWarehouse(
            robotMoves: String(robotMoves.dropFirst()),
            grid: newGrid
        )
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
        ["O", "[", "]"].contains(grid.charAt(nextPosition))
    }

    var canMoveToNextPosition: Bool {
        let next = nextPosition
        if grid.charAt(next) == "#" {
            return false
        }
        return true
    }

    var nextMoveBoxesToPush: [LanternWarehouseBox] {
        guard let firstBox = boxInFrontOfRobot else { return [] }
        var boxesToPush: [[LanternWarehouseBox]] = [[firstBox]]
        var steps = 1
        while true {
            let previousBoxesPushed = boxesToPush.last!
            let next = nextPosition(plus: steps)
            let nextWallsHit = grid[next.y]
                .enumerated()
                .filter { $1 == "#" }
                .compactMap(\.offset)
                .filter { x in
                    previousBoxesPushed.contains { $0.hitsWallInNextRow(with: x)}
                }
            if nextWallsHit.count > 0 {
                return []
            }
            let nextBoxesPushed = grid[next.y]
                .enumerated()
                .filter { $1 == "[" }
                .compactMap(\.offset)
                .filter { x in
                    previousBoxesPushed.contains { $0.pushesBoxInNextRow(with: x) }
                }
                .map { LanternWarehouseBox(leftCoords: Coordinates(x: $0, y: next.y))}
            if nextBoxesPushed.isEmpty {
                break
            }
            if steps > 1 {
                boxesToPush.append(nextBoxesPushed)
            }
            steps += 1
        }
        return boxesToPush.flatMap(\.self)
    }

    var boxInFrontOfRobot: LanternWarehouseBox? {
        let next = nextPosition
        let char = grid.charAt(next)
        if char == "#" || char == "." { return nil }
        if char == "[" {
            return LanternWarehouseBox(leftCoords: Coordinates(x: next.x, y: next.y)
            )
        }
        if char == "]" {
            return LanternWarehouseBox(leftCoords: Coordinates(x: next.x - 1, y: next.y)
            )
        }
        return nil
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

    var gridWidth: Int {
        grid.maxX + 1
    }

    var gridHeight: Int {
        grid.maxY + 1
    }
}

extension LanternWarehouseBox {
    // ##############
    // ##......##..##
    // ##...[].....##
    // ##...[][]...##  -> leftX = x - 1 || leftX == x || leftX == x + 1
    // ##....[]....##
    // ##.....@....##
    // ##############
    func pushesBoxInNextRow(with leftX: Int) -> Bool {
        switch leftX {
        case (leftCoords.x - 1)...(leftCoords.x + 1): return true
        default: return false
        }
    }

    func hitsWallInNextRow(with leftX: Int) -> Bool {
        switch leftX {
        case leftCoords.x...(leftCoords.x + 1): return true
        default: return false
        }
    }
}

extension Coordinates {
    var gps: Int {
        100 * y + x
    }
}

extension Array where Element == [Character] {
    var allBoxes: [Coordinates] {
        findCoordinates(for: "O")
    }

    var allDoubleWidthBoxes: [LanternWarehouseBox] {
        findCoordinates(for: "[").map(LanternWarehouseBox.init)
    }
}

extension Array where Element == Character {
    var hasEmptySpaces: Bool {
        contains(".")
    }

    var pushBoxes: [Character] {
        guard self[0] != "." else {
            return self.dropFirst().map(Character.init)
        }
        var copy = self
        let spaceIndex = firstIndex(of: ".")!
        var index = spaceIndex
        while index > 0 {
            copy[index] = copy[index - 1]
            index -= 1
        }
        copy.removeFirst()
        return copy
    }
}

extension String {
    var extractLanternfishRobotData: LanternWarehouse {
        extractLanternfishRobotData(isDoubleWidth: false)
    }

    func extractLanternfishRobotData(isDoubleWidth: Bool) -> LanternWarehouse {
        var copy = self
        if isDoubleWidth {
            copy = copy.replacingOccurrences(of: "#", with: "##")
            copy = copy.replacingOccurrences(of: "O", with: "[]")
            copy = copy.replacingOccurrences(of: ".", with: "..")
            copy = copy.replacingOccurrences(of: "@", with: "@.")
        }
        let data = copy.splitByEmptyLines
        let grid = data[0].grid
        let moves = String(data[1].replacingOccurrences(of: "\n", with: ""))
        return LanternWarehouse(robotMoves: moves, grid: grid, isDoubleWidth: isDoubleWidth)
    }
}
