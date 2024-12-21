import Foundation
import Collections

public enum Day16 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.grid.reindeerPaths()
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
           -1
        }
    }
}

extension Array where Element == [Character] {
    func reindeerPaths(debug: Bool = false) -> Int {
        let start = findCoordinates(for: "S").first!
        let end = findCoordinates(for: "E").first!
        let startStep = DirectedStep(direction: .east, to: start)

        var pathQueue = Heap<DirectedStep>()
        pathQueue.insert(startStep)
        var foundEnd = false
        var step = 0
        while !foundEnd {
            let currentStep = pathQueue.popMin()!
            var nextSteps = nextStepOptions(from: currentStep)

            for nextStep in nextSteps {
                if pathQueue.unordered.contains(where: { $0.coordinates == nextStep.coordinates && $0.direction == nextStep.direction } ) {
                    nextSteps.removeAll { $0 == nextStep }
                } // avoid looping
            }
            pathQueue.insert(contentsOf: nextSteps)
            let min = pathQueue.min!
            if debug {
                print("\(step): \(min.direction.displayChar) \(min.coordinates.x), \(min.coordinates.y), score: \(min.score)")
            }
            if pathQueue.unordered.contains(where: { $0.coordinates == end }) {
                foundEnd = true
            }
            step += 1
        }
        return pathQueue.unordered.filter { $0.coordinates == end }.score
    }

    func nextStepOptions(from step: DirectedStep, stopAtEnd: Bool = false) -> [DirectedStep] {
        let x = step.coordinates.x
        let y = step.coordinates.y

        if stopAtEnd && self[y][x] == "E" {
            return []
        }

        let north = self[y - 1][x]
        let south = self[y + 1][x]
        let east = self[y][x + 1]
        let west = self[y][x - 1]

        let from = step.coordinates
        var nextSteps: [DirectedStep] = []
        let doNotVisit: [Character] = ["#", "S"] // avoid walls and revisiting 'S'
        if !doNotVisit.contains(north) {
            let score = step.score(nextDirection: .north)
            nextSteps.append(DirectedStep(direction: .north, from: from, to: Coordinates(x: x, y: y - 1), score: score))
        }
        if !doNotVisit.contains(south) {
            let score = step.score(nextDirection: .south)
            nextSteps.append(DirectedStep(direction: .south, from: from, to: Coordinates(x: x, y: y + 1), score: score))
        }
        if !doNotVisit.contains(east) {
            let score = step.score(nextDirection: .east)
            nextSteps.append(DirectedStep(direction: .east, from: from, to: Coordinates(x: x + 1, y: y), score: score))
        }
        if !doNotVisit.contains(west){
            let score = step.score(nextDirection: .west)
            nextSteps.append(DirectedStep(direction: .west, from: from, to: Coordinates(x: x - 1, y: y), score: score))
        }
        return nextSteps .filter { $0.direction != step.direction.reversed } // avoid backtracking
    }
}

extension DirectedStep {
    func score(nextDirection: Direction) -> Int {
        let rotations = direction.rotations(to: nextDirection)
        return score + rotations * 1000 + 1
    }
}
