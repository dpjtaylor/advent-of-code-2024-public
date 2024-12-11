import Foundation

public enum Day09 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.diskmapBlocks.defragmented.checksum
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.diskmapBlocks.defragmentedWholeFiles.checksum
        }
    }
}

extension Array where Element == Int {
    var diskmapBlockString: String {
        var stringValue = ""
        for block in self {
            if block == -1 {
                stringValue += "."
            } else {
                stringValue += String(block)
            }
        }
        return stringValue
    }

    func attemptToMoveFile(_ fileNumber: Int, in diskmap: [Int]) -> [Int] {
        var copy = diskmap
        if let firstIndex = firstIndex(of: fileNumber),
           let lastIndex = lastIndex(of: fileNumber),
           let emptyRange = copy.firstRange(of: Array(repeating: -1, count: lastIndex + 1 - firstIndex)),
            emptyRange.startIndex < firstIndex {
            let rangeLength = lastIndex - firstIndex + 1
            let file = Array(repeating: fileNumber, count: rangeLength)
            copy.replaceSubrange(firstIndex...lastIndex, with: Array(repeating: -1, count: rangeLength))
            let replaceEndIndex = emptyRange.first! + rangeLength - 1
            copy.replaceSubrange(emptyRange.first!...replaceEndIndex, with: file)
        }
        return copy
    }

    var defragmentedWholeFiles: [Int] {
        var defragmented = self
        let fileNumbers = Array(Set<Int>(self).subtracting([-1])).sorted()
        for fileNumber in fileNumbers.reversed() {
            defragmented = attemptToMoveFile(fileNumber, in: defragmented)
        }
        return defragmented
    }

    var defragmented: [Int] {
        let originalLength = count
        var defragmented = self
        let components = split(separator: -1).reversed()
        for component in components {
            for char in component.reversed() {
                while defragmented.last == -1 {
                    defragmented.removeLast()
                }
                if let nextIndex = defragmented.firstIndex(of: -1) {
                    defragmented.remove(at: nextIndex)
                    defragmented.insert(char, at: nextIndex)
                    defragmented.removeLast()
                }
            }
        }
        return defragmented + Array(repeating: -1, count: originalLength - defragmented.count)
    }

    var checksum: Int {
        var total = 0
        for (index, fileIDNumber) in enumerated() {
            if fileIDNumber != -1 {
                total += index * fileIDNumber
            }
        }
        return total
    }
}

extension String {
    var diskmapBlocks: [Int] {
        var blocks = [Int]()
        var fileIndex = 0
        for (index, char) in enumerated() {
            if index % 2 == 0 {
                // is length of file
                let file = Array(repeating: fileIndex, count: Int(String(char))!)
                blocks += file
                fileIndex += 1
            } else {
                // is length of free space
                blocks += Array(repeating: -1, count: Int(String(char))!)
            }
        }
        return blocks
    }
}
