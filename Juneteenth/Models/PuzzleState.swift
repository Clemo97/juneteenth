 import SwiftUI

// MARK: - Puzzle difficulty

enum GridSize: Int, CaseIterable, Identifiable {
    case easy   = 3   // 3×3  –  9 tiles
    case medium = 4   // 4×4  – 16 tiles
    case hard   = 5   // 5×5  – 25 tiles

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .easy:   return "Easy (3×3)"
        case .medium: return "Medium (4×4)"
        case .hard:   return "Hard (5×5)"
        }
    }
}

// MARK: - PuzzleState

/// Central state machine for a single puzzle session.
/// Owned by the view hierarchy via @StateObject.
final class PuzzleState: ObservableObject {

    // MARK: Published state

    /// The current arrangement of tiles. Index in the array == currentIndex of the tile.
    @Published private(set) var tiles: [Tile] = []

    /// Grid dimension (3, 4, or 5).
    @Published private(set) var gridSize: Int = 3

    /// True once every tile is in its correct slot.
    @Published private(set) var isSolved: Bool = false

    /// Number of moves the player has made this session.
    @Published private(set) var moveCount: Int = 0

    // MARK: Private

    private var sourceImage: UIImage?

    // MARK: - Setup

    /// Load a puzzle from a named asset and a chosen grid size.
    func loadPuzzle(imageName: String, size: GridSize) {
        guard let image = UIImage(named: imageName) else {
            assertionFailure("ImageSlicer: asset '\(imageName)' not found")
            return
        }
        loadPuzzle(image: image, size: size)
    }

    /// Load a puzzle from a UIImage directly (useful for testing).
    func loadPuzzle(image: UIImage, size: GridSize) {
        guard let slices = try? ImageSlicer.slice(image, gridSize: size.rawValue) else {
            assertionFailure("ImageSlicer failed for gridSize \(size.rawValue)")
            return
        }

        sourceImage = image
        gridSize    = size.rawValue
        isSolved    = false
        moveCount   = 0

        // Build tiles with identity mapping, then shuffle slot assignments.
        var newTiles = slices.enumerated().map { index, img in
            Tile(id: index, correctIndex: index, currentIndex: index, image: img)
        }

        shuffle(&newTiles)
        tiles = newTiles
    }

    // MARK: - Move

    /// Move the tile with `tileID` into `targetIndex`.
    /// If `targetIndex` is occupied by another tile, the two swap.
    func move(tileID: Int, to targetIndex: Int) {
        guard
            let draggedIdx = tiles.firstIndex(where: { $0.id == tileID }),
            targetIndex >= 0,
            targetIndex < tiles.count
        else { return }

        let originIndex = tiles[draggedIdx].currentIndex

        // Nothing to do if dropped on its own slot.
        guard originIndex != targetIndex else { return }

        if let occupantIdx = tiles.firstIndex(where: { $0.currentIndex == targetIndex }) {
            // Swap: occupant moves to origin, dragged tile moves to target.
            tiles[occupantIdx].currentIndex = originIndex
        }

        tiles[draggedIdx].currentIndex = targetIndex
        moveCount += 1

        checkSolved()
    }

    // MARK: - Reset / Reshuffle

    /// Re-shuffle the current puzzle without reloading the image.
    func reshuffle() {
        guard !tiles.isEmpty else { return }
        isSolved  = false
        moveCount = 0
        shuffle(&tiles)
    }

    // MARK: - Private helpers

    private func shuffle(_ tiles: inout [Tile]) {
        // Assign a random permutation of slot indices.
        var indices = Array(0 ..< tiles.count)
        indices.shuffle()

        // Guarantee the shuffle isn't accidentally solved.
        if tiles.count > 1, indices.enumerated().allSatisfy({ $0.offset == $0.element }) {
            indices.swapAt(0, 1)
        }

        for i in tiles.indices {
            tiles[i].currentIndex = indices[i]
        }
    }

    private func checkSolved() {
        isSolved = tiles.allSatisfy(\.isSolved)
    }

    // MARK: - Convenience accessors

    /// Returns the tile currently sitting in `slotIndex`, if any.
    func tile(at slotIndex: Int) -> Tile? {
        tiles.first(where: { $0.currentIndex == slotIndex })
    }

    /// Returns tiles sorted by their current slot index (display order).
    var sortedBySlot: [Tile] {
        tiles.sorted(by: { $0.currentIndex < $1.currentIndex })
    }
}
