import SwiftUI

// MARK: - PuzzleCardView

/// A vintage portrait card in the Art of Fauna style.
/// Displays the puzzle image, title, subtitle, and year context.
/// Degrades gracefully when the named image asset is not yet in the catalogue.
struct PuzzleCardView: View {

    let card: PuzzleCard
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Image ──────────────────────────────────────────────────────
            imageArea

            // ── Thin rule ─────────────────────────────────────────────────
            Rectangle()
                .fill(Theme.tileBorder.opacity(0.28))
                .frame(height: 1)
                .padding(.horizontal, 14)

            // ── Text block ────────────────────────────────────────────────
            VStack(spacing: 5) {
                Text(card.title)
                    .font(Theme.serifBold(.title3))
                    .foregroundStyle(Theme.inkBrown)
                    .multilineTextAlignment(.center)

                Text(card.subtitle)
                    .font(Theme.serif(.caption))
                    .foregroundStyle(Theme.tileBorder)
                    .italic()
                    .multilineTextAlignment(.center)

                Text(card.yearContext)
                    .font(.system(.caption2, design: .serif))
                    .tracking(1)
                    .foregroundStyle(Theme.goldAccent)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.99, green: 0.97, blue: 0.93))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isSelected ? Theme.goldAccent : Theme.tileBorder.opacity(0.35),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: Theme.inkBrown.opacity(isSelected ? 0.28 : 0.14),
            radius: isSelected ? 18 : 8,
            x: 0,
            y: isSelected ? 8 : 4
        )
    }

    // MARK: Private

    @ViewBuilder
    private var imageArea: some View {
        Group {
            if let uiImage = UIImage(named: card.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Placeholder shown when image asset is not yet added
                ZStack {
                    Theme.inkBrown.opacity(0.08)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.tileBorder.opacity(0.45))
                        Text(card.title)
                            .font(Theme.serif(.caption))
                            .foregroundStyle(Theme.tileBorder.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipped()
        .clipShape(
            .rect(
                topLeadingRadius: 14,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 14
            )
        )
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        PuzzleCardView(card: PuzzleCard.all[0])
            .frame(width: 180)
        PuzzleCardView(card: PuzzleCard.all[0], isSelected: true)
            .frame(width: 180)
    }
    .padding(24)
    .background(Theme.parchment)
}
