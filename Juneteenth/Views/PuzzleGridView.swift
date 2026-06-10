import SwiftUI

// MARK: - Cell frame preference key

/// Collects each slot's CGRect (in the "puzzle" coordinate space) up the view tree.
private struct CellFrameKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - PuzzleGridView

/// The interactive tile grid.
///
/// Layout structure:
/// ```
/// ZStack  ← coordinateSpace "puzzle"
/// ├── LazyVGrid
/// │   └── ForEach 0..<(N*N)          ← one slot per index
/// │       └── SlotView               ← TileView (ghost) or empty placeholder
/// │           └── GeometryReader     ← reports slot frame via CellFrameKey
/// │           └── DragGesture        ← picks up tile, tracks finger
/// └── Overlay: floating TileView     ← only present while dragging
/// ```
///
/// Drag flow:
/// 1. `onChanged` — identify the tile in the touched slot, set `draggingTileID`,
///    update `dragPosition` (finger in puzzle coords), highlight hovered slot.
/// 2. `onEnded`   — find which slot contains the final finger position,
///    call `puzzleState.move(tileID:to:)`, clear drag state.
struct PuzzleGridView: View {

    @ObservedObject var puzzleState: PuzzleState

    // MARK: Local drag state (60 fps — not routed through ObservableObject)
    @State private var draggingTileID:  Int?     = nil
    @State private var dragPosition:    CGPoint  = .zero
    @State private var hoveredSlotIndex: Int?    = nil

    // Cell frames reported by each slot's GeometryReader
    @State private var cellFrames: [Int: CGRect] = [:]

    // Solved flash animation
    @State private var showSolvedFlash = false

    // MARK: - Body

    var body: some View {
        ZStack {
            grid
            draggingOverlay

            // Gold shimmer when puzzle is solved
            if showSolvedFlash {
                RoundedRectangle(cornerRadius: Theme.tileCornerRadius * 2)
                    .fill(Theme.goldAccent.opacity(0.22))
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .coordinateSpace(name: "puzzle")
        .onPreferenceChange(CellFrameKey.self) { cellFrames = $0 }
        .onChange(of: puzzleState.isSolved) { isSolved in
            guard isSolved else { return }
            withAnimation(.easeIn(duration: 0.15)) { showSolvedFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.easeOut(duration: 0.4)) { showSolvedFlash = false }
            }
        }
    }

    // MARK: - Grid

    private var grid: some View {
        let n = puzzleState.gridSize
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: Theme.tileGap),
            count: n
        )

        return LazyVGrid(columns: columns, spacing: Theme.tileGap) {
            ForEach(0 ..< n * n, id: \.self) { slotIndex in
                slotView(slotIndex: slotIndex)
            }
        }
    }

    // MARK: - Single slot

    @ViewBuilder
    private func slotView(slotIndex: Int) -> some View {
        let tile           = puzzleState.tile(at: slotIndex)
        let isDragging     = tile?.id == draggingTileID
        let isDropTarget   = hoveredSlotIndex == slotIndex && draggingTileID != nil && !isDragging

        ZStack {
            if let tile {
                TileView(
                    tile: tile,
                    isBeingDragged: isDragging,
                    isDropTarget: isDropTarget
                )
            } else {
                // Empty slot placeholder
                RoundedRectangle(cornerRadius: Theme.tileCornerRadius)
                    .fill(Theme.inkBrown.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.tileCornerRadius)
                            .strokeBorder(
                                Theme.tileBorder.opacity(isDropTarget ? 0.6 : 0.2),
                                lineWidth: isDropTarget ? 2 : 1
                            )
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        // Report this slot's frame up the tree
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CellFrameKey.self,
                    value: [slotIndex: geo.frame(in: .named("puzzle"))]
                )
            }
        )
        // Drag gesture — only meaningful when there's a tile in this slot
        .gesture(dragGesture(slotIndex: slotIndex, tile: tile))
    }

    // MARK: - Dragging overlay

    @ViewBuilder
    private var draggingOverlay: some View {
        if let tid = draggingTileID,
           let tile = puzzleState.tiles.first(where: { $0.id == tid }) {
            TileView(tile: tile, isBeingDragged: false, isDropTarget: false)
                .frame(width: cellSize, height: cellSize)
                .scaleEffect(1.06)
                .shadow(color: Theme.inkBrown.opacity(0.35), radius: 14, x: 0, y: 7)
                .position(dragPosition)
                .allowsHitTesting(false)
                .animation(nil, value: dragPosition) // position must follow finger instantly
        }
    }

    // MARK: - DragGesture factory

    private func dragGesture(slotIndex: Int, tile: Tile?) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .named("puzzle"))
            .onChanged { value in
                // Only start a new drag if we have a tile and no drag is in flight
                if draggingTileID == nil {
                    guard let tile else { return }
                    draggingTileID = tile.id
                }

                dragPosition     = value.location
                hoveredSlotIndex = findSlot(containing: value.location)
            }
            .onEnded { value in
                defer {
                    draggingTileID   = nil
                    dragPosition     = .zero
                    hoveredSlotIndex = nil
                }

                guard let tileID = draggingTileID else { return }

                let target = findSlot(containing: value.location)
                           ?? originSlot(of: tileID)
                           ?? slotIndex

                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    puzzleState.move(tileID: tileID, to: target)
                }
            }
    }

    // MARK: - Helpers

    /// Returns the slot index whose frame contains `point`, or nil.
    private func findSlot(containing point: CGPoint) -> Int? {
        cellFrames.first(where: { $0.value.contains(point) })?.key
    }

    /// Returns the current slot index for the tile with `tileID`.
    private func originSlot(of tileID: Int) -> Int? {
        puzzleState.tiles.first(where: { $0.id == tileID })?.currentIndex
    }

    /// Derive cell size from the first reported frame so the overlay tile matches.
    private var cellSize: CGFloat {
        cellFrames.values.first.map { min($0.width, $0.height) } ?? 80
    }
}

// MARK: - Preview

#Preview {
    let state = PuzzleState()
    // Use a solid-colour image as placeholder in preview
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
    let img = renderer.image { ctx in
        UIColor.systemBrown.setFill()
        ctx.fill(CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
    }
    state.loadPuzzle(image: img, size: .easy)

    return PuzzleGridView(puzzleState: state)
        .padding()
        .background(Theme.parchment)
}
