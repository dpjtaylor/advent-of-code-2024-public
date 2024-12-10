import Foundation

public enum Day08 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.grid.findAntinodes(for: data.antennas).count
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            -1
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

extension Coordinates {
    func findAntinodes(with coordinates: Coordinates) -> [Coordinates] {
        let minX = min(x, coordinates.x)
        let maxX = max(x, coordinates.x)
        let minY = min(y, coordinates.y)
        let maxY = max(y, coordinates.y)

        let xDiff = maxX - minX
        let yDiff = maxY - minY
        let xModifier = x > coordinates.x ? 1 : -1
        let yModifier = y > coordinates.y ? 1 : -1

        return [
            Coordinates(
                x: x + (xModifier * xDiff),
                y: y + (yModifier * yDiff)
            ),
            Coordinates(
                x: coordinates.x + (-xModifier * xDiff),
                y: coordinates.y + (-yModifier * yDiff)
            )
        ]
    }
}

extension Array where Element == [Character] {
    func coordinates(for antenna: Character) -> [Coordinates] {
        var coordinates: [Coordinates] = []
        walk { x, y, char in
            if char == antenna {
                coordinates.append(Coordinates(x: x, y: y))
            }
        }
        return coordinates
    }

    func findAntinodes(for antenna: Character) -> Set<Coordinates> {
        let antennaCoordinates = coordinates(for: antenna)
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
}
