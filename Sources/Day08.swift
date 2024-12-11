import Foundation

public enum Day08 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.grid.findAntinodes(for: data.antennas).count
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.grid.findAntinodesWithHarmonics(for: data.antennas).count
        }
    }
}

extension String {
    var antennas: Set<Character> {
        var antennas = Set(self)
        antennas.remove(".")
        antennas.remove("\n")
        return antennas
    }
}

private func inverted(_ diff: (xDiff: Int, yDiff: Int)) -> (Int, Int) {
    (-diff.xDiff, -diff.yDiff)
}

extension Coordinates {
    func findAntinodes(with coordinates: Coordinates) -> [Coordinates] {
        let diff = diff(with: coordinates)
        return [
            project(diff),
            coordinates.project(inverted(diff))
        ]
    }

    func diff(with coordinates: Coordinates) -> (xDiff: Int, yDiff: Int) {
        let minX = min(x, coordinates.x)
        let maxX = max(x, coordinates.x)
        let minY = min(y, coordinates.y)
        let maxY = max(y, coordinates.y)

        let xDiff = (maxX - minX) * (x > coordinates.x ? 1 : -1)
        let yDiff = (maxY - minY) * (y > coordinates.y ? 1 : -1)
        return (xDiff, yDiff)
    }

    func project(_ diff: (xDiff: Int, yDiff: Int)) -> Coordinates {
        Coordinates(x: x + diff.xDiff, y: y + diff.yDiff)
    }
}

extension Array where Element == [Character] {
    func findHarmonics(from coordinates: Coordinates, diff: (xDiff: Int, yDiff: Int)) -> Set<Coordinates> {
        var nextCoordinates = coordinates.project(diff)
        var harmonicCoordinates: Set<Coordinates> = [coordinates]
        while(isInsideGrid(nextCoordinates)) {
            harmonicCoordinates.insert(nextCoordinates)
            nextCoordinates = nextCoordinates.project(diff)
        }
        return harmonicCoordinates
    }

    func findAntinodes(for antenna: Character) -> Set<Coordinates> {
        let antennaCoordinates = findCoordinates(for: antenna)
        var antinodes = Set<Coordinates>()
        for coordinate in antennaCoordinates {
            let otherCoordinates = antennaCoordinates.filter { $0 != coordinate }
            otherCoordinates.forEach { other in
                antinodes = antinodes.union(coordinate.findAntinodes(with: other))
            }
        }
        return antinodes.filter(isInsideGrid)
    }

    func findAntinodes(for antennas: Set<Character>) -> Set<Coordinates> {
        var antinodes = Set<Coordinates>()
        antennas.forEach { antenna in
            antinodes = antinodes.union(findAntinodes(for: antenna))
        }
        return antinodes
    }

    func findAntinodesWithHarmonics(between coordinates: Coordinates, and other: Coordinates) -> Set<Coordinates> {
        let diff = coordinates.diff(with: other)
        return findHarmonics(from: coordinates, diff: diff)
            .union(findHarmonics(from: other, diff: inverted(diff)))
    }

    func findAntinodesWithHarmonics(for antennas: Set<Character>) -> Set<Coordinates> {
        var antinodes = Set<Coordinates>()
        antennas.forEach { antenna in
            antinodes = antinodes.union(findAntinodesWithHarmonics(for: antenna))
        }
        return antinodes
    }

    func findAntinodesWithHarmonics(for antenna: Character) -> Set<Coordinates> {
        let antennaCoordinates = findCoordinates(for: antenna)
        var antinodes = Set<Coordinates>()
        for coordinate in antennaCoordinates {
            let otherCoordinates = antennaCoordinates.filter { $0 != coordinate }
            otherCoordinates.forEach { other in
                antinodes = antinodes.union(findAntinodesWithHarmonics(between: coordinate, and: other))
            }
        }
        return antinodes
    }
}
