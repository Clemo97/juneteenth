import SwiftUI

// MARK: - CardSelectionView

/// Root screen of the app.
/// Shows the app title and a swipeable carousel of puzzle cards in the
/// Art of Fauna style, with a difficulty picker and a "Begin Puzzle" button.
struct CardSelectionView: View {

    @State private var selectedIndex:     Int      = 0
    @State private var selectedDifficulty: GridSize = .easy

    private let cards = PuzzleCard.all

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.parchment.ignoresSafeArea()

                VStack(spacing: 0) {
                    titleBlock
                    cardCarousel
                    pageIndicator
                    Spacer(minLength: 16)
                    difficultyPicker
                    beginButton
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(spacing: 4) {
            Text("JUNETEENTH")
                .font(.system(.largeTitle, design: .serif).bold())
                .tracking(5)
                .foregroundStyle(Theme.inkBrown)

            Text("A Puzzle of Freedom")
                .font(.system(.subheadline, design: .serif).italic())
                .foregroundStyle(Theme.tileBorder)
        }
        .padding(.top, 48)
        .padding(.bottom, 28)
    }

    // MARK: - Card carousel (TabView page-style)

    private var cardCarousel: some View {
        TabView(selection: $selectedIndex) {
            ForEach(cards.indices, id: \.self) { idx in
                PuzzleCardView(
                    card: cards[idx],
                    isSelected: selectedIndex == idx
                )
                .padding(.horizontal, 36)
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 370)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedIndex)
    }

    // MARK: - Dot page indicator

    private var pageIndicator: some View {
        HStack(spacing: 7) {
            ForEach(cards.indices, id: \.self) { idx in
                Capsule()
                    .fill(selectedIndex == idx
                          ? Theme.inkBrown
                          : Theme.tileBorder.opacity(0.35))
                    .frame(width: selectedIndex == idx ? 18 : 7, height: 7)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7),
                               value: selectedIndex)
            }
        }
        .padding(.top, 14)
    }

    // MARK: - Difficulty picker

    private var difficultyPicker: some View {
        VStack(spacing: 10) {
            Text("DIFFICULTY")
                .font(.system(.caption2, design: .serif))
                .tracking(3)
                .foregroundStyle(Theme.tileBorder)

            HStack(spacing: 10) {
                ForEach(GridSize.allCases) { size in
                    DifficultyChip(
                        size: size,
                        isSelected: selectedDifficulty == size
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedDifficulty = size
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }

    // MARK: - Begin Puzzle button

    private var beginButton: some View {
        NavigationLink(
            destination: PuzzleView(
                card: cards[selectedIndex],
                difficulty: selectedDifficulty
            )
        ) {
            Text("Begin Puzzle")
                .font(.system(.title3, design: .serif).bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.juneteenthRed)
                        .shadow(color: Theme.juneteenthRed.opacity(0.4),
                                radius: 8, x: 0, y: 4)
                )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 44)
    }
}

// MARK: - DifficultyChip

private struct DifficultyChip: View {

    let size: GridSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.label)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(isSelected ? .white : Theme.inkBrown)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Theme.inkBrown : Color.white.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Theme.tileBorder.opacity(0.35), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Preview

#Preview {
    CardSelectionView()
}
