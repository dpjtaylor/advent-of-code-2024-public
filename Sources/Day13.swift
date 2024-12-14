import Foundation

public enum Day13 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.extractClawData()
                .map { $0.options(maxTaps: 100) } // retained the part 1 version for posterity (a reminder there are better ways!)
                .compactMap(\.minCost)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.extractClawData(prizeOffset: 10_000_000_000_000)
                .compactMap(\.winningTaps)
                .map(\.cost)
                .reduce(0, +)
        }
    }
}

struct ClawOption: Equatable {
    let aTaps: Int
    let bTaps: Int

    var cost: Int {
        3 * aTaps + bTaps
    }
}

struct ClawConfig: Equatable {
    struct ButtonConfig: Equatable {
        let x: Int
        let y: Int
    }
    let buttonA: ButtonConfig
    let buttonB: ButtonConfig
    let prizeLocation: Coordinates
    let prizeOffset: Int

    init(buttonA: ButtonConfig, buttonB: ButtonConfig, prizeLocation: Coordinates, prizeOffset: Int = 0) {
        self.buttonA = buttonA
        self.buttonB = buttonB
        self.prizeLocation = prizeLocation
        self.prizeOffset = prizeOffset
    }

    var prizeX: Int {
        prizeLocation.x + prizeOffset
    }

    var prizeY: Int {
        prizeLocation.y + prizeOffset
    }

    // Thanks to https://javorszky.co.uk/2024/12/13/advent-of-code-2024-day-13/ for the example normalising the equations to eliminate a factor.
    //
    // Goal: remove aTaps from the pair of equations so we can
    //       determine aTaps without needing to know bTaps
    //
    // These two linear equations must both be true for a valid combination of A and B taps:
    //     aX * aTaps + bX * bTaps = prizeX
    //     aY * aTaps + bY * bTaps = prizeY
    //
    // Multiply the 1st equation by the B button y-value and the 2nd equation by the B button x-value. This enables us to subtract one equation from the other to remove bTaps from the equation:
    //     bY * (aX * aTaps + bX * bTaps) = prizeX * bY
    //     bX * (aY * aTaps + bY * bTaps) = prizeY * bX
    //
    // Expand:
    //     bY * aX * aTaps + bY * bX * bTaps = prizeX * bY
    //     bX * aY * aTaps + bX * bY * bTaps = prizeY * bX
    //
    // Subtract one equation from the other:
    //     bY * aX * aTaps + bY * bX * bTaps - bX * aY * aTaps - bX * bY * bTaps = prizeX * bY - prizeY * bX
    //
    // (bY * bX * bTaps) cancels itself out:
    //     bY * aX * aTaps - bX * aY * aTaps = prizeX * bY - prizeY * bX
    //
    // Isolate aTaps:
    //     aTaps * (by * aX - bX * aY) = prizeX * bY - prizeY *bX
    //
    // Rearrange -> now aTaps can be calculated from known values:
    //     aTaps = (prizeX * bY - prizeY *bX) / (by * aX - bX * aY)
    func aTaps() -> Int {
        (prizeX * buttonB.y - prizeY * buttonB.x) / (buttonB.y * buttonA.x - buttonB.x * buttonA.y)
    }

    func bTaps(for aTaps: Int, offset: Int = 0) -> Int? {
        let xTapsNeeded = Int(exactly: (Double(prizeX + offset) - Double(buttonA.x * aTaps)) / Double(buttonB.x))
        let yTapsNeeded = Int(exactly: (Double(prizeY + offset) - Double(buttonA.y * aTaps)) / Double(buttonB.y))

        if xTapsNeeded == nil || yTapsNeeded == nil {
            return nil
        }
        if xTapsNeeded == yTapsNeeded {
            return xTapsNeeded
        }
        return nil
    }

    // Part 2 version
    var winningTaps: ClawOption? {
        let aTaps = aTaps()
        if let bTaps = bTaps(for: aTaps) {
            return ClawOption(aTaps: aTaps, bTaps: bTaps)
        }
        return nil
    }

    // Part 1 version
    func options(maxTaps: Int, offset: Int = 0) -> [ClawOption] {
        var options = [ClawOption]()
        for a in 0...maxTaps {
            if let b = bTaps(for: a, offset: offset) {
                options.append(ClawOption(aTaps: a, bTaps: b))
            }
        }
        return options
    }
}

extension Array where Element == ClawOption {
    // Part 1 version
    var minCost: Int? {
        sorted(by: { $0.cost < $1.cost }).first?.cost
    }
}

extension String {
    func extractClawData(prizeOffset: Int = 0) -> [ClawConfig] {
        let rawData = splitByEmptyLines

        var clawConfig = [ClawConfig]()
        for data in rawData {
            let lines = data.lines()
            clawConfig.append(
                ClawConfig(
                    buttonA: lines[0].buttonConfig(cost: 3),
                    buttonB: lines[1].buttonConfig(cost: 1),
                    prizeLocation: lines[2].prizeLocation,
                    prizeOffset: prizeOffset
                )
            )
        }
        return clawConfig
    }

    func buttonConfig(cost: Int) -> ClawConfig.ButtonConfig {
        let components = dropFirst(10).split(separator: ", ")
        return ClawConfig.ButtonConfig(
            x: components[0].extractMovement,
            y: components[1].extractMovement
        )
    }

    var prizeLocation: Coordinates {
        let components = dropFirst(7).split(separator: ", ")
        return Coordinates(
            x: components[0].extractPrize,
            y: components[1].extractPrize
        )
    }
}

private extension Substring {
    var extractMovement: Int {
        extractSecondComponentAsInt(separator: "+")
    }

    var extractPrize: Int {
        extractSecondComponentAsInt(separator: "=")
    }

    func extractSecondComponentAsInt(separator: String) -> Int {
        Int(String(split(separator: separator)[1]))!
    }
}
