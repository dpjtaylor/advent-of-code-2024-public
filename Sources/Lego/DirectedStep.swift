import Foundation

struct DirectedStep: Equatable, Hashable, Comparable {
    let direction: Direction
    let from: Coordinates
    let coordinates: Coordinates // TODO: refactor to 'to:'
    let score: Int

    init(direction: Direction, from: Coordinates = Coordinates(x: 0, y: 0), to coordinates: Coordinates, score: Int = 0) {
        self.direction = direction
        self.from = from
        self.coordinates = coordinates
        self.score = score
    }

    static func < (lhs: DirectedStep, rhs: DirectedStep) -> Bool {
        lhs.score < rhs.score
    }

    var targetCoordinates: Coordinates {
        coordinates.move(direction)
    }

    var north: DirectedStep { move(.north) }
    var south: DirectedStep { move(.south) }
    var east: DirectedStep { move(.east) }
    var west: DirectedStep { move(.west) }

    func move(_ direction: Direction) -> DirectedStep {
        DirectedStep(direction: direction, from: coordinates, to: coordinates.move(direction))
    }
}

extension Array where Element == DirectedStep {

    static func < (lhs: [DirectedStep], rhs: [DirectedStep]) -> Bool {
        lhs.score < rhs.score
    }

    var score: Int {
        map(\.score).reduce(0, +)
    }

    static func from(_ steps: [(direction: Direction, x: Int, y: Int)]) -> [DirectedStep] {
        steps.map {
            DirectedStep(direction: $0.direction, to: Coordinates(x: $0.x, y: $0.y))
        }
    }

    static func from(_ steps: [(direction: Direction, fromX: Int, fromY: Int, toX: Int, toY: Int)]) -> [DirectedStep] {
        steps.map {
            DirectedStep(
                direction: $0.direction,
                from: Coordinates(x: $0.fromX, y: $0.fromY),
                to: Coordinates(x: $0.toX, y: $0.toY)
            )
        }
    }
}

extension Coordinates {
    func move(_ direction: Direction) -> Coordinates {
        switch direction {
        case .north: Coordinates(x: x, y: y - 1)
        case .south: Coordinates(x: x, y: y + 1)
        case .east: Coordinates(x: x + 1, y: y)
        case .west: Coordinates(x: x - 1, y: y)
        }
    }
}

enum Direction: Equatable, Hashable {
    case north
    case south
    case east
    case west

    var turnRight: Direction {
        switch self {
        case .north: .east
        case .west: .north
        case .south: .west
        case .east: .south
        }
    }

    var reversed: Direction {
        switch self {
        case .north: .south
        case .west: .east
        case .south: .north
        case .east: .west
        }
    }

    func rotations(to direction: Direction) -> Int {
        if self == direction {
            return 0
        }
        if reversed == direction {
            return 2
        }
        return 1
    }

    var displayChar: Character {
        switch self {
        case .north: "^"
        case .west: "<"
        case .south: "v"
        case .east: ">"
        }
    }
}
