import Foundation

public enum Day10 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            let grid = data.grid
            let peakCoordinates = grid.findCoordinates(for: "9")
            return grid.trailheads.map { coordinate in
                let paths = grid.paths(for: coordinate)
                let trailheadScore = peakCoordinates.filter { coordinates in
                    !paths.filter { $0.contains(coordinates) }.isEmpty
                }.count
                return trailheadScore
            }.reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            let grid = data.grid
            return grid.trailheads
                .map { grid.paths(for: $0).count }
                .reduce(0, +)
        }
    }
}

extension String {
    var trailheads: [Coordinates] {
        grid.trailheads
    }
}

struct TrailStep: Hashable {
    let number: Character
    let coordinates: Coordinates
}

extension Array where Element == [Character] {
    static let pathSequence = [Character]("0123456789")

    var trailheads: [Coordinates] {
        findCoordinates(for: "0")
    }

    func paths(for trailhead: Coordinates) -> [[Coordinates]] {
        paths(for: "0", at: trailhead)
    }

    func paths(for number: Character, at coordinates: Coordinates) -> [[Coordinates]] {
        let pathSequence = Self.pathSequence
        let pathSequenceIndex = pathSequence.firstIndex(of: number)!
        var currentCoordinates = coordinates
        var path: [Coordinates] = [coordinates]
        for number in pathSequence[pathSequenceIndex...] {
            if number == "9" { break }
            let options = options(for: number, at: currentCoordinates)
            if options.isEmpty { return [] }
            if options.count == 1 {
                currentCoordinates = options[0]
                path.append(currentCoordinates)
            }
            if options.count > 1 {
                var optionPaths = [[Coordinates]]()
                for option in options {
                    let pathTails = paths(for: next(from: number)!, at: option)
                    for pathTail in pathTails {
                        optionPaths.append(pathTail)
                    }
                }
                return optionPaths.map { path + $0 }
            }
        }
        return [path]
    }

    func next(from character: Character) -> Character? {
        guard character != "9" else { return nil }
        let index = Self.pathSequence.firstIndex(of: character)!
        return Self.pathSequence[index + 1]
    }

    func options(for number: Character, at coordinates: Coordinates) -> [Coordinates] {
        let nextCharacter = next(from: number)
        var options = [Coordinates]()
        if coordinates.x - 1 >= 0 {
            if self[coordinates.y][coordinates.x - 1] == nextCharacter {
                options.append(Coordinates(x: coordinates.x - 1, y: coordinates.y))
            }
        }
        if coordinates.x + 1 <= maxX {
            if self[coordinates.y][coordinates.x + 1] == nextCharacter {
                options.append(Coordinates(x: coordinates.x + 1, y: coordinates.y))
            }
        }
        if coordinates.y - 1 >= 0 {
            if self[coordinates.y - 1][coordinates.x] == nextCharacter {
                options.append(Coordinates(x: coordinates.x, y: coordinates.y - 1))
            }
        }
        if coordinates.y + 1 <= maxY {
            if self[coordinates.y + 1][coordinates.x] == nextCharacter {
                options.append(Coordinates(x: coordinates.x, y: coordinates.y + 1))
            }
        }
        return options
    }
}
