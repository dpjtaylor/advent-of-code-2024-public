import Foundation

public enum Day11 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.stones.blink(repeats: 25)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.stones.blink(repeats: 75)
        }
    }
}

private extension String {
    var stones: [Int] {
        split(separator: " ")
            .map(String.init)
            .compactMap(Int.init)
    }
}

extension Array where Element == Int {
    func blink(repeats: Int) -> Int {
        var memo = [String: Int]()
        return reduce(0) { partialResult, number in
            partialResult + number.blink(memo: &memo, repeats: repeats)
        }
    }
}

extension Int {
    func blink(memo: inout [String: Int], repeats: Int) -> Int {
        if repeats == 0 {
            return 1
        }
        if let stoneCount = memo[lookupKey(repeats: repeats)] {
            return stoneCount
        }
        let stoneCount: Int
        if self == 0 {
            stoneCount = 1.blink(memo: &memo, repeats: repeats - 1)
        } else if digits % 2 == 0 {
            stoneCount = leftStone.blink(memo: &memo, repeats: repeats - 1) + rightStone.blink(memo: &memo, repeats: repeats - 1)
        } else {
            stoneCount = (2024 * self).blink(memo: &memo, repeats: repeats - 1)
        }
        memo[lookupKey(repeats: repeats)] = stoneCount
        return stoneCount
    }

    var leftStone: Int {
        Int(String(String(self).prefix(digits / 2)))!
    }

    var rightStone: Int {
        Int(String(String(self).suffix(digits / 2)))!
    }

    func lookupKey(repeats: Int) -> String {
        "\(self) \(repeats)"
    }

    var digits: Int {
        String(self).count
    }
}
