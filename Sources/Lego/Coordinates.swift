import Foundation

struct Coordinates: Equatable, Hashable {
    let x: Int
    let y: Int

    func isOutsideOfGrid(maxX: Int, maxY: Int) -> Bool {
        x < 0 || y < 0 || x > maxX || y > maxY
    }

    func up(by value: Int) -> Coordinates {
        Coordinates(x: x, y: y - value)
    }

    func down(by value: Int) -> Coordinates {
        Coordinates(x: x, y: y + value)
    }

    func left(by value: Int) -> Coordinates {
        Coordinates(x: x - value, y: y)
    }

    func right(by value: Int) -> Coordinates {
        Coordinates(x: x + value, y: y)
    }
}

extension Array where Element == [Character] {
    subscript(coordinates: Coordinates) -> Character {
        get { charAt(coordinates) }
        set { self[coordinates.y][coordinates.x] = newValue }
    }

    func charAt(_ coordinates: Coordinates) -> Character {
        self[coordinates.y][coordinates.x]
    }

    func findCoordinates(for character: Character) -> [Coordinates] {
        var coordinates: [Coordinates] = []
        walk { x, y, char in
            if char == character {
                coordinates.append(Coordinates(x: x, y: y))
            }
        }
        return coordinates
    }

    func isInsideGrid(_ coordinates: Coordinates) -> Bool {
        !coordinates.isOutsideOfGrid(maxX: maxX, maxY: maxY)
    }
}
