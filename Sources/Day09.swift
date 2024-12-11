import Foundation

public enum Day09 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.diskmapBlocks.defragmented.checksum
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            -1
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
