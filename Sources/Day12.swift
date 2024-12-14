import Foundation

public enum Day12 {
    public enum Part1 {
        static func solve(_ data: String) -> Int {
            data.gardenRegions
                .map(\.price)
                .reduce(0, +)
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            data.gardenRegions
                .map(\.discountedPrice)
                .reduce(0, +)
        }
    }
}

extension String {
    var gardenRegions: [GardenRegion] {
        var regionsMap = [Character: Set<GardenRegion>]()
        grid.walk { x, y, _ in
            let plot = grid.gardenPlot(x: x, y: y)
            if let existingRegions = regionsMap[plot.type] {
                if var matchingRegion = existingRegions.first(where: { $0.containsNeighbour(of: plot) }) {
                    regionsMap[plot.type]?.remove(matchingRegion)
                    matchingRegion.plots.insert(plot)
                    regionsMap[plot.type]?.insert(matchingRegion)
                } else {
                    let newRegion = GardenRegion(type: plot.type, plots: [plot])
                    regionsMap[plot.type]?.insert(newRegion)
                }
            } else {
                var newRegionSet = Set<GardenRegion>()
                let newRegion = GardenRegion(type: plot.type, plots: [plot])
                newRegionSet.insert(newRegion)
                regionsMap[plot.type] = newRegionSet
            }
        }
        return regionsMap.values
            .map(\.stitched) // Stitch together separate regions that should be a single region
            .flatMap(\.self)
    }
}

extension Collection where Element == GardenRegion {
    func regions(with plotType: Character) -> [GardenRegion] {
        filter { $0.type == plotType }
    }
}

extension Set where Element == GardenRegion {
    var stitched: Set<GardenRegion> {
        var stitched = self
        for region in self {
            let others = stitched.filter { $0 != region }
            let neighbours = others.neighbours(of: region)
            if neighbours.count == 0 {
                continue
            }
            var regionCopy = region
            for neighbour in neighbours {
                let stitchedPlots = regionCopy.plots.union(neighbour.plots)
                let stitchedRegion = GardenRegion(type: region.type, plots: stitchedPlots)
                stitched.remove(regionCopy)
                stitched.remove(neighbour)
                regionCopy = stitchedRegion
                stitched.insert(stitchedRegion)
            }
        }
        return stitched
    }

    func neighbours(of region: GardenRegion) -> Set<GardenRegion> {
        filter { $0.isNeighbour(of: region) }
    }
}

extension Set where Element == GardenPlot {
    var area: Int {
        count
    }

    var discountedPrice: Int {
        area * map(\.borderCoordinates).flatMap(\.self).edgeCount
    }

    var price: Int {
        area * perimeter
    }

    var perimeter: Int {
        map(\.borderEdges).reduce(0, +)
    }
}

extension Array where Element == [Character] {
    func gardenPlot(x: Int, y: Int) -> GardenPlot {
        var north, south, east, west: Character?
        if y - 1 >= 0 {
            north = self[y - 1][x]
        }
        if y + 1 <= maxY {
            south = self[y + 1][x]
        }
        if x + 1 <= maxX {
            east = self[y][x + 1]
        }
        if x - 1 >= 0 {
            west = self[y][x - 1]
        }
        return GardenPlot(
            type: self[y][x],
            coordinates: Coordinates(x: x, y: y),
            north: north,
            south: south,
            east: east,
            west: west
        )
    }
}

struct GardenRegion: Equatable, Hashable {
    let type: Character
    var plots: Set<GardenPlot>

    var discountedPrice: Int {
        plots.discountedPrice
    }

    var price: Int {
        plots.price
    }

    var sides: Int {
        plots.map(\.borderCoordinates)
            .flatMap(\.self)
            .edgeCount
    }
}

extension GardenRegion {
    func containsNeighbour(of plot: GardenPlot) -> Bool {
        plots.contains { $0.neighbourCoordinates.contains(plot.coordinates) }
    }

    func isNeighbour(of other: GardenRegion) -> Bool {
        for plot in plots {
            if other.containsNeighbour(of: plot) {
                return true
            }
        }
        return false
    }
}

struct GardenEdge {
    let coordinates: Coordinates
    let direction: Character

    var isNorth: Bool {
        direction == "N"
    }

    var isEast: Bool {
        direction == "E"
    }

    var isSouth: Bool {
        direction == "S"
    }

    var isWest: Bool {
        direction == "W"
    }
}

struct GardenPlot: Equatable, Hashable {
    let type: Character
    let coordinates: Coordinates
    let north: Character?
    let south: Character?
    let east: Character?
    let west: Character?

    var borderEdges: Int {
        neighbours.filter { $0 != type }.count
        + gardenEdges
    }

    var borderCoordinates: [GardenEdge] {
        var coords: [GardenEdge] = []
        if north != type {
            coords.append(GardenEdge(coordinates: northCoordinates, direction: "N"))
        }
        if south != type {
            coords.append(GardenEdge(coordinates: southCoordinates, direction: "S"))
        }
        if east != type {
            coords.append(GardenEdge(coordinates: eastCoordinates, direction: "E"))
        }
        if west != type {
            coords.append(GardenEdge(coordinates: westCoordinates, direction: "W"))
        }
        return coords
    }

    var gardenEdges: Int {
        4 - neighbours.count
    }

    var neighbours: [Character] {
        [north, south, east, west]
            .compactMap(\.self)
    }

    var neighbourCoordinates: [Coordinates] {
        [northCoordinates, southCoordinates, eastCoordinates, westCoordinates]
    }

    var northCoordinates: Coordinates {
        Coordinates(x: coordinates.x, y: coordinates.y - 1)
    }

    var southCoordinates: Coordinates {
        Coordinates(x: coordinates.x, y: coordinates.y + 1)
    }

    var eastCoordinates: Coordinates {
        Coordinates(x: coordinates.x + 1, y: coordinates.y)
    }

    var westCoordinates: Coordinates {
        Coordinates(x: coordinates.x - 1, y: coordinates.y)
    }
}

extension Array where Element == GardenEdge {
    var edgeCount: Int {
        northEdgeCount + southEdgeCount + eastEdgeCount + westEdgeCount
    }

    var northEdgeCount: Int {
        northSouthEdgeCount(\.isNorth)
    }

    var southEdgeCount: Int {
        northSouthEdgeCount(\.isSouth)
    }

    var eastEdgeCount: Int {
        eastWestEdgeCount(\.isEast)
    }

    var westEdgeCount: Int {
        eastWestEdgeCount(\.isWest)
    }

    func northSouthEdgeCount(_ edgeFilter: (GardenEdge) -> Bool) -> Int {
        let edges = filter { edgeFilter($0) }.map(\.coordinates)

        let uniqueYs = Set(edges.map(\.y))

        var edgeCount = 0
        for y in uniqueYs {
            let orderedXs = edges.filter { $0.y == y }.map(\.x).sorted()
            var previousX = orderedXs.first!
            edgeCount += 1
            for x in orderedXs {
                if x == previousX { continue }
                if x != previousX + 1 {
                    edgeCount += 1
                }
                previousX = x
            }
        }
        return edgeCount
    }

    func eastWestEdgeCount(_ edgeFilter: (GardenEdge) -> Bool) -> Int {
        let edges = filter { edgeFilter($0) }.map(\.coordinates)

        let uniqueXs = Set(edges.map(\.x))

        var edgeCount = 0
        for x in uniqueXs {
            let orderedYs = edges.filter { $0.x == x }.map(\.y).sorted()
            var previousY = orderedYs.first!
            edgeCount += 1
            for y in orderedYs {
                if y == previousY { continue }
                if y != previousY + 1 {
                    edgeCount += 1
                }
                previousY = y
            }
        }
        return edgeCount
    }
}
