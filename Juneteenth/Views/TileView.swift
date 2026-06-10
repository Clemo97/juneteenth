import SwiftUI

// MARK: - TileView

/// Renders a single puzzle tile.
///
/// Visual states:
/// - **Normal**       — full image, aged-paper border, subtle drop shadow
/// - **Ghost**        — `isBeingDragged == true`; faded image + dashed border.
///                      The "real" tile is in the ZStack overlay while this placeholder
///                      holds the slot in the grid.
/// - **Drop target**  — `isDropTarget == true`; gold highlight border
/// - **Solved**       — `tile.isSolved == true`; gold tint on border
struct TileView: View {

    let tile: Tile
    var isBeingDragged: Bool = false
    var isDropTarget: Bool   = false

    var body: some View {
        ZStack {
            // ── Image ──────────────────────────────────────────────────────
            Image(uiImage: tile.image)
                .resizable()
                .scaledToFill()
                .opacity(isBeingDragged ? 0.18 : 1.0)
                .clipShape(RoundedRectangle(cornerRadius: Theme.tileCornerRadius))

            // ── Drop-target highlight ──────────────────────────────────────
            if isDropTarget {
                RoundedRectangle(cornerRadius: Theme.tileCornerRadius)
                    .fill(Theme.goldAccent.opacity(0.20))
            }

            // ── Border ────────────────────────────────────────────────────
            RoundedRectangle(cornerRadius: Theme.tileCornerRadius)
                .strokeBorder(borderColor, lineWidth: borderWidth)

            // ── Ghost dashes ──────────────────────────────────────────────
            if isBeingDragged {
                RoundedRectangle(cornerRadius: Theme.tileCornerRadius)
                    .strokeBorder(
                        Theme.tileBorder.opacity(0.45),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
            }
        }
        // Lift / flatten shadow based on state
        .shadow(
            color: shadowColor,
            radius: isBeingDragged ? 0 : 3,
            x: 0, y: isBeingDragged ? 0 : 2
        )
    }

    // MARK: Derived style helpers

    private var borderColor: Color {
        if tile.isSolved && !isBeingDragged { return Theme.goldAccent }
        if isDropTarget                      { return Theme.goldAccent }
        return Theme.tileBorder.opacity(0.55)
    }

    private var borderWidth: CGFloat {
        (tile.isSolved && !isBeingDragged) || isDropTarget ? 2 : 1
    }

    private var shadowColor: Color {
        Theme.inkBrown.opacity(isBeingDragged ? 0 : 0.25)
    }
}

// MARK: - Preview

#Preview("States") {
    let image = UIImage(systemName: "photo")!
    let tile  = Tile(id: 0, correctIndex: 0, currentIndex: 0, image: image)

    HStack(spacing: 12) {
        TileView(tile: tile)
            .frame(width: 90, height: 90)
        TileView(tile: tile, isBeingDragged: true)
            .frame(width: 90, height: 90)
        TileView(tile: tile, isDropTarget: true)
            .frame(width: 90, height: 90)
    }
    .padding()
    .background(Theme.parchment)
}
