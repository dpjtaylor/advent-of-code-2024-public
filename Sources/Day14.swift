import Foundation

public enum Day14 {
    public enum Part1 {
        static func solve(_ data: String, gridWidth: Int, gridHeight: Int) -> Int {
            data.extractRobotStates.map {
                $0.position(after: 100, gridWidth: gridWidth, gridHeight: gridHeight)
            }.safetyFactor(gridWidth: gridWidth, gridHeight: gridHeight)
        }
    }

    public enum Part2 {
//        7344 seconds---70%-------------------------------------------
//                                                                     *  *
//                                                              *
//             *  *                                          * *
//
//
//                                *                                             *  *
//
//          *        *                                 *
//                                  *
//                                                                                *             *
//              * *
//                                                *
//           *                                                        *
//
//                                       *                   *
//                                                                                *         *
//                                                                                         *
//                                   *
//          *                                                                    *       *          *
//                    *
//                  *           *                  *******************************                       *
//                                                 *                             *  *
//          *                                  *   *                             *
//                                         *       *                             *
//                                                 *                             *               *
//                                                 *              *              *
//                                                 *             ***             *                        *
//                                                 *            *****            *
//                                    * *          *           *******           *           *
//                                                 *          *********          *           *
//           *                                *    *            *****            *
//                           *                     *           *******           *                   *
//                                 *               *          *********          *  *        *
//                                                 *         ***********         *
//                                                 *        *************        *                *
//         *             *      *                  *          *********          *
//                                                 *         ***********         *
//                                                 *        *************        *
//                                                 *       ***************       *             *
//                       *                         *      *****************      *
//          *           *              *           *        *************        *
//                                                 *       ***************       *        *               *
//                 *       *                       *      *****************      *
//                                                 *     *******************     *           *
//                                                 *    *********************    *
//                                   *             *             ***             *
//                                          *      *             ***             *
//                                                 *             ***             *
//                                            *    *                             *
//                                          *   *  *                             *          *            *
//                                                 *                             *
//                          *                      *                             *              * *          *
//                   *                             *******************************             *    *
//             *          *       *                                                      *
//                                                                                                    *   *
//                                        *                   *
//                                                   *                                                    *
//
//                                                                      *               *
//                   *
//
//                                                                                   *                *
//         *         *                                           *
//                                                                                                           *
//                            *                                                            *       *
//                                                                                                         *
//             *
//                        *                                       *
//                           *                                              *                              *
//                                                                                 *
//                           * *                                                                         *
//                                                    *
//                                         *
//                                *
//                                                          *
//            *
//                                                   *
//
//                                                                                                      *
//                                         *       *
//                                   *                                                      *
//
//
//
//        *
//                                    *                                                        *
//                 *                                *                                                  *
//                                                                          *
//                               *         *                                                             *
//
//                             *
//                                        *
//
//               *                                                                                        *
//                                                                   *       *
//                                                        *
//                       *                                                                                    *
//                                             *
//                                                                 *
//                                                                                           *
//
//                                                                          *
        static func solve(_ data: String, gridWidth: Int, gridHeight: Int, debug: Bool = false) -> Int {
            let states = data.extractRobotStates
            var seconds = 0
            var foundChristmasTree = false
            while !foundChristmasTree {
                let coordinates = states.map {
                    $0.position(after: seconds, gridWidth: gridWidth, gridHeight: gridHeight)
                }
                let adjacentPercent = coordinates.percentageOfRobotsWithAdjacentRobots
                if adjacentPercent >= 70 {
                    foundChristmasTree = true
                    if debug {
                        print("\(seconds) seconds---\(adjacentPercent)%-------------------------------------------")
                        coordinates.debug(gridWidth: gridWidth, gridHeight: gridHeight)
                    }
                    continue
                }
                seconds += 1
            }
            return seconds
        }
    }
}

struct RobotState: Equatable {
    let coordinates: Coordinates
    let xVelocity: Int
    let yVelocity: Int

    func position(after seconds: Int, gridWidth: Int, gridHeight: Int) -> Coordinates {
        let newX = (((coordinates.x + seconds * xVelocity) % gridWidth) + gridWidth) % gridWidth
        let newY = (((coordinates.y + seconds * yVelocity) % gridHeight) + gridHeight) % gridHeight
        return Coordinates(x: newX, y: newY)
    }
}

extension Array where Element == Coordinates {
    func safetyFactor(gridWidth: Int, gridHeight: Int) -> Int {
        [Int](1...4).reduce(1) { product, quadrant in
            product * robotsInQuadrant(quadrant: quadrant, gridWidth: gridWidth, gridHeight: gridHeight)
        }
    }

    func robotsInQuadrant(quadrant: Int, gridWidth: Int, gridHeight: Int) -> Int {
        filter { $0.quadrant(gridWidth: gridWidth, gridHeight: gridHeight) == quadrant }.count
    }
}

extension Coordinates {
    func quadrant(gridWidth: Int, gridHeight: Int) -> Int {
        let middleX = (gridWidth - 1) / 2
        let middleY = (gridHeight - 1) / 2
        if x == middleX || y == middleY {
            return -1
        }
        if x < middleX && y < middleY {
            return 1
        }
        if x > middleX && y < middleY {
            return 2
        }
        if x < middleX && y > middleY {
            return 3
        }
        if x > middleX && y > middleY {
            return 4
        }
        return -1
    }
}

extension String {
    var extractRobotStates: [RobotState] {
        var robotStates: [RobotState] = []
        for line in lines() {
            let components = line.split(separator: " ")
            let positionData = components.first!.extractData
            let velocityData = components.last!.extractData
            let state = RobotState(
                coordinates: Coordinates(x: positionData[0], y: positionData[1]),
                xVelocity: velocityData[0],
                yVelocity: velocityData[1]
            )
            robotStates.append(state)
        }
        return robotStates
    }
}

private extension Substring {
    var extractData: [Int] {
        dropFirst(2)
        .split(separator: ",")
        .map(String.init)
        .compactMap(Int.init)
    }
}

extension Array where Element == Coordinates {
    var percentageOfRobotsWithAdjacentRobots: Int {
        var adjacentCount = 0
        for coordinate in self {
            if containsAdjacentCoordinates(for: coordinate) {
                adjacentCount += 1
            }
        }
        return Int(Double(adjacentCount) / Double(count) * 100)
    }

    func containsAdjacentCoordinates(for coordinates: Coordinates) -> Bool {
        filter { other in
            (other.x == coordinates.x && other.y == coordinates.y + 1) || // north
            (other.x == coordinates.x && other.y == coordinates.y - 1) || // south
            (other.x == coordinates.x + 1 && other.y == coordinates.y) || // east
            (other.x == coordinates.x + 1 && other.y == coordinates.y)    // west
        }.count > 0
    }

    func debug(gridWidth: Int, gridHeight: Int) {
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                print(contains(Coordinates(x: x, y: y)) ? "*" : " ", terminator: "")
            }
            print()
        }
    }
}
