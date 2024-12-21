import Foundation

public enum Day06 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.grid.visitedCoordinatesCount
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.grid.loopCount
        }
    }
}

private extension Character {
    static let start: Character = "^"
    static let obstacle: Character = "#"

    var isObstacle: Bool {
        self == Self.obstacle
    }
}

extension Array where Element == [Character] {
    var firstStep: DirectedStep {
        DirectedStep(direction: .north, to: startCoordinates)
    }

    var startCoordinates: Coordinates {
        coordinates(of: Character.start)
    }

    func coordinates(of character: Character) -> Coordinates {
        let y = firstIndex { $0.contains(character) }!
        let x = self[y].firstIndex(of: character)!
        return Coordinates(x: x, y: y)
    }

    var allSteps: [DirectedStep] {
        var steps: [DirectedStep] = [firstStep]
        walkRoute { step in
            steps.append(step)
        }
        return steps
    }

    func walkRoute(performing action: @escaping (DirectedStep) -> Void) {
        var previousStep: DirectedStep = firstStep
        while let step = nextStep(from: previousStep) {
            action(step)
            previousStep = step
        }
    }

    var loopCount: Int {
        var loopCount = 0
        var testedObstacleCoordinates: Set<Coordinates> = []
        let firstStep = firstStep
        walkRoute { step in
            if step.coordinates != firstStep.coordinates &&
                self[step.coordinates.y][step.coordinates.x] != Character.obstacle &&
                !testedObstacleCoordinates.contains(step.coordinates) {
                var gridCopy = self
                gridCopy[step.coordinates.y][step.coordinates.x] = Character.obstacle
                if gridCopy.hasLoop(firstStep: firstStep) {
                    loopCount += 1
                }
                testedObstacleCoordinates.insert(step.coordinates)
            }
        }
        return loopCount
    }

    func hasLoop(firstStep: DirectedStep) -> Bool {
        var visited: Set<DirectedStep> = [firstStep]
        var previousStep: DirectedStep = firstStep
        while let step = nextStep(from: previousStep) {
            if visited.contains(step) {
                return true
            }
            visited.insert(step)
            previousStep = step
        }
        return false
    }

    var visitedCoordinatesCount: Int {
        var visited: Set<Coordinates> = [firstStep.coordinates]
        walkRoute { step in
            visited.insert(step.coordinates)
        }
        return visited.count
    }

    func nextStep(from step: DirectedStep) -> DirectedStep? {
        let targetCoordinates = step.targetCoordinates
        let maxX = self[0].count - 1
        let maxY = count - 1
        if targetCoordinates.isOutsideOfGrid(maxX: maxX, maxY: maxY) { return nil }
        let targetCharacter = self[targetCoordinates.y][targetCoordinates.x]
        if targetCharacter.isObstacle {
            let newDirection = step.direction.turnRight
            return nextStep(
                from: DirectedStep(
                direction: newDirection,
                to: step.coordinates)
            )
        }
        return DirectedStep(
            direction: step.direction,
            to: targetCoordinates
        )
    }
}
