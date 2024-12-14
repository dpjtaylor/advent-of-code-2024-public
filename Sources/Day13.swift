import Foundation

public enum Day13 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            -1
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
           -1
        }
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
}

extension String {
    var extractClawData: [ClawConfig] {
        let rawData = splitByEmptyLines

        var clawConfig = [ClawConfig]()
        for data in rawData {
            let lines = data.lines()
            clawConfig.append(
                ClawConfig(
                    buttonA: lines[0].buttonConfig,
                    buttonB: lines[1].buttonConfig,
                    prizeLocation: lines[2].prizeLocation
                )
            )
        }
        return clawConfig
    }

    var buttonConfig: ClawConfig.ButtonConfig {
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
