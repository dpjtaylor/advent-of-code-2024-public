import Foundation

struct Coordinates: Equatable, Hashable {
    let x: Int
    let y: Int

    func isOutsideOfGrid(maxX: Int, maxY: Int) -> Bool {
        x < 0 || y < 0 || x > maxX || y > maxY
    }
}
