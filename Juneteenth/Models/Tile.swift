import SwiftUI

// MARK: - Tile

/// A single puzzle tile.
/// The tile knows where it *should* be (correctIndex) and where it *currently* is
/// (currentIndex) within the flat row-major grid array.
struct Tile: Identifiable, Equatable {
    let id: Int               // stable identity - never changes
    let correctIndex: Int     // slot this tile belongs in when solved
    var currentIndex: Int     // slot this tile is sitting in right now
    let image: UIImage        // pre-sliced image for this tile

    var isSolved: Bool { currentIndex == correctIndex }
}
