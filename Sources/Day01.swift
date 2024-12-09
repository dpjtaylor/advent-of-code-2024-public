import Foundation

public enum Day01 {
    enum Part1 {
        public static func solve(_ data: String) -> Int {
            let lists = process(data)
            let sortedLists = sort(lists)

            var sum = 0
            for (index, value) in sortedLists.0.enumerated() {
                sum += abs(sortedLists.1[index] - value)
            }
            return sum
        }
    }

    enum Part2 {
        public static func solve(_ data: String) -> Int {
            let lists = process(data)
            let sortedLists = sort(lists)
            
            var sum = 0
            for value in sortedLists.0 {
                let rightListCount = sortedLists.1.filter { $0 == value }.count
                sum += value * rightListCount
            }
            return sum
        }
    }

    static func process(_ data: String) -> ([Int], [Int]) {
        var leftList = [Int]()
        var rightList = [Int]()
        data.lines().forEach { row in
            let values = row.intComponents()
            leftList.append(values[0])
            rightList.append(values[1])
        }
        return (leftList, rightList)
    }

    static func sort(_ data: ([Int], [Int])) -> ([Int], [Int]) {
        (data.0.sorted(), data.1.sorted())
    }
}
