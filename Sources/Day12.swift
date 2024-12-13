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
            -1
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

    var price: Int {
        plots.price
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
