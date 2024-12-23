import Foundation
import Collections

public enum Day16 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.grid.reindeerPathsPart1()
        }
    }

    public enum Part2 {
        static func solve(_ data: String, minScore: Int) -> Int {
            data.grid.reindeerPathsPart2(minScore: minScore)
        }
    }
}

struct ReindeerPath: Hashable, Equatable, Comparable {
    let step: ReindeerPathStep
    let score: Int
    let visited: [Coordinates]

    static func < (lhs: ReindeerPath, rhs: ReindeerPath) -> Bool {
        lhs.score < rhs.score
    }
}

struct ReindeerPathStep: Equatable, Hashable {
    let coordinates: Coordinates
    let direction: Direction

    init(coordinates: Coordinates, direction: Direction) {
        self.coordinates = coordinates
        self.direction = direction
    }

    var nextSteps: [ReindeerPathStep] {
        let nextDirection: [Direction] = switch direction {
        case .north: [.north, .east, .west]
        case .south: [.south, .east, .west]
        case .east: [.east, .north, .south]
        case .west: [.west, .north, .south]
        }

        return nextDirection.map { direction in
            switch direction {
            case .north: move(.north)
            case .south: move(.south)
            case .east: move(.east)
            case .west: move(.west)
            }
        }
    }

    func move(_ direction: Direction) -> ReindeerPathStep {
        ReindeerPathStep(coordinates: coordinates.move(direction), direction: direction)
    }
}

extension Array where Element == [Character] {
    func reindeerPathsPart1(debug: Bool = false) -> Int {
        let start = findCoordinates(for: "S").first!
        let end = findCoordinates(for: "E").first!
        let startStep = ReindeerPathStep(coordinates: start, direction: .east)
        let startPath = ReindeerPath(step: startStep, score: 0, visited: [start])

        var optimalPaths: [ReindeerPath] = []
        var pathQueue = Heap<ReindeerPath>()
        pathQueue.insert(startPath)
        var visited: Set<ReindeerPathStep> = []
        var minScore = Int.max
        while !pathQueue.isEmpty {
            let currentPath = pathQueue.popMin()!

            let currentStep = currentPath.step
            if visited.contains(currentStep) {
                continue
            }
            visited.insert(currentStep)

            if currentStep.coordinates == end {
                if currentPath.score <= minScore {
                    minScore = currentPath.score
                    optimalPaths.append(currentPath)
                }
                continue
            }

            for nextPath in nextPaths(from: currentPath) {
                pathQueue.insert(nextPath)
            }
        }

        if debug {
            for path in optimalPaths {
                var gridCopy = self
                for coord in path.visited {
                    gridCopy[coord.y][coord.x] = "+"
                }
                gridCopy.debug()
                print("")
            }
            print("optimal path score: \(minScore)")
        }

        return minScore
    }

    // Struggled with Part 2 for a few days with solutions that would take days to run, and ended up translating this python example here, which solves the problem very quickly. I then went back and re-wrote part 1 🙌
    // https://github.com/seapagan/aoc-2024/blob/main/16/main.py
    func reindeerPathsPart2(debug: Bool = false, minScore: Int) -> Int {
        let start = findCoordinates(for: "S").first!
        let end = findCoordinates(for: "E").first!
        let startStep = ReindeerPathStep(coordinates: start, direction: .east)
        let startPath = ReindeerPath(step: startStep, score: 0, visited: [start])

        var pathQueue = Heap<ReindeerPath>()
        pathQueue.insert(startPath)
        var stepScoreLookup: [ReindeerPathStep: Int] = [startStep: 0]

        var optimalTiles: Set<Coordinates> = []

        while !pathQueue.isEmpty {
            let currentPath = pathQueue.popMin()!

            if currentPath.score > minScore {
                continue
            }

            let currentStep = currentPath.step
            if let existingStepScore = stepScoreLookup[currentStep],
               existingStepScore < currentPath.score {
                continue
            }
            stepScoreLookup[currentStep] = currentPath.score

            if currentStep.coordinates == end,
               currentPath.score == minScore {
                optimalTiles = optimalTiles.union(Set(currentPath.visited))
                continue
            }

            for nextPath in nextPaths(from: currentPath) {
                pathQueue.insert(nextPath)
            }
        }

        if debug {
            var gridCopy = self
            for tile in optimalTiles {
                gridCopy[tile.y][tile.x] = "O"
            }
            gridCopy.debug()
            print("optimal tiles: \(optimalTiles.count)")
        }
        return optimalTiles.count
    }

    func nextPaths(from path: ReindeerPath) -> [ReindeerPath] {
        nextStepOptions(from: path.step).map { nextStep in
            let rotationScore = nextStep.direction == path.step.direction ? 0 : 1000
            let newScore = path.score + 1 + rotationScore
            return ReindeerPath(step: nextStep, score: newScore, visited: path.visited + [nextStep.coordinates])
        }
    }

    func nextStepOptions(from step: ReindeerPathStep) -> [ReindeerPathStep] {
        let doNotVisit: [Character] = ["#", "S"] // avoid walls and revisiting 'S'

        return step.nextSteps.filter { step in !doNotVisit.contains(self[step.coordinates.y][step.coordinates.x])
        }
    }
}
