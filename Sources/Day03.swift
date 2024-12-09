import Foundation
import RegexBuilder

public enum Day03 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.allInstructions.reduce(0) { partialResult, tuple in
                partialResult + tuple.0 * tuple.1
            }
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.validInstructions.reduce(0) { partialResult, tuple in
                partialResult + tuple.0 * tuple.1
            }
        }
    }
}

private extension Array where Element == String {
    var excludedInstructions: [(Int, Int)] {
        var excludedInstructions = [(Int, Int)]()
        for excludedSection in self {
            excludedInstructions = excludedInstructions + excludedSection.allInstructions
        }
        return excludedInstructions
    }
}

private extension String {
    var allInstructions: [(Int, Int)] {
        let firstDigitRef = Reference(Int.self)
        let secondDigitRef = Reference(Int.self)
        let regex = Regex {
            One("mul(")
            TryCapture(as: firstDigitRef) {
                OneOrMore(.digit)
            } transform: { firstDigit in
                Int(firstDigit)
            }
            One(",")
            TryCapture(as: secondDigitRef) {
                OneOrMore(.digit)
            } transform: { secondDigitRef in
                Int(secondDigitRef)
            }
            One(")")
        }
        return matches(of: regex)
            .map { ($0[firstDigitRef], $0[secondDigitRef]) }
    }

    var excludedInstructions: [(Int, Int)] {
        excludedSections.excludedInstructions
    }

    var validInstructions: [(Int, Int)] {
        let allInstructions = allInstructions
        let excludedInstructions = excludedInstructions
        var validInstructions = allInstructions
        for excludedInstruction in excludedInstructions {
            guard let index = validInstructions.firstIndex(where: { $0 == excludedInstruction} ) else {
                continue
            }
            validInstructions.remove(at: index)
        }
        return validInstructions
    }

    var excludedSections: [String] {
        let stringRef = Reference(Substring.self)
        let regex = Regex {
            Capture(as: stringRef) {
                One("don't()")
                ZeroOrMore(.any, .reluctant) // reluctant match or we get a string from the first "don't()" to the last "do()"
                One("do()")
            }
        }
        return matches(of: regex).map { $0[stringRef] }.map(String.init)
    }
}
