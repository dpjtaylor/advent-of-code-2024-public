import Foundation

public enum Day07 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.lines()
                .map(CalibrationEquation.init(line:))
                .filter(\.canBeMadeTrue)
                .map(\.testValue)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.lines()
                .map { CalibrationEquation(line: $0, allowConcatenation: true) }
                .filter(\.canBeMadeTrue)
                .map(\.testValue)
                .reduce(0, +)
        }
    }
}

extension Character {
    static let addition: Character = "+"
    static let concatenation: Character = "@"
    static let multiplication: Character = "*"
}

struct CalibrationEquation {
    let testValue: Int
    let operators: [Int]
    let operations: [Character]

    init(testValue: Int, operators: [Int], allowConcatenation: Bool = false) {
        self.testValue = testValue
        self.operators = operators
        if allowConcatenation {
            self.operations = [.addition, .concatenation, .multiplication]
        } else {
            self.operations = [.addition, .multiplication]
        }
    }

    init(line: String) {
        self.init(line: line, allowConcatenation: false)
    }

    init(line: String, allowConcatenation: Bool) {
        let components = line.split(separator: ":")
        self.init(
            testValue: Int(String(components.first!))!,
            operators: components.last!.split(separator: .whitespace).map(String.init).compactMap(Int.init),
            allowConcatenation: allowConcatenation
        )
    }

    var operatorCombinations: [String] {
        operatorCombinations(length: operators.count - 1)
    }

    func operatorCombinations(length: Int) -> [String] {
        if length == 0 {
            return [""]
        }

        let smallCombinations = operatorCombinations(length: length - 1)

        var combinations = [String]()
        for combination in smallCombinations {
            for char in operations {
                combinations.append(combination + String(char))
            }
        }

        return combinations
    }

    var canBeMadeTrue: Bool {
        for combination in operatorCombinations {
            var result = operators[0]
            for (index, char) in combination.enumerated() {
                if char == .addition {
                    result = result + operators[index + 1]
                }
                if char == .concatenation {
                    result = Int("\(result)\(operators[index + 1])")!
                }
                if char == .multiplication {
                    result = result * operators[index + 1]
                }
            }
            if result == testValue {
                return true
            }
        }
        return false
    }
}
