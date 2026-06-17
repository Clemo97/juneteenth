import Foundation
import FoundationModels

// MARK: - HistorianModel

/// Drives the AI Historical Narrator feature.
///
/// Uses Apple's on-device Foundation Models (iOS 26 + Apple Intelligence) to
/// stream a rich historical narrative about the completed puzzle's subject.
/// Falls back gracefully — showing the card's static `historicalNote` — on
/// any device or OS version that doesn't support the model.
@MainActor
final class HistorianModel: ObservableObject {

    // MARK: - State

    enum GenerationState: Equatable {
        /// Not yet started.
        case idle
        /// Model is producing tokens; `narrative` grows with each update.
        case generating
        /// Stream finished; `narrative` holds the complete text.
        case done
        /// Device / OS doesn't support Apple Intelligence.
        case unavailable
        /// Generation threw an error; caller should show the static note.
        case failed
    }

    @Published private(set) var narrative: String = ""
    @Published private(set) var state: GenerationState = .idle

    // MARK: - Public Interface

    /// Begin streaming a narrative for `card`. No-op if already generating.
    func generate(for card: PuzzleCard) {
        guard state == .idle else { return }

        if #available(iOS 26.0, *) {
            startGeneration(for: card)
        } else {
            state = .unavailable
        }
    }

    /// Reset so the same instance can be used for a new card.
    func reset() {
        narrative = ""
        state = .idle
    }

    // MARK: - Foundation Models (iOS 26+)

    @available(iOS 26.0, *)
    private func startGeneration(for card: PuzzleCard) {
        guard SystemLanguageModel.default.isAvailable else {
            state = .unavailable
            return
        }

        state = .generating

        Task {
            let session = LanguageModelSession(
                instructions: """
                    You are a passionate historian specialising in African American \
                    history and the Juneteenth celebration. Write rich, evocative, \
                    factually accurate prose for a general audience. Be warm, inspiring, \
                    and deeply human. Plain paragraphs only — no headers, no lists.
                    """
            )

            let prompt = """
                Write a 2–3 paragraph narrative about \(card.title), \
                \(card.subtitle) (\(card.yearContext)).
                Build on this seed: "\(card.historicalNote)"
                Expand on their significance to the road to freedom and the enduring \
                spirit of Juneteenth. Keep the response under 130 words.
                """

            do {
                let stream = session.streamResponse(to: prompt)
                for try await snapshot in stream {
                    narrative = snapshot.content
                }
                state = .done
            } catch {
                state = .failed
            }
        }
    }
}
