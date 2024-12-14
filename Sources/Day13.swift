import Foundation

public enum Day13 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.extractClawData
                .map { $0.options(maxTaps: 100) }
                .compactMap(\.minCost)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
           -1
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

    func bTaps(for aTaps: Int) -> Int? {
        let xTapsNeeded = Int(exactly: (Double(prizeLocation.x) - Double(buttonA.x * aTaps)) / Double(buttonB.x))
        let yTapsNeeded = Int(exactly: (Double(prizeLocation.y) - Double(buttonA.y * aTaps)) / Double(buttonB.y))

        if xTapsNeeded == nil || yTapsNeeded == nil {
            return nil
        }
        if xTapsNeeded == yTapsNeeded {
            return xTapsNeeded
        }
        return nil
    }

    func options(maxTaps: Int) -> [ClawOption] {
        var options = [ClawOption]()
        for a in 0...maxTaps {
            if let b = bTaps(for: a) {
                options.append(ClawOption(aTaps: a, bTaps: b))
            }
        }
        return options
    }
}

extension Array where Element == ClawOption {
    var minCost: Int? {
        sorted(by: { $0.cost < $1.cost }).first?.cost
    }
}

// Button A: X+94, Y+34
// Button B: X+22, Y+67
// Prize: X=8400, Y=5400

// cost = 3a +b

// a(94x + 34y) + b(22x + 67y) = 8400x + 5400y
// 94a + 22b = 8400 && 34a + 67b = 5400

// 1 * 34 + 67b = 5400
// b = 5400 - 34 / 67 -> not a whole number

extension String {
    var extractClawData: [ClawConfig] {
        let rawData = splitByEmptyLines

        var clawConfig = [ClawConfig]()
        for data in rawData {
            let lines = data.lines()
            clawConfig.append(
                ClawConfig(
                    buttonA: lines[0].buttonConfig(cost: 3),
                    buttonB: lines[1].buttonConfig(cost: 1),
                    prizeLocation: lines[2].prizeLocation
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
