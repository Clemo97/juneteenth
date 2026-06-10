import SwiftUI

// MARK: - PuzzleView

/// The active game screen.
/// Hosts the puzzle grid, a vintage header, move counter, and the
/// CompletionView overlay that slides up when the puzzle is solved.
struct PuzzleView: View {

    let card: PuzzleCard
    let difficulty: GridSize

    @StateObject private var puzzleState  = PuzzleState()
    @State private var showCompletion     = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.parchment.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ornamentalRule
                    .padding(.vertical, 10)

                PuzzleGridView(puzzleState: puzzleState)
                    .padding(.horizontal, 16)

                Spacer(minLength: 12)
                footer
            }
            .padding(.top, 12)

            if showCompletion {
                CompletionView(
                    card: card,
                    moveCount: puzzleState.moveCount,
                    onPlayAgain: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCompletion = false
                        }
                        // Slight delay so sheet is gone before tiles animate
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            puzzleState.reshuffle()
                        }
                    },
                    onChooseAnother: {
                        dismiss()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            puzzleState.loadPuzzle(imageName: card.imageName, size: difficulty)
        }
        .onChange(of: puzzleState.isSolved) { isSolved in
            guard isSolved else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    showCompletion = true
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {

            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .foregroundStyle(Theme.inkBrown)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.55))
                            .overlay(Circle().strokeBorder(Theme.tileBorder.opacity(0.3), lineWidth: 1))
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.title)
                    .font(Theme.serifBold(.headline))
                    .foregroundStyle(Theme.inkBrown)
                Text(card.subtitle)
                    .font(.system(.caption, design: .serif).italic())
                    .foregroundStyle(Theme.tileBorder)
            }

            Spacer()

            // Move counter
            VStack(spacing: 1) {
                Text("\(puzzleState.moveCount)")
                    .font(Theme.serifBold(.title3))
                    .foregroundStyle(Theme.inkBrown)
                    .contentTransition(.numericText())
                Text("moves")
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(Theme.tileBorder)
            }
            .animation(.spring(response: 0.25), value: puzzleState.moveCount)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 20) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    puzzleState.reshuffle()
                }
            } label: {
                Label("Shuffle", systemImage: "shuffle")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Theme.inkBrown.opacity(0.7))
            }
        }
        .padding(.bottom, 28)
    }

    // MARK: - Ornamental rule

    private var ornamentalRule: some View {
        HStack {
            Rectangle()
                .fill(Theme.tileBorder.opacity(0.25))
                .frame(height: 1)
            Image(systemName: "seal.fill")
                .font(.caption2)
                .foregroundStyle(Theme.goldAccent.opacity(0.55))
            Rectangle()
                .fill(Theme.tileBorder.opacity(0.25))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    PuzzleView(card: PuzzleCard.all[0], difficulty: .easy)
}
