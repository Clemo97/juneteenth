import SwiftUI

// MARK: - CompletionView

/// Bottom-sheet overlay that slides up when the puzzle is solved.
/// Shows move count, a historical note about the image, and action buttons.
struct CompletionView: View {

    let card: PuzzleCard
    let moveCount: Int
    let onPlayAgain: () -> Void
    let onChooseAnother: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {

                // Handle bar
                Capsule()
                    .fill(Theme.tileBorder.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 14)

                // Heading
                VStack(spacing: 6) {
                    Text("Puzzle Complete")
                        .font(Theme.serifBold(.title2))
                        .foregroundStyle(Theme.inkBrown)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").foregroundStyle(Theme.goldAccent)
                        Text("\(moveCount) move\(moveCount == 1 ? "" : "s")")
                            .font(Theme.serif(.subheadline))
                            .foregroundStyle(Theme.tileBorder)
                        Image(systemName: "star.fill").foregroundStyle(Theme.goldAccent)
                    }
                }

                ornamentalDivider

                // Historical note
                Text(card.historicalNote)
                    .font(Theme.serif(.subheadline))
                    .foregroundStyle(Theme.inkBrown.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 28)

                ornamentalDivider

                // Action buttons
                VStack(spacing: 10) {
                    Button(action: onPlayAgain) {
                        Label("Play Again", systemImage: "arrow.counterclockwise")
                            .font(Theme.serifBold(.subheadline))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Theme.juneteenthRed)
                                    .shadow(color: Theme.juneteenthRed.opacity(0.35),
                                            radius: 6, x: 0, y: 3)
                            )
                    }

                    Button(action: onChooseAnother) {
                        Text("Choose Another Puzzle")
                            .font(Theme.serif(.subheadline))
                            .foregroundStyle(Theme.inkBrown)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.55))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Theme.tileBorder.opacity(0.35),
                                                          lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.parchment)
                    .shadow(color: Theme.inkBrown.opacity(0.18), radius: 24, x: 0, y: -6)
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: Private

    private var ornamentalDivider: some View {
        HStack {
            Rectangle()
                .fill(Theme.tileBorder.opacity(0.22))
                .frame(height: 1)
            Text("✦")
                .font(.caption2)
                .foregroundStyle(Theme.goldAccent.opacity(0.8))
            Rectangle()
                .fill(Theme.tileBorder.opacity(0.22))
                .frame(height: 1)
        }
        .padding(.horizontal, 24)
    }
}
