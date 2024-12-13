import Foundation

public enum Day11 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.stones.blink(repeating: 25).count
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
           -1
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
    func blink(repeating times: Int) -> [Int] {
        var result = self
        for _ in 0..<times {
            result = result.blink
        }
        return result
    }

    var blink: [Int] {
        flatMap(\.blink)
    }
}

extension Int {
    var blink: [Int] {
        let digits = self.digits
        return if self == 0 {
            [1]
        } else if digits % 2 == 0 {
            [
                Int(String(String(self).prefix(digits / 2)))!,
                Int(String(String(self).suffix(digits / 2)))!
            ]
        }
        else {
            [self * 2024]
        }
    }

    var digits: Int {
        String(self).count
    }
}
