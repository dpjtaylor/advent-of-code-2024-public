import Foundation

public enum Day02 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            process(data)
                .filter(\.isSafe)
                .count
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            process(data)
                .filter(\.isSafeWhenDampened)
                .count
        }
    }

    static func process(_ data: String) -> [Report] {
        data.lines()
            .map { $0.intComponents() }
            .map(Report.init(levels:))
    }
}

struct Report: Equatable {
    let levels: [Int]

    var isSafe: Bool {
        levels.isSafe
    }

    var isSafeWhenDampened: Bool {
        let deltas = levels.deltas
        if deltas.isSafe {
            return true
        }
        let unsafeDeltas = deltas.unsafeValues
        for delta in unsafeDeltas {
            let dampenedLevels = levels.combinationsRemovingDelta(delta: delta)
            if dampenedLevels.hasSafeValue {
                return true
            }
        }
        return false
    }
}

struct Delta {
    let left: Int
    let right: Int
    let leftIndex: Int
    let rightIndex: Int

    var isIncreasing: Bool {
        right > left
    }

    var isDecreasing: Bool {
        right < left
    }

    var isUnchanged: Bool {
        right == left
    }

    var value: Int {
        right - left
    }

    var isChangingTooFast: Bool {
        abs(value) > 3
    }

    var isSafe: Bool {
        !isUnchanged &&
        !isChangingTooFast
    }
}

extension Array where Element == Delta {
    var intSequence: [Int] {
        map(\.left) + [last!.right]
    }

    var isSafe: Bool {
        unsafeValues.isEmpty
    }

    var unsafeValues: [Delta] {
        filter {
            $0.isUnchanged ||
            $0.isChangingTooFast ||
            ($0.isIncreasing && !filter { $0.isDecreasing }.isEmpty) ||
            ($0.isDecreasing && !filter { $0.isIncreasing }.isEmpty)
        }
    }
}

private extension Array where Element == [Int] {
    var hasSafeValue: Bool {
        for levels in self {
            if levels.isSafe {
                return true
            }
        }
        return false
    }
}

private extension Array where Element == Int {
    func combinationsRemovingDelta(delta: Delta) -> [[Int]] {
        var copyRemovingLeft = self
        var copyRemovingRight = self
        copyRemovingLeft.remove(at: delta.leftIndex)
        copyRemovingRight.remove(at: delta.rightIndex)
        return [copyRemovingLeft, copyRemovingRight]
    }

    var deltas: [Delta] {
        var deltas = [Delta]()
        for (index, level) in self.enumerated() {
            if index < self.count - 1 {
                deltas.append(
                    Delta(
                        left: level,
                        right: self[index + 1],
                        leftIndex: index,
                        rightIndex: index + 1
                    )
                )
            }
        }
        return deltas
    }

    var isSafe: Bool {
        deltas.unsafeValues.isEmpty
    }
}
