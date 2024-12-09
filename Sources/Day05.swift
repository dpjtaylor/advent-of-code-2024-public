import Foundation

public enum Day05 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.pageUpdates
                .filter(\.isCorrectlyOrdered)
                .map(\.middlePage)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.pageUpdates
                .filter { !$0.isCorrectlyOrdered }
                .map(\.corrected)
                .map(\.middlePage)
                .reduce(0, +)
        }
    }
}

struct PageOrderingRule: Equatable {
    let firstPage: Int
    let secondPage: Int
}

struct PageUpdate {
    let pages: [Int]
    let rules: [PageOrderingRule]

    var middlePage: Int {
        pages[(pages.count - 1) / 2]
    }

    var isCorrectlyOrdered: Bool {
        for rule in rules {
            if !pages.satisfies(rule) {
                return false
            }
        }
        return true
    }

    var violatedRules: [PageOrderingRule] {
        rules.filter { !pages.satisfies($0) }
    }

    var corrected: PageUpdate {
        var corrected = self

        while corrected.violatedRules.count > 0 {
            var correctedPages = corrected.pages
            let rule = corrected.violatedRules.first!
            let firstPageIndex = correctedPages.firstIndex(of: rule.firstPage)!
            let secondPageIndex = correctedPages.firstIndex(of: rule.secondPage)!
            correctedPages.insert(rule.firstPage, at: secondPageIndex)
            correctedPages.remove(at: firstPageIndex + 1)
            corrected = PageUpdate(pages: correctedPages, rules: rules)
        }
        return corrected
    }
}

extension Array where Element == Int {
    func satisfies(_ rule: PageOrderingRule) -> Bool {
        firstIndex(of: rule.firstPage)! < firstIndex(of: rule.secondPage)!
    }
}

extension String {
    var pageUpdates: [PageUpdate] {
        let sections = split(separator: "\n\n")
            .map(String.init)
        let rules = sections[0]
            .lines()
            .map(\.pageOrderIngRule)
        let updates = sections[1]
            .lines()
            .map { $0.pageUpdate(rules: rules) }
        return updates
    }

    var pageOrderIngRule: PageOrderingRule {
        let numbers = split(separator: "|")
            .map(String.init)
            .compactMap(Int.init)

        return PageOrderingRule(firstPage: numbers[0], secondPage: numbers[1])
    }

    func pageUpdate(rules: [PageOrderingRule]) -> PageUpdate {
        let pages = split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)

        let rules = rules.filter { rule in
            let firstPageIsInUpdate = pages.contains(rule.firstPage)
            let secondPageIsInUpdate = pages.contains(rule.secondPage)
            return firstPageIsInUpdate && secondPageIsInUpdate
        }

        return PageUpdate(pages: pages, rules: rules)
    }
}
