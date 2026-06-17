import SwiftUI

// MARK: - CompletionView

/// Bottom-sheet overlay that slides up when the puzzle is solved.
///
/// On iOS 26+ devices with Apple Intelligence, the static historical note is
/// replaced by a richer AI-generated narrative that streams in word-by-word.
/// On older devices the static note is shown unchanged — no degraded UX.
struct CompletionView: View {

    let card: PuzzleCard
    let moveCount: Int
    let onPlayAgain: () -> Void
    let onChooseAnother: () -> Void

    @StateObject private var historian = HistorianModel()
    @State private var isPulsing = false

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

                // Historical narrative — AI-generated or static fallback
                historianSection

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
        .onAppear {
            historian.generate(for: card)
        }
    }

    // MARK: - Historian Section

    @ViewBuilder
    private var historianSection: some View {
        VStack(spacing: 10) {

            // Pulsing badge — only while generating and no text has arrived yet
            if historian.state == .generating && historian.narrative.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Theme.goldAccent)
                        .opacity(isPulsing ? 1.0 : 0.2)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.75)
                                .repeatForever(autoreverses: true)
                            ) { isPulsing = true }
                        }
                    Text("Writing history\u{2026}")
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundStyle(Theme.tileBorder.opacity(0.7))
                }
                .transition(.opacity)
            }

            // Main text — static note until tokens arrive, then narrative streams in
            Text(displayedText)
                .font(Theme.serif(.subheadline))
                .foregroundStyle(Theme.inkBrown.opacity(0.82))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 28)

            // Apple Intelligence attribution — only when generation is complete
            if historian.state == .done {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("Apple Intelligence")
                        .font(.system(.caption2, design: .serif))
                }
                .foregroundStyle(Theme.tileBorder.opacity(0.45))
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: historian.state)
    }

    // MARK: - Derived

    /// Shows the growing narrative while streaming; falls back to the static
    /// note before generation starts or when the model is unavailable.
    private var displayedText: String {
        historian.narrative.isEmpty ? card.historicalNote : historian.narrative
    }

    // MARK: - Private views

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
